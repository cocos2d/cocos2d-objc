#!/bin/sh
#
# run this script from the cocos2d directory
# eg: $ cd ~/src/cocos2d-iphone/cocos2d/
#
mv ccDeprecated.h ccDeprecated.xxx

# Common
../tools/js/generate_complement.py -e ../tools/js/cocos2d-ios-complement-exceptions.txt -o ../tools/js/cocos2d-complement.txt *.h Support/*.h Platforms/*.h

# iOS
../tools/js/generate_complement.py -e ../tools/js/cocos2d-ios-complement-exceptions.txt -o ../tools/js/cocos2d-ios-complement.txt *.h Support/*.h Platforms/*.h Platforms/iOS/*.h

# Mac
../tools/js/generate_complement.py -e ../tools/js/cocos2d-mac-complement-exceptions.txt -o ../tools/js/cocos2d-mac-complement.txt *.h Support/*.h Platforms/*.h Platforms/Mac/*.h

mv ccDeprecated.xxx ccDeprecated.h
