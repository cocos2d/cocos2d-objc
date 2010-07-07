/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2009 Valentin Milea
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



#import "ccConfig.h"
#import "CCNode.h"
#import "CCCamera.h"
#import "CCGrid.h"
#import "CCScheduler.h"
#import "ccMacros.h"
#import "CCDirector.h"
#import "CCActionManager.h"
#import "Support/CGPointExtension.h"
#import "Support/ccCArray.h"
#import "Support/TransformUtils.h"


#if CC_COCOSNODE_RENDER_SUBPIXEL
#define RENDER_IN_SUBPIXEL
#else
#define RENDER_IN_SUBPIXEL (int)
#endif

@interface CCNode (Private)
// lazy allocs
-(void) childrenAlloc;
// helper that reorder a child
-(void) insertChild:(CCNode*)child z:(int)z;
// used internally to alter the zOrder variable. DON'T call this method manually
-(void) _setZOrder:(int) z;
-(void) detachChild:(CCNode *)child cleanup:(BOOL)doCleanup;
@end

@implementation CCNode

@synthesize children = children_;
@synthesize visible=visible_;
@synthesize parent=parent_;
@synthesize grid=grid_;
@synthesize zOrder=zOrder_;
@synthesize tag=tag_;
@synthesize vertexZ = vertexZ_;
@synthesize isRunning=isRunning_;

#pragma mark CCNode - Transform related properties

@synthesize rotation=rotation_, scaleX=scaleX_, scaleY=scaleY_, position=position_;
@synthesize anchorPointInPixels=anchorPointInPixels_, isRelativeAnchorPoint=isRelativeAnchorPoint_;
@synthesize userData;

// getters synthesized, setters explicit
-(void) setRotation: (float)newRotation
{
	rotation_ = newRotation;
	isTransformDirty_ = isInverseDirty_ = YES;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	isTransformGLDirty_ = YES;
#endif
}

-(void) setScaleX: (float)newScaleX
{
	scaleX_ = newScaleX;
	isTransformDirty_ = isInverseDirty_ = YES;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	isTransformGLDirty_ = YES;
#endif	
}

-(void) setScaleY: (float)newScaleY
{
	scaleY_ = newScaleY;
	isTransformDirty_ = isInverseDirty_ = YES;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	isTransformGLDirty_ = YES;
#endif	
}

-(void) setPosition: (CGPoint)newPosition
{
	position_ = newPosition;
	isTransformDirty_ = isInverseDirty_ = YES;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	isTransformGLDirty_ = YES;
#endif	
}

-(void) setIsRelativeAnchorPoint: (BOOL)newValue
{
	isRelativeAnchorPoint_ = newValue;
	isTransformDirty_ = isInverseDirty_ = YES;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	isTransformGLDirty_ = YES;
#endif	
}

-(void) setAnchorPoint:(CGPoint)point
{
	if( ! CGPointEqualToPoint(point, anchorPoint_) ) {
		anchorPoint_ = point;
		anchorPointInPixels_ = ccp( contentSize_.width * anchorPoint_.x, contentSize_.height * anchorPoint_.y );
		isTransformDirty_ = isInverseDirty_ = YES;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
		isTransformGLDirty_ = YES;
#endif		
	}
}
-(CGPoint) anchorPoint
{
	return anchorPoint_;
}

-(void) setContentSize:(CGSize)size
{
	if( ! CGSizeEqualToSize(size, contentSize_) ) {
		contentSize_ = size;
		anchorPointInPixels_ = ccp( contentSize_.width * anchorPoint_.x, contentSize_.height * anchorPoint_.y );
		isTransformDirty_ = isInverseDirty_ = YES;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
		isTransformGLDirty_ = YES;
#endif		
	}
}
-(CGSize) contentSize
{
	return contentSize_;
}

- (CGRect) boundingBox
{
	CGRect rect = CGRectMake(0, 0, contentSize_.width, contentSize_.height);
	return CGRectApplyAffineTransform(rect, [self nodeToParentTransform]);
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
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	isTransformGLDirty_ = YES;
#endif	
}

#pragma mark CCNode - Init & cleanup

+(id) node
{
	return [[[self alloc] init] autorelease];
}

