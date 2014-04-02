#!/bin/bash
# ----------------------------------------------------
# Variables setup
# ----------------------------------------------------
COCOS2D_VER="Cocos2D-v3.0.0"
TARGET_DIR="$HOME/Downloads/${COCOS2D_VER}"
INSTALL_FILE=install.tar.gz

# Fun
COLOREND=$(tput sgr0)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)	
UNDER=$(tput smul)
BOLD=$(tput bold)

# Extract to Target Directory
echo "${BOLD}>>> Installing ${COCOS2D_VER} files ${COLOREND}"
mkdir -p $TARGET_DIR && tar zxf $INSTALL_FILE -C $TARGET_DIR

# Run cocos2d template installer 
echo "${BOLD}>>> Installing ${COCOS2D_VER} templates ${COLOREND}"
sudo -u $USER $TARGET_DIR/install.sh -f

# Build/Install Appledoc
echo "${BOLD}>>> Building/Installing ${COCOS2D_VER} documentation, this may take a minute.... ${COLOREND}"
cd $TARGET_DIR
./tools/build_docs.sh

# Finished
echo "${BOLD}>>> ${COCOS2D_VER} installation complete! ${COLOREND}"

# Clean up
rm -fr $TARGET_DIR

# Landing Page, @todo Needs a nice welcome page
open http://www.cocos2d-iphone.org/getting-started/
