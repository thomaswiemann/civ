{
  description = "Flake for development of the civ R package";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let

      pkgs = nixpkgs.legacyPackages.${system};

      # Install local version of civ
      civ = pkgs.rPackages.buildRPackage {
        name = "civ";
        src = ./.;
        # civ dependencies
        propagatedBuildInputs = with pkgs.rPackages; [AER kcmeans];
      };

      # Fetch kcmeans package from GitHub (until it's on CRAN)
      kcmeans = pkgs.rPackages.buildRPackage {
        name = "kcmeans";
        src = pkgs.fetchFromGitHub {
          owner = "thomaswiemann";
          repo = "kcmeans";
          rev = "62958b74175e46f59d99b554746f56c77031c8e4";
          sha256 = "iqEhb8NTcnF2IlqSBdHmBI43qOwuSgpfT44C6Ts92Nk=";
        };
        # kcmeans dependencies
        propagatedBuildInputs = with pkgs.rPackages; [Ckmeans_1d_dp MASS Matrix];
      };

      # R packages
      my-R-packages = with pkgs.rPackages; [
        # this package
        civ
        # general develppment packages
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
        # dependencies for vignettes only:
        hdm
        ranger
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
