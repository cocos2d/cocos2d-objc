#!/bin/sh
#
# run this script from the cocosBuilderReader directory. eg:
# cd ~/src/cocos2d-iphone/externals/CocosBuilderReader/
#
gen_bridge_metadata -F complete --no-64-bit -c '-DNDEBUG -I. -I../../cocos2d/.' *.h ../../cocos2d/CCScene.h -o ../../tools/js/CocosBuilderReader.bridgesupport
