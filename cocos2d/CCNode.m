/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Valentin Milea
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
 */

#import "CCNode.h"
#import "CCGrid.h"
#import "CCDirector.h"
#import "CCActionManager.h"
#import "CCCamera.h"
#import "CCScheduler.h"
#import "ccConfig.h"
#import "ccMacros.h"
#import "Support/CGPointExtension.h"
#import "Support/ccCArray.h"
#import "Support/TransformUtils.h"
#import "ccMacros.h"
#import "CCGLProgram.h"

// externals
#import "kazmath/GL/matrix.h"

#ifdef __CC_PLATFORM_IOS
#import "Platforms/iOS/CCDirectorIOS.h"
#endif


#if CC_NODE_RENDER_SUBPIXEL
#define RENDER_IN_SUBPIXEL
#else
#define RENDER_IN_SUBPIXEL (NSInteger)
#endif


@interface CCNode ()
// lazy allocs
-(void) childrenAlloc;
// helper that reorder a child
-(void) insertChild:(CCNode*)child z:(NSInteger)z;
// used internally to alter the zOrder variable. DON'T call this method manually
-(void) _setZOrder:(NSInteger) z;
-(void) detachChild:(CCNode *)child cleanup:(BOOL)doCleanup;
@end

@implementation CCNode

// XXX: Yes, nodes might have a sort problem once every 15 days if the game runs at 60 FPS and each frame sprites are reordered.
static NSUInteger globalOrderOfArrival = 1;

@synthesize children = children_;
@synthesize visible = visible_;
@synthesize parent = parent_;
@synthesize grid = grid_;
@synthesize zOrder = zOrder_;
@synthesize tag = tag_;
@synthesize vertexZ = vertexZ_;
@synthesize isRunning = isRunning_;
@synthesize userData = userData_, userObject = userObject_;
@synthesize	shaderProgram = shaderProgram_;
@synthesize orderOfArrival = orderOfArrival_;
@synthesize glServerState = glServerState_;

#pragma mark CCNode - Transform related properties

@synthesize rotation = rotation_, scaleX = scaleX_, scaleY = scaleY_;
@synthesize position = position_;
@synthesize anchorPoint = anchorPoint_, anchorPointInPoints = anchorPointInPoints_;
@synthesize contentSize = contentSize_;
@synthesize ignoreAnchorPointForPosition = ignoreAnchorPointForPosition_;
@synthesize skewX = skewX_, skewY = skewY_;

#pragma mark CCNode - Init & cleanup

+(id) node
{
	return [[[self alloc] init] autorelease];
}

-(id) init
{
	if ((self=[super init]) ) {

		isRunning_ = NO;

		skewX_ = skewY_ = 0.0f;
		rotation_ = 0.0f;
		scaleX_ = scaleY_ = 1.0f;
        position_ = CGPointZero;
        contentSize_ = CGSizeZero;
		anchorPointInPoints_ = anchorPoint_ = CGPointZero;


		// "whole screen" objects. like Scenes and Layers, should set ignoreAnchorPointForPosition to YES
		ignoreAnchorPointForPosition_ = NO;

		isTransformDirty_ = isInverseDirty_ = YES;

		vertexZ_ = 0;

		grid_ = nil;

		visible_ = YES;

		tag_ = kCCNodeTagInvalid;

		zOrder_ = 0;

		// lazy alloc
		camera_ = nil;

		// children (lazy allocs)
		children_ = nil;

		// userData is always inited as nil
		userData_ = NULL;
		userObject_ = nil;

		//initialize parent to nil
		parent_ = nil;

		shaderProgram_ = nil;

		orderOfArrival_ = 0;

		glServerState_ = CC_GL_BLEND;
		
		// set default scheduler and actionManager
		CCDirector *director = [CCDirector sharedDirector];
		self.actionManager = [director actionManager];
		self.scheduler = [director scheduler];
	}

	return self;
}

