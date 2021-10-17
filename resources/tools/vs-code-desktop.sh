#!/bin/sh

# Stops script execution if a command has an error
set -e

INSTALL_ONLY=0
# Loop through arguments and process them: https://pretzelhands.com/posts/command-line-flags
for arg in "$@"; do
    case $arg in
        -i|--install) INSTALL_ONLY=1 ; shift ;;
        *) break ;;
    esac
done

if [ ! -f "/opt/visual-studio-code" ]; then
    echo "Installing VS Code. Please wait..."
    cd $RESOURCES_PATH
    # Tmp fix to run vs code without no-sandbox: https://github.com/microsoft/vscode/issues/126027
    git clone https://aur.archlinux.org/visual-studio-code-bin.git
    chmod a+rwx $RESOURCES_PATH/visual-studio-code-bin
    cd $RESOURCES_PATH/visual-studio-code-bin
    useradd --no-create-home --shell=/bin/bash build
    usermod -a -G wheel build
    su - build -c 'makepkg -s'
    userdel -r build
    pacman -U *.pkg.tar.zst --noconfirm
    rm -fr $RESOURCES_PATH/visual-studio-code-bin
else
    echo "VS Code is already installed"
fi

# Run
if [ $INSTALL_ONLY = 0 ] ; then
    echo "Starting VS Code"
    /usr/share/code/code --no-sandbox --unity-launch $WORKSPACE_HOME
    sleep 10
fi
