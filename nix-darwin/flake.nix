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
      nix-darwin,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment = {
            shells = [
              pkgs.zsh
              pkgs.nushell
            ];
            systemPackages = [
              pkgs.aerospace
              pkgs.arc-browser
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
              pkgs.glow
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
              pkgs.zed-editor
              pkgs.zoxide
              pkgs.zsh
              pkgs.zsh-autocomplete
              pkgs.zsh-autosuggestions
              pkgs.zsh-syntax-highlighting
            ];
          };

          fonts.packages = [
            pkgs.nerd-fonts.jetbrains-mono
          ];

          system = {
            activationScripts.applications.text = let
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
            # Used for backwards compatibility, please read the changelog before changing.
            # $ darwin-rebuild changelog
            stateVersion = 5;
            # Set Git commit hash for darwin-version.
            configurationRevision = self.rev or self.dirtyRev or null;
            # defaults
            defaults = {
              dock = {
                autohide = true;
                mru-spaces = false;
                persistent-apps = [
                  "/Applications/zoom.us.app"
                  "/Users/krenil/Applications/Chrome Apps.localized/Google Chat.app"
                  "/Applications/Nix Apps/Arc.app"
                  "/Applications/Zen Browser.app"
                  "/Applications/Nix Apps/Wezterm.app"
                  "/Applications/Ghostty.app"
                  "/Users/krenil/Applications/GoLand.app"
                  "/Applications/Nix Apps/Visual Studio Code.app"
                  "/Applications/Nix Apps/Zed.app"
                  "/Applications/Nix Apps/Obsidian.app"
                  "/Applications/Insomnia.app"
                  "/Applications/Notion.app"
                  "/Applications/LICEcap.app"
                ];
              };
            };
          };

          programs = {
            zsh = {
              enable = true;
              enableCompletion = true;
              enableSyntaxHighlighting = true;
            };
          };

          users.users.krenil.shell = pkgs.zsh;

          services.nix-daemon.enable = true;
          
          nix = {
            # Necessary for using flakes on this system.
            settings.experimental-features = "nix-command flakes";
            configureBuildUsers = true;
            useDaemon = true;
          };
          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          nixpkgs = {
            config.allowUnfree = true;
            # The platform the configuration will be used on.
            hostPlatform = "aarch64-darwin";
          };

          security.pam.enableSudoTouchIdAuth = true;

          homebrew = {
            enable = true;
            casks = [
              "ghostty"
            ];
            brews = [
              "vault"
            ];
          };
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#CNQD6VNP9M
      darwinConfigurations."default" = nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [ configuration ];
      };

      # Expose the package set, including overlays, for convenience.
      darwinPackages = self.darwinConfigurations."default".pkgs;
    };
}
