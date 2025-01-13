{
  description = "nix-darwin system flake";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/release-24.05";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nixpkgs-stable,
    }:
    let
      configuration =
        { pkgs, config, ... }:
        {
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";
          nix.configureBuildUsers = true;
          nix.useDaemon = true;

          nixpkgs.config.allowUnfree = true;
          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";
          nixpkgs.overlays = [
            (_: prev: {
              # https://github.com/LnL7/nix-darwin/issues/1041
              inherit (nixpkgs-stable.legacyPackages.${prev.system}) karabiner-elements;
            })
          ];

          environment.shells = [
            pkgs.zsh
            pkgs.nushell
          ];
          environment.systemPackages = [
            pkgs.arc-browser
            pkgs.aerospace
            pkgs.atac
            pkgs.atuin
            pkgs.bash
            pkgs.bat
            pkgs.bazelisk
            pkgs.btop
            pkgs.carapace
            pkgs.ctop
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
            pkgs.gitui
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
            pkgs.gping
            pkgs.httpie
            pkgs.imgpkg
            pkgs.inetutils
            pkgs.jankyborders
            pkgs.jdk23
            pkgs.jetbrains.goland
            pkgs.jq
            pkgs.just
            pkgs.k6
            pkgs.k9s
            pkgs.kapp
            # pkgs.karabiner-elements
            pkgs.kbld
            pkgs.kdash
            pkgs.kind
            pkgs.krew
            pkgs.ktop
            pkgs.kubebuilder
            pkgs.kubeconform
            pkgs.kubectl
            pkgs.kubectx
            pkgs.kubernetes-helm
            pkgs.kubescape
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
            pkgs.rsync
            pkgs.rustup
            pkgs.sd
            pkgs.shellcheck
            pkgs.shellharden
            pkgs.shfmt
            pkgs.sketchybar
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
            pkgs.vegeta
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
            pkgs.zellij
            pkgs.zig
            pkgs.zoxide
            pkgs.zsh-autocomplete
          ];
          environment.variables = {
            GOROOT = pkgs.go + "/share/go";
          };
          environment.systemPath = [
            "$HOME/go/bin"
          ];

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
          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 5;
          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;
          # defaults
          system.defaults.dock.autohide = true;
          system.defaults.dock.mru-spaces = false;
          system.defaults.dock.persistent-apps = [
            "/Applications/zoom.us.app"
            "/Users/krenil/Applications/Chrome Apps.localized/Google Chat.app"
            "/run/current-system/Applications/Arc.app"
            "/Applications/Ghostty.app"
            "/run/current-system/Applications/Visual Studio Code.app"
          ];

          programs.zsh.enable = true;
          programs.zsh.enableSyntaxHighlighting = true;
          programs.direnv.enable = true;
          programs.tmux.enable = true;
          programs.tmux.enableFzf = true;
          programs.tmux.enableMouse = true;
          programs.tmux.enableSensible = true;
          programs.tmux.enableVim = true;
          programs.tmux.extraConfig = "source-file $HOME/.config/tmux/tmux.conf";

          services.nix-daemon.enable = true;
          # services.karabiner-elements.enable = true;

          security.pam.enableSudoTouchIdAuth = true;

          homebrew.enable = true;
          homebrew.taps = [
            "hashicorp/tap"
            "carvel-dev/carvel"
            "messense/macos-cross-toolchains"
          ];
          homebrew.casks = [
            "ghostty"
            "insomnia"
            "licecap"
            "notion"
            "karabiner-elements"
          ];
          homebrew.brews = [
            "hashicorp/tap/vault"
            "carvel-dev/carvel/kctrl"
            "messense/macos-cross-toolchains/x86_64-unknown-linux-gnu"
          ];

          launchd = {
            user = {
              agents = {
                aerospace = {
                  command = "${pkgs.aerospace}/Applications/AeroSpace.app/Contents/MacOS/AeroSpace";
                  serviceConfig = {
                    KeepAlive = true;
                    RunAtLoad = true;
                  };
                };
                raycast = {
                  command = "${pkgs.raycast}/Applications/Raycast.app/Contents/MacOS/Raycast";
                  serviceConfig = {
                    KeepAlive = true;
                    RunAtLoad = true;
                  };
                };
                sketchybar = {
                  path = [ pkgs.sketchybar ] ++ [ config.environment.systemPath ];
                  serviceConfig = {
                    ProgramArguments = [ "${pkgs.sketchybar}/bin/sketchybar" ];
                    KeepAlive = true;
                    RunAtLoad = true;
                  };
                };
                jankyborders = {
                  path = [ pkgs.jankyborders ] ++ [ config.environment.systemPath ];
                  serviceConfig = {
                    ProgramArguments = [ "${pkgs.jankyborders}/bin/borders" ];
                    KeepAlive = true;
                    RunAtLoad = true;
                  };
                };
              };
            };
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
