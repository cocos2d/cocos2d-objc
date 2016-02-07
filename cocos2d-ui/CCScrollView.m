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

#import "CCScrollView.h"
#import "CCDirector.h"
#import "CGPointExtension.h"
#import "CCActionInterval.h"
#import "CCActionEase.h"
#import "CCActionInstant.h"
#import "CCResponderManager.h"
#import "CCTouch.h"


#if __CC_PLATFORM_IOS

#import <UIKit/UIGestureRecognizerSubclass.h>

#elif __CC_PLATFORM_MAC

#endif

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

#define kCCScrollViewActionXTag 8080
#define kCCScrollViewActionYTag 8081

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

- (id) initWithContentNode:(CCNode*)contentNode
{
    self = [super init];
    if (!self) return NULL;
    
    _flipYCoordinates = YES;
    
    // Setup content node
    self.contentSize = CGSizeMake(1, 1);
    self.contentSizeType = CCSizeTypeNormalized;
    self.contentNode = contentNode;
    
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
    if (_contentNode == contentNode) return;
    
    // Replace content node
    if (_contentNode) [self removeChild:_contentNode];
    _contentNode = contentNode;
    if (contentNode)
    {
        [self addChild:contentNode];
        
        // Update coordinate flipping
        self.flipYCoordinates = self.flipYCoordinates;
    }
}

- (void) setFlipYCoordinates:(BOOL)flipYCoordinates
{
    if (flipYCoordinates)
    {
        _contentNode.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerTopLeft);
        _contentNode.anchorPoint = ccp(0,1);
    }
    else
    {
        _contentNode.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerBottomLeft);
        _contentNode.anchorPoint = ccp(0,0);
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
    if (!_contentNode) return 0;
    
    float maxScroll = _contentNode.contentSizeInPoints.width - self.contentSizeInPoints.width;
    if (maxScroll < 0) maxScroll = 0;
    
    return maxScroll;
}

- (float) minScrollY
{
    return 0;
}

- (float) maxScrollY
{
    if (!_contentNode) return 0;
    
    float maxScroll = _contentNode.contentSizeInPoints.height - self.contentSizeInPoints.height;
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
    if (!self.contentSizeInPoints.width || !_contentNode.contentSizeInPoints.width) return 0;
    
    return roundf(_contentNode.contentSizeInPoints.width / self.contentSizeInPoints.width);
}

- (int) numVerticalPages
{
    if (!_pagingEnabled) return 0;
    if (!self.contentSizeInPoints.height || !_contentNode.contentSizeInPoints.height) return 0;
    
    return roundf(_contentNode.contentSizeInPoints.height / self.contentSizeInPoints.height);
}

#pragma mark Panning and setting position

- (void) setScrollPosition:(CGPoint)newPos
{
    [self setScrollPosition:newPos animated:NO];
}

