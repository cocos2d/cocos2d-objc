//
//  CCProgressBar.h
//  iMoonlightsHD
//
//  Created by macbook on 10/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCNode.h"
#import "CCProtocols.h"


@class CCSpriteScale9;

@interface CCProgressBar : CCNode {
	CCSpriteScale9 *bg,*fg;
	CGSize margin;
	float progress;
	float animAngle;
}
+(id)progressBarWithBgSprite:(CCSpriteScale9*)b andFgSprite:(CCSpriteScale9*)f andSize:(CGSize)s andMargin:(CGSize)m;
-(id)initWithBgSprite:(CCSpriteScale9*)b andFgSprite:(CCSpriteScale9*)f andSize:(CGSize)s andMargin:(CGSize)m;
-(void)setProgress:(float)p;
-(void)startAnimation;
-(void)stopAnimation;
-(void)setOpacity:(GLubyte)opacity;
@end
