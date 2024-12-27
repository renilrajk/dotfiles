stow:
    stow --target "$HOME/.config" --ignore vscode .
    stow --target="$HOME/Library/Application Support/Code/User" vscode

unstow:
   stow -D --target "$HOME/.config" --ignore vscode .
   stow -D --target="$HOME/Library/Application Support/Code/User" vscode 