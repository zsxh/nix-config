{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule {
  pname = "reftools";
  version = "0.0.0-20240211192525-f5f96ef18854";

  src = fetchFromGitHub {
    owner = "davidrjenni";
    repo = "reftools";
    rev = "34b10582faa4220d684a595b3e1237f244707e23";
    sha256 = "sha256-nxnJzbFViU8O+Yw1+7GhsrhBiQC7WhsK3rcwMAZDTmM=";
    # sha256 = lib.fakeSha256;
  };

  vendorHash = null;
  doCheck = false;
  subPackages = [
    "cmd/fillstruct"
    # "cmd/fillswitch"
    # "cmd/fixplurals"
  ];

  meta = {
    description = "Go tool to fills a struct literal with default values";
    homepage = "https://github.com/davidrjenni/reftools";
    license = lib.licenses.bsd2;
  };
}
