self: super: {
  mps = super.mps.overrideAttrs (oldAttrs: {
    # 更新meta信息添加darwin支持
    meta = oldAttrs.meta // {
      platforms = oldAttrs.meta.platforms ++ super.lib.platforms.darwin;
    };

    # 根据平台动态调整构建参数
    nativeBuildInputs = if super.stdenv.isDarwin then [ super.xcbuildHook ] else oldAttrs.nativeBuildInputs;

    sourceRoot = super.lib.optionalString super.stdenv.isDarwin "${oldAttrs.src.name}/code";

    xcbuildFlags = super.lib.optionals super.stdenv.isDarwin [
      "-configuration"
      "Release"
      "-project"
      "mps.xcodeproj"
      "OTHER_CFLAGS='-Wno-error=unused-but-set-variable'"
    ];

    installPhase = if super.stdenv.isDarwin then ''
      mkdir -p $out/lib
      cp "$TMPDIR/source/code/Products/Release/libmps.a" $out/lib/

      mkdir -p $out/include
      cp mps*.h $out/include/
    '' else oldAttrs.installPhase;

    # 保持Linux平台的原始补丁
    postPatch = super.lib.optionalString super.stdenv.isLinux ''
      substituteInPlace code/gc.gmk --replace-fail '-Werror ' ' '
      substituteInPlace code/gp.gmk --replace-fail '-Werror ' ' '
      substituteInPlace code/ll.gmk --replace-fail '-Werror ' ' '
    '';
  });
}
