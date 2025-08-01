{ pkgs, ... }:
{
  virtualisation = {
    libvirtd = {
      enable = true;

      # Allow non-root users in the libvirtd group to manage VMs
      onBoot = "ignore";
      onShutdown = "shutdown";
      # graphicsListenTcp = false;
      # tls = false;

      # Enable listening (optional, for remote access)
      # Uncomment only if you need TCP access (secure with TLS)
      # unixSocketGroup = "libvirtd";
      # unixSocketRoGroup = "libvirtd";
      # unixSocketRwGroup = "libvirtd";
      # tcpListen = true;
      # listenTcp = true;
      # extraConfig = ''
      #   listen_tls = 0
      #   listen_tcp = 1
      #   auth_tcp = "none"
      # '';

      qemu = {
        # nested = 1;
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

          # verbatimConfig = ''
          #   nvram = [ "${pkgs.OVMFFull}/FV/OVMF.fd:${pkgs.OVMFFull}/FV/OVMF_VARS.fd" ]
          #   gl = true
          #   egl = true
          # '';
        };
      };
    };
    spiceUSBRedirection.enable = true; # USB redirection
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
    cdrkit

    # nftables
    # ebtables
    spice-gtk
    spice-protocol
    virtiofsd # VirtioFS daemon for file sharing
    win-virtio # VirtIO drivers for Windows guests
    win-spice # SPICE drivers for Windows guests
    usbutils # For lsusb, useful for USB passthrough
    gtk-vnc
    usbredir
    dmidecode
    seabios
  ];

  services.udev.extraRules = ''
    # Allow user session to access libvirt
    SUBSYSTEM=="virtio", GROUP="libvirtd", MODE="0660"
  '';

  systemd.services."libvirt-default-network" = {
    description = "Start libvirt default network";
    requires = [ "libvirtd.service" ];
    after = [ "libvirtd.service" ];
    script = ''
      sleep 5
      if ! virsh net-info default >/dev/null 2>&1; then
        echo "Defining default network..."
        virsh net-define /nix/store/*/etc/libvirt/qemu/networks/default.xml
      fi
      if ! virsh net-autostart default; then
        virsh net-autostart default
      fi
      if ! virsh net-start default; then
        virsh net-start default
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  services.udev.packages = [
    pkgs.spice-gtk
    pkgs.usbredir
  ];
  systemd.services.virtlogd.enable = true;

  security.pam.loginLimits = [
    {
      domain = "@libvirtd";
      type = "soft";
      item = "nofile";
      value = "65536";
    }
  ];

  # Optional: for bridged networking
  # bridgeDevices = [ "br0" ];
  # interfaces.enp3s0.useDHCP = false;
  # interfaces.br0 = {
  #   useDHCP = true;
  #   bridge = {
  #     interfaces = [ "enp3s0" ];
  #   };
  # };

  # security.policies.libvirtd = {
  #   "org.libvirt.unix.manage" = {
  #     identity = "unix-group:libvirtd";
  #     action = "org.libvirt.unix.manage";
  #     resultAny = "yes";
  #   };
  # };
  # networking.firewall.extraRules = ''
  #   # Allow libvirt network (default NAT)
  #   -A INPUT -s 192.168.122.0/24 -d 224.0.0.0/24 -j ACCEPT
  #   -A INPUT -s 192.168.122.0/24 -j ACCEPT
  #   -A INPUT -i virbr0 -j ACCEPT
  #   -A FORWARD -i virbr0 -o virbr0 -j ACCEPT
  #   -A FORWARD -i virbr0 -o ${config.networking.primaryIPAddress} -j ACCEPT
  #   -A FORWARD -i ${config.networking.primaryIPAddress} -o virbr0 -j ACCEPT
  # '';
  # Configure firewall to allow SPICE ports (optional, adjust as needed)
  # networking.firewall.enable = true;
  # networking.firewall.extraRules = ''
  #   # libvirt default network
  #   -A INPUT -i virbr0 -j ACCEPT
  #   -A FORWARD -i virbr0 -j ACCEPT
  #   -A FORWARD -o virbr0 -j ACCEPT
  # '';

}
