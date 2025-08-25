#! /bin/bash
#    ____           __        ____   _____           _       __
#    /  _/___  _____/ /_____ _/ / /  / ___/__________(_)___  / /_
#    / // __ \/ ___/ __/ __ `/ / /   \__ \/ ___/ ___/ / __ \/ __/
#  _/ // / / (__  ) /_/ /_/ / / /   ___/ / /__/ /  / / /_/ / /_
# /___/_/ /_/____/\__/\__,_/_/_/   /____/\___/_/  /_/ .___/\__/
#                                                  /_/
clear

from="$HOME/manjaro/"
cfgPath="$from/.config/"

packages=(
  "go"
  "gum"
  "npm"
  "zip"
  "unzip"
  "curl"
  "wget"
  "btop"
  "mpv"
  "mpv-mpris"
  "vim"
  "nodejs"
  "npm"
  "zsh"
  "fastfetch"
  "fakeroot"
  "glow"
  "discord"
  "lazygit"
  "ufw"
  "yazi"
  "eza"
  "steam"
  "zoxide"
  "fzf"
  "bat"
  "jdk-openjdk"
  "docker"
  "xsel"
  "ripgrep"
  "cargo"
  "fd"
  "starship"
  "xdg-desktop-portal-wlr"
  "wine"
  "ttf-font-awesome"
  "ttf-nerd-fonts-symbols"
  "ttf-jetbrains-mono-nerd"
  "otf-geist-mono-nerd"
  "noto-fonts-emoji"
  "7zip"
  "texlive"
  "net-tools"
  "inetutils"
)

aur_paqkages=(
  "google-chrome"
  "lazydocker"
  "ani-cli"
  "luajit-tiktoken-bin"
  "visual-studio-code-bin"
  "xwaylandvideobridge"
  )

installPackages() {
  for pgk in "${packages[@]}"; do
    pamac install --no-confirm "$pgk"
  done
}

installAurPackages() {
  for aur_pkg in "${aur_paqkages[@]}"; do
    pamac build --no-confirm "$aur_pkg"
  done
}

installDeepCoolDriver() {
  echo "Do you want to install DeepCool CPU-Fan driver?"
  deepcool=$(gum choose "Yes" "No")
  if [[ "$deepcool" == "Yes" ]]; then
    sudo cp "$location/DeepCool/deepcool-digital-linux" "/usr/sbin"
    sudo cp "$location/DeepCool/deepcool-digital.service" "/etc/systemd/system/"
  fi
}

configure_git() {
  echo ":: Want to configure git?"
  answer=$(gum choose "Yes" "No")
  if [[ "$answer" == "Yes" ]]; then
    username=$(gum input --prompt ":: > What is your user name?")
    git config --global user.name "$username"
    useremail=$(gum input --prompt ":: > What is your email?")
    git config --global user.email "$useremail"
    git config --global pull.rebase true
  fi

  echo ":: Want to create a ssh-key?"
  ssh=$(gum choose "Yes" "No")
  if [[ "$ssh" == "Yes" ]]; then
    ssh-keygen -t ed25519 -C "$useremail"
  fi

  echo ":: Want to create a physical key (Yubikey)?"
  key=$(gum choose "Yes" "No")
  if [[ "$key" == "Yes" ]]; then
    read -r -p ":: Insert a device like a Yubikey and press enter..."
    ssh-keygen -t ecdsa-sk -b 521
  fi
}

# detect_nvidia() {
#   gpu=$(lspci | grep -i '.* vga .* nvidia .*')
#
#   shopt -s nocasematch
#
#   if [[ $gpu == *' nvidia '* ]]; then
#     echo ":: Nvidia GPU is present"
#     gum spin --spinner dot --title "Installaling nvidia drivers now..." -- sleep 2
#     pamac install --noconfirm nvidia nvidia-utils nvidia-settings
#   else
#     echo "It seems you are not using a Nvidia GPU"
#     echo "If you have a Nvidia GPU then download the drivers yourself please :)"
#   fi
# }

copy_config() {
  gum spin --spinner dot --title "Creating bakups..." -- sleep 2

  if [[ -f "$HOME/.zshrc" ]]; then
    mv "$HOME/.zshrc" "$HOME/.zshrc.bak"
  fi

  if [[ -d "$HOME/.config" ]]; then
    mv "$HOME/.config" "$HOME/.config.bak"
  fi

  sudo cp "$from/scripts/pullall.sh" "/usr/bin/pullall"

  if [[ ! -d "$HOME/Pictures/Screenshots/" ]]; then
    mkdir -p "$HOME/Pictures/Screenshots/"
  fi

  cp "$from/.zshrc" "$HOME/"
  cp -r "$cfgPath" "$HOME/"

  sudo cp -r "$from/icons/" "/usr/share/"

  echo ":: Want to install Vencord?"
  vencord=$(gum choose "Yes" "No")

  if [[ "$vencord" == "Yes" ]]; then
    bash "$from/Vencord/VencordInstaller.sh"
    cp -r "$from/Vencord/themes/" "$HOME/.config/Vencord/"
  fi
}

add_tmux_tpm() {
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
  mkdir -p ~/.config/tmux/plugins/catppuccin
  git clone -b v2.1.2 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
}

MAGENTA='\033[0;35m'
NONE='\033[0m'

# Header
echo -e "${MAGENTA}"
cat <<"EOF"
   ____         __       ____
  /  _/__  ___ / /____ _/ / /__ ____
 _/ // _ \(_-</ __/ _ `/ / / -_) __/
/___/_//_/___/\__/\_,_/_/_/\__/_/

EOF

echo "Post Manjaro Installation Script"
echo -e "${NONE}"
while true; do
    read -p ":: DO YOU WANT TO START THE INSTALLATION NOW? (Yy/Nn): " yn
    case $yn in
        [Yy]*)
            echo ":: Installation started."
            echo
            break
            ;;
        [Nn]*)
            echo ":: Installation canceled"
            exit
            break
            ;;
        *)
            echo ":: Please answer yes or no."
            ;;
    esac
done

pamac upgrade -a

# Install required packages
echo ":: Installing required packages..."
installPackages
installAurPackages

gum spin --spinner dot --title "Starting setup now..." -- sleep 2
copy_config
# detect_nvidia
configure_git
add_tmux_tpm
installDeepCoolDriver

echo -e "${MAGENTA}"
cat <<"EOF"
    ____  __                        ____       __                __
   / __ \/ /__  ____ _________     / __ \___  / /_  ____  ____  / /_
  / /_/ / / _ \/ __ `/ ___/ _ \   / /_/ / _ \/ __ \/ __ \/ __ \/ __/
 / ____/ /  __/ /_/ (__  )  __/  / _, _/  __/ /_/ / /_/ / /_/ / /_
/_/   /_/\___/\__,_/____/\___/  /_/ |_|\___/_.___/\____/\____/\__/
EOF
echo "and thank you for choosing my config :)"
echo -e "${NONE}"
