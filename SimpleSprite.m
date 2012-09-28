//
//  SimpleSprite.m
//  cocos2d-ios
//
//  Created by Goffredo Marocchi on 9/28/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SimpleSprite.h"


@implementation SimpleSprite

-(void) draw
{
    // temp var to store transformation matrix
    //kmMat4 currMtx;
    if(!self.disableFix) {
        kmGLPushMatrix(); //Save the current matrix.
    }
    
    if(rt == nil) {
        CGSize s = [[CCDirector sharedDirector] winSize];
        rt = [[CCRenderTexture alloc] initWithWidth:s.width height:s.height pixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    }
    [rt beginWithClear:0.0f g:0.0f b:0.0f a:1.0f];
    [rt end];
    
    if(!self.disableFix) {
        kmGLPopMatrix(); //Restore the current matrix.
    }
    
	CC_NODE_DRAW_SETUP();
    
	ccGLBlendFunc( blendFunc_.src, blendFunc_.dst );
    
	ccGLBindTexture2D( [texture_ name] );
    
	//
	// Attributes
	//
    
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_PosColorTex );
    
#define kQuadSize sizeof(quad_.bl)
	long offset = (long)&quad_;
    
	// vertex
	NSInteger diff = offsetof( ccV3F_C4B_T2F, vertices);
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*) (offset + diff));
    
	// texCoods
	diff = offsetof( ccV3F_C4B_T2F, texCoords);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));
    
	// color
	diff = offsetof( ccV3F_C4B_T2F, colors);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));
    
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
}

@end
