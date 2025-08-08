{ pkgs, ... }:
{
  # Add your user to the libvirtd group for password-less access
  users.users.me.extraGroups = [ "libvirtd" ];

  virtualisation = {
    libvirtd = {
      enable = true;
      # defaultNetwork.enable = true;

      # Grant the 'libvirtd' group access to the libvirt socket
      extraConfig = ''
        unix_sock_group = "libvirtd"
        unix_sock_rw_perms = "0770"
        auth_unix_ro = "none"
        auth_unix_rw = "none"
      '';

      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
        vhostUserPackages = with pkgs; [ virtiofsd ];
        ovmf = {
          enable = true;
          packages = [
            (pkgs.OVMF.override {
              secureBoot = true;
              tpmSupport = true;
            }).fd
          ];
        };
      };
    };
    spiceUSBRedirection.enable = true;
  };

  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    qemu
    qemu_kvm
    qemu-utils
    dnsmasq
    openssl
    xorriso
    spice-gtk
    spice-protocol
    virtiofsd
    win-virtio
    win-spice
    usbutils
    gtk-vnc
    usbredir
    dmidecode
    seabios
  ];

  services.udev.packages = [
    pkgs.spice-gtk
    pkgs.usbredir
  ];
}
