//
//  CCSpriteHole.m
//  RunArena
//
//  Created by macbook on 05/08/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CCSpriteHole.h"
#import "ccConfig.h"
#import "Support/CGPointExtension.h"
#import "CCTextureCache.h"

@interface CCSpriteHole (Private)
-(void)setTextureRectInPixels:(CGRect)rect untrimmedSize:(CGSize)untrimmedSize;
-(void)updateTextureCoords:(CGRect)rect;
@end


@implementation CCSpriteHole
@synthesize blendFunc = blendFunc_;

-(id) init {
	if( (self=[super init]) ) {
		opacityModifyRGB_			= YES;
		opacity_					= 255;
		color_ = colorUnmodified_	= ccWHITE;
        
        capSize=capSizeInPixels=CGSizeZero; //Not used
		
		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;
		
		// update texture (calls updateBlendFunc)
		[self setTexture:nil];
		
		// default transform anchor
		anchorPoint_ =  ccp(0.5f, 0.5f);
		
		vertexDataCount=24;
		vertexData = (ccV2F_C4F_T2F*) malloc(vertexDataCount * sizeof(ccV2F_C4F_T2F));
		
		[self setTextureRectInPixels:CGRectZero untrimmedSize:CGSizeZero];
	}
	return self;
}
-(id) initWithTexture:(CCTexture2D*)texture rect:(CGRect)rect {
	NSAssert(texture!=nil, @"Invalid texture for sprite");
	// IMPORTANT: [self init] and not [super init];
	if( (self = [self init]) ) {
		[self setTexture:texture];
		[self setTextureRect:rect];
	}
	return self;
}
-(id) initWithTexture:(CCTexture2D*)texture {
	NSAssert(texture!=nil, @"Invalid texture for sprite");
	
	CGRect rect = CGRectZero;
	rect.size = texture.contentSize;
	return [self initWithTexture:texture rect:rect];
}
-(id) initWithFile:(NSString*)filename {
	NSAssert(filename!=nil, @"Invalid filename for sprite");
	
	CCTexture2D *texture = [[CCTextureCache sharedTextureCache] addImage: filename];
	if( texture )
		return [self initWithTexture:texture];
	
	[self release];
	return nil;
}

