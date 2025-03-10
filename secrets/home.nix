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
    "github-api-token" = {
      file = "${mysecrets}/github-api-token.age";
    };
  };

  home.sessionVariables = {
    GITHUB_API_TOKEN = "$(cat ${config.age.secrets.github-api-token.path})";
  };
}
