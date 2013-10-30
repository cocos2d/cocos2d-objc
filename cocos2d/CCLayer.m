/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */


#import <stdarg.h>

#import "Platforms/CCGL.h"

#import "CCLayer.h"
#import "CCDirector.h"
#import "ccMacros.h"
#import "CCShaderCache.h"
#import "CCGLProgram.h"
#import "ccGLStateCache.h"
#import "Support/TransformUtils.h"
#import "Support/CGPointExtension.h"
#import "CCNode_Private.h"

#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCDirectorIOS.h"
#elif defined(__CC_PLATFORM_MAC)
#import "Platforms/Mac/CCDirectorMac.h"
#endif

// extern
#import "kazmath/GL/matrix.h"

#pragma mark -
#pragma mark Layer

#if __CC_PLATFORM_IOS

#endif // __CC_PLATFORM_IOS

#pragma mark -
#pragma mark LayerColor

@interface CCLayerColor (Private)
-(void) updateColor;
@end

@implementation CCLayerColor

// Opacity and RGB color protocol
@synthesize blendFunc = _blendFunc;


+ (id) layerWithColor:(ccColor4B)color width:(GLfloat)w  height:(GLfloat) h
{
	return [[self alloc] initWithColor:color width:w height:h];
}

+ (id) layerWithColor:(ccColor4B)color
{
	return [(CCLayerColor*)[self alloc] initWithColor:color];
}

-(id) init
{
	CGSize s = [[CCDirector sharedDirector] viewSize];
	return [self initWithColor:ccc4(0,0,0,0) width:s.width height:s.height];
}

// Designated initializer
- (id) initWithColor:(ccColor4B)color width:(GLfloat)w  height:(GLfloat) h
{
	if( (self=[super init]) ) {

		// default blend function
		_blendFunc = (ccBlendFunc) { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };

		_displayedColor.r = _realColor.r = color.r;
		_displayedColor.g = _realColor.g = color.g;
		_displayedColor.b = _realColor.b = color.b;
		_displayedOpacity = _realOpacity = color.a;

		for (NSUInteger i = 0; i<sizeof(_squareVertices) / sizeof( _squareVertices[0]); i++ ) {
			_squareVertices[i].x = 0.0f;
			_squareVertices[i].y = 0.0f;
		}

		[self updateColor];
		[self setContentSize:CGSizeMake(w, h) ];

		self.shaderProgram = [[CCShaderCache sharedShaderCache] programForKey:kCCShader_PositionColor];
	}
	return self;
}

- (id) initWithColor:(ccColor4B)color
{
	CGSize s = [[CCDirector sharedDirector] viewSize];
	return [self initWithColor:color width:s.width height:s.height];
}

- (void) updateColor
{
	for( NSUInteger i = 0; i < 4; i++ )
	{
		_squareColors[i].r = _displayedColor.r / 255.0f;
		_squareColors[i].g = _displayedColor.g / 255.0f;
		_squareColors[i].b = _displayedColor.b / 255.0f;
		_squareColors[i].a = _displayedOpacity / 255.0f;
	}
}

- (void) draw
{
    CGSize size = self.contentSizeInPoints;
    
    _squareVertices[1].x = size.width;
	_squareVertices[2].y = size.height;
	_squareVertices[3].x = size.width;
	_squareVertices[3].y = size.height;
    
	CC_NODE_DRAW_SETUP();

	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position | kCCVertexAttribFlag_Color );

	//
	// Attributes
	//
	glVertexAttribPointer(kCCVertexAttrib_Position, 2, GL_FLOAT, GL_FALSE, 0, _squareVertices);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_FLOAT, GL_FALSE, 0, _squareColors);

	ccGLBlendFunc( _blendFunc.src, _blendFunc.dst );

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	
	CC_INCREMENT_GL_DRAWS(1);
}

#pragma mark Protocols
// Color Protocol

-(void) setColor:(ccColor3B)color
{
    [super setColor:color];
	[self updateColor];
}

-(void) setOpacity: (GLubyte) opacity
{
    [super setOpacity:opacity];
	[self updateColor];
}
@end


#pragma mark -
#pragma mark LayerGradient

@implementation CCLayerGradient

@synthesize startOpacity = _startOpacity;
@synthesize endColor = _endColor, endOpacity = _endOpacity;
@synthesize vector = _vector;

+ (id) layerWithColor: (ccColor4B) start fadingTo: (ccColor4B) end
{
    return [[self alloc] initWithColor:start fadingTo:end];
}

+ (id) layerWithColor: (ccColor4B) start fadingTo: (ccColor4B) end alongVector: (CGPoint) v
{
    return [[self alloc] initWithColor:start fadingTo:end alongVector:v];
}

- (id) init
{
	return [self initWithColor:ccc4(0, 0, 0, 255) fadingTo:ccc4(0, 0, 0, 255)];
}

- (id) initWithColor: (ccColor4B) start fadingTo: (ccColor4B) end
{
    return [self initWithColor:start fadingTo:end alongVector:ccp(0, -1)];
}

- (id) initWithColor: (ccColor4B) start fadingTo: (ccColor4B) end alongVector: (CGPoint) v
{
	_endColor.r = end.r;
	_endColor.g = end.g;
	_endColor.b = end.b;

	_endOpacity		= end.a;
	_startOpacity	= start.a;
	_vector = v;

	start.a	= 255;
	_compressedInterpolation = YES;

	return [super initWithColor:start];
}