- (void)cleanup
{
	// actions
	[self stopAllActions];
	[self unscheduleAllSelectors];

	// timers
	[children_ makeObjectsPerformSelector:@selector(cleanup)];
}

- (NSString*) description
{
	return [NSString stringWithFormat:@"<%@ = %p | Tag = %ld>", [self class], self, (long)tag_];
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);

	[actionManager_ release];
	[scheduler_ release];
	[camera_ release];
	[grid_ release];
	[shaderProgram_ release];
	[userObject_ release];

	// children
	CCNode *child;
	CCARRAY_FOREACH(children_, child)
		child.parent = nil;

	[children_ release];

	[super dealloc];
}

#pragma mark Setters

// getters synthesized, setters explicit
-(void) setRotation: (float)newRotation
{
	rotation_ = newRotation;
	isTransformDirty_ = isInverseDirty_ = YES;
}

-(void) setScaleX: (float)newScaleX
{
	scaleX_ = newScaleX;
	isTransformDirty_ = isInverseDirty_ = YES;
}

-(void) setScaleY: (float)newScaleY
{
	scaleY_ = newScaleY;
	isTransformDirty_ = isInverseDirty_ = YES;
}

-(void) setSkewX:(float)newSkewX
{
	skewX_ = newSkewX;
	isTransformDirty_ = isInverseDirty_ = YES;
}

-(void) setSkewY:(float)newSkewY
{
	skewY_ = newSkewY;
	isTransformDirty_ = isInverseDirty_ = YES;
}

-(void) setPosition: (CGPoint)newPosition
{
	position_ = newPosition;
	isTransformDirty_ = isInverseDirty_ = YES;
}

-(void) setIgnoreAnchorPointForPosition: (BOOL)newValue
{
	if( newValue != ignoreAnchorPointForPosition_ ) {
		ignoreAnchorPointForPosition_ = newValue;
		isTransformDirty_ = isInverseDirty_ = YES;
	}
}

-(void) setAnchorPoint:(CGPoint)point
{
	if( ! CGPointEqualToPoint(point, anchorPoint_) ) {
		anchorPoint_ = point;
		anchorPointInPoints_ = ccp( contentSize_.width * anchorPoint_.x, contentSize_.height * anchorPoint_.y );
		isTransformDirty_ = isInverseDirty_ = YES;
	}
}

-(void) setContentSize:(CGSize)size
{
	if( ! CGSizeEqualToSize(size, contentSize_) ) {
		contentSize_ = size;

		anchorPointInPoints_ = ccp( contentSize_.width * anchorPoint_.x, contentSize_.height * anchorPoint_.y );
		isTransformDirty_ = isInverseDirty_ = YES;
	}
}

- (CGRect) boundingBox
{
	CGRect rect = CGRectMake(0, 0, contentSize_.width, contentSize_.height);
	return CGRectApplyAffineTransform(rect, [self nodeToParentTransform]);
}

-(void) setVertexZ:(float)vertexZ
{
	vertexZ_ = vertexZ;
}

-(float) scale
{
	NSAssert( scaleX_ == scaleY_, @"CCNode#scale. ScaleX != ScaleY. Don't know which one to return");
	return scaleX_;
}

-(void) setScale:(float) s
{
	scaleX_ = scaleY_ = s;
	isTransformDirty_ = isInverseDirty_ = YES;
}

- (void) setZOrder:(NSInteger)zOrder
{
	[self _setZOrder:zOrder];

    if (parent_)
        [parent_ reorderChild:self z:zOrder];
}

#pragma mark CCNode Composition

-(void) childrenAlloc
{
	children_ = [[CCArray alloc] initWithCapacity:4];
}

// camera: lazy alloc
-(CCCamera*) camera
{
	if( ! camera_ ) {
		camera_ = [[CCCamera alloc] init];

		// by default, center camera at the Sprite's anchor point
//		[camera_ setCenterX:anchorPointInPoints_.x centerY:anchorPointInPoints_.y centerZ:0];
//		[camera_ setEyeX:anchorPointInPoints_.x eyeY:anchorPointInPoints_.y eyeZ:1];

//		[camera_ setCenterX:0 centerY:0 centerZ:0];
//		[camera_ setEyeX:0 eyeY:0 eyeZ:1];
	}

	return camera_;
}

