{ pkgs, ... }:
{
  services.snapper = {
    enable = true;
    snapshotRootOnBoot = true;

    configs = {
      root = {
        SUBVOLUME = "/";

        ALLOW_USERS = [ "root" ];
        ALLOW_GROUPS = [ "wheel" ];

        TIMELINE_CREATE = true;
        TIMELINE_CLEANUP = true;

        TIMELINE_MIN_AGE = "1800";
        TIMELINE_LIMIT_HOURLY = "10";
        TIMELINE_LIMIT_DAILY = "10";
        TIMELINE_LIMIT_WEEKLY = "0";
        TIMELINE_LIMIT_MONTHLY = "0";
        TIMELINE_LIMIT_YEARLY = "0";

        NUMBER_CLEANUP = true;
        NUMBER_MIN_AGE = "1800";
        NUMBER_LIMIT = "50";
        NUMBER_LIMIT_IMPORTANT = "10";

        EMPTY_PRE_POST_CLEANUP = true;
        EMPTY_PRE_POST_MIN_AGE = "1800";

        SPACE_LIMIT = "0.5";
        FREE_LIMIT = "0.2";
      };
    };

  };

  environment.systemPackages = with pkgs; [
    snapper
    snapper-gui
  ];

  systemd.timers.snapper-cleanup = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };

  systemd.services.snapper-cleanup = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.snapper}/bin/snapper cleanup timeline";
    };
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  services.btrfs.autoBalance = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };
}
