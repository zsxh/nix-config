self: super: {
  tdlib = super.tdlib.overrideAttrs (oldAttrs: {
    version = "1.8.60";
    src = super.fetchFromGitHub {
      owner = "tdlib";
      repo = "td";
      rev = "0da5c72f8365fb4857096e716d53175ddbdf5a15";
      hash = "sha256-0bVBz0Wi7kfbU8w4jA/7qyYE1K1oV2UZTnSfdHGFiIo=";
    };
  });
}
