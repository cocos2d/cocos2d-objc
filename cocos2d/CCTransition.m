/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013-2014 Cocos2D Authors
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

#import "CCTransition.h"
#import "CCDirector_Private.h"
#import "CCNode_Private.h"

// -----------------------------------------------------------------

const float CCTransitionDownScaleMin = 1.0f;                        // range for transition downscales
const float CCTransitionDownScaleRetina = 2.0f;
const float CCTransitionDownScaleMax = 128.0f;

typedef NS_ENUM(NSInteger, CCTransitionFixedFunction)
{
    CCTransitionFixedFunctionCrossFade,
    CCTransitionFixedFunctionFadeWithColor,
    CCTransitionFixedFunctionMoveIn,
    CCTransitionFixedFunctionPush,
    CCTransitionFixedFunctionReveal,
};

// -----------------------------------------------------------------

@implementation CCTransition
{
    NSTimeInterval _duration;
    __strong CCScene *_incomingScene;
    __strong CCScene *_outgoingScene;
    CCRenderTexture *_incomingTexture;
    CCRenderTexture *_outgoingTexture;
    BOOL _incomingPauseState;
    //
    CCTransitionFixedFunction _fixedFunction;
    CCTransitionDirection _direction;
    ccColor4F _color;
    SEL _drawSelector;
    BOOL _outgoingOverIncoming;
    CGPoint _outgoingDestination;
}

// -----------------------------------------------------------------

+ (CCTransition *)transitionCrossFadeWithDuration:(NSTimeInterval)duration
{
    return([[self alloc] initWithDuration:duration fixedFunction:CCTransitionFixedFunctionCrossFade direction:CCTransitionDirectionInvalid color:ccBLACK]);
}

+ (CCTransition *)transitionFadeWithColor:(CCColor*)color duration:(NSTimeInterval)duration
{
    return([[self alloc] initWithDuration:duration fixedFunction:CCTransitionFixedFunctionFadeWithColor direction:CCTransitionDirectionInvalid color:color.ccColor3b]);
}

+ (CCTransition *)transitionFadeWithDuration:(NSTimeInterval)duration
{
    return([[self alloc] initWithDuration:duration fixedFunction:CCTransitionFixedFunctionFadeWithColor direction:CCTransitionDirectionInvalid color:ccBLACK]);
}

+ (CCTransition *)transitionMoveInWithDirection:(CCTransitionDirection)direction duration:(NSTimeInterval)duration
{
    return([[self alloc] initWithDuration:duration fixedFunction:CCTransitionFixedFunctionMoveIn direction:direction color:ccBLACK]);
}

+ (CCTransition *)transitionPushWithDirection:(CCTransitionDirection)direction duration:(NSTimeInterval)duration
{
    return([[self alloc] initWithDuration:duration fixedFunction:CCTransitionFixedFunctionPush direction:direction color:ccBLACK]);
}

+ (CCTransition *)transitionRevealWithDirection:(CCTransitionDirection)direction duration:(NSTimeInterval)duration
{
    return([[self alloc] initWithDuration:duration fixedFunction:CCTransitionFixedFunctionReveal direction:direction color:ccBLACK]);
}

// -----------------------------------------------------------------

- (id)initWithDuration:(NSTimeInterval)duration
         fixedFunction:(CCTransitionFixedFunction)function
             direction:(CCTransitionDirection)direction
                 color:(ccColor3B)color
{
    self = [self initWithDuration:duration];

    // set up fixed function transition
    _fixedFunction = function;
    _direction = direction;
    _color = (ccColor4F){(float)color.r / 255, (float)color.g / 255, (float)color.b / 255, 1};
    _drawSelector = @selector(drawFixedFunction);
    _outgoingOverIncoming = NO;
    
    // find out where the outgoing scene will end (if it is a transition with movement)
    CGSize size = [CCDirector sharedDirector].viewportRect.size;
    switch (direction) {
        case CCTransitionDirectionDown: _outgoingDestination = CGPointMake(0, -size.height); break;
        case CCTransitionDirectionLeft: _outgoingDestination = CGPointMake(-size.width, 0); break;
        case CCTransitionDirectionRight: _outgoingDestination = CGPointMake(size.width, 0); break;
        case CCTransitionDirectionUp: _outgoingDestination = CGPointMake(0, size.height); break;
        case CCTransitionDirectionInvalid: _outgoingDestination = CGPointZero; break;
        default: NSAssert(NO, @"Unknown fixed transition");
    }
    
    // start actions to move sprites into position (will not start until scene is started by director)
    switch (_fixedFunction) {
        case CCTransitionFixedFunctionCrossFade:
        case CCTransitionFixedFunctionFadeWithColor:
            break;
        case CCTransitionFixedFunctionReveal:
            _outgoingOverIncoming = YES;
            break;
        case CCTransitionFixedFunctionMoveIn:
        case CCTransitionFixedFunctionPush:
            break;
        default: NSAssert(NO, @"Unknown fixed transition");
    }
    
    // done
    return(self);
}

