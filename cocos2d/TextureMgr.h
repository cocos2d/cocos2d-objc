//
//  TextureMgr.h
//  cocos2d
//

#import <UIKit/UIKit.h>

#import "Texture2D.h"

@interface TextureMgr : NSObject
{
	NSMutableDictionary *textures;
}

+ (TextureMgr *) sharedTextureMgr;

-(Texture2D*) addImage: (NSString*) fileimage;

@end