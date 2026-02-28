#! /usr/bin/env nu

use utils.nu

# ============================================
# VM Creation Functions
# ============================================

export def virt-docker [vm_name: string = "docker"]: nothing -> nothing {
    slog $"Creating Docker VM: ($vm_name)"
    sleep 1sec
    vm-create --distro debian --name $vm_name --docker
}

export def virt-incus [vm_name: string = "incus"]: nothing -> nothing {
    slog $"Creating Incus VM: ($vm_name)"
    sleep 1sec
    vm-create --distro debian --name $vm_name --dotfiles incus
}

export def virt-nix [vm_name: string = "nix"]: nothing -> nothing {
    slog $"Creating Debian VM: ($vm_name)"
    sleep 1sec
    vm-create --distro debian --name $vm_name --nix
}

export def virt-dev [vm_name: string = "dev"]: nothing -> nothing {
    slog $"Creating Dev VM: ($vm_name)"
    sleep 1sec
    vm-create --distro debian --name $vm_name --docker --brew
}

export def virt-ilm [vm_name: string = "ilm"]: nothing -> nothing {
    slog $"Creating ilm VM: ($vm_name)"
    sleep 1sec
    vm-create --distro debian --name $vm_name --dotfiles min
}

# ============================================
# VM Execution Functions
# ============================================

export def virt-exec [username: string, vm_name: string, extra_arg: string]: nothing -> nothing {
    let url = ($env.ILM_SETUP_URL? | default "https://raw.githubusercontent.com/pervezfunctor/dotfiles/main/share/installers/setup")
    ssh $"($username)@($vm_name)" $"bash -c \"\$\(curl -sSL ($url)\)\" -- ($extra_arg)"
}
