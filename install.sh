#!/bin/bash
# cocos2d template installer script
# Author: Dominik Hadl (based on original script made by Stuart Carnie and Ricardo Quesada)
# Date: November 2013
# Description: This script installs cocos2d project templates to the Xcode templates directory, so they can be used within Xcode.
# -------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------
# Variables setup
# ----------------------------------------------------
SCRIPT_VER="v0.9.1"
COCOS2D_VER="cocos2d-v3.0"
COCOS2D_DST_DIR="cocos2d v3.x"
SCRIPT_DIR="$(dirname $0)"

BASE_DIR="$HOME/Library/Developer/Xcode/Templates"
TEMPLATE_DIR="$HOME/Library/Developer/Xcode/Templates/$COCOS2D_DST_DIR"
DST_DIR="$TEMPLATE_DIR"

INSTALL=true
FORCE=false
DELETE=false

# ----------------------------------------------------
# Header and usage
# ----------------------------------------------------
header()
{
	echo ""
	echo "cocos2d template installer (${SCRIPT_VER}, November 2013) by Dominik Hadl and Lars Birkemose"
	echo "-------------------------------------------------------------------------------------"
}

usage()
{
	header
	echo ""
	echo "usage:	$0 [options]"
	echo ""
	echo "options:"
	echo "--install     executed by default, installs project templates if not already installed (synonym: -i)"
	echo "--force       force re-installation when templates already installed (synonym: -f)"
	echo "--delete      deletes already installed templates (synonym: -d)"
	echo "--help        shows this help notice (synonym: -h)"
	echo ""
	echo "This script installs ${COCOS2D_VER} project templates to the Xcode templates directory,"
	echo "so they can be easily used within Xcode without needing to manually add required cocos2d frameworks."
	echo "If you already have template files installed, they will not be overwritten, unless you run this"
	echo "script with --force option, which will automatically delete all previously installed files before installing."
	echo "If you just want to uninstall the templates, then run this script with the --delete option specified."
	echo ""
	echo "If this script is behaving unexpectedly, then please send support emails to 'support (at) dynamicdust (dot) com'"
	echo "along with the version number of this script (${SCRIPT_VER}). Thank you!"
	echo ""
	exit 0
}

