self: super: {
  tdlib = super.tdlib.overrideAttrs (oldAttrs: {
    version = "1.8.64";
    src = super.fetchFromGitHub {
      owner = "tdlib";
      repo = "td";
      rev = "e0943d068ce90b5010f1aea946e6901e25b43bf6";
      hash = "sha256-H6R959XVkMB9OVAynRvBYB53hzUPKY0Us+HkbiuPZN0=";
    };
  });
}
