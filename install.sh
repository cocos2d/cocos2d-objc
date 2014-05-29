#!/bin/bash
# cocos2d template installer script
# Author: Dominik Hadl (based on original script made by Stuart Carnie and Ricardo Quesada)
# Date: November 2013
# Description: This script installs cocos2d project templates to the Xcode templates directory, so they can be used within Xcode.
# TODO: 
# * Create an error log, if there were any errors during installation
# * Better handle errors on rsync
# * Add more colors... Yay!
# -------------------------------------------------------------------------------------------------------------------------------

# ----------------------------------------------------
# Variables setup
# ----------------------------------------------------
SCRIPT_VER="v0.9.5"
COCOS2D_VER="Cocos2D-v3.0.0"
COCOS2D_DST_DIR="cocos2d v3.x"
SCRIPT_DIR="$(dirname $0)"

BASE_DIR="$HOME/Library/Developer/Xcode/Templates"
TEMPLATE_DIR="$HOME/Library/Developer/Xcode/Templates/$COCOS2D_DST_DIR"
DST_DIR="$TEMPLATE_DIR"
LOG_PATH="/tmp/cocos2d-install"
ERROR_LOG="${LOG_PATH}/error.log"

INSTALL=true
FORCE=false
DELETE=false

COLOREND=$(tput sgr0)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)	
UNDER=$(tput smul)
BOLD=$(tput bold)

# ----------------------------------------------------
# Header and usage
# ----------------------------------------------------
header()
{
	echo ""
	echo "${UNDER}${BOLD}Cocos2D Template Installer (${COCOS2D_VER})${COLOREND}"
	echo ""
}

usage()
{
	echo "usage:	$0 [options]"
	echo ""
	echo "options:"
	echo "${GREEN}--install${COLOREND}     executed by default, installs project templates if not already installed (synonym: ${GREEN}-i${COLOREND})"
	echo "${GREEN}--force${COLOREND}       force re-installation when templates already installed (synonym: ${GREEN}-f${COLOREND})"
	echo "${GREEN}--delete${COLOREND}      deletes already installed templates (synonym: ${GREEN}-d${COLOREND})"
	echo "${GREEN}--help${COLOREND}        shows this help notice (synonym: ${GREEN}-h${COLOREND})"
	echo ""
	echo "This script installs ${COCOS2D_VER} project templates to the Xcode templates directory,"
	echo "so they can be easily used within Xcode without needing to manually add required cocos2d frameworks."
	echo "If you already have template files installed, they will not be overwritten, unless you run this"
	echo "script with --force option, which will automatically delete all previously installed files before installing."
	echo "If you just want to uninstall the templates, then run this script with the --delete option specified."
	echo ""
	echo "Everything installed only to this directory: ${BASE_DIR}."
	echo "The files copied are Xcode templates (.xctemplate) and required libraries (cocos2d, cocos2d-ui, kazmath, CCBReader and Chipmunk)."
	echo "Included are also some basic resources - app icons, launch images and Hello World examples."
	echo ""		
	echo "If this script is behaving unexpectedly, then please send support emails to 'support (at) dynamicdust (dot) com'"
	echo "along with the version number of this script (${RED}${SCRIPT_VER}${COLOREND}). Thank you!"
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
		echo "Error: ${RED}✖︎${COLOREND} Script cannot be executed as root."
		echo "       In order for it to work properly, please execute the script again without 'sudo'."
		echo ""
		echo "If you want to know more about how to use this script execute '$0 --help'."
	elif [[ "$1" -eq "2" ]]; then
		# Script run with too many options.
		echo "Error: ${RED}✖︎${COLOREND} Too many options specified."
		echo "       This script only takes one option (--install, --delete, --force or --help)."
		echo "       Please, execute the script again with only one or less options specified."
		echo ""
		echo "If you want to know more about how to use this script execute '$0 --help'."
	elif [[ "$1" -eq "3" ]]; then
		# Uknown option specified
		echo "Error: ${RED}✖︎${COLOREND} Unknown option specified."
		echo "       This script only takes these options: --install, --delete, --force or --help."
		echo "       Please, execute the script again with or without one of the supported options."
		echo ""
		echo "If you want to know more about how to use this script execute '$0 --help'."
	elif [[ "$1" -eq "4" ]]; then
		# Templates already installed
		echo "Error: ${RED}✖︎${COLOREND} Templates are already installed."
		echo "       If you want to override and re-install the templates, then please execute"
		echo "       this script with the --force option specified."
		echo ""
		echo "If you want to know more about how to use this script execute '$0 --help'."
	elif [[ "$1" -eq "5" ]]; then
		# Nothing to delete
		echo "Error: ${RED}✖︎${COLOREND} Template files not found, nothing to delete."
		echo "       No $COCOS2D_VER template files were found thus cannot be deleted."
		echo ""
		echo "If you want to know more about how to use this script execute '$0 --help'."
	elif [[ "$1" -eq "6" ]]; then
		# Command-line tools not installed
		echo "Error: ${RED}✖︎${COLOREND} Xcode command line tools are not installed."
		echo "       Please, install the command line tools from Xcode or Apple Developer website"
		echo "       an then run this script again. These tools are required for making"
		echo "       fat static library for Chipmnuk."
		echo ""
		echo "If you want to know more about how to use this script execute '$0 --help'."
	elif [[ "$1" -eq "7" ]]; then
		# Something bad happened, error notice
		echo "${UNDER}                                     ${COLOREND}"
		echo ""
		echo "${BOLD}${RED}Installation failed!${COLOREND}"
		echo "Please, send an email containing your error.log on the support email (written in the --help)."
		echo "It would make it easier for us to improve this script and fix the issues immediately."
		echo ""
		echo "Your error log is located at: ${HOME}/Desktop/cocos2d-install.log"
	fi
	echo ""
	if [[ "$1" -ne "7" ]]; then
		exit "$1"
	fi
}

