mv ccDeprecated.h ccDeprecated.xxx

# Common
../tools/js/generate_brige_metadata_complement.py -e ../tools/js/cocos2d-ios-class_hierarchy-protocols-exceptions.txt -o ../tools/js/cocos2d-class_hierarchy-protocols.txt *.h Support/*.h Platforms/*.h

# iOS
../tools/js/generate_brige_metadata_complement.py -e ../tools/js/cocos2d-ios-class_hierarchy-protocols-exceptions.txt -o ../tools/js/cocos2d-ios-class_hierarchy-protocols.txt *.h Support/*.h Platforms/*.h Platforms/iOS/*.h

# Mac
../tools/js/generate_brige_metadata_complement.py -e ../tools/js/cocos2d-mac-class_hierarchy-protocols-exceptions.txt -o ../tools/js/cocos2d-mac-class_hierarchy-protocols.txt *.h Support/*.h Platforms/*.h Platforms/Mac/*.h

mv ccDeprecated.xxx ccDeprecated.h
