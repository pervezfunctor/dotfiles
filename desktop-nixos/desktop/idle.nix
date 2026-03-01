{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.idleLock;

  lockscreen = pkgs.writeShellScriptBin "lockscreen" ''
    set -eou pipefail

    if command -v dms >/dev/null && pgrep -u "$UID" -f dms >/dev/null; then
      exec dms ipc call lock lock
    fi

    if command -v noctalia-shell >/dev/null && pgrep -u "$UID" -f noctalia-shell >/dev/null; then
      exec noctalia-shell ipc call lockScreen lock
    fi

    if command -v swaylock >/dev/null; then
      exec swaylock -f
    fi
  '';

  compositorDpms = pkgs.writeShellScriptBin "compositor-dpms" ''
    set -eu
    mode="$1"

    if command -v hyprctl >/dev/null && pgrep -x Hyprland >/dev/null; then
      exec hyprctl dispatch dpms "$mode"
    fi

    if command -v swaymsg >/dev/null && pgrep -x sway >/dev/null; then
      exec swaymsg "output * power $mode"
    fi

    exit 0
  '';

  suspendIfIdle = pkgs.writeShellScriptBin "suspend-if-idle" ''
    set -eu

    if command -v wpctl >/dev/null; then
      if wpctl status | grep -q "RUNNING"; then
        exit 0
      fi
    fi

    exec systemctl suspend
  '';
in
{
  options.services.idleLock = {
    enable = lib.mkEnableOption "Wayland idle lock, DPMS, and smart suspend";

    lockTimeout = lib.mkOption {
      type = lib.types.int;
      default = 240;
    };

    montir = lib.mkOption {
      type = lib.types.int;
      default = 300;
    };

    suspendTimeout = lib.mkOption {
      type = lib.types.int;
      default = 600;
    };
  };

  config = lib.mkIf cfg.enable {

    home.packages = [
      lockscreen
      compositorDpms
      suspendIfIdle
      pkgs.swayidle
      pkgs.hypridle
      pkgs.wireplumber
    ];

    systemd.user.services.idle-lock = {
      Unit = {
        Description = "Wayland idle lock + DPMS + smart suspend";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.swayidle}/bin/swayidle -w \
            timeout ${toString cfg.lockTimeout} lockscreen \
            timeout ${toString cfg.montir} 'compositor-dpms off' \
            resume        'compositor-dpms on' \
            before-sleep lockscreen \
            timeout ${toString cfg.suspendTimeout} suspend-if-idle";

        Restart = "always";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
