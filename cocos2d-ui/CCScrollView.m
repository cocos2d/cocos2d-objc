/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2013 Apportable Inc.
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
 */

#import "ccMacros.h"
#import "CCAction_Private.h"

#if __CC_PLATFORM_IOS
#import <UIKit/UIGestureRecognizerSubclass.h>
#elif __CC_PLATFORM_ANDROID
#import "CCActivity.h"
#import "CCGestureListener.h"
#import <AndroidKit/AndroidGestureDetector.h>
#import <AndroidKit/AndroidMotionEvent.h>
#endif

#import "CCScrollView.h"
#import "CGPointExtension.h"
#import "CCActionInterval.h"
#import "CCActionEase.h"
#import "CCActionInstant.h"
#import "CCResponderManager.h"
#import "CCTouch.h"
#import "CCDirector_Private.h"

#pragma mark Constants

#define kCCScrollViewBoundsSlowDown 0.5
#define kCCScrollViewDeacceleration 0.95
#define kCCScrollViewVelocityLowerCap 20.0
#define kCCScrollViewAllowInteractionBelowVelocity 50.0
#define kCCScrollViewSnapDuration 0.4
#define kCCScrollViewSnapDurationFallOff 100.0
#define kCCScrollViewAutoPageSpeed 500.0
#define kCCScrollViewMaxOuterDistBeforeBounceBack 50.0
#define kCCScrollViewMinVelocityBeforeBounceBack 100.0

#define CCScrollViewActionXTag @"CCScrollViewActionXTag"
#define CCScrollViewActionYTag @"CCScrollViewActionYTag"

#pragma mark -
#pragma mark Helper classes

#if __CC_PLATFORM_IOS

@interface CCTapDownGestureRecognizer : UIGestureRecognizer
@end

@implementation CCTapDownGestureRecognizer

- (void)touchesBegan:(NSSet *)touches withEvent:(CCTouchEvent *)event
{
    if (self.state == UIGestureRecognizerStatePossible)
    {
        self.state = UIGestureRecognizerStateRecognized;
    }
}

@end

#endif

@interface CCScrollViewOrthoProjection : NSObject<CCProjectionDelegate>
-(instancetype)initWithTarget:(CCNode *)target;
@end
@implementation CCScrollViewOrthoProjection
{
    __weak CCNode *_target;
}

-(instancetype)initWithTarget:(CCNode *)target
{
    if( (self=[super init]) ) {
        _target = target;
    }
    return self;
}

-(GLKMatrix4)projection
{
    CGSize size = _target.contentSizeInPoints;
    return GLKMatrix4MakeOrtho(0, size.width, 0, size.height, -1024, 1024);
}

@end


@interface CCMoveToX : CCActionInterval
{
	float _endPosition;
	float _startPos;
	void (^block)(void);
}
@end

@implementation CCMoveToX

-(id) initWithDuration: (CCTime) t positionX: (float) p callback:(void(^)(void))callback
{
	if( (self=[super initWithDuration: t]) ) {
		_endPosition = p;
		block = callback;
	}
	return self;
}


-(void) startWithTarget:(CCNode *)target
{
	[super startWithTarget:target];
	_startPos = target.position.x;
}

-(void) update: (CCTime) t
{
    CCNode *node = (CCNode*)_target;
    
    float positionDelta = _endPosition - _startPos;
    float x = _startPos + positionDelta * t;
    float y = node.position.y;
    
	node.position = ccp(x,y);
	block();
}
@end


@interface CCMoveToY : CCActionInterval
{
	float _endPosition;
	float _startPos;
	void (^block)(void);
}
@end

@implementation CCMoveToY

-(id) initWithDuration: (CCTime) t positionY: (float) p callback:(void(^)(void))callback
{
	if( (self=[super initWithDuration: t]) ) {
		_endPosition = p;
		block = [callback copy];
	}
	return self;
}


-(void) startWithTarget:(CCNode *)target
{
	[super startWithTarget:target];
	_startPos = target.position.y;
}

-(void) update: (CCTime) t
{
    CCNode *node = (CCNode*)_target;
    
    float positionDelta = _endPosition - _startPos;
    float y = _startPos + positionDelta * t;
    float x = node.position.x;
    
	node.position = ccp(x,y);
	block();
}
@end


#pragma mark -
#pragma mark CCScrollView

@implementation CCScrollView {
	BOOL _decelerating;

#if __CC_PLATFORM_MAC
	CGPoint _lastPosition;
#elif __CC_PLATFORM_ANDROID
    CCGestureListener *_listener;
    AndroidGestureDetector *_detector;
    CGPoint _rawScrollTranslation;
#endif
}

