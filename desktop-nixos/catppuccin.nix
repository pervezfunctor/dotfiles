{ inputs, ... }:
{
  modules = [
    inputs.catppuccin.nixosModules.catppuccin
  ];

  catppuccin = {
    enable = true;
    flavor = "frappe";
    accent = "teal";
  };
}
