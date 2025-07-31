{ pkgs, ... }:
{
  environment.sessionVariables = {
    # Force Electron to use Wayland + fix fractional scaling
    NIXOS_OZONE_WL = "1";
    ELECTRON_ENABLE_SCALE_FACTOR = "true";
    # GDK_SCALE = "";
    # GDK_DPI_SCALE = "";
  };

  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji

      font-awesome
    ];

    fontconfig = {
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        serif = [ "Noto Serif" ];
        sansSerif = [ "Noto Sans" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  environment.systemPackages = with pkgs; [
    uv
    mise
    volta
    vscode
    ghostty
    ptyxis
  ];
}
