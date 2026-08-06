{
  config,
  agenix,
  mysecrets,
  ...
}:
{
  imports = [
    agenix.homeManagerModules.default
  ];

  # age recipient keys 用来解密所有的加密文件
  # 如果更改了此密钥，需要从解密内容重新生成所有加密文件
  age.identityPaths = [
    # 使用用户密钥进行解密, 用 `ssh-keygen -t ed25519 -a 256 -C "<COMMNET>"` 来生成
    "${config.home.homeDirectory}/.ssh/id_ed25519"
  ];

  age.secrets = {
    "secrets-env" = {
      file = "${mysecrets}/secrets.env.age";
    };
  };

  # 由 programs.fish.shellInit 加载 环境变量，防止 shell 启动的时候文件还未创建
  # home.sessionVariables = {
  # };

}