#pragma mark Initializers

+ (id) scrollViewWithContentNode:(CCNode*)contentNode
{
    return [[CCScrollView alloc] initWithContentNode:contentNode];
}

- (id) init
{
    self = [self initWithContentNode:[CCNode node]];
    self.contentSizeType = CCSizeTypeNormalized;
    return self;
}

// Designated initializer
- (id) initWithContentNode:(CCNode*)contentNode
{
    self = [super initWithContentNode:contentNode];
    self.projectionDelegate = [[CCScrollViewOrthoProjection alloc] initWithTarget:self];
    
    if (!self) return NULL;
    
    _flipYCoordinates = YES;
    
    // Setup content node
    self.contentSize = CGSizeMake(1, 1);
    self.contentSizeType = CCSizeTypeNormalized;

    // Default properties
    _horizontalScrollEnabled = YES;
    _verticalScrollEnabled = YES;
    _bounces = YES;
    
#if __CC_PLATFORM_IOS
    
    // Create gesture recognizers
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    _tapRecognizer = [[CCTapDownGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    
    _panRecognizer.delegate = self;
    _tapRecognizer.delegate = self;
#elif __CC_PLATFORM_ANDROID
    dispatch_async(dispatch_get_main_queue(), ^{
        _listener = [[CCGestureListener alloc] init];
        _listener.delegate = (id<CCGestureListenerDelegate>)self;
        _detector = [[AndroidGestureDetector alloc] initWithContext:[CCActivity currentActivity] onGestureListener:_listener];
    });
#elif __CC_PLATFORM_MAC
    
    // Use scroll wheel
    self.userInteractionEnabled = YES;
#endif
    
    self.userInteractionEnabled = YES;
    
    return self;
}

#pragma mark Setting content node
- (void) setContentNode:(CCNode *)contentNode
{
    if (self.contentNode == contentNode) return;

    // Call superclass setter.
    [super setContentNode:contentNode];
    if (contentNode)
    {
        // Force specific position types and anchors based on coordinate flipping
        [self setFlipYCoordinates: _flipYCoordinates];
    }
}

- (void) setFlipYCoordinates:(BOOL)flipYCoordinates
{
    if (flipYCoordinates)
    {
        self.contentNode.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerTopLeft);
        self.contentNode.anchorPoint = ccp(0,1);
        
        // Note, if this class is modified to change the flipping behavior, consider adjusting the camera positionType like this:
//        self.camera.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerTopLeft);
//        self.camera.anchorPoint = ccp(0,1);
    }
    else
    {
        self.contentNode.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerBottomLeft);
        self.contentNode.anchorPoint = ccp(0,0);
//        self.camera.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerBottomLeft);
//        self.camera.anchorPoint = ccp(0,0);
    }
    
    _flipYCoordinates = flipYCoordinates;
}

#pragma mark Min/Max size

- (float) minScrollX
{
    return 0;
}

- (float) maxScrollX
{
    if (!self.contentNode) return 0;
    
    float maxScroll = self.contentNode.contentSizeInPoints.width - self.contentSizeInPoints.width;
    if (maxScroll < 0) maxScroll = 0;
    
    return maxScroll;
}

- (float) minScrollY
{
    return 0;
}

- (float) maxScrollY
{
    if (!self.contentNode) return 0;
    
    float maxScroll = self.contentNode.contentSizeInPoints.height - self.contentSizeInPoints.height;
    if (maxScroll < 0) maxScroll = 0;
    
    return maxScroll;
}

#pragma mark Paging

- (void) setHorizontalPage:(int)horizontalPage
{
    [self setHorizontalPage:horizontalPage animated:NO];
}

- (void) setHorizontalPage:(int)horizontalPage animated:(BOOL)animated
{
    NSAssert(horizontalPage >= 0 && horizontalPage < self.numHorizontalPages, @"Setting invalid horizontal page");
    
    CGPoint pos = self.scrollPosition;
    pos.x = horizontalPage * self.contentSizeInPoints.width;
    
    [self setScrollPosition:pos animated:animated];
    _horizontalPage = horizontalPage;
}

- (void) setVerticalPage:(int)verticalPage
{
    [self setVerticalPage:verticalPage animated:NO];
}

- (void) setVerticalPage:(int)verticalPage animated:(BOOL)animated
{
    NSAssert(verticalPage >= 0 && verticalPage < self.numVerticalPages, @"Setting invalid vertical page");
    
    CGPoint pos = self.scrollPosition;
    pos.y = verticalPage * self.contentSizeInPoints.height;
    
    [self setScrollPosition:pos animated:animated];
    _verticalPage = verticalPage;
}

