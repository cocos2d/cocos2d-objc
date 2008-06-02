//
//  sprite.h
//  test-opengl
//
//  Created by Ricardo Quesada on 28/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
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