-(id) init
{
	if ((self=[super init]) ) {
		
		isRunning_ = NO;
		
		rotation_ = 0.0f;
		scaleX_ = scaleY_ = 1.0f;
		position_ = CGPointZero;
		anchorPointInPixels_ = anchorPoint_ = CGPointZero;
		contentSize_ = CGSizeZero;
		
		
		// "whole screen" objects. like Scenes and Layers, should set isRelativeAnchorPoint to NO
		isRelativeAnchorPoint_ = YES; 
		
		isTransformDirty_ = isInverseDirty_ = YES;
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
		isTransformGLDirty_ = YES;
#endif
		
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
		userData = nil;
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
	return [NSString stringWithFormat:@"<%@ = %08X | Tag = %i>", [self class], self, tag_];
}

- (void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self);
	
	// attributes
	[camera_ release];
	
	[grid_ release];
	
	// children
	
	CCNode *child;
	CCARRAY_FOREACH(children_, child)
		child.parent = nil;
	
	[children_ release];
	
	[super dealloc];
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
		//		[camera_ setCenterX:anchorPointInPixels_.x centerY:anchorPointInPixels_.y centerZ:0];
		//		[camera_ setEyeX:anchorPointInPixels_.x eyeY:anchorPointInPixels_.y eyeZ:1];
		
		//		[camera_ setCenterX:0 centerY:0 centerZ:0];
		//		[camera_ setEyeX:0 eyeY:0 eyeZ:1];
		
	}
	
	return camera_;
}

-(CCNode*) getChildByTag:(int) aTag
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
-(id) addChild: (CCNode*) child z:(int)z tag:(int) aTag
{	
	NSAssert( child != nil, @"Argument must be non-nil");
	NSAssert( child.parent == nil, @"child already added. It can't be added again");
	
	if( ! children_ )
		[self childrenAlloc];
	
	[self insertChild:child z:z];
	
	child.tag = aTag;
	
	[child setParent: self];
	
	if( isRunning_ )
		[child onEnter];
	return self;
}

-(id) addChild: (CCNode*) child z:(int)z
{
	NSAssert( child != nil, @"Argument must be non-nil");
	return [self addChild:child z:z tag:child.tag];
}

-(id) addChild: (CCNode*) child
{
	NSAssert( child != nil, @"Argument must be non-nil");
	return [self addChild:child z:child.zOrder tag:child.tag];
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

-(void) removeChildByTag:(int)aTag cleanup:(BOOL)cleanup
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
			[c onExit];
		
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
		[child onExit];
	
	// If you don't do cleanup, the child's actions will not get removed and the
	// its scheduledSelectors_ dict will not get released!
	if (doCleanup)
		[child cleanup];
	
	// set parent nil at the end (issue #476)
	[child setParent:nil];
	
	[children_ removeObject:child];
}

// used internally to alter the zOrder variable. DON'T call this method manually
-(void) _setZOrder:(int) z
{
	zOrder_ = z;
}

// helper used by reorderChild & add
-(void) insertChild:(CCNode*)child z:(int)z
{
	int index=0;
	BOOL added = NO;
	CCNode *a;
	CCARRAY_FOREACH(children_, a){
		if ( a.zOrder > z ) {
			added = YES;
			[ children_ insertObject:child atIndex:index];
			break;
		}
		index++;
	}
	
	if( ! added )
		[children_ addObject:child];
	
	[child _setZOrder:z];
}

-(void) reorderChild:(CCNode*) child z:(int)z
{
	NSAssert( child != nil, @"Child must be non-nil");
	
	[child retain];
	[children_ removeObject:child];
	
	[self insertChild:child z:z];
	
	[child release];
}

#pragma mark CCNode Draw

-(void) draw
{
	// override me
	// Only use this function to draw your staff.
	// DON'T draw your stuff outside this method
}