# ----------------------------------------------------
# Helper functions
# ----------------------------------------------------
handle_error()
{
	echo ""	
	if [[ "$1" -eq "1" ]]; then
		# Script executed as root.
		echo "Error: Script cannot be executed as root."
		echo "       In order for it to work properly, please execute the script again without 'sudo'."
		echo ""
		echo "If you want to know more about how to use this script execute '$0 --help'."
	elif [[ "$1" -eq "2" ]]; then
		# Script run with too many options.
		echo "Error: Too many options specified."
		echo "       This script only takes one option (--install, --delete, --force or --help)."
		echo "       Please, execute the script again with only one or less options specified."
		echo ""
		echo "If you want to know more about how to use this script execute '$0 --help'."
	elif [[ "$1" -eq "3" ]]; then
		# Uknown option specified
		echo "Error: Unknown option specified."
		echo "       This script only takes these options: --install, --delete, --force or --help."
		echo "       Please, execute the script again with or without one of the supported options."
		echo ""
		echo "If you want to know more about how to use this script execute '$0 --help'."
	elif [[ "$1" -eq "4" ]]; then
		# Templates already installed
		echo "Error: Templates are already installed."
		echo "       If you want to override and re-install the templates, then please execute"
		echo "       this script with the --force option specified."
		echo ""
		echo "If you want to know more about how to use this script execute '$0 --help'."
	elif [[ "$1" -eq "5" ]]; then
		# Nothing to delete
		echo "Error: Template files not found, nothing to delete."
		echo "       No $COCOS2D_VER template files were found thus cannot be deleted."
		echo ""
		echo "If you want to know more about how to use this script execute '$0 --help'."
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

# Print header
header

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
if [[ "${1}" = "--install" ]] || [[ "${1}" = "-i" ]]; then
	INSTALL=true
elif [[ "${1}" = "--force" ]] || [[ "${1}" = "-f" ]]; then
	FORCE=true
	INSTALL=true
elif [[ "${1}" = "--delete" ]] || [[ "${1}" = "-d" ]]; then
	DELETE=true
	INSTALL=false
elif [[ "${1}" = "--help" ]] || [[ "${1}" = "-h" ]]; then
	usage
elif [[ "$#" -eq "1" ]]; then
	handle_error 3
fi

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
		echo "Removing old file template files: $HOME/Library/Developer/Xcode/Templates/File Templates/$COCOS2D_DST_DIR"
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
if $INSTALL ; then
	echo ""

	if [[ ! -d  "$BASE_DIR" ]]; then
		mkdir -p "$BASE_DIR"
	else
		perms=$(find "$HOME/Library/Developer/Xcode/Templates" -name "Templates" -perm 0755 -type d)
		if [[ ! "$perms" =~ "$BASE_DIR" ]]; then
			echo "In order to install templates you need access to the Xcode templates folder. Please enter your password if prompted."
			sudo chmod 755 "$BASE_DIR"
			echo ""	
		fi
	fi
	
	echo ">>> Installing project templates"

	# Copy cocos2d files
	echo "...copying cocos2d files"
	LIBS_DIR="$DST_DIR/Support/Libraries/lib_cocos2d.xctemplate/Libraries/"
	copy_files "cocos2d" "$LIBS_DIR"
	copy_files "LICENSE_cocos2d.txt" "$LIBS_DIR"

	# Copy cocos2d-ui files
	echo "...copying cocos2d-ui files"
	LIBS_DIR="$DST_DIR/Support/Libraries/lib_cocos2d-ui.xctemplate/Libraries/"
	copy_files "cocos2d-ui" "$LIBS_DIR"
	copy_files "LICENSE_cocos2d.txt" "$LIBS_DIR"
	rm -rf "$LIBS_DIR/cocos2d-ui/CCBReader"

	# Download Chipmunk files
	echo "...downloading Chipmunk files, please wait"
	if [[ ! -d "$SCRIPT_DIR/.git" ]]; then
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
		(cd $SCRIPT_DIR && git submodule init "external/Chipmunk") 1>/dev/null 2>/dev/null
		(cd $SCRIPT_DIR && git submodule update "external/Chipmunk") 1>/dev/null 2>/dev/null
	fi
	
	# Building Chipmunk (fat static lib)
	echo "...bulding Chipmunk fat static lib, please wait"
	xcodebuild -project "${SCRIPT_DIR}/external/Chipmunk/xcode/Chipmunk7.xcodeproj" -configuration Release -target ObjectiveChipmunk -sdk iphonesimulator DST_ROOT="$SCRIPT_DIR/external/Chipmunk/xcode/" CONFIGURATION_TEMP_DIR="$SCRIPT_DIR/external/Chipmunk/xcode/build/" 1>/dev/null 2>/dev/null
	xcodebuild -project "${SCRIPT_DIR}/external/Chipmunk/xcode/Chipmunk7.xcodeproj" -configuration Release -target ObjectiveChipmunk -sdk iphoneos DST_ROOT="$SCRIPT_DIR/external/Chipmunk/xcode/" CONFIGURATION_TEMP_DIR="$SCRIPT_DIR/external/Chipmunk/xcode/build/" 1>/dev/null 2>/dev/null
	xcodebuild -project "${SCRIPT_DIR}/external/Chipmunk/xcode/Chipmunk7.xcodeproj" -configuration Release -target ObjectiveChipmunk -sdk macosx DST_ROOT="$SCRIPT_DIR/external/Chipmunk/xcode/" CONFIGURATION_TEMP_DIR="$SCRIPT_DIR/external/Chipmunk/xcode/build/" 1>/dev/null 2>/dev/null
	lipo -create "${SCRIPT_DIR}/external/Chipmunk/xcode/build/Release-iphoneos/libObjectiveChipmunk.a" "${SCRIPT_DIR}/external/Chipmunk/xcode/build/Release-iphonesimulator/libObjectiveChipmunk.a" "${SCRIPT_DIR}/external/Chipmunk/xcode/build/Release/libObjectiveChipmunk.a" -output "$SCRIPT_DIR/external/Chipmunk/xcode/build/libObjectiveChipmunk.a" 1>/dev/null 2>/dev/null

	# Copy Chipmunk files
	echo "...copying Chipmunk files"
	LIBS_DIR="$DST_DIR/Support/Libraries/lib_chipmunk.xctemplate/Libraries/"
	copy_files "external/Chipmunk/objectivec/include" "$LIBS_DIR/Chipmunk/objectivec"
	copy_files "external/Chipmunk/xcode/build/libObjectiveChipmunk.a" "$LIBS_DIR/Chipmunk/objectivec"
	copy_files "external/Chipmunk/include" "$LIBS_DIR/Chipmunk/chipmunk"
	copy_files "external/Chipmunk/src" "$LIBS_DIR/Chipmunk/chipmunk"
	copy_files "external/Chipmunk/LICENSE.txt" "$LIBS_DIR/Chipmunk"
	
	# Clean after Chipmunk
	echo "...cleaning after Chipmunk"
	xcodebuild -project "${SCRIPT_DIR}/external/Chipmunk/xcode/Chipmunk7.xcodeproj" -configuration Release -target ObjectiveChipmunk -sdk iphoneos DST_ROOT="$SCRIPT_DIR/external/Chipmunk/xcode/" clean 1>/dev/null 2>/dev/null
	xcodebuild -project "${SCRIPT_DIR}/external/Chipmunk/xcode/Chipmunk7.xcodeproj" -configuration Release -target ObjectiveChipmunk -sdk iphonesimulator DST_ROOT="$SCRIPT_DIR/external/Chipmunk/xcode/" clean 1>/dev/null 2>/dev/null
	xcodebuild -project "${SCRIPT_DIR}/external/Chipmunk/xcode/Chipmunk7.xcodeproj" -configuration Release -target ObjectiveChipmunk -sdk macosx DST_ROOT="$SCRIPT_DIR/external/Chipmunk/xcode/" clean 1>/dev/null 2>/dev/null	
	rm -rf "$SCRIPT_DIR/external/Chipmunk/xcode/build"

	# DISABLED
	# CocosDenshion isn't ARC, so it does not compile with the rest of library.
	# There is no way right now how to specify compiler flags in Xcode templates,
	# so the only options are: 
	# 1. Convert to ARC 
	# 2. Replace with better audio engine

	# Copy CocosDenshion files
	# echo "...copying CocosDenshion files"
	# LIBS_DIR="$DST_DIR/Support/Libraries/lib_cocosdenshion.xctemplate/Libraries/"
	# copy_files "CocosDenshion" "$LIBS_DIR"
	# copy_files "LICENSE_CocosDenshion.txt" "$LIBS_DIR"

	# Copy kazmath files
	echo "...copying kazmath files"
	LIBS_DIR="$DST_DIR/Support/Libraries/lib_kazmath.xctemplate/Libraries/"
	copy_files "external/kazmath" "$LIBS_DIR"
	copy_files "LICENSE_Kazmath.txt" "$LIBS_DIR"

	# Copy CCBReader files
	echo "...copying CCBReader files"
	LIBS_DIR="$DST_DIR/Support/Libraries/lib_ccbreader.xctemplate/Libraries/"
	copy_files "cocos2d-ui/CCBReader" "$LIBS_DIR"
	copy_files "LICENSE_CCBReader.txt" "$LIBS_DIR"

	# Copy actual template files
	echo "...copying Xcode template files"
	copy_files "templates/" "$DST_DIR"

	echo ""
	echo ">>> Installing file templates"
	echo "...copying CCNode file templates"
	echo ""

	if [[ ! -d  "$HOME/Library/Developer/Xcode/Templates/File Templates" ]]; then
		mkdir "$HOME/Library/Developer/Xcode/Templates/File Templates"
	fi

	if [[ ! -d  "$HOME/Library/Developer/Xcode/Templates/File Templates/$COCOS2D_DST_DIR" ]]; then
		mkdir "$HOME/Library/Developer/Xcode/Templates/File Templates/$COCOS2D_DST_DIR"
	fi

	DST_DIR="$HOME/Library/Developer/Xcode/Templates/File Templates/$COCOS2D_DST_DIR"
	OLD_DIR="$HOME/Library/Developer/Xcode/Templates/$COCOS2D_DST_DIR/"

	mv -f "$OLD_DIR/CCNode class.xctemplate" "$DST_DIR/CCNode class.xctemplate"

	echo "-----------------------"
	echo "Everything installed successfully."
	echo "Have fun!"
	echo ""
fi