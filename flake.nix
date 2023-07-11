{
  description =
    "Infrastructure layer for pythoneda-artifact/pyproject-versioning";

  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    pythoneda-base = {
      url = "github:pythoneda/base/0.0.1a16";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda-artifact-event-versioning = {
      url = "github:pythoneda-artifact-event/versioning/0.0.1a1";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
    };
    pythoneda-artifact-event-infrastructure-versioning = {
      url = "github:pythoneda-artifact-event-infrastructure/versioning/0.0.1a1";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
      inputs.pythoneda-artifact-event-versioning.follows =
        "pythoneda-artifact-event-versioning";
    };
    pythoneda-shared-git = {
      url = "github:pythoneda-shared/git/0.0.1a3";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
    };
    pythoneda-artifact-pyproject-versioning = {
      url = "github:pythoneda-artifact/pyproject-versioning/0.0.1a2";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
      inputs.pythoneda-artifact-event-versioning.follows =
        "pythoneda-artifact-event-versioning";
    };
    pythoneda-infrastructure-base = {
      url = "github:pythoneda-infrastructure/base/0.0.1a12";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        pname = "pythoneda-artifact-infrastructure-pyproject-versioning";
        description =
          "Infrastructure layer for pythoneda-artifact/pyproject-versioning";
        license = pkgs.lib.licenses.gpl3;
        homepage =
          "https://github.com/pythoneda-artifact-infrastructure/pyproject-versioning";
        maintainers = with pkgs.lib.maintainers; [ ];
        nixpkgsRelease = "nixos-23.05";
        shared = import ./nix/shared.nix;
        pythonpackage = "pythonedaartifactinfrastructurepyprojectversioning";
        pythoneda-artifact-infrastructure-pyproject-versioning-for = { version
          , pythoneda-artifact-event-versioning
          , pythoneda-artifact-event-infrastructure-versioning, pythoneda-base
          , pythoneda-artifact-pyproject-versioning
          , pythoneda-infrastructure-base, pythoneda-shared-git, python }:
          let
            pythonVersionParts = builtins.splitVersion python.version;
            pythonMajorVersion = builtins.head pythonVersionParts;
            pythonMajorMinorVersion =
              "${pythonMajorVersion}.${builtins.elemAt pythonVersionParts 1}";
            pnameWithUnderscores =
              builtins.replaceStrings [ "-" ] [ "_" ] pname;
            wheelName =
              "${pnameWithUnderscores}-${version}-py${pythonMajorVersion}-none-any.whl";
          in python.pkgs.buildPythonPackage rec {
            inherit pname version;
            projectDir = ./.;
            src = ./.;
            format = "pyproject";

            nativeBuildInputs = with python.pkgs; [ pip pkgs.jq poetry-core ];
            propagatedBuildInputs = with python.pkgs; [
              dbus-next
              dulwich
              GitPython
              grpcio
              pythoneda-artifact-event-versioning
              pythoneda-artifact-event-infrastructure-versioning
              pythoneda-artifact-pyproject-versioning
              pythoneda-base
              pythoneda-infrastructure-base
              pythoneda-shared-git
              requests
              semver
            ];

            checkInputs = with python.pkgs; [ pytest ];

            pythonImportsCheck = [ pythonpackage ];

            preBuild = ''
              python -m venv .env
              source .env/bin/activate
              pip install ${pythoneda-base}/dist/pythoneda_base-${pythoneda-base.version}-py3-none-any.whl
              pip install ${pythoneda-artifact-event-versioning}/dist/pythoneda_artifact_event_versioning-${pythoneda-artifact-event-versioning.version}-py3-none-any.whl
              pip install ${pythoneda-artifact-event-infrastructure-versioning}/dist/pythoneda_artifact_event_infrastructure_versioning-${pythoneda-artifact-event-infrastructure-versioning.version}-py3-none-any.whl
              pip install ${pythoneda-artifact-pyproject-versioning}/dist/pythoneda_artifact_pyproject_versioning-${pythoneda-artifact-pyproject-versioning.version}-py3-none-any.whl
              pip install ${pythoneda-infrastructure-base}/dist/pythoneda_infrastructure_base-${pythoneda-infrastructure-base.version}-py3-none-any.whl
              pip install ${pythoneda-shared-git}/dist/pythoneda_shared_git-${pythoneda-shared-git.version}-py3-none-any.whl
              rm -rf .env
            '';

            postInstall = ''
              mkdir $out/dist
              cp dist/${wheelName} $out/dist
              jq ".url = \"$out/dist/${wheelName}\"" $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json > temp.json && mv temp.json $out/lib/python${pythonMajorMinorVersion}/site-packages/${pnameWithUnderscores}-${version}.dist-info/direct_url.json
            '';

            meta = with pkgs.lib; {
              inherit description license homepage maintainers;
            };
          };
        pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-for =
          { pythoneda-base, pythoneda-artifact-event-versioning
          , pythoneda-artifact-event-infrastructure-versioning
          , pythoneda-artifact-pyproject-versioning
          , pythoneda-infrastructure-base, pythoneda-shared-git, python }:
          pythoneda-artifact-infrastructure-pyproject-versioning-for {
            version = "0.0.1a2";
            inherit pythoneda-base pythoneda-artifact-event-versioning
              pythoneda-artifact-event-infrastructure-versioning
              pythoneda-artifact-pyproject-versioning
              pythoneda-infrastructure-base pythoneda-shared-git python;
          };
      in rec {
        packages = rec {
          pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-python38 =
            pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python38;
              pythoneda-artifact-event-versioning =
                pythoneda-artifact-event-versioning.packages.${system}.pythoneda-artifact-event-versioning-latest-python38;
              pythoneda-artifact-event-infrastructure-versioning =
                pythoneda-artifact-event-infrastructure-versioning.packages.${system}.pythoneda-artifact-event-infrastructure-versioning-latest-python38;
              pythoneda-artifact-pyproject-versioning =
                pythoneda-artifact-pyproject-versioning.packages.${system}.pythoneda-artifact-pyproject-versioning-latest-python38;
              pythoneda-infrastructure-base =
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base-latest-python38;
              pythoneda-shared-git =
                pythoneda-shared-git.packages.${system}.pythoneda-shared-git-latest-python38;
              python = pkgs.python38;
            };
          pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-python39 =
            pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              pythoneda-artifact-event-versioning =
                pythoneda-artifact-event-versioning.packages.${system}.pythoneda-artifact-event-versioning-latest-python39;
              pythoneda-artifact-event-infrastructure-versioning =
                pythoneda-artifact-event-infrastructure-versioning.packages.${system}.pythoneda-artifact-event-infrastructure-versioning-latest-python39;
              pythoneda-artifact-pyproject-versioning =
                pythoneda-artifact-pyproject-versioning.packages.${system}.pythoneda-artifact-pyproject-versioning-latest-python39;
              pythoneda-infrastructure-base =
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base-latest-python39;
              pythoneda-shared-git =
                pythoneda-shared-git.packages.${system}.pythoneda-shared-git-latest-python39;
              python = pkgs.python39;
            };
          pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-python310 =
            pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python310;
              pythoneda-artifact-event-versioning =
                pythoneda-artifact-event-versioning.packages.${system}.pythoneda-artifact-event-versioning-latest-python310;
              pythoneda-artifact-event-infrastructure-versioning =
                pythoneda-artifact-event-infrastructure-versioning.packages.${system}.pythoneda-artifact-event-infrastructure-versioning-latest-python310;
              pythoneda-artifact-pyproject-versioning =
                pythoneda-artifact-pyproject-versioning.packages.${system}.pythoneda-artifact-pyproject-versioning-latest-python310;
              pythoneda-infrastructure-base =
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base-latest-python310;
              pythoneda-shared-git =
                pythoneda-shared-git.packages.${system}.pythoneda-shared-git-latest-python310;
              python = pkgs.python310;
            };
          pythoneda-artifact-infrastructure-pyproject-versioning-latest-python38 =
            pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-python38;
          pythoneda-artifact-infrastructure-pyproject-versioning-latest-python39 =
            pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-python39;
          pythoneda-artifact-infrastructure-pyproject-versioning-latest-python310 =
            pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-python310;
          pythoneda-artifact-infrastructure-pyproject-versioning-latest =
            pythoneda-artifact-infrastructure-pyproject-versioning-latest-python310;
          default =
            pythoneda-artifact-infrastructure-pyproject-versioning-latest;
        };
        defaultPackage = packages.default;
        devShells = rec {
          pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-python38 =
            shared.devShell-for {
              package =
                packages.pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-python38;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              python = pkgs.python38;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-python39 =
            shared.devShell-for {
              package =
                packages.pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-python39;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              python = pkgs.python39;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-python310 =
            shared.devShell-for {
              package =
                packages.pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-python310;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python310;
              python = pkgs.python310;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-artifact-infrastructure-pyproject-versioning-latest-python38 =
            pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-python38;
          pythoneda-artifact-infrastructure-pyproject-versioning-latest-python39 =
            pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-python39;
          pythoneda-artifact-infrastructure-pyproject-versioning-latest-python310 =
            pythoneda-artifact-infrastructure-pyproject-versioning-0_0_1a2-python310;
          pythoneda-artifact-infrastructure-pyproject-versioning-latest =
            pythoneda-artifact-infrastructure-pyproject-versioning-latest-python310;
          default =
            pythoneda-artifact-infrastructure-pyproject-versioning-latest;

        };
      });
}
