#!/bin/bash

echo 'cocos2d-iphone template installer'

COCOS2D_VER='cocos2d 2.1-beta'
SCRIPT_DIR=$(dirname $0)

COCOS2D_DST_DIR='cocos2d v2.x'

force=

usage(){
cat << EOF
usage: $0 [options]
 
Install / update templates for ${COCOS2D_VER}
 
OPTIONS:
   -f	force overwrite if directories exist
   -h	this help
EOF
}

while getopts "fhu" OPTION; do
	case "$OPTION" in
		f)
			force=1
			;;
		h)
			usage
			exit 0
			;;
		u)
			;;
	esac
done

# Make sure root is not executed
if [[ "$(id -u)" == "0" ]]; then
	echo ""
	echo "Error: Do not run this script as root." 1>&2
	echo ""
	echo "'root' is no longer supported" 1>&2
	echo ""
	echo "RECOMMENDED WAY:" 1>&2
	echo " $0 -f" 1>&2
	echo ""
exit 1
fi


copy_files(){
    SRC_DIR="${SCRIPT_DIR}/${1}"
	rsync -r --exclude=.svn "$SRC_DIR" "$2"
}

check_dst_dir(){
	if [[ -d $DST_DIR ]];  then
		if [[ $force ]]; then
			echo "removing old libraries: ${DST_DIR}"
			rm -rf "$DST_DIR"
		else
			echo "templates already installed. To force a re-install use the '-f' parameter"
			exit 1
		fi
	fi
	
	echo ...creating destination directory: $DST_DIR
	mkdir -p "$DST_DIR"
}

copy_cocos2d_files(){
	echo ...copying cocos2d files
	copy_files cocos2d "$LIBS_DIR"
	copy_files LICENSE_cocos2d.txt "$LIBS_DIR"
}

copy_cocosdenshion_files(){
	echo ...copying CocosDenshion files
	copy_files CocosDenshion/CocosDenshion "$LIBS_DIR"
	copy_files LICENSE_CocosDenshion.txt "$LIBS_DIR"
}

copy_cocosdenshionextras_files(){
	echo ...copying CocosDenshionExtras files
	copy_files CocosDenshion/CocosDenshionExtras "$LIBS_DIR"
}

copy_kazmath_files(){
	echo ...copying Kazmath files
	copy_files external/kazmath "$LIBS_DIR"
	copy_files LICENSE_Kazmath.txt "$LIBS_DIR"
}

copy_box2d_files(){
	echo ...copying Box2d files
	copy_files external/Box2d/Box2D "$LIBS_DIR"
	copy_files LICENSE_Box2D.txt "$LIBS_DIR"
}

copy_chipmunk_files(){
	echo ...copying Chipmunk files
	copy_files external/Chipmunk/src "$LIBS_DIR"/Chipmunk
	copy_files external/Chipmunk/include "$LIBS_DIR"/Chipmunk
	copy_files LICENSE_Chipmunk.txt "$LIBS_DIR"
}

copy_ccbreader_files(){
	echo ...copying CocosBuilderReader files
	copy_files external/CocosBuilderReader "$LIBS_DIR"
	copy_files LICENSE_CCBReader.txt "$LIBS_DIR"
}

copy_spidermonkey_files(){
	echo ...copying SpiderMonkey files

	LIBS_DIR="$DST_DIR""lib_spidermonkey_ios.xctemplate/libs/SpiderMonkey/"
	mkdir -p "$LIBS_DIR"
	copy_files external/SpiderMonkey/ios "$LIBS_DIR"
	copy_files LICENSE_SpiderMonkey.txt "$LIBS_DIR"

	LIBS_DIR="$DST_DIR""lib_spidermonkey_osx.xctemplate/libs/SpiderMonkey/"
	mkdir -p "$LIBS_DIR"
	copy_files external/SpiderMonkey/osx "$LIBS_DIR"
	copy_files LICENSE_SpiderMonkey.txt "$LIBS_DIR"
}

copy_jsbindings_files(){
	echo ...copying JSBindings files
	copy_files external/jsbindings "$LIBS_DIR"
	copy_files LICENSE_jsbindings.txt "$LIBS_DIR"
}

copy_jrswizzle_files(){
	echo ...copying JR Swizzle files
	copy_files external/JRSwizzle "$LIBS_DIR"
	copy_files LICENSE_JRSwizzle.txt "$LIBS_DIR"
}


print_template_banner(){
	echo ''
	echo ''
	echo ''
	echo "$1"
	echo '----------------------------------------------------'
	echo ''
}

# Xcode4 templates
copy_xcode4_project_templates(){
	TEMPLATE_DIR="$HOME/Library/Developer/Xcode/Templates/$COCOS2D_DST_DIR/"

	print_template_banner "Installing cocos2d templates"

	DST_DIR="$TEMPLATE_DIR"
    check_dst_dir

	LIBS_DIR="$DST_DIR""lib_cocos2d.xctemplate/libs/"
	mkdir -p "$LIBS_DIR"
	copy_cocos2d_files


	LIBS_DIR="$DST_DIR""lib_cocosdenshion.xctemplate/libs/"
	mkdir -p "$LIBS_DIR"
	copy_cocosdenshion_files

	LIBS_DIR="$DST_DIR""lib_cocosdenshionextras.xctemplate/libs/"
	mkdir -p "$LIBS_DIR"
	copy_cocosdenshionextras_files

	LIBS_DIR="$DST_DIR""lib_kazmath.xctemplate/libs/"
	mkdir -p "$LIBS_DIR"
	copy_kazmath_files

	echo ...copying template files
	copy_files templates/Xcode4_templates/ "$DST_DIR"

	echo done!


	print_template_banner "Installing Physics Engines templates"
	LIBS_DIR="$DST_DIR""lib_box2d.xctemplate/libs/"
	mkdir -p "$LIBS_DIR"
	copy_box2d_files

	LIBS_DIR="$DST_DIR""lib_chipmunk.xctemplate/libs/"
    mkdir -p "$LIBS_DIR"
	copy_chipmunk_files

	echo done!


	print_template_banner "Installing JS Bindings templates"
	LIBS_DIR="$DST_DIR""lib_jsbindings.xctemplate/libs/"
	mkdir -p "$LIBS_DIR"
	copy_jsbindings_files

	copy_spidermonkey_files

	LIBS_DIR="$DST_DIR""lib_jrswizzle.xctemplate/libs/"
	mkdir -p "$LIBS_DIR"
	copy_jrswizzle_files

	LIBS_DIR="$DST_DIR""lib_ccbreader.xctemplate/libs/"
	mkdir -p "$LIBS_DIR"
	copy_ccbreader_files

    echo done!


	# Move File Templates to correct position
	DST_DIR="$HOME/Library/Developer/Xcode/Templates/File Templates/$COCOS2D_DST_DIR/"
	OLD_DIR="$HOME/Library/Developer/Xcode/Templates/$COCOS2D_DST_DIR/"
	
	print_template_banner "Installing CCNode file templates..."

	check_dst_dir
	
	mv -f "$OLD_DIR""/CCNode class.xctemplate" "$DST_DIR"
	
	echo done!
}

# copy Xcode4 templates
copy_xcode4_project_templates

