{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  xz,
  zlib,
  ncurses,
  gcc-unwrapped,
}:

let
  platform = {
    x86_64-linux = {
      name = "x86_64-unknown-linux-gnu";
      sha256 = "sha256-n+L+4BkI/M8y6hg3N5zoNqJPPaw6gMok4zyHplmcNuw=";
    };
    aarch64-linux = {
      name = "aarch64-unknown-linux-gnu";
      sha256 = "sha256-pvsdzN9VUrMd1QJM8RqrIM8PyJRW4JxD4+CsaQ0NQTQ=";
    };
    x86_64-darwin = {
      name = "x86_64-apple-darwin";
      sha256 = "sha256-jsQ18AWBlIAkyBMpIesUSdQLLJ6k5imZ/AGW2F0ek5A=";
    };
    aarch64-darwin = {
      name = "aarch64-apple-darwin";
      sha256 = "sha256-GvU/SINTrSSi+bHXCvNot0IjHDkG8EiMbbn9xZWfhpo=";
    };
  }.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation rec {
  pname = "sp1-rust-toolchain";
  version = "1.91.1";

  src = fetchurl {
    url = "https://github.com/succinctlabs/rust/releases/download/succinct-${version}/rust-toolchain-${platform.name}.tar.gz";
    inherit (platform) sha256;
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    xz
    zlib
    ncurses
    gcc-unwrapped
    stdenv.cc.cc.lib
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp -r bin/* $out/bin/
    cp -r lib/* $out/lib/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Succinct Labs Rust toolchain";
    homepage = "https://github.com/succinctlabs/rust";
    license = licenses.mit;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
  };
}