- (int) numHorizontalPages
{
    if (!_pagingEnabled) return 0;
    if (!self.contentSizeInPoints.width || !self.contentNode.contentSizeInPoints.width) return 0;
    
    return roundf(self.contentNode.contentSizeInPoints.width / self.contentSizeInPoints.width);
}

- (int) numVerticalPages
{
    if (!_pagingEnabled) return 0;
    if (!self.contentSizeInPoints.height || !self.contentNode.contentSizeInPoints.height) return 0;
    
    return roundf(self.contentNode.contentSizeInPoints.height / self.contentSizeInPoints.height);
}

#pragma mark Panning and setting position

- (void) setScrollPosition:(CGPoint)newPos
{
    [self setScrollPosition:newPos animated:NO];
}

- (CGPoint) clampToBounds:(CGPoint)pos
{
    pos.x = MAX(MIN(pos.x, self.maxScrollX), self.minScrollX);
    if(_flipYCoordinates){
        pos.y = -MAX(MIN(pos.y, self.maxScrollY), self.minScrollY);
    }else{
        pos.y = MAX(MIN(pos.y, self.maxScrollY), self.minScrollY);
    }
    return pos;
}

- (void) setScrollPosition:(CGPoint)newPos animated:(BOOL)animated
{
    // Check bounds
    newPos = [self clampToBounds:newPos];
    
    [self updateAndroidScrollTranslation:newPos];
    
    BOOL xMoved = (newPos.x != self.scrollPosition.x);
    BOOL yMoved = (newPos.y != self.scrollPosition.y);

    if (animated)
    {
        CGPoint oldPos = self.scrollPosition;
        float dist = ccpDistance(newPos, oldPos);
        
        float duration = clampf(dist / kCCScrollViewSnapDurationFallOff, 0, kCCScrollViewSnapDuration);
        
        if (xMoved)
        {
            // Animate horizontally
            
            _velocity.x = 0;
            _animatingX = YES;
            
            // Create animation action
            CCActionInterval* action = [CCActionEaseOut actionWithAction:[[CCMoveToX alloc] initWithDuration:duration positionX:newPos.x callback:^{
				[self scrollViewDidScroll];
			}] rate:2];
            CCActionCallFunc* callFunc = [CCActionCallFunc actionWithTarget:self selector:@selector(xAnimationDone)];
            action = [CCActionSequence actions:action, callFunc, nil];
            action.name = CCScrollViewActionXTag;
            [self.camera runAction:action];
        }
        if (yMoved)
        {
            // Animate vertically
            
            _velocity.y = 0;
            _animatingY = YES;
            
            // Create animation action
            CCActionInterval* action = [CCActionEaseOut actionWithAction:[[CCMoveToY alloc] initWithDuration:duration positionY:newPos.y callback:^{
				[self scrollViewDidScroll];
			}] rate:2];
            CCActionCallFunc* callFunc = [CCActionCallFunc actionWithTarget:self selector:@selector(yAnimationDone)];
            action = [CCActionSequence actions:action, callFunc, nil];
            action.name = CCScrollViewActionYTag;
            [self.camera runAction:action];
        }
    }
    else
    {
#if __CC_PLATFORM_MAC
		_lastPosition = self.scrollPosition;
#endif
        [self.camera stopActionByName:CCScrollViewActionXTag];
        [self.camera stopActionByName:CCScrollViewActionYTag];
        self.camera.position = newPos;
    }
}

- (void)updateAndroidScrollTranslation:(CGPoint)worldPosition
{
#if __CC_PLATFORM_ANDROID
    _rawScrollTranslation = [self convertToWindowSpace:CGPointMake(-worldPosition.x, worldPosition.y)];
#endif
}


- (void) xAnimationDone
{
    _animatingX = NO;
}

- (void) yAnimationDone
{
    _animatingY = NO;
}

- (CGPoint) scrollPosition
{
    return self.camera.position;
}

