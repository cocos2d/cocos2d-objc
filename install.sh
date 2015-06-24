#!/bin/bash
# ----------------------------------------------------
# Cocos2D Installer
# Author: Lars Birkemose (based on original script made by Dominik Hadl, Stuart Carnie and Ricardo Quesada)
# Date: June 2015
# ----------------------------------------------------

VERSION="Cocos2D-ObjC v3.4.x"
TEMPLATE_NAME="cocos2d v3.4"
EXECUTION_FOLDER="$(dirname $0)"

BASE_FOLDER="$HOME/Library/Developer/Xcode/Templates"
TEMPLATE_FOLDER="$HOME/Library/Developer/Xcode/Templates/$TEMPLATE_NAME"
LOG_FOLDER="/tmp/cocos2d-install"
LOG_FILE="${LOG_FOLDER}/error.log"

# ----------------------------------------------------

log_error()
{
	echo ""	
    if [[ "$1" -eq "1" ]]; then
        echo "Invoke the installer with the following options"
        echo "./install.sh -i   to install Cocos2D"
        echo "./install.sh -u   to update Cocos2D"
        echo "./install.sh -d   to delete Cocos2D"
    elif [[ "$1" -eq "2" ]]; then
        echo "Cocos2D is already installed"
        echo "Invoke the installer with option -u, to update Cocos2D"
	elif [[ "$1" -eq "3" ]]; then
		echo "Installer was executes as root"
		echo "To install Cocos2D, run './install.sh -i' from the folder where you downloaded Cocos2D"
	else
		echo "An unknown error occured"
	fi
	echo ""
    echo "Cocos2d exited with an error"
    echo "For details see: $LOG_FILE"
    echo ""

    mv -f "${LOG_FILE}" "${HOME}/Desktop/cocos2d-install.log"

    exit "$1"
}

# ----------------------------------------------------

check_status()
{
	if [[ "$?" != "0" ]]; then
		log_error 99
	fi
}

# ----------------------------------------------------

status_ok()
{
    printf " [Ok]\n"
}

# ----------------------------------------------------

check_folders()
{
    if [[ ! -d  "$BASE_FOLDER" ]]; then
        mkdir -p "$BASE_FOLDER" 1>/dev/null 2>>"${LOG_FILE}"
        check_status
    else
        perms=$(find "$HOME/Library/Developer/Xcode/Templates" -name "Templates" -perm 0755 -type d)
        if [[ ! "$perms" =~ "$BASE_FOLDER" ]]; then
            didPrint=true
            echo "In order to install templates you need access to the Xcode templates folder. Please enter your password if prompted."
            sudo chmod 755 "$BASE_FOLDER" 1>/dev/null 2>>"${LOG_FILE}"
            check_status
            echo ""
        fi
    fi

    if [[ ! -d  "$HOME/Library/Developer/Xcode/Templates/File Templates" ]]; then
        mkdir "$HOME/Library/Developer/Xcode/Templates/File Templates" 1>/dev/null 2>>"${LOG_FILE}"
        check_status
    fi
}

# ----------------------------------------------------

copy_files()
{
	if [[ ! -d "$2" ]]; then
		mkdir -p "$2"
	fi
    SOURCE_DIR="${EXECUTION_FOLDER}/${1}"
	rsync -r --exclude=".*" "$SOURCE_DIR" "$2" 1>/dev/null 2>>"${LOG_FILE}"
	check_status
}

# ----------------------------------------------------

download_chipmunk()
{
    echo -n "Downloading Chipmunk"
    DOWNLOAD_DIR="$EXECUTION_FOLDER/external"
    mkdir -p "$DOWNLOAD_DIR" 1>/dev/null 2>>"${LOG_FILE}"
    check_status

    curl -L -# "https://github.com/slembcke/Chipmunk2D/archive/Cocos2D-3.0.zip" -o "$DOWNLOAD_DIR/chipmunk.zip" 1>/dev/null 2>>"${LOG_FILE}"
    check_status

    if [[ ! -d "${DOWNLOAD_DIR}/Chipmunk/" ]]; then
        mkdir -p "${DOWNLOAD_DIR}/Chipmunk/" 1>/dev/null 2>>"${LOG_FILE}"
        check_status
    fi

    tar -xf "$DOWNLOAD_DIR/chipmunk.zip" -C "${DOWNLOAD_DIR}/Chipmunk/" --strip-components=1 1>>"${LOG_FILE}" 2>>"${LOG_FILE}"
    check_status
    rm "$DOWNLOAD_DIR/chipmunk.zip"
    status_ok
}

# ----------------------------------------------------

download_objectal()
{
    echo -n "Downloading ObjectAL"
    DOWNLOAD_DIR="$EXECUTION_FOLDER/external"
    mkdir -p "$DOWNLOAD_DIR" 1>/dev/null 2>>"${LOG_FILE}"
    check_status

    curl -L -# "http://github.com/kstenerud/ObjectAL-for-iPhone/tarball/v2.2" -o "$DOWNLOAD_DIR/objectal.tar.gz" 1>/dev/null 2>>"${LOG_FILE}"
    check_status

    if [[ ! -d "${DOWNLOAD_DIR}/ObjectAL/" ]]; then
        mkdir -p "${DOWNLOAD_DIR}/ObjectAL/" 1>/dev/null 2>>"${LOG_FILE}"
        check_status
    fi

    tar -xf "$DOWNLOAD_DIR/objectal.tar.gz" -C "${DOWNLOAD_DIR}/ObjectAL/" --strip-components=1 1>>"${LOG_FILE}" 2>>"${LOG_FILE}"
    check_status
    rm "$DOWNLOAD_DIR/objectal.tar.gz"
    status_ok
}

