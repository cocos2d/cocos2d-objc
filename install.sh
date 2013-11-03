#!/bin/bash
# cocos2d template installer script
# Author: Dominik Hadl (based on original v2.1 script made by Stuart Carnie and Ricardo Quesada)
# Date: November 2013
# Description: This script installs cocos2d project templates to the Xcode templates directory, so they can be used within Xcode.
# -------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------
# Variables setup
# ----------------------------------------------------
COCOS2D_VER="cocos2d-v3.0"
COCOS2D_DST_DIR="cocos2d v3.x"
SCRIPT_DIR="$(dirname $0)"

TEMPLATE_DIR="$HOME/Library/Developer/Xcode/Templates/$COCOS2D_DST_DIR"
DST_DIR="$TEMPLATE_DIR"

FORCE=false
DELETE=false

# ----------------------------------------------------
# Header and usage
# ----------------------------------------------------
header()
{
	echo ""
	echo "${COCOS2D_VER} template installer, November 2013, by Lars Birkemose, Dominik Hadl and cocos2d community."
	echo "------------------------------------------------------------------------------------------------------"
}

usage()
{
	header
	echo ""
	echo "usage:	$0 [options]"
	echo ""
	echo "options:"
	echo "--force       force re-installation when templates already installed (synonym: -f)"
	echo "--delete      deletes already installed templates (synonym: -d)"
	echo "--help        shows this help notice (synonym: -h)"
	echo ""
	echo "This script installs ${COCOS2D_VER} project templates to the Xcode templates directory,"
	echo "so they can be easily used within Xcode without needing to manually add required cocos2d frameworks."
	echo "If you already have template files installed, they won't by default be overwritten. You have to run this"
	echo "script with --force option if you want to overwrite templates that are already installed. It will automatically"
	echo "delete all previously installed files and install new ones."
	echo ""
	exit 0
}

# ----------------------------------------------------
# Helper functions
# ----------------------------------------------------
handle_error()
{
	if [[ "$1" -eq "1" ]]; then
		# Script executed as root.
		echo "TODO: Add correct text..."
		echo "Error: Do not run this script as root."
		echo "       If you want to know more about how to use this script execute '$0 --help'."
		echo ""
	elif [[ "$1" -eq "2" ]]; then
		# Script run with too many arguments.
		echo "TODO: Add correct text..."
		echo "Too many arguments"
	elif [[ "$1" -eq "3" ]]; then
		# Templates already installed
		echo "TODO: Add correct text..."
		echo "Unknown argument specified"
	elif [[ "$1" -eq "4" ]]; then
		# Templates already installed
		echo "TODO: Add correct text..."
		echo "Templates already installed"
	elif [[ "$1" -eq "5" ]]; then
		# Nothing to delete
		echo "TODO: Add correct text..."
		echo "Nothing to delete"
	fi
	echo ""
	exit "$1"
}

copy_files()
{
	if [[ ! -d "$2" ]]; then
		mkdir -p "$2"
	fi
    SOURCE_DIR="${SCRIPT_DIR}/${1}"
	rsync -r --exclude=".*" "$SOURCE_DIR" "$2"
}

# ----------------------------------------------------
# Basic checks
# ----------------------------------------------------

# Check for root exectuion
if [[ "$(id -u)" == "0" ]]; then
	handle_error 1
fi

# Check for number of arguments
if [[ "$#" > "1" ]]; then
	handle_error 2
fi

# Check for arguments
if [[ "${1}" = "--help" ]] || [[ "${1}" = "-h" ]]; then
	usage
elif [[ "${1}" = "--force" ]] || [[ "${1}" = "-f" ]]; then
	FORCE=true
elif [[ "${1}" = "--delete" ]] || [[ "${1}" = "-d" ]]; then
	DELETE=true
elif [[ "$#" -eq "1" ]]; then
	handle_error 3
fi

# Print header
header

# Check if templates installed
if [[ -d $DST_DIR ]]; then
	if $FORCE || $DELETE ; then
		echo "Removing old project template files: $DST_DIR"
		rm -rf "$DST_DIR"
	else
		handle_error 4
	fi
else
	if $DELETE ; then
		handle_error 5
	fi
fi

if [[ -d "$HOME/Library/Developer/Xcode/Templates/File Templates/$COCOS2D_DST_DIR/" ]]; then
	if $FORCE || $DELETE ; then
		echo "Removing old file template files: $DST_DIR"
		rm -rf "$HOME/Library/Developer/Xcode/Templates/File Templates/$COCOS2D_DST_DIR/"
	else
		handle_error 4
	fi
