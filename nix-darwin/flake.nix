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
              pkgs.delve
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
              pkgs.golangci-lint
              pkgs.gopls
              pkgs.gotools
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
              pkgs.luaformatter
              pkgs.luajitPackages.luarocks
              pkgs.mariadb
              pkgs.minikube
              pkgs.minio-client
              pkgs.mkalias
              pkgs.neovim
              pkgs.nixfmt-rfc-style
              pkgs.nixpkgs-fmt
              pkgs.nixpkgs-lint
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
              pkgs.pprof
              pkgs.protobuf
              pkgs.protoc-gen-go
              pkgs.raycast
              pkgs.ripgrep
              pkgs.rustup
              pkgs.shellcheck
              pkgs.shellharden
              pkgs.shfmt
              pkgs.sqlite
              pkgs.sshpass
              pkgs.sshuttle
              pkgs.starship
              pkgs.stern
              pkgs.stow
              pkgs.terraform
              pkgs.tlrc
              pkgs.tree
              pkgs.unixtools.watch
              pkgs.vendir
              pkgs.vscode
              pkgs.wezterm
              pkgs.wget
              pkgs.yamlfmt
              pkgs.yamllint
              pkgs.yazi
              pkgs.yq-go
              pkgs.ytt
              pkgs.zed-editor
              pkgs.zoxide
            ];
            variables = {
              XDG_CONFIG_HOME = "$HOME/.config";
              EDITOR = "nvim";
              LANG = "en_US.UTF-8";
              GOROOT = pkgs.go + "/share/go";
              GOPATH = "$HOME/go";
              NIX_CONF_DIR = "$HOME/.config/nix";
              CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
              FZF_DEFAULT_OP = "--extended";
              STARSHIP_CONFIG = "$HOME/.config/starship/starship.toml";
            };
            shellAliases = {
              cat = "bat";
              ls = "eza";
              ll = "ls -l";
              vi = "nvim";
              vim = "nvim";
              lg = "lazygit";
              ld = "lazydocker";
            };
            systemPath = [
              "$HOME/go/bin"
            ];
          };

          fonts.packages = [
            pkgs.nerd-fonts.jetbrains-mono
          ];

          system = {
            activationScripts.applications.text =
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
                  "/run/current-system/Applications/Arc.app"
                  "/Applications/Zen Browser.app"
                  "/run/current-system/Applications/Wezterm.app"
                  "/Applications/Ghostty.app"
                  "/Users/krenil/Applications/GoLand.app"
                  "/run/current-system/Applications/Visual Studio Code.app"
                  "/run/current-system/Applications/Zed.app"
                  "/run/current-system/Applications/Obsidian.app"
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
              enableSyntaxHighlighting = true;
            };
            direnv = {
              enable = true;
            };
            tmux = {
              enable = true;
              enableFzf = true;
              enableMouse = true;
              enableSensible = true;
              enableVim = true;
              extraConfig = "source-file $HOME/.config/tmux/tmux.conf";
            };
          };

          services.nix-daemon.enable = true;

          nix = {
            # Necessary for using flakes on this system.
            settings.experimental-features = "nix-command flakes";
            configureBuildUsers = true;
            useDaemon = true;
          };

          nixpkgs = {
            config.allowUnfree = true;
            # The platform the configuration will be used on.
            hostPlatform = "aarch64-darwin";
          };

          security.pam.enableSudoTouchIdAuth = true;

          homebrew = {
            enable = true;
            taps = [
              "hashicorp/tap"
              "carvel-dev/carvel"
              "messense/macos-cross-toolchains"
            ];
            casks = [
              "ghostty"
            ];
            brews = [
              "hashicorp/tap/vault"
              "carvel-dev/carvel/kctrl"
              "messense/macos-cross-toolchains/x86_64-unknown-linux-gnu"
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