+(id)spriteWithFile:(NSString*)f {
    return [[[self alloc] initWithFile:f] autorelease];
}
- (void) dealloc {
	if (vertexData) free(vertexData);
	[super dealloc];
}
-(void) updateColor {
	ccColor4F color4;
	color4.r=(float)color_.r/255.0f;
	color4.g=(float)color_.g/255.0f;
	color4.b=(float)color_.b/255.0f;
	color4.a=(float)opacity_/255.0f;
	
	for (int i=0; i<vertexDataCount; i++) {
		vertexData[i].colors=color4;
	}
}
-(void)updateTextureCoords:(CGRect)rect {
	CCTexture2D *tex = texture_;
	if(!tex)
		return;
	
	float atlasWidth = (float)tex.pixelsWide;
	float atlasHeight = (float)tex.pixelsHigh;
	
	float left,right,top,bottom;
	
	left	= rect.origin.x/atlasWidth;
	right	= left + rect.size.width/atlasWidth;
	top		= rect.origin.y/atlasHeight;
	bottom	= top + rect.size.height/atlasHeight;
	
	//
	//  |/|/|/|
	//
	
	
	CGSize capTexCoordsSize=CGSizeMake(capSizeInPixels.width/atlasWidth, capSizeInPixels.height/atlasHeight);

	// From left to right
	
	//Top band
	// Left
	vertexData[0].texCoords=(ccTex2F){left,top};
	vertexData[1].texCoords=(ccTex2F){left,top+capTexCoordsSize.height};
	vertexData[2].texCoords=(ccTex2F){left+capTexCoordsSize.width,top};
	vertexData[3].texCoords=(ccTex2F){left+capTexCoordsSize.width,top+capTexCoordsSize.height};
	// Center
	vertexData[4].texCoords=(ccTex2F){right-capTexCoordsSize.width,top};
	vertexData[5].texCoords=(ccTex2F){right-capTexCoordsSize.width,top+capTexCoordsSize.height};
	// Right
	vertexData[6].texCoords=(ccTex2F){right,top};
	vertexData[7].texCoords=(ccTex2F){right,top+capTexCoordsSize.height};
	
	//Center band
	// Left
	vertexData[8].texCoords=(ccTex2F){left,bottom-capTexCoordsSize.height};
	vertexData[9].texCoords=(ccTex2F){left,top+capTexCoordsSize.height};
	vertexData[10].texCoords=(ccTex2F){left+capTexCoordsSize.width,bottom-capTexCoordsSize.height};
	vertexData[11].texCoords=(ccTex2F){left+capTexCoordsSize.width,top+capTexCoordsSize.height};
	// Center
	vertexData[12].texCoords=(ccTex2F){right-capTexCoordsSize.width,bottom-capTexCoordsSize.height};
	vertexData[13].texCoords=(ccTex2F){right-capTexCoordsSize.width,top+capTexCoordsSize.height};
	// Right
	vertexData[14].texCoords=(ccTex2F){right,bottom-capTexCoordsSize.height};
	vertexData[15].texCoords=(ccTex2F){right,top+capTexCoordsSize.height};

	//Bottom band
	//Left
	vertexData[16].texCoords=(ccTex2F){left,bottom};
	vertexData[17].texCoords=(ccTex2F){left,bottom-capTexCoordsSize.height};
	vertexData[18].texCoords=(ccTex2F){left+capTexCoordsSize.width,bottom};
	vertexData[19].texCoords=(ccTex2F){left+capTexCoordsSize.width,bottom-capTexCoordsSize.height};
	// Center
	vertexData[20].texCoords=(ccTex2F){right-capTexCoordsSize.width,bottom};
	vertexData[21].texCoords=(ccTex2F){right-capTexCoordsSize.width,bottom-capTexCoordsSize.height};
	// Right
	vertexData[22].texCoords=(ccTex2F){right,bottom};
	vertexData[23].texCoords=(ccTex2F){right,bottom-capTexCoordsSize.height};
}
-(void) updateVertices {
	float left=0; //-spriteSizeInPixels.width*0.5f;
	float right=left+contentSizeInPixels_.width;
	float bottom=0; //-spriteSizeInPixels.height*0.5f;
	float top=bottom+contentSizeInPixels_.height;
    
    float holeLeft=holeRect.origin.x*CC_CONTENT_SCALE_FACTOR();
    float holeRight=holeLeft+holeRect.size.width*CC_CONTENT_SCALE_FACTOR();
    
    float holeBottom=holeRect.origin.y*CC_CONTENT_SCALE_FACTOR();
    float holeTop=holeBottom+holeRect.size.height*CC_CONTENT_SCALE_FACTOR();
    
    
    //
	//  |/|/|/|
	//
	
	// From left to right
	
	//Top band
	// Left
	vertexData[0].vertices=(ccVertex2F){left,top};
	vertexData[1].vertices=(ccVertex2F){left,holeTop};
	vertexData[2].vertices=(ccVertex2F){holeLeft,top};
	vertexData[3].vertices=(ccVertex2F){holeLeft,holeTop};
	// Center
	vertexData[4].vertices=(ccVertex2F){holeRight,top};
	vertexData[5].vertices=(ccVertex2F){holeRight,holeTop};
	// Right
	vertexData[6].vertices=(ccVertex2F){right,top};
	vertexData[7].vertices=(ccVertex2F){right,holeTop};
	
	//Center band
	// Left
	vertexData[8].vertices=(ccVertex2F){left,holeBottom};
	vertexData[9].vertices=(ccVertex2F){left,holeTop};
	vertexData[10].vertices=(ccVertex2F){holeLeft,holeBottom};
	vertexData[11].vertices=(ccVertex2F){holeLeft,holeTop};
	// Center
	vertexData[12].vertices=(ccVertex2F){holeRight,holeBottom};
	vertexData[13].vertices=(ccVertex2F){holeRight,holeTop};
	// Right
	vertexData[14].vertices=(ccVertex2F){right,holeBottom};
	vertexData[15].vertices=(ccVertex2F){right,holeTop};
	
	//Bottom band
	//Left
	vertexData[16].vertices=(ccVertex2F){left,bottom};
	vertexData[17].vertices=(ccVertex2F){left,holeBottom};
	vertexData[18].vertices=(ccVertex2F){holeLeft,bottom};
	vertexData[19].vertices=(ccVertex2F){holeLeft,holeBottom};
	// Center
	vertexData[20].vertices=(ccVertex2F){holeRight,bottom};
	vertexData[21].vertices=(ccVertex2F){holeRight,holeBottom};
	// Right
	vertexData[22].vertices=(ccVertex2F){right,bottom};
	vertexData[23].vertices=(ccVertex2F){right,holeBottom};
}

