#!/bin/sh

#
# How to use it:
#
# To install the templates in the default Xcode directory (/Developer/)
#   ./install_tempalte.sh
#
#
# to install the templates in the a custom Xcode directory. eg: /DeveloperBeta
#  ./install_tempalte.sh /DeveloperBeta
#
#
echo 'cocos2d-iphone template installer'

if [[ $# == 1 ]]; then
    TPL_DIR=$1'/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Project Templates/Application/'
else
    TPL_DIR='/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Project Templates/Application/'
fi

DST_DIR="$TPL_DIR"'cocos2d-0.99.2-pre Application/'
LIBS_DIR="$DST_DIR"libs

echo 'Installing cocos2d template'
echo '---------------------------'
echo 'Template dir: '$TPL_DIR
echo ''

#rm -rf $DST_DIR

if [[ -d $DST_DIR ]];  then
    echo "template alredy installed"
    exit 1
fi

echo ...creating destination directory: $DST_DIR
mkdir -p "$DST_DIR"

echo ...copying template files
cp -R templates/cocos2d_app/ "$DST_DIR"

echo ...copying cocos2d files
cp -R cocos2d "$LIBS_DIR"

echo ...copying cocos2d dependency files
cp -R external/FontLabel "$LIBS_DIR"

echo ...copying CocosDenshion files
cp -R CocosDenshion "$LIBS_DIR"

echo ...copying cocoslive files
cp -R cocoslive "$LIBS_DIR"

echo ...copying cocoslive dependency files
cp -R external/TouchJSON "$LIBS_DIR"

echo done!

echo ''
echo ''
echo ''
echo 'Installing cocos2d + box2d template'
echo '-----------------------------------'
echo ''

DST_DIR="$TPL_DIR"'cocos2d-0.99.2-pre Box2d Application/'
LIBS_DIR="$DST_DIR"libs

if [[ -d $DST_DIR ]];  then
    echo "template alredy installed"
    exit 1
fi

echo ...creating destination directory: $DST_DIR
mkdir -p "$DST_DIR"

echo ...copying template files
cp -R templates/cocos2d_box2d_app/ "$DST_DIR"

echo ...copying cocos2d files
cp -R cocos2d "$LIBS_DIR"

echo ...copying cocos2d dependency files
cp -R external/FontLabel "$LIBS_DIR"

echo ...copying CocosDenshion files
cp -R CocosDenshion "$LIBS_DIR"

echo ...copying cocoslive files
cp -R cocoslive "$LIBS_DIR"

echo ...copying cocoslive dependency files
cp -R external/TouchJSON "$LIBS_DIR"

echo ...copying Box2D files
cp -R external/Box2d/Box2D "$LIBS_DIR"

echo done!


echo ''
echo ''
echo ''
echo 'Installing cocos2d + chipmunk template'
echo '--------------------------------------'
echo ''

DST_DIR="$TPL_DIR"'cocos2d-0.99.2-pre Chipmunk Application/'
LIBS_DIR="$DST_DIR"libs

if [[ -d $DST_DIR ]];  then
    echo "template alredy installed"
    exit 1
fi

echo ...creating destination directory: $DST_DIR
mkdir -p "$DST_DIR"

echo ...copying template files
cp -R templates/cocos2d_chipmunk_app/ "$DST_DIR"

echo ...copying cocos2d files
cp -R cocos2d "$LIBS_DIR"

echo ...copying cocos2d dependency files
cp -R external/FontLabel "$LIBS_DIR"

echo ...copying CocosDenshion files
cp -R CocosDenshion "$LIBS_DIR"

echo ...copying cocoslive files
cp -R cocoslive "$LIBS_DIR"

echo ...copying cocoslive dependency files
cp -R external/TouchJSON "$LIBS_DIR"

echo ...copying Chipmunk files
cp -R external/Chipmunk "$LIBS_DIR"

echo done!
