# `source` targets must exist while config.nu is parsed. Nushell runs env.nu
# first, so generate Carapace's integration here to make a cleared cache safe.
mkdir ~/.cache/carapace
carapace _carapace nushell | save --force ~/.cache/carapace/init.nu
