#!/bin/sh
#
# run this script from the CocosDenshion directory. eg:
# cd ~/src/cocos2d-iphone/CocosDenshion/CocosDenshion
#
gen_bridge_metadata -F complete --no-64-bit -c '-DNDEBUG -I.' *.h -o ../../tools/js/CocosDenshion.bridgesupport