else
	if $DELETE ; then
		handle_error 5
	fi
fi

if $DELETE ; then
	echo ""
	exit 0;
fi

# ----------------------------------------------------
# Installation
# ----------------------------------------------------

echo ""
echo ">>> Installing project templates"

# Copy cocos2d files
echo "...copying cocos2d files"
LIBS_DIR="$DST_DIR/lib_cocos2d.xctemplate/Libraries/"
copy_files "cocos2d" "$LIBS_DIR"
copy_files "LICENSE_cocos2d.txt" "$LIBS_DIR"

# Download Chipmunk files
echo "...downloading Chipmunk files, please wait"
if [[ ! -d "$SCRIPT_DIR/.git" ]]; then
	echo "	...downloading zip file"
	if [[ -d "$SCRIPT_DIR/external/Chipmunk/" ]]; then
		rm -rf "$SCRIPT_DIR/external/Chipmunk/"
	fi
	DOWNLOAD_DIR="$SCRIPT_DIR/external/Chipmunk_download"
	
	mkdir -p "$SCRIPT_DIR/external/Chipmunk/"
	mkdir -p "$DOWNLOAD_DIR"
	
	curl -L -# "https://github.com/slembcke/Chipmunk2D/archive/a51044feb5d2aa227941c2faa91271a312928ef3.zip" -o "$DOWNLOAD_DIR/Chipmunk_tarball.zip"
	tar -xf "$DOWNLOAD_DIR/Chipmunk_tarball.zip" -C "$SCRIPT_DIR/external/Chipmunk/" --strip-components=1
	rm -rf "$DOWNLOAD_DIR"
else
	git submodule init "$SCRIPT_DIR/external/Chipmunk" 1>/dev/null 2>/dev/null
	git submodule update "$SCRIPT_DIR/external/Chipmunk" 1>/dev/null 2>/dev/null
fi

# Copy Chipmunk files
echo "...copying Chipmunk files"
LIBS_DIR="$DST_DIR/lib_chipmunk.xctemplate/Libraries/"
copy_files "external/Chipmunk/objectivec" "$LIBS_DIR"
copy_files "external/Chipmunk/include" "$LIBS_DIR/Chipmunk/chipmunk"
copy_files "external/Chipmunk/src" "$LIBS_DIR/Chipmunk/chipmunk"
copy_files "external/Chipmunk/LICENSE.txt" "$LIBS_DIR"
mv -f "$LIBS_DIR/objectivec" "$LIBS_DIR/Chipmunk"
mv -f "$LIBS_DIR/LICENSE.txt" "$LIBS_DIR/LICENSE_Chipmunk.txt"

# Copy CocosDenshion files
echo "...copying CocosDenshion files"
LIBS_DIR="$DST_DIR/lib_cocosdenshion.xctemplate/Libraries/"
copy_files "CocosDenshion" "$LIBS_DIR"
copy_files "LICENSE_CocosDenshion.txt" "$LIBS_DIR"

# Copy kazmath files
echo "...copying kazmath files"
LIBS_DIR="$DST_DIR/lib_kazmath.xctemplate/Libraries/"
copy_files "external/kazmath" "$LIBS_DIR"
copy_files "LICENSE_Kazmath.txt" "$LIBS_DIR"

# Copy CCBReader files
echo "...copying CCBReader files"
LIBS_DIR="$DST_DIR/lib_ccbreader.xctemplate/Libraries/"
copy_files "cocos2d-ui/CCBReader" "$LIBS_DIR"
copy_files "LICENSE_CCBReader.txt" "$LIBS_DIR"

# Copy actual template files
echo "...copying Xcode template files"
copy_files "templates/" "$DST_DIR"

echo ""
echo ">>> Installing file templates"
echo "...copying CCNode file templates"
echo ""

if [[ ! -d  "$HOME/Library/Developer/Xcode/Templates/File Templates/" ]]; then
	mkdir - "$HOME/Library/Developer/Xcode/Templates/File Templates/"
fi

DST_DIR="$HOME/Library/Developer/Xcode/Templates/File Templates/$COCOS2D_DST_DIR/"
OLD_DIR="$HOME/Library/Developer/Xcode/Templates/$COCOS2D_DST_DIR/"

mv -f "$OLD_DIR""/CCNode class.xctemplate" "$DST_DIR"

echo "-----------------------"
echo "Everything installed successfully."
echo "Have fun!"
echo ""