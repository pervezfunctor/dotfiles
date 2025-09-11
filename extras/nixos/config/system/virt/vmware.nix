{ ... }:

{
  virtualisation.vmware.host.enable = true;
  virtualisation.vmware.host.extraConfig = "
  # Allow unsupported device's OpenGL and Vulkan acceleration for guest vGPU
  mks.gl.allowUnsupportedDrivers = \"TRUE\"\n
  mks.vk.allowUnsupportedDevices = \"TRUE\"\n";

}
