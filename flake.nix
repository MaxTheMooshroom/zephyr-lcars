{
  inputs.nixpkgs.url = "nixpkgs/release-23.11";

  inputs.zephyr-rtos = {
    url = "github:katyo/zephyr-rtos.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, zephyr-rtos, ... }:
    let
      # supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        overlays = [ zephyr-rtos.overlays.default ];
      });
    in
    {
      devShells = forAllSystems (system:
      let
        pkgs = nixpkgsFor.${system};
        pkgs32 = pkgs.pkgsi686Linux;
        zephyrSdk = pkgs.mkZephyrSdk { inputs = with pkgs32; [ SDL2 ]; };
      in
      {
        default = zephyrSdk.overrideAttrs (prev: { nativeBuildInputs = with pkgs; [ pkg-config ]; });
      });
    };
}