check_status()
{
	if [[ "$?" != "0" ]]; then
		printf " ${RED}✖︎${COLOREND}"
		handle_error 7
		mv -f "${ERROR_LOG}" "${HOME}/Desktop/cocos2d-install.log"
		exit 7		
	fi
}

copy_files()
{
	if [[ ! -d "$2" ]]; then
		mkdir -p "$2"
	fi
    SOURCE_DIR="${SCRIPT_DIR}/${1}"
	rsync -r --exclude=".*" "$SOURCE_DIR" "$2" 1>/dev/null 2>>"${ERROR_LOG}"
	check_status
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
		echo -n "Removing old project template files: $DST_DIR"
		printf " ${GREEN}✔${COLOREND}\n"		
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
		echo -n "Removing old file template files: $HOME/Library/Developer/Xcode/Templates/File Templates/$COCOS2D_DST_DIR"
		rm -rf "$HOME/Library/Developer/Xcode/Templates/File Templates/$COCOS2D_DST_DIR/"
		printf " ${GREEN}✔${COLOREND}\n"
	else
		handle_error 4
	fi
else
	if $DELETE ; then
		handle_error 5
	fi
fi

# Check if command line tools installed
command -v xcodebuild > /dev/null || handle_error 6

if $DELETE ; then
	echo ""
	exit 0;
fi

# ----------------------------------------------------
# Installation
# ----------------------------------------------------
if $INSTALL ; then
	echo ""

	mkdir -p "${LOG_PATH}"

	# Check directories
	if [[ ! -d  "$BASE_DIR" ]]; then
		mkdir -p "$BASE_DIR" 1>/dev/null 2>>"${ERROR_LOG}"
		check_status
	else
		perms=$(find "$HOME/Library/Developer/Xcode/Templates" -name "Templates" -perm 0755 -type d)
		if [[ ! "$perms" =~ "$BASE_DIR" ]]; then
			didPrint=true
			echo "In order to install templates you need access to the Xcode templates folder. Please enter your password if prompted."
			sudo chmod 755 "$BASE_DIR" 1>/dev/null 2>>"${ERROR_LOG}"
			check_status
			echo ""	
		fi
	fi
	
	if [[ ! -d  "$HOME/Library/Developer/Xcode/Templates/File Templates" ]]; then
		mkdir "$HOME/Library/Developer/Xcode/Templates/File Templates" 1>/dev/null 2>>"${ERROR_LOG}"
		check_status
	fi
	
	echo "${BOLD}>>> Installing project templates${COLOREND}"

	# Copy cocos2d files
	echo -n "...copying cocos2d files"
	LIBS_DIR="$DST_DIR/Support/Libraries/lib_cocos2d.xctemplate/Libraries/"
	copy_files "cocos2d" "$LIBS_DIR"
	copy_files "LICENSE_cocos2d.txt" "$LIBS_DIR"
	printf " ${GREEN}✔${COLOREND}\n"

	# Copy cocos2d-ui files
	echo -n "...copying cocos2d-ui files"
	LIBS_DIR="$DST_DIR/Support/Libraries/lib_cocos2d-ui.xctemplate/Libraries/"
	copy_files "cocos2d-ui" "$LIBS_DIR"
	copy_files "LICENSE_cocos2d.txt" "$LIBS_DIR"
	rm -rf "$LIBS_DIR/cocos2d-ui/CCBReader" 1>/dev/null 2>>"${ERROR_LOG}"
	check_status
	printf " ${GREEN}✔${COLOREND}\n"

	if [[ -d "$SCRIPT_DIR/.git" ]]; then
		# If this is a git repo, make sure that the Chipmunk submodule is checked out and current.
		git submodule update --init 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
		check_status
	elif [[ ! -d "$SCRIPT_DIR/external/Chipmunk/src" ]]; then
		# Not a git repo, download Chipmunk files.
		echo -n "...downloading Chipmunk files, please wait"
		DOWNLOAD_DIR="$SCRIPT_DIR/external"
		mkdir -p "$DOWNLOAD_DIR" 1>/dev/null 2>>"${ERROR_LOG}"
		check_status
	
		echo -n "."
		curl -L -# "https://github.com/slembcke/Chipmunk2D/archive/Cocos2D-3.0.zip" -o "$DOWNLOAD_DIR/Chipmunk_tarball.zip" 1>/dev/null 2>>"${ERROR_LOG}"
		check_status
		echo -n "."
		if [[ ! -d "${DOWNLOAD_DIR}/Chipmunk/" ]]; then
			mkdir -p "${DOWNLOAD_DIR}/Chipmunk/" 1>/dev/null 2>>"${ERROR_LOG}"
			check_status
		fi
		echo -n "."
		tar -xf "$DOWNLOAD_DIR/Chipmunk_tarball.zip" -C "${DOWNLOAD_DIR}/Chipmunk/" --strip-components=1 1>>"${ERROR_LOG}" 2>>"${ERROR_LOG}"
		rm "$DOWNLOAD_DIR/Chipmunk_tarball.zip"
		check_status	
		printf " ${GREEN}✔${COLOREND}\n"
	fi
		
	# Copy Chipmunk files
	echo -n "...copying Chipmunk files"
	LIBS_DIR="$DST_DIR/Support/Libraries/lib_chipmunk.xctemplate/Libraries/"
	copy_files "external/Chipmunk/objectivec/include" "$LIBS_DIR/Chipmunk/objectivec"
	copy_files "external/Chipmunk/objectivec/src" "$LIBS_DIR/Chipmunk/objectivec"
	copy_files "external/Chipmunk/include" "$LIBS_DIR/Chipmunk/chipmunk"
	copy_files "external/Chipmunk/src" "$LIBS_DIR/Chipmunk/chipmunk"
	copy_files "LICENSE_Chipmunk.txt" "$LIBS_DIR"
	check_status
	printf " ${GREEN}✔${COLOREND}\n"

	# Copy ObjectAL files
	echo -n "...copying ObjectAL files"
	LIBS_DIR="$DST_DIR/Support/Libraries/lib_objectal.xctemplate/Libraries/"
	copy_files "external/ObjectAL" "$LIBS_DIR"
	printf " ${GREEN}✔${COLOREND}\n"

	# Copy kazmath files
	#echo -n "...copying kazmath files"
	#LIBS_DIR="$DST_DIR/Support/Libraries/lib_kazmath.xctemplate/Libraries/"
	#copy_files "external/kazmath" "$LIBS_DIR"
	#copy_files "LICENSE_Kazmath.txt" "$LIBS_DIR"
	#printf " ${GREEN}✔${COLOREND}\n"	

	# Copy CCBReader files
	echo -n "...copying CCBReader files"
	LIBS_DIR="$DST_DIR/Support/Libraries/lib_ccbreader.xctemplate/Libraries/"
	copy_files "cocos2d-ui/CCBReader" "$LIBS_DIR"
	copy_files "LICENSE_CCBReader.txt" "$LIBS_DIR"
	printf " ${GREEN}✔${COLOREND}\n"	

	# Copy actual template files
	echo -n "...copying Xcode template files"
	copy_files "templates/" "$DST_DIR"
	printf " ${GREEN}✔${COLOREND}\n"

	echo ""
	echo "${BOLD}>>> Installing file templates${COLOREND}"
	echo -n "...copying CCNode file templates"

	if [[ ! -d  "$HOME/Library/Developer/Xcode/Templates/File Templates/$COCOS2D_DST_DIR" ]]; then
		mkdir "$HOME/Library/Developer/Xcode/Templates/File Templates/$COCOS2D_DST_DIR" 1>/dev/null 2>>"${ERROR_LOG}"
		check_status
	fi

	DST_DIR="$HOME/Library/Developer/Xcode/Templates/File Templates/$COCOS2D_DST_DIR"
	OLD_DIR="$HOME/Library/Developer/Xcode/Templates/$COCOS2D_DST_DIR/"

	mv -f "$OLD_DIR/CCNode class.xctemplate" "$DST_DIR/CCNode class.xctemplate" 1>/dev/null 2>>"${ERROR_LOG}"
	check_status
	printf " ${GREEN}✔${COLOREND}\n\n"
	echo "${UNDER}                                     ${COLOREND}"
	echo ""
	echo "${BOLD}Templates installed successfully.${COLOREND}"
	echo "${BOLD}Have fun!${COLOREND}"
	echo ""
	
	rm -rf "${LOG_PATH}" 1>/dev/null 2>/dev/null
fi
