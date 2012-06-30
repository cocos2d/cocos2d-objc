mv ccDeprecated.h ccDeprecated.xxx

gen_bridge_metadata -F complete --no-64-bit -c '-ISupport -IPlatforms -I.' *.h Support/*.h Platforms/*.h -o ../tools/js/cocos2d.bridgesupport 

gen_bridge_metadata -F complete --64-bit -c '-D__CC_PLATFORM_MAC -ISupport -IPlatforms -IPlatforms/Mac -I.' *.h Platforms/*.h Platforms/Mac/*.h -o ../tools/js/cocos2d-mac.bridgesupport 

gen_bridge_metadata -F complete --no-64-bit -c '-D__CC_PLATFORM_IOS -ISupport -IPlatforms -IPlatforms/iOS -I.' *.h Platforms/*.h Platforms/iOS/*.h -o ../tools/js/cocos2d-ios.bridgesupport -e ../tools/js/cocos2d-ios-exceptions.bridgesupport

mv ccDeprecated.xxx ccDeprecated.h
