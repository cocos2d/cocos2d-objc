# Only for ChipmunkSprite and ChipmunkDebugNode
gen_bridge_metadata -F complete --no-64-bit -c '-I. -I../../cocos2d/. -I../../external/Chipmunk/include/chipmunk/. -I../../external/Chipmunk/include/chipmunk/constraints/.' ChipmunkSprite.h ChipmunkDebugNode.h -o ../../tools/js/ChipmunkSprite.bridgesupport
