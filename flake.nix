{
  description = "ISO SVG flags that works on the web";

  inputs = {
    flake-utils.url = "flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
    ...
  }: (flake-utils.lib.eachSystem ["aarch64-linux" "x86_64-linux"] (system: let
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # Specify formatter package for "nix fmt ." and "nix fmt . -- --check"
    formatter = pkgs.alejandra;

    # Expose the theme files.
    packages.default =
      pkgs.runCommandNoCC "iso-flags-for-web" {
        nativeBuildInputs = [pkgs.inkscape];
      } ''
        mkdir $out

        # Copy raw SVG files
        cp -vr ${pkgs.iso-flags}/share/iso-flags/svg-country-4x2-simple/*.svg $out
        cp -vr ${pkgs.iso-flags}/share/iso-flags/svg-country-4x2-simple/fore.png $out/fore.png
        cp -vr ${pkgs.iso-flags}/share/iso-flags/common/4x2-back-shadow.png $out/back.png

        cd $out

        # Process them
        for input in *.svg; do
          echo "Processing $input"
          inkscape --export-type=svg --export-filename=_tmp_.svg --export-plain-svg $input
          mv _tmp_.svg $input
        done
      '';

    checks.outputhash = pkgs.runCommandNoCC "iso-flags-for-web-outputhash-check" {} ''
      cd ${self.packages.${system}.default}

      sha512sum -c ${./output-hashes.sha512sum}

      touch $out
    '';
  }));
}