-(CCNode*) getChildByTag:(NSInteger) aTag
{
	NSAssert( aTag != kCCNodeTagInvalid, @"Invalid tag");

	CCNode *node;
	CCARRAY_FOREACH(children_, node){
		if( node.tag == aTag )
			return node;
	}
	// not found
	return nil;
}

/* "add" logic MUST only be on this method
 * If a class want's to extend the 'addChild' behaviour it only needs
 * to override this method
 */
-(void) addChild: (CCNode*) child z:(NSInteger)z tag:(NSInteger) aTag
{
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( child.parent == nil, @"child already added. It can't be added again");

	if( ! children_ )
		[self childrenAlloc];

	[self insertChild:child z:z];

	child.tag = aTag;

	[child setParent: self];

	[child setOrderOfArrival: globalOrderOfArrival++];

	if( isRunning_ ) {
		[child onEnter];
		[child onEnterTransitionDidFinish];
	}
}

-(void) addChild: (CCNode*) child z:(NSInteger)z
{
	NSAssert( child != nil, @"Argument must be non-nil");
	[self addChild:child z:z tag:child.tag];
}

-(void) addChild: (CCNode*) child
{
	NSAssert( child != nil, @"Argument must be non-nil");
	[self addChild:child z:child.zOrder tag:child.tag];
}

-(void) removeFromParentAndCleanup:(BOOL)cleanup
{
	[parent_ removeChild:self cleanup:cleanup];
}

/* "remove" logic MUST only be on this method
 * If a class want's to extend the 'removeChild' behavior it only needs
 * to override this method
 */
-(void) removeChild: (CCNode*)child cleanup:(BOOL)cleanup
{
	// explicit nil handling
	if (child == nil)
		return;

	if ( [children_ containsObject:child] )
		[self detachChild:child cleanup:cleanup];
}

-(void) removeChildByTag:(NSInteger)aTag cleanup:(BOOL)cleanup
{
	NSAssert( aTag != kCCNodeTagInvalid, @"Invalid tag");

	CCNode *child = [self getChildByTag:aTag];

	if (child == nil)
		CCLOG(@"cocos2d: removeChildByTag: child not found!");
	else
		[self removeChild:child cleanup:cleanup];
}

-(void) removeAllChildrenWithCleanup:(BOOL)cleanup
{
	// not using detachChild improves speed here
	CCNode *c;
	CCARRAY_FOREACH(children_, c)
	{
		// IMPORTANT:
		//  -1st do onExit
		//  -2nd cleanup
		if (isRunning_)
		{
			[c onExitTransitionDidStart];
			[c onExit];
		}

		if (cleanup)
			[c cleanup];

		// set parent nil at the end (issue #476)
		[c setParent:nil];
	}

	[children_ removeAllObjects];
}

-(void) detachChild:(CCNode *)child cleanup:(BOOL)doCleanup
{
	// IMPORTANT:
	//  -1st do onExit
	//  -2nd cleanup
	if (isRunning_)
	{
		[child onExitTransitionDidStart];
		[child onExit];
	}

	// If you don't do cleanup, the child's actions will not get removed and the
	// its scheduledSelectors_ dict will not get released!
	if (doCleanup)
		[child cleanup];

	// set parent nil at the end (issue #476)
	[child setParent:nil];

	[children_ removeObject:child];
}

// used internally to alter the zOrder variable. DON'T call this method manually
-(void) _setZOrder:(NSInteger) z
{
	zOrder_ = z;
}

// helper used by reorderChild & add
-(void) insertChild:(CCNode*)child z:(NSInteger)z
{
	isReorderChildDirty_=YES;

	ccArrayAppendObjectWithResize(children_->data, child);
	[child _setZOrder:z];
}

