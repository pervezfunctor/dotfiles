#! /usr/bin/env nu

export def managed-commands [] {
    ["vm" "vm-create" "ivm" "ivm-create" "ict" "ict-create"]
}

export def vm-commands [] {
    ["install" "list" "status" "create" "autostart" "start" "stop" "restart" "destroy" "delete" "console" "ip" "logs" "cleanup" "ssh"]
}

export def vm-create-distros [] {
    ["ubuntu" "fedora" "arch" "debian"]
}

export def incus-distros [] {
    ["ubuntu" "fedora" "arch" "debian" "centos" "alpine"]
}

export def completion-metadata [] {
    {
        commands: (managed-commands)
        vm_commands: (vm-commands)
        vm_create_distros: (vm-create-distros)
        incus_distros: (incus-distros)
        shell_completion_dir: ($env.DOT_DIR | path join "share" "completions")
    }
}

export def main [] {
    completion-metadata
}