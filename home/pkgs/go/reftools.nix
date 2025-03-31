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
    rev = "f5f96ef1885420cd327f39d1d90d8bedd7c7e918";
    sha256 = "sha256-ZTtV2GwyUTa2HSwwPtD/hVxtLGotVDUT3Ig/XrfBJnY=";
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
