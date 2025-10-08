{ pkgs, ... }:
{
  home.packages = with pkgs; [
    claude-code
    codex
    copilot-cli
    crush
    gemini-cli
    qwen-code
  ];
}