- (void) handlePanFrom:(CGPoint) start delta:(CGPoint) delta
{
    // Check if scroll directions has been disabled
    if (!_horizontalScrollEnabled) delta.x = 0;
    if (!_verticalScrollEnabled) delta.y = 0;
    
    // Check bounds
    CGPoint newPos = ccpAdd(start, delta);
    
    // If we're in flipped Y mode, we flip coordinates, do the bounds checks, then flip back.
    if(_flipYCoordinates){
        newPos.y = -newPos.y;
    }
    
    if (_bounces)
    {
        // Scroll at half speed outside of bounds
        if (newPos.x > self.maxScrollX)
        {
            float diff = newPos.x - self.maxScrollX;
            newPos.x = self.maxScrollX + diff * kCCScrollViewBoundsSlowDown;
        }
        if (newPos.x < self.minScrollX)
        {
            float diff = self.minScrollX - newPos.x;
            newPos.x = self.minScrollX - diff * kCCScrollViewBoundsSlowDown;
        }
        if (newPos.y > self.maxScrollY)
        {
            float diff = newPos.y - self.maxScrollY;
            newPos.y = self.maxScrollY + diff * kCCScrollViewBoundsSlowDown;
        }
        if (newPos.y < self.minScrollY)
        {
            float diff = self.minScrollY - newPos.y;
            newPos.y = self.minScrollY - diff * kCCScrollViewBoundsSlowDown;
        }
        if(_flipYCoordinates){
            newPos.y = -newPos.y;
        }
    }
    
    if(!_bounces){
        newPos = [self clampToBounds:newPos];
    }
    

    self.camera.position = newPos;

    [self scrollViewDidScroll];
}

- (void) update:(CCTime)df
{
    float fps = 1.0/df;
    float p = 60/fps;

	if (! CGPointEqualToPoint(_velocity, CGPointZero) ) {
		[self scrollViewDidScroll];
	} else {

#if __CC_PLATFORM_IOS
		if ( _decelerating && !(_animatingX || _animatingY)) {
			[self scrollViewDidEndDecelerating];
			_decelerating = NO;
		}
#elif __CC_PLATFORM_MAC
		if ( _decelerating && CGPointEqualToPoint(_lastPosition, self.scrollPosition)) {
			[self scrollViewDidEndDecelerating];
			_decelerating = NO;
		}
#endif
    }

    if (!_isPanning)
    {
        if (_velocity.x != 0 || _velocity.y != 0)
        {
            CGPoint delta = ccpMult(_velocity, df);
            
            self.camera.position = ccpSub(self.camera.position, delta);
            
            [self updateAndroidScrollTranslation:CGPointMake(self.camera.position.x * -1, self.camera.position.y * -1)]; // TODO: not sure on this android api, might not need to be flipped anymore

            // Deaccelerate layer
            float deaccelerationX = kCCScrollViewDeacceleration;
            float deaccelerationY = kCCScrollViewDeacceleration;
            
            // Adjust for frame rate
            deaccelerationX = powf(deaccelerationX, p);
            deaccelerationY = powf(deaccelerationY, p);
            
            // Update velocity
            _velocity.x *= deaccelerationX;
            _velocity.y *= deaccelerationY;
            
            // If velocity is low make it 0
            if (fabs(_velocity.x) < kCCScrollViewVelocityLowerCap) _velocity.x = 0;
            if (fabs(_velocity.y) < kCCScrollViewVelocityLowerCap) _velocity.y = 0;
        }
        
        CGPoint posTarget = self.scrollPosition;
        if(_flipYCoordinates){
            posTarget.y = -posTarget.y;
        }
        
        if (_bounces)
        {
            
            // Bounce back to edge if layer is too far outside of the scroll area or if it is outside and moving slowly
            BOOL bounceToEdge = NO;
            if (!_animatingX && !_pagingEnabled)
            {
                if ((posTarget.x < self.minScrollX && fabs(_velocity.x) < kCCScrollViewMinVelocityBeforeBounceBack) ||
                    (posTarget.x < self.minScrollX - kCCScrollViewMaxOuterDistBeforeBounceBack))
                {
                    bounceToEdge = YES;
                }
                
                if ((posTarget.x > self.maxScrollX && fabs(_velocity.x) < kCCScrollViewMinVelocityBeforeBounceBack) ||
                    (posTarget.x > self.maxScrollX + kCCScrollViewMaxOuterDistBeforeBounceBack))
                {
                    bounceToEdge = YES;
                }
            }
            if (!_animatingY && !_pagingEnabled)
            {
                if ((posTarget.y < self.minScrollY && fabs(_velocity.y) < kCCScrollViewMinVelocityBeforeBounceBack) ||
                    (posTarget.y < self.minScrollY - kCCScrollViewMaxOuterDistBeforeBounceBack))
                {
                    bounceToEdge = YES;
                }
                
                if ((posTarget.y > self.maxScrollY && fabs(_velocity.y) < kCCScrollViewMinVelocityBeforeBounceBack) ||
                    (posTarget.y > self.maxScrollY + kCCScrollViewMaxOuterDistBeforeBounceBack))
                {
                    bounceToEdge = YES;
                }
            }
            
            if (bounceToEdge)
            {
                // Setting the scroll position to the current position will force it to be in bounds
                [self setScrollPosition:posTarget animated:YES];
            }
        }
        else
        {
            if (!_pagingEnabled)
            {
                // Make sure we are within bounds
                [self setScrollPosition:posTarget animated:NO];
            }
        }
    }
}