-(void) reorderChild:(CCNode*) child z:(NSInteger)z
{
	NSAssert( child != nil, @"Child must be non-nil");

	isReorderChildDirty_ = YES;

	[child setOrderOfArrival: globalOrderOfArrival++];
	[child _setZOrder:z];
}

- (void) sortAllChildren
{
	if (isReorderChildDirty_)
	{
		NSInteger i,j,length = children_->data->num;
		CCNode ** x = children_->data->arr;
		CCNode *tempItem;

		// insertion sort
		for(i=1; i<length; i++)
		{
			tempItem = x[i];
			j = i-1;

			//continue moving element downwards while zOrder is smaller or when zOrder is the same but mutatedIndex is smaller
			while(j>=0 && ( tempItem.zOrder < x[j].zOrder || ( tempItem.zOrder== x[j].zOrder && tempItem.orderOfArrival < x[j].orderOfArrival ) ) )
			{
				x[j+1] = x[j];
				j = j-1;
			}
			x[j+1] = tempItem;
		}

		//don't need to check children recursively, that's done in visit of each child

		isReorderChildDirty_ = NO;
	}
}

#pragma mark CCNode Draw

-(void) draw
{
}

-(void) visit
{
	// quick return if not visible. children won't be drawn.
	if (!visible_)
		return;

	kmGLPushMatrix();

	if ( grid_ && grid_.active)
		[grid_ beforeDraw];

	[self transform];

	if(children_) {

		[self sortAllChildren];

		ccArray *arrayData = children_->data;
		NSUInteger i = 0;

		// draw children zOrder < 0
		for( ; i < arrayData->num; i++ ) {
			CCNode *child = arrayData->arr[i];
			if ( [child zOrder] < 0 )
				[child visit];
			else
				break;
		}

		// self draw
		[self draw];

		// draw children zOrder >= 0
		for( ; i < arrayData->num; i++ ) {
			CCNode *child =  arrayData->arr[i];
			[child visit];
		}

	} else
		[self draw];

	// reset for next frame
	orderOfArrival_ = 0;

	if ( grid_ && grid_.active)
		[grid_ afterDraw:self];

	kmGLPopMatrix();
}

#pragma mark CCNode - Transformations

-(void) transformAncestors
{
	if( parent_ ) {
		[parent_ transformAncestors];
		[parent_ transform];
	}
}

-(void) transform
{
	kmMat4 transfrom4x4;

	// Convert 3x3 into 4x4 matrix
	CGAffineTransform tmpAffine = [self nodeToParentTransform];
	CGAffineToGL(&tmpAffine, transfrom4x4.mat);

	// Update Z vertex manually
	transfrom4x4.mat[14] = vertexZ_;

	kmGLMultMatrix( &transfrom4x4 );


	// XXX: Expensive calls. Camera should be integrated into the cached affine matrix
	if ( camera_ && !(grid_ && grid_.active) )
	{
		BOOL translate = (anchorPointInPoints_.x != 0.0f || anchorPointInPoints_.y != 0.0f);

		if( translate )
			kmGLTranslatef(RENDER_IN_SUBPIXEL(anchorPointInPoints_.x), RENDER_IN_SUBPIXEL(anchorPointInPoints_.y), 0 );

		[camera_ locate];

		if( translate )
			kmGLTranslatef(RENDER_IN_SUBPIXEL(-anchorPointInPoints_.x), RENDER_IN_SUBPIXEL(-anchorPointInPoints_.y), 0 );
	}
}

#pragma mark CCNode SceneManagement

-(void) onEnter
{
	[children_ makeObjectsPerformSelector:@selector(onEnter)];
	[self resumeSchedulerAndActions];

	isRunning_ = YES;
}

-(void) onEnterTransitionDidFinish
{
	[children_ makeObjectsPerformSelector:@selector(onEnterTransitionDidFinish)];
}

-(void) onExitTransitionDidStart
{
	[children_ makeObjectsPerformSelector:@selector(onExitTransitionDidStart)];
}

