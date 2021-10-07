{
  description = "The WASM package for prisma-fmt";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      with builtins;
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain;
        buildRustPackage = pkgs.rustPlatform.buildRustPackage;
        wasm-bindgen-cli = pkgs.wasm-bindgen-cli;
        fakeSha256 = pkgs.lib.fakeSha256;
      in {
        defaultPackage = buildRustPackage {
          buildPhase =
            "echo 'wasm build...'; RUSTC=${rust}/bin/rustc ${rust}/bin/cargo build --release --target=wasm32-unknown-unknown";
          checkPhase = "echo 'checkPhase: echo yolo'";
          name = "prisma-fmt-wasm";
          src = ./.;
          cargoSha256 = "sha256-T9zov9UUsKt4sKZ6AvjWJILHQlNWv83jvTGMedWDlWA=";
          installPhase = ''
            echo 'ls`ing target';
            ls -a target/**/*;
            mkdir $out;

            RUST_BACKTRACE=1 ${wasm-bindgen-cli}/bin/wasm-bindgen \
              --target nodejs \
              --out-dir $out \
              target/wasm32-unknown-unknown/release/prisma_fmt_build.wasm;
          '';
        };
      });
}