# ----------------------------------------------------

install_cocos2d()
{
    echo -n "Installing Cocos2D Libraries"

    LIBS_DIR="$TEMPLATE_FOLDER/Support/Libraries/cocos2d-base.xctemplate/Libraries/"
    copy_files "cocos2d" "$LIBS_DIR"
    copy_files "LICENSE_cocos2d.txt" "$LIBS_DIR"

    LIBS_DIR="$TEMPLATE_FOLDER/Support/Libraries/cocos2d-effects.xctemplate/Libraries/"
    copy_files "cocos2d" "$LIBS_DIR"

    LIBS_DIR="$TEMPLATE_FOLDER/Support/Libraries/cocos2d-platform.xctemplate/Libraries/"
    copy_files "cocos2d" "$LIBS_DIR"

    LIBS_DIR="$TEMPLATE_FOLDER/Support/Libraries/cocos2d-support.xctemplate/Libraries/"
    copy_files "cocos2d" "$LIBS_DIR"

    LIBS_DIR="$TEMPLATE_FOLDER/Support/Libraries/cocos2d-ui.xctemplate/Libraries/"
    copy_files "cocos2d-ui" "$LIBS_DIR"

    LIBS_DIR="$TEMPLATE_FOLDER/Support/Libraries/cocos2d-ccb.xctemplate/Libraries/"
    copy_files "cocos2d-ui/CCBReader" "$LIBS_DIR"

    check_status
    status_ok
}

# ----------------------------------------------------

install_chipmunk()
{
    echo -n "Installing Chipmunk Libraries"

    LIBS_DIR="$TEMPLATE_FOLDER/Support/Libraries/chipmunk.xctemplate/Libraries/"
    copy_files "external/Chipmunk/objectivec/include" "$LIBS_DIR/Chipmunk/objectivec"
    copy_files "external/Chipmunk/objectivec/src" "$LIBS_DIR/Chipmunk/objectivec"
    copy_files "external/Chipmunk/include" "$LIBS_DIR/Chipmunk/chipmunk"
    copy_files "external/Chipmunk/src" "$LIBS_DIR/Chipmunk/chipmunk"

    check_status
    status_ok
}

# ----------------------------------------------------

install_objectal()
{
    echo -n "Installing ObjectAL Libraries"

    LIBS_DIR="$TEMPLATE_FOLDER/Support/Libraries/objectal.xctemplate/Libraries/ObjectAL"
    copy_files "external/ObjectAL/ObjectAL/ObjectAL (iOS)/" "$LIBS_DIR"

    check_status
    status_ok
}

# ----------------------------------------------------

install_templates()
{
    echo -n "Installing Xcode Templates"

    copy_files "templates/" "$TEMPLATE_FOLDER"
    check_status

    if [[ ! -d  "$HOME/Library/Developer/Xcode/Templates/File Templates/$TEMPLATE_NAME" ]]; then
        mkdir "$HOME/Library/Developer/Xcode/Templates/File Templates/$TEMPLATE_NAME" 1>/dev/null 2>>"${LOG_FILE}"
        check_status
    fi

    TEMPLATE_FOLDER="$HOME/Library/Developer/Xcode/Templates/File Templates/$TEMPLATE_NAME"
    OLD_DIR="$HOME/Library/Developer/Xcode/Templates/$TEMPLATE_NAME/"

    mv -f "$OLD_DIR/CCNode class.xctemplate" "$TEMPLATE_FOLDER/CCNode class.xctemplate" 1>/dev/null 2>>"${LOG_FILE}"

    check_status
    status_ok
}

# ----------------------------------------------------

delete_libraries()
{
    echo -n "Deleting Libraries"
    rm -rf "$TEMPLATE_FOLDER"

    check_status
    status_ok
}

# ----------------------------------------------------

delete_templates()
{
    echo -n "Deleting Templates"
    rm -rf "$HOME/Library/Developer/Xcode/Templates/File Templates/$TEMPLATE_NAME/"

    check_status
    status_ok
}

# ----------------------------------------------------
# Script start
# ----------------------------------------------------

# Header
echo ""
echo "Cocos2D Installer (${VERSION})"
echo "--------------------------------------"
echo ""

# Root exectuion
if [[ "$(id -u)" == "0" ]]; then
	log_error 3
fi

mkdir -p "${LOG_FOLDER}"

# Check for arguments
if [[ "${1}" = "-i" ]]; then

    # ----------------------------------------------------
    # Install
    # ----------------------------------------------------
    if [[ -d $TEMPLATE_FOLDER ]]; then
        log_error 2
    fi

    check_folders

    download_chipmunk
    download_objectal

    install_cocos2d
    install_chipmunk
    install_objectal

    install_templates

    echo ""
    echo "Cocos2D was successfully installed"
    echo ""

elif [[ "${1}" = "-u" ]]; then

    # ----------------------------------------------------
    # Update
    # ----------------------------------------------------

    delete_libraries
    delete_templates

    check_folders

    download_chipmunk
    download_objectal

    install_cocos2d
    install_chipmunk
    install_objectal

    install_templates

    echo ""
    echo "Cocos2D was successfully updated"
    echo ""

elif [[ "${1}" = "-d" ]]; then

    # ----------------------------------------------------
    # Delete
    # ----------------------------------------------------

    delete_libraries
    delete_templates

    echo ""
    echo "Cocos2D was successfully deleted"
    echo ""

else

    # ----------------------------------------------------
    # Unknown
    # ----------------------------------------------------
    log_error 1

fi

rm -rf "${LOG_FOLDER}" 1>/dev/null 2>/dev/null