- (void) updateColor
{
    [super updateColor];

	float h = ccpLength(_vector);
    if (h == 0)
		return;

	float c = sqrtf(2);
    CGPoint u = ccp(_vector.x / h, _vector.y / h);

	// Compressed Interpolation mode
	if( _compressedInterpolation ) {
		float h2 = 1 / ( fabsf(u.x) + fabsf(u.y) );
		u = ccpMult(u, h2 * (float)c);
	}

	float opacityf = (float)_displayedOpacity/255.0f;

    ccColor4F S = {
		_displayedColor.r / 255.0f,
		_displayedColor.g / 255.0f,
		_displayedColor.b / 255.0f,
		_startOpacity*opacityf / 255.0f,
	};

    ccColor4F E = {
		_endColor.r / 255.0f,
		_endColor.g / 255.0f,
		_endColor.b / 255.0f,
		_endOpacity*opacityf / 255.0f,
	};


    // (-1, -1)
	_squareColors[0].r = E.r + (S.r - E.r) * ((c + u.x + u.y) / (2.0f * c));
	_squareColors[0].g = E.g + (S.g - E.g) * ((c + u.x + u.y) / (2.0f * c));
	_squareColors[0].b = E.b + (S.b - E.b) * ((c + u.x + u.y) / (2.0f * c));
	_squareColors[0].a = E.a + (S.a - E.a) * ((c + u.x + u.y) / (2.0f * c));
    // (1, -1)
	_squareColors[1].r = E.r + (S.r - E.r) * ((c - u.x + u.y) / (2.0f * c));
	_squareColors[1].g = E.g + (S.g - E.g) * ((c - u.x + u.y) / (2.0f * c));
	_squareColors[1].b = E.b + (S.b - E.b) * ((c - u.x + u.y) / (2.0f * c));
	_squareColors[1].a = E.a + (S.a - E.a) * ((c - u.x + u.y) / (2.0f * c));
	// (-1, 1)
	_squareColors[2].r = E.r + (S.r - E.r) * ((c + u.x - u.y) / (2.0f * c));
	_squareColors[2].g = E.g + (S.g - E.g) * ((c + u.x - u.y) / (2.0f * c));
	_squareColors[2].b = E.b + (S.b - E.b) * ((c + u.x - u.y) / (2.0f * c));
	_squareColors[2].a = E.a + (S.a - E.a) * ((c + u.x - u.y) / (2.0f * c));
	// (1, 1)
	_squareColors[3].r = E.r + (S.r - E.r) * ((c - u.x - u.y) / (2.0f * c));
	_squareColors[3].g = E.g + (S.g - E.g) * ((c - u.x - u.y) / (2.0f * c));
	_squareColors[3].b = E.b + (S.b - E.b) * ((c - u.x - u.y) / (2.0f * c));
	_squareColors[3].a = E.a + (S.a - E.a) * ((c - u.x - u.y) / (2.0f * c));
}

-(ccColor3B) startColor
{
	return _realColor;
}

-(void) setStartColor:(ccColor3B)color
{
	[self setColor:color];
}

-(void) setEndColor:(ccColor3B)color
{
    _endColor = color;
    [self updateColor];
}

-(void) setStartOpacity: (GLubyte) o
{
	_startOpacity = o;
    [self updateColor];
}

-(void) setEndOpacity: (GLubyte) o
{
    _endOpacity = o;
    [self updateColor];
}

-(void) setVector: (CGPoint) v
{
    _vector = v;
    [self updateColor];
}

-(BOOL) compressedInterpolation
{
	return _compressedInterpolation;
}

-(void) setCompressedInterpolation:(BOOL)compress
{
	_compressedInterpolation = compress;
	[self updateColor];
}
@end

#pragma mark -
#pragma mark MultiplexLayer

@implementation CCNodeMultiplex
+(id) nodeWithArray:(NSArray *)arrayOfLayers
{
	return [[self alloc] initWithArray:arrayOfLayers];
}

+(id) nodeWithNodes: (CCNode*) layer, ...
{
	va_list args;
	va_start(args,layer);

	id s = [[self alloc] initWithLayers: layer vaList:args];

	va_end(args);
	return s;
}

-(id) initWithArray:(NSArray *)arrayOfLayers
{
	if( (self=[super init])) {
		_layers = [arrayOfLayers mutableCopy];

		_enabledLayer = 0;

		[self addChild: [_layers objectAtIndex:_enabledLayer]];
	}


	return self;
}

-(id) initWithLayers: (CCNode*) layer vaList:(va_list) params
{
	if( (self=[super init]) ) {

		_layers = [NSMutableArray arrayWithCapacity:5];

		[_layers addObject: layer];

		CCNode *l = va_arg(params,CCNode*);
		while( l ) {
			[_layers addObject: l];
			l = va_arg(params,CCNode*);
		}

		_enabledLayer = 0;
		[self addChild: [_layers objectAtIndex: _enabledLayer]];
	}

	return self;
}


-(void) switchTo: (unsigned int) n
{
	NSAssert( n < [_layers count], @"Invalid index in MultiplexLayer switchTo message" );

	[self removeChild: [_layers objectAtIndex:_enabledLayer] cleanup:YES];

	_enabledLayer = n;

	[self addChild: [_layers objectAtIndex:n]];
}

-(void) switchToAndReleaseMe: (unsigned int) n
{
	NSAssert( n < [_layers count], @"Invalid index in MultiplexLayer switchTo message" );

	[self removeChild: [_layers objectAtIndex:_enabledLayer] cleanup:YES];

	[_layers replaceObjectAtIndex:_enabledLayer withObject:[NSNull null]];

	_enabledLayer = n;

	[self addChild: [_layers objectAtIndex:n]];
}
@end