- (id)initWithDuration:(NSTimeInterval)duration
{
    self = [super init];
    NSAssert(self, @"Unable to create class");
    NSAssert(duration > 0,@"Invalid duration");
    
    // initialize
    _incomingScene = nil;
    _outgoingScene = nil;
    _duration = duration;
    
    _incomingDownScale = CCTransitionDownScaleMin;
    _outgoingDownScale = CCTransitionDownScaleMin;
    
    _incomingSceneAnimated = NO;
    _outgoingSceneAnimated = NO;
    
    _incomingTexture = nil;
    _outgoingTexture = nil;
    
    // reset internal data
    _runTime = 0.0f;
    _progress = 0.0f;
    
    _transitionPixelFormat = CCTexturePixelFormat_RGBA8888;
		_transitionDepthStencilFormat = GL_DEPTH24_STENCIL8;
    
    // disable touch during transition
    self.userInteractionEnabled = NO;
    
    // done
    return(self);
}

// -----------------------------------------------------------------

- (void)startTransition:(CCScene *)scene
{
    _incomingScene = scene;
    [_incomingScene onEnter];
    _incomingPauseState = _incomingScene.paused;
    _incomingScene.paused = _incomingScene.paused || !_incomingSceneAnimated;
    
    _outgoingScene = [CCDirector sharedDirector].runningScene;
    [_outgoingScene onExitTransitionDidStart];
    _outgoingScene.paused = _outgoingScene.paused || !_outgoingSceneAnimated;

    // create render textures
    // get viewport size
    CGRect rect = [CCDirector sharedDirector].viewportRect;
		
		// Make sure we aren't rounding down.
		rect.size.width = ceil(rect.size.width);
		rect.size.height = ceil(rect.size.height);

    // create texture for outgoing scene
    _outgoingTexture = [CCRenderTexture renderTextureWithWidth:rect.size.width / _outgoingDownScale
                                                        height:rect.size.height / _outgoingDownScale
                                                   pixelFormat:_transitionPixelFormat depthStencilFormat:_transitionDepthStencilFormat];
    _outgoingTexture.position = CGPointMake(rect.size.width * 0.5f + rect.origin.x, rect.size.height * 0.5f + rect.origin.y);
    _outgoingTexture.scale = _outgoingDownScale;
    [self addChild:_outgoingTexture z:_outgoingOverIncoming];
    
    // create texture for incoming scene
    _incomingTexture = [CCRenderTexture renderTextureWithWidth:rect.size.width / _incomingDownScale
                                                        height:rect.size.height / _incomingDownScale
                                                   pixelFormat:_transitionPixelFormat depthStencilFormat:_transitionDepthStencilFormat];
    _incomingTexture.position = CGPointMake(rect.size.width * 0.5f + rect.origin.x, rect.size.height * 0.5f + rect.origin.y);
    _incomingTexture.scale = _incomingDownScale;
    [self addChild:_incomingTexture];
    
    // make sure scene is rendered at least once at progress 0.0
    [self renderOutgoing:0];
    [self renderIncoming:0];
    
    // switch to transition scene
    [[CCDirector sharedDirector] performSelector:@selector(startTransition:) withObject:self];
}

// -----------------------------------------------------------------

- (void)dealloc
{
    // clean up if needed
    
}

// -----------------------------------------------------------------