- (void) setScrollPosition:(CGPoint)newPos animated:(BOOL)animated
{
    // Check bounds
	newPos.x = MAX(MIN(newPos.x, self.maxScrollX), self.minScrollX);
	newPos.y = MAX(MIN(newPos.y, self.maxScrollY), self.minScrollY);
    
    BOOL xMoved = (newPos.x != self.scrollPosition.x);
    BOOL yMoved = (newPos.y != self.scrollPosition.y);

    if (animated)
    {
#if CC_ENABLE_DELEGATE_CALLS_DURING_ANIMATIONS
        [self scrollViewWillBeginDragging];
#endif
        CGPoint oldPos = self.scrollPosition;
        float dist = ccpDistance(newPos, oldPos);
        
        float duration = clampf(dist / kCCScrollViewSnapDurationFallOff, 0, kCCScrollViewSnapDuration);
        
        if (xMoved)
        {
            // Animate horizontally
            
            _velocity.x = 0;
            _animatingX = YES;
            
            // Create animation action
            CCActionInterval* action = [CCActionEaseOut actionWithAction:[[CCMoveToX alloc] initWithDuration:duration positionX:-newPos.x callback:^{
				[self scrollViewDidScroll];
			}] rate:2];
            CCActionCallFunc* callFunc = [CCActionCallFunc actionWithTarget:self selector:@selector(xAnimationDone)];
            action = [CCActionSequence actions:action, callFunc, nil];
            action.tag = kCCScrollViewActionXTag;
            [_contentNode stopActionByTag:kCCScrollViewActionXTag];
            [_contentNode runAction:action];
        }
        if (yMoved)
        {
            // Animate vertically
            
            _velocity.y = 0;
            _animatingY = YES;
            
            // Create animation action
            CCActionInterval* action = [CCActionEaseOut actionWithAction:[[CCMoveToY alloc] initWithDuration:duration positionY:-newPos.y callback:^{
				[self scrollViewDidScroll];
			}] rate:2];
            CCActionCallFunc* callFunc = [CCActionCallFunc actionWithTarget:self selector:@selector(yAnimationDone)];
            action = [CCActionSequence actions:action, callFunc, nil];
            action.tag = kCCScrollViewActionYTag;
            [_contentNode stopActionByTag:kCCScrollViewActionYTag];
            [_contentNode runAction:action];
        }
        
    }
    else
    {
#if __CC_PLATFORM_MAC
		_lastPosition = self.scrollPosition;
#endif
        [_contentNode stopActionByTag:kCCScrollViewActionXTag];
        [_contentNode stopActionByTag:kCCScrollViewActionYTag];
        _contentNode.position = ccpMult(newPos, -1);
    }
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
    return ccpMult(_contentNode.position, -1);
}

- (void) panLayerToTarget:(CGPoint) newPos
{
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
    }
    else
    {
        if (newPos.x > self.maxScrollX) newPos.x = self.maxScrollX;
        if (newPos.x < self.minScrollX) newPos.x = self.minScrollX;
        if (newPos.y > self.maxScrollY) newPos.y = self.maxScrollY;
        if (newPos.y < self.minScrollY) newPos.y = self.minScrollY;
    }
    [self scrollViewDidScroll];
    
    _contentNode.position = ccpMult(newPos, -1);
}

- (void) update:(CCTime)df
{
    float fps = 1.0/df;
    float p = 60/fps;

	if (! CGPointEqualToPoint(_velocity, CGPointZero) ) {
		[self scrollViewDidScroll];
	} else {

#if __CC_PLATFORM_IOS
		if ( _decelerating
#if !CC_ENABLE_DELEGATE_CALLS_DURING_ANIMATIONS
            && !(_animatingX || _animatingY)
#endif
            ) {
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
            
            _contentNode.position = ccpAdd(_contentNode.position, delta);

            // Deaccelerate layer
            float deaccelerationX = kCCScrollViewDeacceleration;
            float deaccelerationY = kCCScrollViewDeacceleration;
            
            // Adjust for frame rate
            deaccelerationX = powf(deaccelerationX, p);
            
            // Update velocity
            _velocity.x *= deaccelerationX;
            _velocity.y *= deaccelerationY;
            
            // If velocity is low make it 0
            if (fabs(_velocity.x) < kCCScrollViewVelocityLowerCap) _velocity.x = 0;
            if (fabs(_velocity.y) < kCCScrollViewVelocityLowerCap) _velocity.y = 0;
        }
        
        if (_bounces)
        {
            // Bounce back to edge if layer is too far outside of the scroll area or if it is outside and moving slowly
            BOOL bounceToEdge = NO;
            CGPoint posTarget = self.scrollPosition;
            
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
                [self setScrollPosition:self.scrollPosition animated:NO];
            }
        }
    }
}

#pragma mark Gesture recognizer

#if __CC_PLATFORM_IOS

