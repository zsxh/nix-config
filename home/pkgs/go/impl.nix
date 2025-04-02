{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "impl";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "josharian";
    repo = "impl";
    tag = "v${finalAttrs.version}";
    sha256 = "sha256-0TSyg7YEPur+h0tkDxI3twr2PzT7tmo3shKgmSSJ6qk=";
  };

  vendorHash = null;
  doCheck = false;

  # 防止 inconsistent vendoring
  preBuild = ''
    export GOPROXY=https://goproxy.cn,direct
  '';
  proxyVendor = true; # 允许下载
  # allowGoReference = true;  # Enable references to the Go toolchain, 防止找不到 $GOROOT

  meta = {
    description = "Go tool to generates method stubs for implementing an interface";
    mainProgram = "impl";
    homepage = "https://github.com/josharian/impl";
    license = lib.licenses.mit;
  };
})
