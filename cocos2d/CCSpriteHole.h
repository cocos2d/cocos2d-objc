//
//  CCSpriteHole.h
//  RunArena
//
//  Created by macbook on 05/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNode.h"
#import "CCProtocols.h"


@interface CCSpriteHole : CCNode <CCRGBAProtocol, CCTextureProtocol> {
    CGSize capSize,capSizeInPixels;
    
    CGRect holeRect;
    
	int vertexDataCount;
	ccV2F_C4F_T2F *vertexData;

	//
	// Data used when the sprite is self-rendered
	//
	ccBlendFunc				blendFunc_;				// Needed for the texture protocol
	CCTexture2D				*texture_;				// Texture used to render the sprite
	
	// Texture rects
	CGRect	rect_;
	CGRect	rectInPixels_;
	
	// opacity and RGB protocol
	GLubyte		opacity_;
	ccColor3B	color_;
	ccColor3B	colorUnmodified_;
	BOOL		opacityModifyRGB_;
}
+(id)spriteWithFile:(NSString*)f;

/** conforms to CCTextureProtocol protocol */
@property (nonatomic,readwrite) ccBlendFunc blendFunc;

-(void) setTextureRect:(CGRect) rect;

//Set hole and surface (and anchorPoint in the middle of the hole)
-(void) setHole:(CGRect)holeRect inRect:(CGRect)totalSurface;
@end