-(void) onExit
{
	[self pauseSchedulerAndActions];
	isRunning_ = NO;

	[children_ makeObjectsPerformSelector:@selector(onExit)];
}

#pragma mark CCNode Actions

-(void) setActionManager:(CCActionManager *)actionManager
{
	if( actionManager != actionManager_ ) {
		[self stopAllActions];
		[actionManager_ release];

		actionManager_ = [actionManager retain];
	}
}

-(CCActionManager*) actionManager
{
	return actionManager_;
}

-(CCAction*) runAction:(CCAction*) action
{
	NSAssert( action != nil, @"Argument must be non-nil");

	[actionManager_ addAction:action target:self paused:!isRunning_];
	return action;
}

-(void) stopAllActions
{
	[actionManager_ removeAllActionsFromTarget:self];
}

-(void) stopAction: (CCAction*) action
{
	[actionManager_ removeAction:action];
}

-(void) stopActionByTag:(NSInteger)aTag
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	[actionManager_ removeActionByTag:aTag target:self];
}

-(CCAction*) getActionByTag:(NSInteger) aTag
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	return 	[actionManager_ getActionByTag:aTag target:self];
}

-(NSUInteger) numberOfRunningActions
{
	return [actionManager_ numberOfRunningActionsInTarget:self];
}

#pragma mark CCNode - Scheduler

-(void) setScheduler:(CCScheduler *)scheduler
{
	if( scheduler != scheduler_ ) {
		[self unscheduleAllSelectors];
		[scheduler_ release];

		scheduler_ = [scheduler retain];
	}
}

-(CCScheduler*) scheduler
{
	return scheduler_;
}

-(void) scheduleUpdate
{
	[self scheduleUpdateWithPriority:0];
}

-(void) scheduleUpdateWithPriority:(NSInteger)priority
{
	[scheduler_ scheduleUpdateForTarget:self priority:priority paused:!isRunning_];
}

-(void) unscheduleUpdate
{
	[scheduler_ unscheduleUpdateForTarget:self];
}

-(void) schedule:(SEL)selector
{
	[self schedule:selector interval:0 repeat:kCCRepeatForever delay:0];
}

-(void) schedule:(SEL)selector interval:(ccTime)interval
{
	[self schedule:selector interval:interval repeat:kCCRepeatForever delay:0];
}

-(void) schedule:(SEL)selector interval:(ccTime)interval repeat: (uint) repeat delay:(ccTime) delay
{
	NSAssert( selector != nil, @"Argument must be non-nil");
	NSAssert( interval >=0, @"Arguemnt must be positive");

	[scheduler_ scheduleSelector:selector forTarget:self interval:interval paused:!isRunning_ repeat:repeat delay:delay];
}

- (void) scheduleOnce:(SEL) selector delay:(ccTime) delay
{
	[self schedule:selector interval:0.f repeat:0 delay:delay];
}

-(void) unschedule:(SEL)selector
{
	// explicit nil handling
	if (selector == nil)
		return;

	[scheduler_ unscheduleSelector:selector forTarget:self];
}

-(void) unscheduleAllSelectors
{
	[scheduler_ unscheduleAllSelectorsForTarget:self];
}
- (void) resumeSchedulerAndActions
{
	[scheduler_ resumeTarget:self];
	[actionManager_ resumeTarget:self];
}

- (void) pauseSchedulerAndActions
{
	[scheduler_ pauseTarget:self];
	[actionManager_ pauseTarget:self];
}

#pragma mark CCNode Transform

