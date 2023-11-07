{
  description = "Flake for development of the civ R package";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let

      pkgs = nixpkgs.legacyPackages.${system};

      # Fetch kcmeans package from GitHub (until it's on CRAN)
      kcmeans = pkgs.rPackages.buildRPackage {
        name = "kcmeans";
        src = pkgs.fetchFromGitHub {
          owner = "thomaswiemann";
          repo = "kcmeans";
          rev = "d6139426c9de8da5dd045350929f014900c8ee73";
          sha256 = "AKN2mnh5WlBIfTYp1frD0aUL18dDYDnRLSnaOzRj+9c=";
        };
        # kcmeans dependencies
        propagatedBuildInputs = with pkgs.rPackages; [Ckmeans_1d_dp MASS Matrix];
      };

      # R packages
      my-R-packages = with pkgs.rPackages; [
        devtools
        pkgdown
        testthat
        covr
        knitr
        markdown
        rmarkdown
        # add other dependencies below
        AER
        kcmeans
      ];
      my-R = [pkgs.R my-R-packages];

    in {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [ pkgs.bashInteractive ];
        buildInputs = [
          my-R
          pkgs.rstudio
          pkgs.quarto # needed for rstudio
        ];
       };
    });
}
