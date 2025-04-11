{
  pkgs,
  lib,
  username,
  ...
}:
{
  imports = [
    ./nix-core.nix
    ./system.nix
    ./programs.nix
    ./users.nix
  ];
}
