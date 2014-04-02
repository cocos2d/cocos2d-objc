#!/bin/bash
# ----------------------------------------------------
# Variables setup
# ----------------------------------------------------
BUILD_TOOL=/usr/local/bin/platypus
INSTALL_TARGET_APP="Cocos2D Installer 3.0.0.app"
INSTALL_FILE_TARGET=install.tar.gz

# Fun
COLOREND=$(tput sgr0)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)	
UNDER=$(tput smul)
BOLD=$(tput bold)

# Check Platypus CLI Tools Installed
echo "${BOLD}>>> Checking for Platypus installer tools. ${COLOREND}"
if [ -z `command -v $BUILD_TOOL` ]; then
	echo "${BOLD}>>> Please install Platypus CLI tools. See http://sveinbjorn.org/platypus_installer for more information. ${COLOREND}"
	exit 0;
fi

# Tar / Gzip Cocos2D Repositry
echo "${BOLD}>>> Creating Cocos2D Archive. ${COLOREND}"
tar -C ../. --exclude='.git' --exclude='installer' --exclude='build' --exclude='DerivedData' --exclude='api-docs' -zcf install.tar.gz .

# Create Installer
echo "${BOLD}>>> Building $INSTALL_TARGET_APP Installer Application. ${COLOREND}"
$BUILD_TOOL -P install.platypus -y "$INSTALL_TARGET_APP"

echo "${BOLD}>>> Build Complete. ${COLOREND}"
du -h -d=1 "$INSTALL_TARGET_APP"

#Clean Up
rm -f $INSTALL_FILE_TARGET
