{ username, ... }:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${username}" = {
    home = "/Users/${username}";
    description = username;

    # TODO: https://nixos.wiki/wiki/SSH_public_key_authentication
    # openssh.authorizedKeys.keys = [];
  };
}
