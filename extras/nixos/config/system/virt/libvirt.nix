{ pkgs, ... }:
{
  environment.sessionVariables = {
    LIBVIRT_DEFAULT_URI = "qemu:///system";
  };

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
    dmidecode
    dnsmasq
    gtk-vnc
    guestfs-tools
    parted
    libosinfo
    openssl
    qemu
    qemu_kvm
    qemu-utils
    seabios
    spice-gtk
    spice-protocol
    usbredir
    usbutils
    virtiofsd
    win-spice
    win-virtio
    xorriso
  ];

  services.udev.packages = [
    pkgs.spice-gtk
    pkgs.usbredir
  ];
}
