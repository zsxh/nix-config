{
  pkgs,
  agenix,
  mysecrets,
  ...
}:
{
  imports = [
    agenix.darwinModules.default
  ];

  environment.systemPackages = [
    agenix.packages."${pkgs.system}".default
  ];

  # age recipient keys 用来解密所有的加密文件
  # 如果更改了此密钥，需要从解密内容重新生成所有加密文件
  age.identityPaths = [
    # 使用主机密钥进行解密, 用 `sudo ssh-keygen -A` 来生成
    "/etc/ssh/ssh_host_ed25519_key"
  ];

  age.secrets = { };
}
