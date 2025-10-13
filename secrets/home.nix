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
    "github-api-key" = {
      file = "${mysecrets}/secrets/api/github.age";
    };
    "context7-api-key" = {
      file = "${mysecrets}/secrets/api/context7.age";
    };
    "exa-api-key" = {
      file = "${mysecrets}/secrets/api/exa.age";
    };
    "metaso-api-key" = {
      file = "${mysecrets}/secrets/api/metaso.age";
    };
    "tavily-api-key" = {
      file = "${mysecrets}/secrets/api/tavily.age";
    };
  };

  home.sessionVariables = {
    GITHUB_API_TOKEN = "$(cat ${config.age.secrets.github-api-key.path})";
    CONTEXT7_API_KEY = "$(cat ${config.age.secrets.context7-api-key.path})";
    EXA_API_KEY = "$(cat ${config.age.secrets.exa-api-key.path})";
    METASO_API_KEY = "$(cat ${config.age.secrets.metaso-api-key.path})";
    TAVILY_API_KEY = "$(cat ${config.age.secrets.tavily-api-key.path})";
  };

}
