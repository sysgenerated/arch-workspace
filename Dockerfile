# Install archlinux base image
FROM archlinux

# Set up conda environment variables
ENV \
    RESOURCES_PATH="/resources" \
    WORKSPACE_HOME="/workspace"

# Make folders
RUN \
    mkdir $RESOURCES_PATH && chmod a+rwx $RESOURCES_PATH && \
    mkdir $WORKSPACE_HOME && chmod a+rwx $WORKSPACE_HOME

# Copy layer cleanup script
COPY resources/scripts/clean-layer.sh  /usr/bin/clean-layer.sh

# Update base system then install wget and git
RUN \
    yes | pacman -Syu && \
    yes | pacman -S wget && \
    yes | pacman -S git

# Install base-devel packages
RUN pacman -S base-devel --noconfirm

# Install requirements for Visual Studio Code
RUN \
    yes | pacman -S libxkbfile && \
    yes | pacman -S gtk3 && \
    yes | pacman -S nss && \
    yes | pacman -S libnotify && \
    yes | pacman -S libxss && \
    yes | pacman -S lsof && \
    yes | pacman -S shared-mime-info && \
    yes | pacman -S xdg-utils

# Install Visual Studio Code
COPY resources/tools/vs-code-desktop.sh $RESOURCES_PATH/tools/vs-code-desktop.sh
RUN \
    # If minimal flavor - do not install
    if [ "$WORKSPACE_FLAVOR" = "minimal" ]; then \
        exit 0 ; \
    fi && \
    /bin/bash $RESOURCES_PATH/tools/vs-code-desktop.sh --install && \
    # Cleanup
    clean-layer.sh

# Install Visual Studio Code Server: https://github.com/codercom/code-server
COPY resources/tools/vs-code-server.sh $RESOURCES_PATH/tools/vs-code-server.sh
RUN \
    /bin/bash $RESOURCES_PATH/tools/vs-code-server.sh --install && \
    # Cleanup
    clean-layer.sh
