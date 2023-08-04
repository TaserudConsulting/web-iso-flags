{
  description = "ISO SVG flags that works on the web";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable-small;
    flake-utils.url = "flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  } @ inputs: (flake-utils.lib.eachSystem [ "aarch64-linux" "x86_64-linux" ] (system: let
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # Specify formatter package for "nix fmt ." and "nix fmt . -- --check"
    formatter = pkgs.alejandra;

    # Expose the theme files.
    packages.default = pkgs.stdenv.mkDerivation {
      pname = "iso-flags-for-web";
      inherit (pkgs.iso-flags) version;

      src = pkgs.iso-flags;

      installPhase = ''
        mkdir $out

        # Copy raw SVG files
        cp -vr share/iso-flags/svg-country-4x2-simple/* $out
        cp -vr share/iso-flags/common/4x2-back-shadow.png $out/back.png

        # Process them
        for input in $out/*.svg; do
          echo "Processing $(basename $input)"
          ${pkgs.inkscape}/bin/inkscape --export-type=svg --export-filename=$input --export-plain-svg $input
        done
      '';
    };

    checks.outputhash = pkgs.stdenv.mkDerivation {
      pname = "${self.packages.${system}.default.pname}-outputhash-check";
      inherit (self.packages.${system}.default) version;
      dontBuild = true;

      src = self.packages.${system}.default;

      installPhase = ''
        sha512sum -c ${./output-hashes.sha512sum}

        touch $out
      '';
    };
  }));
}