- (void) touchBeganAtTranslation:(CGPoint) rawTranslation
{
    [self scrollViewWillBeginDragging];
    _animatingX = NO;
    _animatingY = NO;
    _rawTranslationStart = rawTranslation;
    _startScrollPos = self.scrollPosition;
    
    _isPanning = YES;
    [self.camera stopActionByName:CCScrollViewActionXTag];
    [self.camera stopActionByName:CCScrollViewActionYTag];

}

- (void) handleTouchEnded:(CGPoint) rawVelocity
{
    CCDirector* dir = [CCDirector currentDirector];

    rawVelocity = [dir convertToGL:rawVelocity];
    rawVelocity = [self convertToNodeSpace:rawVelocity];
    
    // Calculate the velocity in node space
    CGPoint ref = [dir convertToGL:CGPointZero];
    ref = [self convertToNodeSpace:ref];
    
    _velocity = ccpSub(rawVelocity, ref);
    
    // Check if scroll directions has been disabled
    if (!_horizontalScrollEnabled) _velocity.x = 0;
    if (!_verticalScrollEnabled) _velocity.y = 0;
    [self scrollViewDidEndDraggingAndWillDecelerate:!CGPointEqualToPoint(_velocity, CGPointZero)];
    
    // Setup a target if paging is enabled
    if (_pagingEnabled)
    {
        CGPoint posTarget = CGPointZero;
        
        // Calculate new horizontal page
        int pageX = roundf(self.scrollPosition.x/self.contentSizeInPoints.width);
        
        if (fabs(_velocity.x) >= kCCScrollViewAutoPageSpeed && _horizontalPage == pageX)
        {
            if (_velocity.x < 0) pageX += 1;
            else pageX -= 1;
        }
        
        pageX = clampf(pageX, 0, self.numHorizontalPages -1);
        _horizontalPage = pageX;
        
        posTarget.x = pageX * self.contentSizeInPoints.width;
        
        // Calculate new vertical page
        int pageY = roundf(self.scrollPosition.y/self.contentSizeInPoints.height);
        
        if (fabs(_velocity.y) >= kCCScrollViewAutoPageSpeed && _verticalPage == pageY)
        {
            if (_velocity.y < 0) pageY += 1;
            else pageY -= 1;
        }
        
        pageY = clampf(pageY, 0, self.numVerticalPages -1);
        _verticalPage = pageY;
        
        posTarget.y = pageY * self.contentSizeInPoints.height;
        
        [self setScrollPosition:posTarget animated:YES];
        
        _velocity = CGPointZero;
    }
    [self scrollViewWillBeginDecelerating];
    
    _decelerating = YES;
    _isPanning = NO;
}

#pragma mark - Gesture recognizer: iOS

#if __CC_PLATFORM_IOS

- (void)handlePan:(UIGestureRecognizer *)gestureRecognizer
{
    CCDirector* dir = self.director;
    [CCDirector pushCurrentDirector:self.director];
    
    UIPanGestureRecognizer* pgr = (UIPanGestureRecognizer*)gestureRecognizer;
    
    CGPoint rawTranslation = [pgr translationInView:dir.view];
    rawTranslation = [dir convertToGL:rawTranslation];
    rawTranslation = [self convertToNodeSpace:rawTranslation];
    
    if (pgr.state == UIGestureRecognizerStateBegan)
    {
        [self touchBeganAtTranslation:rawTranslation];
    }
    else if (pgr.state == UIGestureRecognizerStateChanged)
    {
        // Calculate the translation in node space
        CGPoint translation = ccpSub(_rawTranslationStart, rawTranslation);

        [self handlePanFrom:_startScrollPos delta:translation];
    }
    else if (pgr.state == UIGestureRecognizerStateEnded)
    {
        CGPoint velocityRaw = [pgr velocityInView:dir.view];
        [self handleTouchEnded: velocityRaw];
    }
    else if (pgr.state == UIGestureRecognizerStateCancelled)
    {
        _isPanning = NO;
        _velocity = CGPointZero;
        _animatingX = NO;
        _animatingY = NO;
        
        [self setScrollPosition:self.scrollPosition animated:NO];
    }
    [CCDirector popCurrentDirector];
}