-(void) visit
{
	// quick return if not visible
	if (!visible_)
		return;
	
	glPushMatrix();
	
	if ( grid_ && grid_.active) {
		[grid_ beforeDraw];
		[self transformAncestors];
	}
	
	[self transform];
	
	if(children_) {
		ccArray *arrayData = children_->data;
		int i=0;
		
		// draw children zOrder < 0
		for( ; i < arrayData->num; i++ ) {
			CCNode *child =  arrayData->arr[i];
			if ( [child zOrder] < 0 ) {
				[child visit];
			} else
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
	
	if ( grid_ && grid_.active)
		[grid_ afterDraw:self];
	
	glPopMatrix();
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
	// transformations
	
#if CC_NODE_TRANSFORM_USING_AFFINE_MATRIX
	// BEGIN alternative -- using cached transform
	//
	if( isTransformGLDirty_ ) {
		CGAffineTransform t = [self nodeToParentTransform];
		CGAffineToGL(&t, transformGL_);
		isTransformGLDirty_ = NO;
	}
	
	glMultMatrixf(transformGL_);
	if( vertexZ_ )
		glTranslatef(0, 0, vertexZ_);
	
	// XXX: Expensive calls. Camera should be integrated into the cached affine matrix
	if ( camera_ && !(grid_ && grid_.active) ) {
		BOOL translate = (anchorPointInPixels_.x != 0.0f || anchorPointInPixels_.y != 0.0f);
		
		if( translate )
			glTranslatef(RENDER_IN_SUBPIXEL(anchorPointInPixels_.x), RENDER_IN_SUBPIXEL(anchorPointInPixels_.y), 0);
		
		[camera_ locate];
		
		if( translate )
			glTranslatef(RENDER_IN_SUBPIXEL(-anchorPointInPixels_.x), RENDER_IN_SUBPIXEL(-anchorPointInPixels_.y), 0);
	}
	
	
	// END alternative
	
#else
	// BEGIN original implementation
	// 
	// translate
	if ( isRelativeAnchorPoint_ && (anchorPointInPixels_.x != 0 || anchorPointInPixels_.y != 0 ) )
		glTranslatef( RENDER_IN_SUBPIXEL(-anchorPointInPixels_.x), RENDER_IN_SUBPIXEL(-anchorPointInPixels_.y), 0);
	
	if (anchorPointInPixels_.x != 0 || anchorPointInPixels_.y != 0)
		glTranslatef( RENDER_IN_SUBPIXEL(position_.x + anchorPointInPixels_.x), RENDER_IN_SUBPIXEL(position_.y + anchorPointInPixels_.y), vertexZ_);
	else if ( position_.x !=0 || position_.y !=0 || vertexZ_ != 0)
		glTranslatef( RENDER_IN_SUBPIXEL(position_.x), RENDER_IN_SUBPIXEL(position_.y), vertexZ_ );
	
	// rotate
	if (rotation_ != 0.0f )
		glRotatef( -rotation_, 0.0f, 0.0f, 1.0f );
	
	// scale
	if (scaleX_ != 1.0f || scaleY_ != 1.0f)
		glScalef( scaleX_, scaleY_, 1.0f );
	
	if ( camera_ && !(grid_ && grid_.active) )
		[camera_ locate];
	
	// restore and re-position point
	if (anchorPointInPixels_.x != 0.0f || anchorPointInPixels_.y != 0.0f)
		glTranslatef(RENDER_IN_SUBPIXEL(-anchorPointInPixels_.x), RENDER_IN_SUBPIXEL(-anchorPointInPixels_.y), 0);
	
	//
	// END original implementation
#endif
	
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

-(void) onExit
{
	[self pauseSchedulerAndActions];
	
	isRunning_ = NO;	
	
	[children_ makeObjectsPerformSelector:@selector(onExit)];
}

#pragma mark CCNode Actions

-(CCAction*) runAction:(CCAction*) action
{
	NSAssert( action != nil, @"Argument must be non-nil");
	
	[[CCActionManager sharedManager] addAction:action target:self paused:!isRunning_];
	return action;
}

-(void) stopAllActions
{
	[[CCActionManager sharedManager] removeAllActionsFromTarget:self];
}

-(void) stopAction: (CCAction*) action
{
	[[CCActionManager sharedManager] removeAction:action];
}

-(void) stopActionByTag:(int)aTag
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	[[CCActionManager sharedManager] removeActionByTag:aTag target:self];
}

-(CCAction*) getActionByTag:(int) aTag
{
	NSAssert( aTag != kCCActionTagInvalid, @"Invalid tag");
	
	return [[CCActionManager sharedManager] getActionByTag:aTag target:self];
}

-(int) numberOfRunningActions
{
	return [[CCActionManager sharedManager] numberOfRunningActionsInTarget:self];
}


#pragma mark CCNode - Callbacks

-(void) scheduleUpdate
{
	[self scheduleUpdateWithPriority:0];
}

-(void) scheduleUpdateWithPriority:(int)priority
{
	[[CCScheduler sharedScheduler] scheduleUpdateForTarget:self priority:priority paused:!isRunning_];
}

-(void) unscheduleUpdate
{
	[[CCScheduler sharedScheduler] unscheduleUpdateForTarget:self];
}

-(void) schedule:(SEL)selector
{
	[self schedule:selector interval:0];
}

-(void) schedule:(SEL)selector interval:(ccTime)interval
{
	NSAssert( selector != nil, @"Argument must be non-nil");
	NSAssert( interval >=0, @"Arguemnt must be positive");
	
	[[CCScheduler sharedScheduler] scheduleSelector:selector forTarget:self interval:interval paused:!isRunning_];
}

-(void) unschedule:(SEL)selector
{
	// explicit nil handling
	if (selector == nil)
		return;
	
	[[CCScheduler sharedScheduler] unscheduleSelector:selector forTarget:self];
}

-(void) unscheduleAllSelectors
{
	[[CCScheduler sharedScheduler] unscheduleAllSelectorsForTarget:self];
}
- (void) resumeSchedulerAndActions
{
	[[CCScheduler sharedScheduler] resumeTarget:self];
	[[CCActionManager sharedManager] resumeTarget:self];
}

- (void) pauseSchedulerAndActions
{
	[[CCScheduler sharedScheduler] pauseTarget:self];
	[[CCActionManager sharedManager] pauseTarget:self];
}

#pragma mark CCNode Transform

- (CGAffineTransform)nodeToParentTransform
{
	if ( isTransformDirty_ ) {
		
		transform_ = CGAffineTransformIdentity;
		
		if ( !isRelativeAnchorPoint_ && !CGPointEqualToPoint(anchorPointInPixels_, CGPointZero) )
			transform_ = CGAffineTransformTranslate(transform_, anchorPointInPixels_.x, anchorPointInPixels_.y);
		
		if( ! CGPointEqualToPoint(position_, CGPointZero) )
			transform_ = CGAffineTransformTranslate(transform_, position_.x, position_.y);
		if( rotation_ != 0 )
			transform_ = CGAffineTransformRotate(transform_, -CC_DEGREES_TO_RADIANS(rotation_));
		if( ! (scaleX_ == 1 && scaleY_ == 1) ) 
			transform_ = CGAffineTransformScale(transform_, scaleX_, scaleY_);
		
		if( ! CGPointEqualToPoint(anchorPointInPixels_, CGPointZero) )
			transform_ = CGAffineTransformTranslate(transform_, -anchorPointInPixels_.x, -anchorPointInPixels_.y);
		
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
	return CGPointApplyAffineTransform(worldPoint, [self worldToNodeTransform]);
}

- (CGPoint)convertToWorldSpace:(CGPoint)nodePoint
{
	return CGPointApplyAffineTransform(nodePoint, [self nodeToWorldTransform]);
}

- (CGPoint)convertToNodeSpaceAR:(CGPoint)worldPoint
{
	CGPoint nodePoint = [self convertToNodeSpace:worldPoint];
	return ccpSub(nodePoint, anchorPointInPixels_);
}

- (CGPoint)convertToWorldSpaceAR:(CGPoint)nodePoint
{
	nodePoint = ccpAdd(nodePoint, anchorPointInPixels_);
	return [self convertToWorldSpace:nodePoint];
}

- (CGPoint)convertToWindowSpace:(CGPoint)nodePoint
{
    CGPoint worldPoint = [self convertToWorldSpace:nodePoint];
	return [[CCDirector sharedDirector] convertToUI:worldPoint];
}

// convenience methods which take a UITouch instead of CGPoint

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

@end
