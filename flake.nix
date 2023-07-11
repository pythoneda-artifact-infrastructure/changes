{
  description = "Infrastructure layer for pythoneda-artifact/changes";
  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    pythoneda-base = {
      url = "github:pythoneda/base/0.0.1a16";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda-artifact-event-changes = {
      url = "github:pythoneda-artifact-event/changes/0.0.1a1";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
    };
    pythoneda-artifact-event-infrastructure-changes = {
      url = "github:pythoneda-artifact-event-infrastructure/changes/0.0.1a1";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
      inputs.pythoneda-artifact-event-changes.follows =
        "pythoneda-artifact-event-changes";
    };
    pythoneda-shared-git = {
      url = "github:pythoneda-shared/git/0.0.1a3";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
    };
    pythoneda-artifact-changes = {
      url = "github:pythoneda-artifact/changes/0.0.1a1";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pythoneda-base.follows = "pythoneda-base";
      inputs.pythoneda-artifact-event-changes.follows =
        "pythoneda-artifact-event-changes";
      inputs.pythoneda-shared-git.follows = "pythoneda-shared-git";
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
        pname = "pythoneda-artifact-infrastructure-changes";
        description = "Infrastructure layer for pythoneda-artifact/changes";
        license = pkgs.lib.licenses.gpl3;
        homepage =
          "https://github.com/pythoneda-artifact-infrastructure/changes";
        maintainers = with pkgs.lib.maintainers; [ ];
        nixpkgsRelease = "nixos-23.05";
        shared = import ./nix/shared.nix;
        pythonpackage = "pythonedaartifactinfrastructurechanges";
        pythoneda-artifact-infrastructure-changes-for = { version
          , pythoneda-artifact-event-changes
          , pythoneda-artifact-event-infrastructure-changes, pythoneda-base
          , pythoneda-artifact-changes, pythoneda-infrastructure-base
          , pythoneda-shared-git, python }:
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
              pythoneda-artifact-event-changes
              pythoneda-artifact-event-infrastructure-changes
              pythoneda-artifact-changes
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
              pip install ${pythoneda-artifact-event-changes}/dist/pythoneda_artifact_event_changes-${pythoneda-artifact-event-changes.version}-py3-none-any.whl
              pip install ${pythoneda-artifact-event-infrastructure-changes}/dist/pythoneda_artifact_event_infrastructure_changes-${pythoneda-artifact-event-infrastructure-changes.version}-py3-none-any.whl
              pip install ${pythoneda-artifact-changes}/dist/pythoneda_artifact_changes-${pythoneda-artifact-changes.version}-py3-none-any.whl
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
        pythoneda-artifact-infrastructure-changes-0_0_1a1-for = { pythoneda-base
          , pythoneda-artifact-event-changes
          , pythoneda-artifact-event-infrastructure-changes
          , pythoneda-artifact-changes, pythoneda-infrastructure-base
          , pythoneda-shared-git, python }:
          pythoneda-artifact-infrastructure-changes-for {
            version = "0.0.1a1";
            inherit pythoneda-base pythoneda-artifact-event-changes
              pythoneda-artifact-event-infrastructure-changes
              pythoneda-artifact-changes pythoneda-infrastructure-base
              pythoneda-shared-git python;
          };
      in rec {
        packages = rec {
          pythoneda-artifact-infrastructure-changes-0_0_1a1-python38 =
            pythoneda-artifact-infrastructure-changes-0_0_1a1-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python38;
              pythoneda-artifact-event-changes =
                pythoneda-artifact-event-changes.packages.${system}.pythoneda-artifact-event-changes-latest-python38;
              pythoneda-artifact-event-infrastructure-changes =
                pythoneda-artifact-event-infrastructure-changes.packages.${system}.pythoneda-artifact-event-infrastructure-changes-latest-python38;
              pythoneda-artifact-changes =
                pythoneda-artifact-changes.packages.${system}.pythoneda-artifact-changes-latest-python38;
              pythoneda-infrastructure-base =
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base-latest-python38;
              pythoneda-shared-git =
                pythoneda-shared-git.packages.${system}.pythoneda-shared-git-latest-python38;
              python = pkgs.python38;
            };
          pythoneda-artifact-infrastructure-changes-0_0_1a1-python39 =
            pythoneda-artifact-infrastructure-changes-0_0_1a1-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              pythoneda-artifact-event-changes =
                pythoneda-artifact-event-changes.packages.${system}.pythoneda-artifact-event-changes-latest-python39;
              pythoneda-artifact-event-infrastructure-changes =
                pythoneda-artifact-event-infrastructure-changes.packages.${system}.pythoneda-artifact-event-infrastructure-changes-latest-python39;
              pythoneda-artifact-changes =
                pythoneda-artifact-changes.packages.${system}.pythoneda-artifact-changes-latest-python39;
              pythoneda-infrastructure-base =
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base-latest-python39;
              pythoneda-shared-git =
                pythoneda-shared-git.packages.${system}.pythoneda-shared-git-latest-python39;
              python = pkgs.python39;
            };
          pythoneda-artifact-infrastructure-changes-0_0_1a1-python310 =
            pythoneda-artifact-infrastructure-changes-0_0_1a1-for {
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python310;
              pythoneda-artifact-event-changes =
                pythoneda-artifact-event-changes.packages.${system}.pythoneda-artifact-event-changes-latest-python310;
              pythoneda-artifact-event-infrastructure-changes =
                pythoneda-artifact-event-infrastructure-changes.packages.${system}.pythoneda-artifact-event-infrastructure-changes-latest-python310;
              pythoneda-artifact-changes =
                pythoneda-artifact-changes.packages.${system}.pythoneda-artifact-changes-latest-python310;
              pythoneda-infrastructure-base =
                pythoneda-infrastructure-base.packages.${system}.pythoneda-infrastructure-base-latest-python310;
              pythoneda-shared-git =
                pythoneda-shared-git.packages.${system}.pythoneda-shared-git-latest-python310;
              python = pkgs.python310;
            };
          pythoneda-artifact-infrastructure-changes-latest-python38 =
            pythoneda-artifact-infrastructure-changes-0_0_1a1-python38;
          pythoneda-artifact-infrastructure-changes-latest-python39 =
            pythoneda-artifact-infrastructure-changes-0_0_1a1-python39;
          pythoneda-artifact-infrastructure-changes-latest-python310 =
            pythoneda-artifact-infrastructure-changes-0_0_1a1-python310;
          pythoneda-artifact-infrastructure-changes-latest =
            pythoneda-artifact-infrastructure-changes-latest-python310;
          default = pythoneda-artifact-infrastructure-changes-latest;
        };
        defaultPackage = packages.default;
        devShells = rec {
          pythoneda-artifact-infrastructure-changes-0_0_1a1-python38 =
            shared.devShell-for {
              package =
                packages.pythoneda-artifact-infrastructure-changes-0_0_1a1-python38;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              python = pkgs.python38;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-artifact-infrastructure-changes-0_0_1a1-python39 =
            shared.devShell-for {
              package =
                packages.pythoneda-artifact-infrastructure-changes-0_0_1a1-python39;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python39;
              python = pkgs.python39;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-artifact-infrastructure-changes-0_0_1a1-python310 =
            shared.devShell-for {
              package =
                packages.pythoneda-artifact-infrastructure-changes-0_0_1a1-python310;
              pythoneda-base =
                pythoneda-base.packages.${system}.pythoneda-base-latest-python310;
              python = pkgs.python310;
              inherit pkgs nixpkgsRelease;
            };
          pythoneda-artifact-infrastructure-changes-latest-python38 =
            pythoneda-artifact-infrastructure-changes-0_0_1a1-python38;
          pythoneda-artifact-infrastructure-changes-latest-python39 =
            pythoneda-artifact-infrastructure-changes-0_0_1a1-python39;
          pythoneda-artifact-infrastructure-changes-latest-python310 =
            pythoneda-artifact-infrastructure-changes-0_0_1a1-python310;
          pythoneda-artifact-infrastructure-changes-latest =
            pythoneda-artifact-infrastructure-changes-latest-python310;
          default = pythoneda-artifact-infrastructure-changes-latest;

        };
      });
}