- (void) handleTap:(UIGestureRecognizer *)gestureRecognizer
{
    // Stop layer from moving
    _velocity = CGPointZero;
    
    // Snap to a whole position
    CGPoint pos = self.camera.position;
    pos.x = roundf(pos.x);
    pos.y = roundf(pos.y);
    self.camera.position = pos;
}

- (BOOL) isAncestor:(CCNode*) ancestor toNode:(CCNode*)node
{
    for (CCNode* child in node.children)
    {
        if (child == ancestor) return YES;
        if ([self isAncestor:ancestor toNode:child]) return YES;
    }
    return NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(CCTouch *)touch
{
    if (!self.camera) return NO;
    if (!self.visible) return NO;
    if (!self.userInteractionEnabled) return NO;
    
    // Check for responders above this scroll view (and not within it). If there are responders above touch should go to them instead.
    CGPoint touchWorldPos = [touch locationInWorld];
    
    NSArray* responders = [self.director.responderManager nodesAtPoint:touchWorldPos];
    BOOL foundSelf = NO;
    for (int i = (int)responders.count - 1; i >= 0; i--)
    {
        CCNode* responder = [responders objectAtIndex:i];
        if (foundSelf)
        {
            if (![self isAncestor:responder toNode:self])
            {
                return NO;
            }
        }
        else if (responder == self)
        {
            foundSelf = YES;
        }
    }
    
    
    // Allow touches to children if view is moving slowly
    BOOL slowMove = (fabs(_velocity.x) < kCCScrollViewAllowInteractionBelowVelocity &&
                     fabs(_velocity.y) < kCCScrollViewAllowInteractionBelowVelocity);
    
    if (gestureRecognizer == _tapRecognizer && (slowMove || _isPanning))
    {
        return NO;
    }
    
    [CCDirector pushCurrentDirector:self.director];
    // Check that the gesture is in the scroll view
    BOOL hit = [self clippedHitTestWithWorldPos:[touch locationInWorld]];
    [CCDirector popCurrentDirector];
    
    return hit;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return (otherGestureRecognizer == _panRecognizer || otherGestureRecognizer == _tapRecognizer);
}

- (void) onEnterTransitionDidFinish
{
    // Add recognizers to view
    UIView* view = self.director.view;
    
    NSMutableArray* recognizers = [view.gestureRecognizers mutableCopy];
    if (!recognizers) recognizers = [NSMutableArray arrayWithCapacity:2];
    [recognizers insertObject:_panRecognizer atIndex:0];
    [recognizers insertObject:_tapRecognizer atIndex:0];
    
    view.gestureRecognizers = recognizers;
    [super onEnterTransitionDidFinish];
}

- (void) onExitTransitionDidStart
{
    // Remove recognizers from view
    UIView* view = self.director.view;
    
    NSMutableArray* recognizers = [view.gestureRecognizers mutableCopy];
    [recognizers removeObject:_panRecognizer];
    [recognizers removeObject:_tapRecognizer];
    
    view.gestureRecognizers = recognizers;
    
    [super onExitTransitionDidStart];
}

#pragma mark Android
#elif __CC_PLATFORM_ANDROID

- (void) onEnterTransitionDidFinish
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_detector)
        {
            [[self.director view] addGestureDetector:_detector];
        }
    });
    [super onEnterTransitionDidFinish];
}

- (void) onExitTransitionDidStart
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_detector)
        {
            [[self.director view] removeGestureDetector:_detector];
        }
    });
    
    [super onExitTransitionDidStart];
}

- (CCTouchPhase)handleGestureEvent:(AndroidMotionEvent *)start end:(AndroidMotionEvent *)end
{
    CCTouchPhase phase = CCTouchPhaseStationary;
    switch (start.action & AndroidMotionEventActionMask) {
        case AndroidMotionEventActionPointerDown:
        case AndroidMotionEventActionDown:
            phase = CCTouchPhaseBegan;
            break;
        case AndroidMotionEventActionMove:
            phase = CCTouchPhaseMoved;
            break;
        case AndroidMotionEventActionPointerUp:
        case AndroidMotionEventActionUp:
            phase = CCTouchPhaseEnded;
            break;
        case AndroidMotionEventActionCancel:
            phase = CCTouchPhaseCancelled;
            break;
        default:
            phase = CCTouchPhaseStationary;
    }
    switch (end.action & AndroidMotionEventActionMask) {
        case AndroidMotionEventActionPointerDown:
        case AndroidMotionEventActionDown:
            phase = CCTouchPhaseBegan;
            break;
        case AndroidMotionEventActionMove:
            phase = CCTouchPhaseMoved;
            break;
        case AndroidMotionEventActionPointerUp:
        case AndroidMotionEventActionUp:
            phase = CCTouchPhaseEnded;
            break;
        case AndroidMotionEventActionCancel:
            phase = CCTouchPhaseCancelled;
            break;
        default:
            phase = CCTouchPhaseStationary;
    }
    
    return phase;
}