- (void)update:(CCTime)delta
{
    // update progress
    _runTime += delta;
    _progress = clampf(_runTime / _duration, 0.0f, 1.0f);
    
    // check for runtime expired
    if (_progress >= 1.0f)
    {
        // Exit out scene
        [_outgoingScene onExit];
        if ([CCDirector sharedDirector].sendCleanupToScene) [_outgoingScene cleanup];
        _outgoingScene = nil;
				
				
				// Start incoming scene
        [[CCDirector sharedDirector] replaceScene:_incomingScene];
        [_incomingScene onEnterTransitionDidFinish];
        [_incomingScene setPaused:NO];
        _incomingScene = nil;
        
        return;
    }
    
    // render the scenes
    if (_incomingSceneAnimated)
    {
        
        [self renderIncoming:_progress];
    }
    if (_outgoingSceneAnimated)
    {
     
        [self renderOutgoing:_progress];
    }
}

// -----------------------------------------------------------------

- (void)renderOutgoing:(float)progress
{
    float oldScale;
    GLfloat clearColor[4];

    // scale the out scene to fit render texture
    oldScale = _outgoingScene.scale;
    _outgoingScene.scale = oldScale / _outgoingDownScale;
    
    glGetFloatv(GL_COLOR_CLEAR_VALUE, clearColor);
    [_outgoingTexture beginWithClear:clearColor[0] g:clearColor[1] b:clearColor[2] a:clearColor[3] depth:1.0 stencil:0];
    [_outgoingScene visit];
    [_outgoingTexture end];
    
    _outgoingScene.scale = oldScale;
}

- (void)renderIncoming:(float)progress
{
    float oldScale;
    GLfloat clearColor[4];
    
    // scale the in scene to fit render texture
    oldScale = _incomingScene.scale;
    _incomingScene.scale = oldScale / _incomingDownScale;
    
    glGetFloatv(GL_COLOR_CLEAR_VALUE, clearColor);
    [_incomingTexture beginWithClear:clearColor[0] g:clearColor[1] b:clearColor[2] a:clearColor[3] depth:1.0 stencil:0];
    [_incomingScene visit];
    [_incomingTexture end];
    
    _incomingScene.scale = oldScale;
    
}

// -----------------------------------------------------------------

- (void)setRetinaTransition:(BOOL)retinaTransition
{
    _retinaTransition = retinaTransition;
    _incomingDownScale = CCTransitionDownScaleMin;
    _outgoingDownScale = CCTransitionDownScaleMin;
    if (!_retinaTransition && (__ccContentScaleFactor > 1.0))
    {
        _incomingDownScale = CCTransitionDownScaleRetina;
        _outgoingDownScale = CCTransitionDownScaleRetina;
        
    }
}

- (void)setIncomingDownScale:(float)incomingDownScale
{
    NSAssert((incomingDownScale >= CCTransitionDownScaleMin) && (incomingDownScale <= CCTransitionDownScaleMax),@"Invalid down scale");
    _incomingDownScale = incomingDownScale;
}

- (void)setOutgoingDownScale:(float)outgoingDownScale
{
    NSAssert((outgoingDownScale >= CCTransitionDownScaleMin) && (outgoingDownScale <= CCTransitionDownScaleMax),@"Invalid down scale");
    _outgoingDownScale = outgoingDownScale;
}

// -----------------------------------------------------------------

- (void)draw
{
    // remove ARC warning about possible leak from performSelector
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:_drawSelector];
#pragma clang diagnostic pop
}

- (void)drawFixedFunction
{
    switch (_fixedFunction)
    {
        case CCTransitionFixedFunctionCrossFade:
            _incomingTexture.sprite.opacity = _progress;
            _outgoingTexture.sprite.opacity = 1;
            break;
        case CCTransitionFixedFunctionFadeWithColor:
            glClearColor(_color.r, _color.g, _color.b, _color.a);
            _incomingTexture.sprite.opacity = clampf(2.0 * (_progress - 0.5), 0, 1);
            _outgoingTexture.sprite.opacity = clampf(1.0 * (1 - (2 * _progress)), 0, 1);
            break;
        case CCTransitionFixedFunctionReveal:
            _outgoingTexture.sprite.position = ccpMult(_outgoingDestination, _progress);
            break;
        case CCTransitionFixedFunctionMoveIn:
            _incomingTexture.sprite.position = ccpMult(_outgoingDestination, -1 + _progress);
            break;
        case CCTransitionFixedFunctionPush:
            _outgoingTexture.sprite.position = ccpMult(_outgoingDestination, _progress);
            _incomingTexture.sprite.position = ccpMult(_outgoingDestination, -1 + _progress);
            break;
        default:
            break;
    }
}

// -----------------------------------------------------------------

@end