-(void) setHole:(CGRect)r inRect:(CGRect)totalSurface {
    holeRect=r;
    self.contentSize=totalSurface.size;
    holeRect.origin=ccpSub(holeRect.origin,totalSurface.origin);
    CGPoint holeCenter=ccp(holeRect.origin.x+holeRect.size.width*0.5f,holeRect.origin.y+holeRect.size.height*0.5f);
    self.anchorPoint=ccp(holeCenter.x/contentSize_.width,holeCenter.y/contentSize_.height);
    
    //[self updateTextureCoords:rectInPixels_];
	[self updateVertices];
	[self updateColor];
}
-(void) draw {
	BOOL newBlend = NO;
	if( blendFunc_.src != CC_BLEND_SRC || blendFunc_.dst != CC_BLEND_DST ) {
		newBlend = YES;
		glBlendFunc( blendFunc_.src, blendFunc_.dst );
	}
	
	glBindTexture(GL_TEXTURE_2D, [texture_ name]);
	

	glVertexPointer(2, GL_FLOAT, sizeof(ccV2F_C4F_T2F), &vertexData[0].vertices);
	glTexCoordPointer(2, GL_FLOAT, sizeof(ccV2F_C4F_T2F), &vertexData[0].texCoords);
	glColorPointer(4, GL_FLOAT, sizeof(ccV2F_C4F_T2F), &vertexData[0].colors);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 8);

	glVertexPointer(2, GL_FLOAT, sizeof(ccV2F_C4F_T2F), &vertexData[8].vertices);
	glTexCoordPointer(2, GL_FLOAT, sizeof(ccV2F_C4F_T2F), &vertexData[8].texCoords);
	glColorPointer(4, GL_FLOAT, sizeof(ccV2F_C4F_T2F), &vertexData[8].colors);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 8);

	glVertexPointer(2, GL_FLOAT, sizeof(ccV2F_C4F_T2F), &vertexData[16].vertices);
	glTexCoordPointer(2, GL_FLOAT, sizeof(ccV2F_C4F_T2F), &vertexData[16].texCoords);
	glColorPointer(4, GL_FLOAT, sizeof(ccV2F_C4F_T2F), &vertexData[16].colors);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 8);
	
	if( newBlend )
		glBlendFunc(CC_BLEND_SRC, CC_BLEND_DST);
	
}

-(void)setTextureRectInPixels:(CGRect)rect untrimmedSize:(CGSize)untrimmedSize {
	rectInPixels_ = rect;
	rect_ = CC_RECT_PIXELS_TO_POINTS( rect );
	
	//[self setContentSizeInPixels:untrimmedSize];
	[self updateTextureCoords:rectInPixels_];	
}
-(void)setTextureRect:(CGRect)rect {
	CGRect rectInPixels = CC_RECT_POINTS_TO_PIXELS( rect );
	[self setTextureRectInPixels:rectInPixels untrimmedSize:rectInPixels.size];
}


//
// RGBA protocol
//
#pragma mark CCSpriteHole - RGBA protocol
-(GLubyte) opacity {
	return opacity_;
}

-(void) setOpacity:(GLubyte) anOpacity {
	opacity_			= anOpacity;
	
	// special opacity for premultiplied textures
	if( opacityModifyRGB_ )
		[self setColor: (opacityModifyRGB_ ? colorUnmodified_ : color_ )];
	
	[self updateColor];
}

- (ccColor3B) color {
	if(opacityModifyRGB_){
		return colorUnmodified_;
	}
	return color_;
}

-(void) setColor:(ccColor3B)color3 {
	color_ = colorUnmodified_ = color3;
	
	if( opacityModifyRGB_ ){
		color_.r = color3.r * opacity_/255;
		color_.g = color3.g * opacity_/255;
		color_.b = color3.b * opacity_/255;
	}
	
	[self updateColor];
}

-(void) setOpacityModifyRGB:(BOOL)modify {
	ccColor3B oldColor	= self.color;
	opacityModifyRGB_	= modify;
	self.color			= oldColor;
}

-(BOOL) doesOpacityModifyRGB {
	return opacityModifyRGB_;
}


#pragma mark CCSpriteHole - CocosNodeTexture protocol

-(void) updateBlendFunc {
	if( !texture_ || ! [texture_ hasPremultipliedAlpha] ) {
		blendFunc_.src = GL_SRC_ALPHA;
		blendFunc_.dst = GL_ONE_MINUS_SRC_ALPHA;
		[self setOpacityModifyRGB:NO];
	} else {
		blendFunc_.src = CC_BLEND_SRC;
		blendFunc_.dst = CC_BLEND_DST;
		[self setOpacityModifyRGB:YES];
	}
}

-(void) setTexture:(CCTexture2D*)texture {	
	// accept texture==nil as argument
	NSAssert( !texture || [texture isKindOfClass:[CCTexture2D class]], @"setTexture expects a CCTexture2D. Invalid argument");
	
	[texture_ release];
	texture_ = [texture retain];
	
	[self updateBlendFunc];
}

-(CCTexture2D*) texture {
	return texture_;
}
@end