- (BOOL)onScroll:(AndroidMotionEvent *)start end:(AndroidMotionEvent *)end distanceX:(float)dx distanceY:(float)dy
{
    _isPanning = YES;
    _velocity = CGPointZero;
    
    // Note about start and end events: We will get a CCTouchPhaseBegan for the start event, followed by CCTouchPhaseMoved in the end event
    CCTouchPhase phase = [self handleGestureEvent:start end:end];
    
    if(phase == CCTouchPhaseCancelled || phase == CCTouchPhaseEnded)
        _rawScrollTranslation = CGPointMake(0.0f, 0.0f);
    
    CCDirector *director = self.director;
    float scaleFactor = [director view].contentScaleFactor;
    
    dx /= scaleFactor;
    dy /= scaleFactor;

    _rawScrollTranslation.x -= dx;
    _rawScrollTranslation.y -= dy;
    
    [[CCActivity currentActivity] runOnGameThread:^{
        [CCDirector pushCurrentDirector:director];
        
        CGPoint translation = [director convertToGL:_rawScrollTranslation];
        translation = [self convertToNodeSpace:translation];
        
        // Is it possible for this to be anything other than a moved event?
        // Somebody with more Android experience should weigh in.
        if (phase == CCTouchPhaseBegan)
        {
            [self touchBeganAtTranslation:translation];
        }
        else if (phase == CCTouchPhaseMoved)
        {
            // Calculate the translation in node space
            translation = ccpSub(_rawTranslationStart, translation);
            [self handlePanFrom:_startScrollPos delta:translation];
        }
        else if (phase == CCTouchPhaseEnded)
        {
            // onScroll does not recieve end events.
        }
        else if (phase == CCTouchPhaseCancelled)
        {
            _isPanning = NO;
            _velocity = CGPointZero;
            _animatingX = NO;
            _animatingY = NO;
            
            [self setScrollPosition:self.scrollPosition animated:NO];
        }
        
        [CCDirector popCurrentDirector];
    } waitUntilDone:YES];
    
    return YES;
}

- (BOOL)onFling:(AndroidMotionEvent *)start end:(AndroidMotionEvent *)end velocityX:(float)vx velocityY:(float)vy
{
    // Static!?! That can't be right.
    static CGPoint rawTranslationFling;

    CCTouchPhase phase = [self handleGestureEvent:start end:end];
    
    if(phase == CCTouchPhaseCancelled || phase == CCTouchPhaseEnded)
        rawTranslationFling = CGPointMake(0.0f, 0.0f);

    CCDirector* director = self.director;
    float scaleFactor = [director view].contentScaleFactor;
    float x0 = [start xForPointerIndex:0] / scaleFactor;
    float x1 = [end xForPointerIndex:0] / scaleFactor;
    
    float y0 = [start yForPointerIndex:0] / scaleFactor;
    float y1 = [end yForPointerIndex:0] / scaleFactor;
    
    int64_t t0 = start.eventTime;
    int64_t t1 = end.eventTime;
    
    vx /= scaleFactor;
    vy /= scaleFactor;
    
    float dx = (x1 - x0) / scaleFactor;
    float dy = (y1 - y0) / scaleFactor;
    
    CGPoint velocityRaw = CGPointMake(vx, vy);
    rawTranslationFling.x -= dx / scaleFactor;
    rawTranslationFling.y -= dy / scaleFactor;
    
    [[CCActivity currentActivity] runOnGameThread:^{
        [CCDirector pushCurrentDirector:director];

        CGPoint translation = [director convertToGL:rawTranslationFling];
        translation = [self convertToNodeSpace:translation];
        
        // Do fling events ever send anything other than end events?
        // Somebody with more Android experience should weigh in.
        if (phase == CCTouchPhaseBegan)
        {
            [self scrollViewWillBeginDragging];
        }
        else if (phase == CCTouchPhaseMoved)
        {
            // stub
        }
        else if (phase == CCTouchPhaseEnded)
        {
            [self handleTouchEnded:velocityRaw];
        }
        else if (phase == CCTouchPhaseCancelled)
        {
            _isPanning = NO;
            _velocity = CGPointZero;
            _animatingX = NO;
            _animatingY = NO;
            
            [self setScrollPosition:self.scrollPosition animated:NO];
        }
        
        [CCDirector popCurrentDirector];
    } waitUntilDone:YES];
    return YES;
}