- (CGAffineTransform)nodeToParentTransform
{
	if ( isTransformDirty_ ) {

		// Translate values
		float x = position_.x;
		float y = position_.y;

		if ( ignoreAnchorPointForPosition_ ) {
			x += anchorPointInPoints_.x;
			y += anchorPointInPoints_.y;
		}

		// Rotation values
		float c = 1, s = 0;
		if( rotation_ ) {
			float radians = -CC_DEGREES_TO_RADIANS(rotation_);
			c = cosf(radians);
			s = sinf(radians);
		}

		BOOL needsSkewMatrix = ( skewX_ || skewY_ );


		// optimization:
		// inline anchor point calculation if skew is not needed
		if( !needsSkewMatrix && !CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) ) {
			x += c * -anchorPointInPoints_.x * scaleX_ + -s * -anchorPointInPoints_.y * scaleY_;
			y += s * -anchorPointInPoints_.x * scaleX_ +  c * -anchorPointInPoints_.y * scaleY_;
		}


		// Build Transform Matrix
		transform_ = CGAffineTransformMake( c * scaleX_,  s * scaleX_,
										   -s * scaleY_, c * scaleY_,
										   x, y );

		// XXX: Try to inline skew
		// If skew is needed, apply skew and then anchor point
		if( needsSkewMatrix ) {
			CGAffineTransform skewMatrix = CGAffineTransformMake(1.0f, tanf(CC_DEGREES_TO_RADIANS(skewY_)),
																 tanf(CC_DEGREES_TO_RADIANS(skewX_)), 1.0f,
																 0.0f, 0.0f );
			transform_ = CGAffineTransformConcat(skewMatrix, transform_);

			// adjust anchor point
			if( ! CGPointEqualToPoint(anchorPointInPoints_, CGPointZero) )
				transform_ = CGAffineTransformTranslate(transform_, -anchorPointInPoints_.x, -anchorPointInPoints_.y);
		}

		isTransformDirty_ = NO;
	}

	return transform_;
}

- (CGAffineTransform)parentToNodeTransform
{
	if ( isInverseDirty_ ) {
		inverse_ = CGAffineTransformInvert([self nodeToParentTransform]);
		isInverseDirty_ = NO;
	}

	return inverse_;
}

- (CGAffineTransform)nodeToWorldTransform
{
	CGAffineTransform t = [self nodeToParentTransform];

	for (CCNode *p = parent_; p != nil; p = p.parent)
		t = CGAffineTransformConcat(t, [p nodeToParentTransform]);

	return t;
}

- (CGAffineTransform)worldToNodeTransform
{
	return CGAffineTransformInvert([self nodeToWorldTransform]);
}

- (CGPoint)convertToNodeSpace:(CGPoint)worldPoint
{
	CGPoint ret = CGPointApplyAffineTransform(worldPoint, [self worldToNodeTransform]);
	return ret;
}

- (CGPoint)convertToWorldSpace:(CGPoint)nodePoint
{
	CGPoint ret = CGPointApplyAffineTransform(nodePoint, [self nodeToWorldTransform]);
	return ret;
}

- (CGPoint)convertToNodeSpaceAR:(CGPoint)worldPoint
{
	CGPoint nodePoint = [self convertToNodeSpace:worldPoint];
	return ccpSub(nodePoint, anchorPointInPoints_);
}

- (CGPoint)convertToWorldSpaceAR:(CGPoint)nodePoint
{
	nodePoint = ccpAdd(nodePoint, anchorPointInPoints_);
	return [self convertToWorldSpace:nodePoint];
}

- (CGPoint)convertToWindowSpace:(CGPoint)nodePoint
{
    CGPoint worldPoint = [self convertToWorldSpace:nodePoint];
	return [[CCDirector sharedDirector] convertToUI:worldPoint];
}

// convenience methods which take a UITouch instead of CGPoint

#ifdef __CC_PLATFORM_IOS

- (CGPoint)convertTouchToNodeSpace:(UITouch *)touch
{
	CGPoint point = [touch locationInView: [touch view]];
	point = [[CCDirector sharedDirector] convertToGL: point];
	return [self convertToNodeSpace:point];
}

- (CGPoint)convertTouchToNodeSpaceAR:(UITouch *)touch
{
	CGPoint point = [touch locationInView: [touch view]];
	point = [[CCDirector sharedDirector] convertToGL: point];
	return [self convertToNodeSpaceAR:point];
}

#endif // __CC_PLATFORM_IOS


@end
