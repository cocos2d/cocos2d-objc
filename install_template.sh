#!/bin/sh

echo 'cocos2d-iphone template installer'

DST_DIR='/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Project Templates/Application/cocos2d-0.8.2-beta Application/'
LIBS_DIR="$DST_DIR"libs

#rm -rf $DST_DIR

if [[ -d $DST_DIR ]];  then
    echo "template alredy installed"
    exit 1
fi

echo ...creating destination directory: $DST_DIR
mkdir -p "$DST_DIR"

echo ...copying template files
cp -R cocos2d-iphone-template/ "$DST_DIR"

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
