{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nix-darwin,
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {

          nixpkgs.config.allowUnfree = true;

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment = {
            shells = [
              pkgs.zsh
              pkgs.nushell
            ];
            systemPackages = [
              pkgs.aerospace
              pkgs.atuin
              pkgs.bash
              pkgs.bat
              pkgs.bazelisk
              pkgs.carapace
              pkgs.curl
              pkgs.dblab
              pkgs.direnv
              pkgs.dive
              pkgs.duf
              pkgs.eza
              pkgs.fd
              pkgs.fish
              pkgs.fzf
              pkgs.gcc
              pkgs.git
              pkgs.git-extras
              pkgs.gnumake
              pkgs.gnused
              pkgs.go
              pkgs.govc
              pkgs.go-migrate
              pkgs.go-task
              pkgs.imgpkg
              pkgs.inetutils
              pkgs.jdk23
              pkgs.jq
              pkgs.just
              pkgs.k9s
              pkgs.kapp
              pkgs.kbld
              pkgs.kind
              pkgs.krew
              pkgs.kubebuilder
              pkgs.kubeconform
              pkgs.kubectl
              pkgs.kubectx
              pkgs.kubernetes-helm
              pkgs.kustomize
              pkgs.lazydocker
              pkgs.lazygit
              pkgs.lua
              pkgs.luajitPackages.luarocks
              pkgs.mariadb
              pkgs.minikube
              pkgs.minio-client
              pkgs.mkalias
              pkgs.neovim
              pkgs.nixfmt-rfc-style
              pkgs.nodejs_23
              pkgs.nushell
              pkgs.obsidian
              pkgs.openssl
              pkgs.openldap
              pkgs.oras
              pkgs.podman
              pkgs.popeye
              pkgs.postgresql
              pkgs.powershell
              pkgs.raycast
              pkgs.ripgrep
              pkgs.rustup
              pkgs.shellcheck
              pkgs.shfmt
              pkgs.sqlite
              pkgs.sshpass
              pkgs.sshuttle
              pkgs.starship
              pkgs.stern
              pkgs.stow
              pkgs.terraform
              pkgs.tlrc
              pkgs.tmux
              pkgs.tree
              pkgs.unixtools.watch
              pkgs.vendir
              pkgs.vscode
              pkgs.warp-terminal
              pkgs.wezterm
              pkgs.wget
              pkgs.yazi
              pkgs.yq-go
              pkgs.ytt
              pkgs.zoxide
              pkgs.zsh
              pkgs.zsh-autosuggestions
              pkgs.zsh-syntax-highlighting
            ];
          };

          fonts.packages = [
            pkgs.nerd-fonts.jetbrains-mono
          ];

          system.activationScripts.applications.text =
            let
              env = pkgs.buildEnv {
                name = "system-applications";
                paths = config.environment.systemPackages;
                pathsToLink = "/Applications";
              };
            in
            pkgs.lib.mkForce ''
              # Set up applications.
              echo "setting up /Applications..." >&2
              rm -rf /Applications/Nix\ Apps
              mkdir -p /Applications/Nix\ Apps
              find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
              while read -r src; do
                app_name=$(basename "$src")
                echo "copying $src" >&2
                ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
              done
            '';

          programs = {
            zsh = {
              enable = true;
              enableCompletion = true;
              enableFzfCompletion = true;
              enableSyntaxHighlighting = true;
            };
          };

          users.users.krenil.shell = pkgs.zsh;

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#CNQD6VNP9M
      darwinConfigurations."CNQD6VNP9M" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
    };
}
