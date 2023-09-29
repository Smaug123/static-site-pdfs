{
  description = "PDFs hosted on patrickstevens.co.uk";

  inputs = {
    flake-utils.url = github:numtide/flake-utils;
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
    scripts.url = "github:Smaug123/flake-shell-script";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    scripts,
  }: let
    commit = self.shortRev or "dirty";
    date = self.lastModifiedDate or self.lastModified or "19700101";
    version = "1.0.0+${builtins.substring 0 8 date}.${commit}";
  in
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in let
      texlive = pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-medium mdframed etoolbox zref needspace tikz-cd;
      };
    in {
      packages.default = pkgs.stdenv.mkDerivation {
        __contentAddressed = true;
        inherit version;
        pname = "patrickstevens.co.uk-pdfs";
        src = ./.;
        buildInputs = [texlive];
        buildPhase = ''
          ${pkgs.bash}/bin/sh ${scripts.lib.createShellScript pkgs "latex" ./build.sh}/run.sh .
        '';

        installPhase = ''
          mkdir -p $out
          cp ./*.pdf $out
          cp ./*.tex $out
          cp ./pdf-targets.txt $out
        '';
      };
      devShells.default = pkgs.mkShell {
        buildInputs = [pkgs.alejandra pkgs.shellcheck];
      };
    });
}
