{
  lib,
  pkgs,
  username,
  ...
}:
{
  programs.fish.enable = true;

  # NOTE: [users.users.<name>.shell does not update the user's shell](https://github.com/LnL7/nix-darwin/issues/1237)
  users.knownUsers = lib.mkIf (pkgs.stdenv.isDarwin) [ "${username}" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;

    # NOTE: [users.users.<name>.shell does not update the user's shell](https://github.com/LnL7/nix-darwin/issues/1237)
    # NOTE: Get user id via `dscl . -read /Users/{username} UniqueID`
    uid = lib.mkIf (pkgs.stdenv.isDarwin) 501;

    shell = pkgs.fish;

    # TODO: https://nixos.wiki/wiki/SSH_public_key_authentication
    # openssh.authorizedKeys.keys = [];
  };
}
