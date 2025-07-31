{ pkgs, config, ... }:
{
  # virtualisation.docker.enable = true;

  # hardware = {
  #   # cpu.intel.updateMicrocode = config.hardware.cpu.amd.fallbackMicrocode != null;
  #   opengl = {
  #     enable = true;
  #     driSupport = true;
  #     driSupport32Bit = true;
  #   };
  # };

  virtualisation = {
    # qemu = {
    #   enable = true;
    #   nestedVirtualization = true;
    # };

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
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
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
    spiceUSBRedirection.enable = true; # USB redirection

    # kvmgt.enable = false;

    # incus.preseed = {
    #   networks = [{
    #     config = {
    #       "ipv4.address" = "10.0.100.1/24";
    #       "ipv4.nat" = "true";
    #     };
    #     name = "incusbr0";
    #     type = "bridge";
    #   }];
    #   profiles = [{
    #     devices = {
    #       eth0 = {
    #         name = "eth0";
    #         network = "incusbr0";
    #         type = "nic";
    #       };
    #       root = {
    #         path = "/";
    #         pool = "default";
    #         size = "35GiB";
    #         type = "disk";
    #       };
    #     };
    #     name = "default";
    #   }];
    #   storage_pools = [{
    #     config = { source = "/var/lib/incus/storage-pools/default"; };
    #     driver = "dir";
    #     name = "default";
    #   }];

    # incus.enable = true;
  };
  programs.virt-manager.enable = true;

  users.users.me.extraGroups = [
    "kvm"
    "libvirtd"
    "incus"
    "incus-admin"
    "docker"
  ];

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    qemu
    qemu_kvm
    qemu-utils
    dnsmasq

    # nftables
    # ebtables
    # spice-gtk
    # spice-protocol
    # virtiofsd # VirtioFS daemon for file sharing
    # win-virtio # VirtIO drivers for Windows guests
    # win-spice # SPICE drivers for Windows guests
    # usbutils # For lsusb, useful for USB passthrough
    # gtk-vnc
    # usbredir
    # dmidecode
    # seabios
    # docker-compose
    openssl
    xorriso
    cdrkit
  ];

  # Enable IP forwarding for NAT networking
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  networking.nftables.enable = true;
  # networking.firewall.trustedInterfaces = [ "incusbr0" ];
  # networking.firewall.interfaces.incusbr0.allowedTCPPorts = [
  #   53
  #   67
  # ];
  # networking.firewall.interfaces.incusbr0.allowedUDPPorts = [
  #   53
  #   67
  # ];

  # Configure firewall to allow SPICE ports (optional, adjust as needed)
  # networking.firewall.enable = true;
  # networking.firewall.extraRules = ''
  #   # libvirt default network
  #   -A INPUT -i virbr0 -j ACCEPT
  #   -A FORWARD -i virbr0 -j ACCEPT
  #   -A FORWARD -o virbr0 -j ACCEPT
  # '';

  networking.firewall.allowedTCPPorts = [ 5900 ]; # SPICE default port

  # networking.firewall.extraRules = ''
  #   # Allow libvirt network (default NAT)
  #   -A INPUT -s 192.168.122.0/24 -d 224.0.0.0/24 -j ACCEPT
  #   -A INPUT -s 192.168.122.0/24 -j ACCEPT
  #   -A INPUT -i virbr0 -j ACCEPT
  #   -A FORWARD -i virbr0 -o virbr0 -j ACCEPT
  #   -A FORWARD -i virbr0 -o ${config.networking.primaryIPAddress} -j ACCEPT
  #   -A FORWARD -i ${config.networking.primaryIPAddress} -o virbr0 -j ACCEPT
  # '';

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
}