- (void)handlePan:(UIGestureRecognizer *)gestureRecognizer
{
    CCDirector* dir = [CCDirector sharedDirector];
    UIPanGestureRecognizer* pgr = (UIPanGestureRecognizer*)gestureRecognizer;
    
    CGPoint rawTranslation = [pgr translationInView:dir.view];
    rawTranslation = [dir convertToGL:rawTranslation];
    rawTranslation = [self convertToNodeSpace:rawTranslation];
    
    if (pgr.state == UIGestureRecognizerStateBegan)
    {
		[self scrollViewWillBeginDragging];
        _animatingX = NO;
        _animatingY = NO;
        _rawTranslationStart = rawTranslation;
        _startScrollPos = self.scrollPosition;
        
        _isPanning = YES;
        [_contentNode stopActionByTag:kCCScrollViewActionXTag];
        [_contentNode stopActionByTag:kCCScrollViewActionYTag];
    }
    else if (pgr.state == UIGestureRecognizerStateChanged)
    {
        // Calculate the translation in node space
        CGPoint translation = ccpSub(_rawTranslationStart, rawTranslation);
        
        // Check if scroll directions has been disabled
        if (!_horizontalScrollEnabled) translation.x = 0;
        if (!_verticalScrollEnabled) translation.y = 0;
        
        if (_flipYCoordinates) translation.y = -translation.y;
        
        // Check bounds
        CGPoint newPos = ccpAdd(_startScrollPos, translation);
        
        // Update position
        [self panLayerToTarget:newPos];
    }
    else if (pgr.state == UIGestureRecognizerStateEnded)
    {

        // Calculate the velocity in node space
        CGPoint ref = [dir convertToGL:CGPointZero];
        ref = [self convertToNodeSpace:ref];
        
        CGPoint velocityRaw = [pgr velocityInView:dir.view];
        velocityRaw = [dir convertToGL:velocityRaw];
        velocityRaw = [self convertToNodeSpace:velocityRaw];
        
        _velocity = ccpSub(velocityRaw, ref);
        if (_flipYCoordinates) _velocity.y = -_velocity.y;
        
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
    else if (pgr.state == UIGestureRecognizerStateCancelled)
    {
        _isPanning = NO;
        _velocity = CGPointZero;
        _animatingX = NO;
        _animatingY = NO;
        
        [self setScrollPosition:self.scrollPosition animated:NO];
    }
}

- (void) handleTap:(UIGestureRecognizer *)gestureRecognizer
{
    // Stop layer from moving
    _velocity = CGPointZero;
    
    // Snap to a whole position
    CGPoint pos = _contentNode.position;
    pos.x = roundf(pos.x);
    pos.y = roundf(pos.y);
    _contentNode.position = pos;
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
    if (!_contentNode) return NO;
    if (!self.visible) return NO;
    if (!self.userInteractionEnabled) return NO;
    
    // Check for responders above this scroll view (and not within it). If there are responders above touch should go to them instead.
    CGPoint touchWorldPos = [touch locationInWorld];
    
    NSArray* responders = [[CCDirector sharedDirector].responderManager nodesAtPoint:touchWorldPos];
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
    
    // Check that the gesture is in the scroll view
    return [self hitTestWithWorldPos:[touch locationInWorld]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return (otherGestureRecognizer == _panRecognizer || otherGestureRecognizer == _tapRecognizer);
}

- (void) onEnterTransitionDidFinish
{
    NSAssert(_panRecognizer.view == nil && _tapRecognizer.view == nil, @"CCScrollView: Probable double call into onEnterTransitionDidFinish - gesture recognizers are already added");

    // Add recognizers to view
    UIView* view = [CCDirector sharedDirector].view;
    
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
    UIView* view = [CCDirector sharedDirector].view;
    
    NSMutableArray* recognizers = [view.gestureRecognizers mutableCopy];
    [recognizers removeObject:_panRecognizer];
    [recognizers removeObject:_tapRecognizer];
    
    view.gestureRecognizers = recognizers;
    
    [super onExitTransitionDidStart];
}

#elif __CC_PLATFORM_MAC

#define kCCScrollViewMinPagingDelta 7

- (void)scrollWheel:(NSEvent *)theEvent
{
	CCDirector* dir = [CCDirector sharedDirector];

    float deltaX = theEvent.deltaX;
    float deltaY = theEvent.deltaY;

	[self scrollViewDidScroll];

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
        scrollPos = ccpAdd(delta, scrollPos);
		self.scrollPosition = scrollPos;
    }
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