#pragma mark Mac
#elif __CC_PLATFORM_MAC

#define kCCScrollViewMinPagingDelta 7

- (void)scrollWheel:(NSEvent *)theEvent
{
	CCDirector* dir = self.director;

    float deltaX = theEvent.deltaX;
    float deltaY = theEvent.deltaY;

    switch (theEvent.phase) {
        case NSEventPhaseBegan:
            [self scrollViewWillBeginDragging];
            break;
        case NSEventPhaseEnded:
			//TODO: add logic to determine if it will decelerate
            [self scrollViewDidEndDraggingAndWillDecelerate:YES];
			_decelerating = YES;
        default:
            break;
    }

    if (theEvent.momentumPhase == NSEventPhaseBegan)
	{
		[self scrollViewWillBeginDecelerating];
    }

    // Calculate the delta in node space
    CGPoint ref = [dir convertToGL:CGPointZero];
    ref = [self convertToNodeSpace:ref];
    
    CGPoint deltaRaw = ccp(deltaX, deltaY);
    deltaRaw = [dir convertToGL:deltaRaw];
    
    deltaRaw = [self convertToNodeSpace:deltaRaw];
    
    CGPoint delta = ccpSub(deltaRaw, ref);
    
    // Flip coordinates
    if (_flipYCoordinates) delta.y = -delta.y;
    delta.x = -delta.x;

    // Handle disabled x/y axis
    if (!_horizontalScrollEnabled) delta.x = 0;
    if (!_verticalScrollEnabled) delta.y = 0;
    
    if (_pagingEnabled)
    {
        if (!_animatingX && _horizontalScrollEnabled)
        {
            // Update horizontal page
            int xPage = self.horizontalPage;
            int xOldPage = xPage;
            
            if (fabs(delta.x) >= kCCScrollViewMinPagingDelta)
            {
                if (delta.x > 0) xPage += 1;
                else xPage -= 1;
            }
            xPage = clampf(xPage, 0, self.numHorizontalPages - 1);
            
            if (xPage != xOldPage)
            {
                [self setHorizontalPage:xPage animated:YES];
            }
        }
        
        if (!_animatingY && _verticalScrollEnabled)
        {
            // Update horizontal page
            int yPage = self.verticalPage;
            int yOldPage = yPage;
            
            if (fabs(delta.y) >= kCCScrollViewMinPagingDelta)
            {
                if (delta.y > 0) yPage += 1;
                else yPage -= 1;
            }
            yPage = clampf(yPage, 0, self.numVerticalPages - 1);
            
            if (yPage != yOldPage)
            {
                [self setVerticalPage:yPage animated:YES];
            }
        }
    }
    else
    {
        // Update scroll position
        CGPoint scrollPos = self.scrollPosition;
        scrollPos.x += delta.x;
        scrollPos.y = (_flipYCoordinates ? -scrollPos.y : scrollPos.y) + delta.y;
		self.scrollPosition = scrollPos;
    }
    
	[self scrollViewDidScroll];
}

#endif


#pragma mark - CCScrollViewDelegate Helpers

- (void)scrollViewDidScroll
{
    if ( [self.delegate respondsToSelector:@selector(scrollViewDidScroll:)] )
    {
        [self.delegate scrollViewDidScroll:self];
    }
}

- (void)scrollViewWillBeginDragging
{
    if ( [self.delegate respondsToSelector:@selector(scrollViewWillBeginDragging:)])
    {
        [self.delegate scrollViewWillBeginDragging:self];
    }
}
- (void)scrollViewDidEndDraggingAndWillDecelerate:(BOOL)decelerate
{
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
    {
        [self.delegate scrollViewDidEndDragging:self
                                 willDecelerate:decelerate];
    }
}
- (void)scrollViewWillBeginDecelerating
{
	if ( !_pagingEnabled )
    {
		if ( [self.delegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)])
		{
			[self.delegate scrollViewWillBeginDecelerating:self];
		}
	}

}
- (void)scrollViewDidEndDecelerating
{
    if ( [self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
    {
        [self.delegate scrollViewDidEndDecelerating:self];
    }
}

@end
