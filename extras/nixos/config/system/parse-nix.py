#!/usr/bin/env python3
import sys, argparse, re
from tree_sitter import Language, Parser

# Load nix grammar
NIX_LANGUAGE = Language("build/my-languages.so", "nix")
parser = Parser()
parser.set_language(NIX_LANGUAGE)


def parse_file(path):
    with open(path, "rb") as f:
        code = f.read()
    tree = parser.parse(code)
    return code, tree


def split_path(path):
    """Split .foo.bar[0] into tokens ["foo", "bar", 0]"""
    tokens = []
    for part in path.strip(".").split("."):
        m = re.findall(r"([a-zA-Z0-9_-]+)|\[(\d+)\]", part)
        for name, idx in m:
            if name:
                tokens.append(name)
            elif idx:
                tokens.append(int(idx))
    return tokens


def find_attr_binding(node, src, name):
    """Return full binding node if found"""
    for c in node.children:
        if c.type == "binding":
            key = c.child_by_field_name("name")
            if key and src[key.start_byte:key.end_byte].decode() == name:
                return c
    return None


def find_attr_value(node, src, name):
    """Return value node inside attrset"""
    b = find_attr_binding(node, src, name)
    if b:
        return b.child_by_field_name("value")
    return None


def resolve_path(node, src, tokens):
    """Walk path into the AST"""
    cur = node
    parent = None
    key = None
    for t in tokens:
        if isinstance(t, str):  # attr
            parent = cur
            key = t
            cur = find_attr_value(cur, src, t)
            if cur is None:
                return None, parent, key
        elif isinstance(t, int):  # array index
            if cur.type != "list_expression":
                return None, parent, t
            elems = [c for c in cur.children if c.type not in {"[", "]"}]
            parent = cur
            key = t
            if t >= len(elems):
                return None, parent, key
            cur = elems[t]
    return cur, parent, key


def get(path, expr):
    code, tree = parse_file(path)
    tokens = split_path(expr)
    val, _, _ = resolve_path(tree.root_node, code, tokens)
    if not val:
        sys.exit(f"Path {expr} not found")
    print(code[val.start_byte:val.end_byte].decode())


def setval(path, expr, newval):
    code, tree = parse_file(path)
    tokens = split_path(expr)

    val, _, _ = resolve_path(tree.root_node, code, tokens)
    if not val:
        sys.exit(f"Path {expr} not found (creation not shown in delete version)")

    if not (newval.startswith('"') or newval in ["true", "false"] or newval.isdigit()):
        newval = f"\"{newval}\""

    new_code = code[:val.start_byte] + newval.encode() + code[val.end_byte:]
    with open(path, "wb") as f:
        f.write(new_code)


def delete(path, expr):
    code, tree = parse_file(path)
    tokens = split_path(expr)
    node, parent, key = resolve_path(tree.root_node, code, tokens)
    if not node:
        sys.exit(f"Path {expr} not found")

    if isinstance(key, str):  # deleting attr binding
        b = find_attr_binding(parent, code, key)
        if not b:
            sys.exit("Could not resolve binding for deletion")
        start, end = b.start_byte, b.end_byte
    elif isinstance(key, int):  # deleting array element
        elems = [c for c in parent.children if c.type not in {"[", "]"}]
        target = elems[key]
        start, end = target.start_byte, target.end_byte
    else:
        sys.exit("Invalid delete target")

    new_code = code[:start] + code[end:]
    with open(path, "wb") as f:
        f.write(new_code)


def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="cmd")

    g = sub.add_parser("get")
    g.add_argument("file")
    g.add_argument("expr")

    s = sub.add_parser("set")
    s.add_argument("file")
    s.add_argument("expr")
    s.add_argument("value")

    d = sub.add_parser("del")
    d.add_argument("file")
    d.add_argument("expr")

    args = p.parse_args()
    if args.cmd == "get":
        get(args.file, args.expr)
    elif args.cmd == "set":
        setval(args.file, args.expr, args.value)
    elif args.cmd == "del":
        delete(args.file, args.expr)
    else:
        p.print_help()


if __name__ == "__main__":
    main()
