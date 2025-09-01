# cloud-init-config.nix
{ pkgs, ... }:
{
  imports = [ ./configuration.nix ];

  settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # System packages
  environment.systemPackages = with pkgs; [
    htop
    btop
    tree
    wget
    curl
    git
    vim
    nano
    tmux

    # Network tools
    nmap
    tcpdump
    nettools
    iperf3

    # Development tools
    gcc
    docker-compose

    # Monitoring
    prometheus-node-exporter

    # File management
    rsync
    unzip
    zip

    # System info
    neofetch
    lshw
    pciutils
    usbutils
  ];

  # Cloud-init specific settings
  services.cloud-init = {
    enable = true;
    network.enable = true;
  };

  # Create a regular user with sudo access
  users.users.nixos = {
    isNormalUser = true;
    description = "NixOS User";
    extraGroups = [
      "wheel" # sudo access
      "networkmanager"
      "docker" # if you plan to use docker
    ];

    # Set initial password (change this or use cloud-init to override)
    initialPassword = "changeme123";

    # SSH keys (these can also be set via cloud-init)
    openssh.authorizedKeys.keys = [
      # Add your SSH public keys here
      # "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ... your-key@hostname"
      # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... another-key@hostname"
    ];
  };

  # Configure sudo access for wheel group
  security.sudo = {
    enable = true;
    wheelNeedsPassword = true; # Set to false for passwordless sudo
  };

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true; # Allow password auth initially
      PubkeyAuthentication = true; # Enable SSH key auth
      PermitRootLogin = "prohibit-password"; # Only allow root with keys
      X11Forwarding = false;
      AllowUsers = [
        "nixos"
        "root"
      ]; # Restrict SSH access
    };
    # Custom SSH port (optional)
    # ports = [ 22 2222 ];
  };

  # Network configuration
  networking = {
    useDHCP = true;
    interfaces.ens18.useDHCP = true; # Common Proxmox interface

    # Firewall configuration
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22 # SSH
        # 80    # HTTP
        # 443   # HTTPS
        # 3000  # Custom app port
      ];
      # allowedUDPPorts = [ ];
    };

    # Set hostname (can be overridden by cloud-init)
    hostName = "nixos-proxmox";
  };

  # Docker support (optional)
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Enable additional services
  services = {
    # QEMU guest agent for Proxmox integration
    qemuGuest.enable = true;

    # Node exporter for monitoring (optional)
    prometheus.exporters.node = {
      enable = true;
      openFirewall = false; # Set to true if you want external access
      port = 9100;
    };

    # Enable automatic updates (optional)
    # nixos-auto-upgrade = {
    #   enable = true;
    #   allowReboot = false;
    # };
  };

  # Timezone and locale
  time.timeZone = "UTC"; # Change to your timezone
  i18n.defaultLocale = "en_US.UTF-8";

  # Console configuration
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us"; # Change to your keyboard layout
  };

  # Ensure cloud-init can resize root partition
  boot.growPartition = true;
  boot.loader.grub.device = "/dev/vda";

  # Enable serial console for Proxmox
  boot.kernelParams = [
    "console=ttyS0,115200"
    "console=tty1"
  ];
  systemd.services."serial-getty@ttyS0".enable = true;

  # Memory and performance tuning for VMs
  boot.kernel.sysctl = {
    "vm.swappiness" = 10;
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # Remove initial user setup since cloud-init will handle it
  users.users.root.initialPassword = null;

  # users.users.nixos.openssh.authorizedKeys.keys = [
  #   # Replace with your actual SSH public keys
  #   "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7... admin@workstation"
  #   "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGq... backup@server"
  # ];

  # users.users.root.openssh.authorizedKeys.keys = [
  #   # Same keys for root access if needed
  #   "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7... admin@workstation"
  # ];

  # Cloud-init user data example (this shows what you can override)
  # You can create this file and use it when creating VMs from the template
  /*
    Example cloud-init user-data.yml:

    #cloud-config
    users:
      - name: nixos
        groups: wheel
        sudo: ALL=(ALL) NOPASSWD:ALL
        ssh_authorized_keys:
          - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQ...
        shell: /run/current-system/sw/bin/bash

    hostname: my-nixos-vm

    packages:
      - curl
      - wget

    runcmd:
      - systemctl restart sshd
  */
}
