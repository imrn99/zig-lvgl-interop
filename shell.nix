{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    zig
    clang
    libclang
    SDL2
    SDL2_image
  ];

  shellHook = ''
  '';
}
