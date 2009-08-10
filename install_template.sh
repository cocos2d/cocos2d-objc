#!/bin/sh

echo 'cocos2d-iphone template installer'

DST_DIR='/Developer/Platforms/iPhoneOS.platform/Developer/Library/Xcode/Project Templates/Application/cocos2d-0.8.1-beta Application/'

#rm -rf $DST_DIR

if [[ -d $DST_DIR ]];  then
    echo "template alredy installed"
    exit 1
fi

echo ...creating destination directory: $DST_DIR
mkdir "$DST_DIR"
echo ...copying template files
cp -R cocos2d-iphone-template/ "$DST_DIR"
echo ...copying cocos2d files
cp -R cocos2d "$DST_DIR"
echo ...copying CocosDenshion files
cp -R CocosDenshion "$DST_DIR"
echo ...copying cocoslive files
cp -R cocoslive "$DST_DIR"
echo ...copying cocoslive dependency files
cp -R external/TouchJSON "$DST_DIR"
echo done!
