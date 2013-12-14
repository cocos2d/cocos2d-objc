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

#import "TestBase.h"
#import "MainMenu.h"
#import <objc/message.h>

@implementation TestBase

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    self.contentSizeType = CCSizeTypeNormalized;
    self.contentSize = CGSizeMake(1, 1);
    
    // Create test content
    self.contentNode = [CCNode node];
    self.contentNode.contentSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitInsetPoints);
    self.contentNode.contentSize = CGSizeMake(1, 44);
		self.contentNode.name = @"TestBase Content Node";
	
    [self addChild:self.contentNode];
    
    // Create interface
    
    // Header background
    CCSprite9Slice* headerBg = [CCSprite9Slice spriteWithImageNamed:@"Interface/header.png"];
    headerBg.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerTopLeft);
    headerBg.position = ccp(0,0);
    headerBg.anchorPoint = ccp(0,1);
    headerBg.contentSizeType = CCSizeTypeMake(CCSizeUnitNormalized, CCSizeUnitPoints);
    headerBg.contentSize = CGSizeMake(1, 44);
    
    [self addChild:headerBg];
    
    // Header label
    _lblTitle = [CCLabelTTF labelWithString:NSStringFromClass([self class]) fontName:@"HelveticaNeue-Medium" fontSize:17];
    _lblTitle.positionType = CCPositionTypeNormalized;
    _lblTitle.position = ccp(0.5f,0.5f);
    
    [headerBg addChild:_lblTitle];
    
    _lblSubTitle = [CCLabelTTF labelWithString:@"" fontName:@"HelveticaNeue-Light" fontSize:14];
    _lblSubTitle.positionType = CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitPoints, CCPositionReferenceCornerTopLeft);
    _lblSubTitle.position = ccp(0.5, 64);
    _lblSubTitle.horizontalAlignment = CCTextAlignmentCenter;
    
    [self addChild:_lblSubTitle];
    
    // Back button
    CCSpriteFrame* frame = [[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"Interface/btn-back.png"];
    
    _btnBack = [CCButton buttonWithTitle:NULL spriteFrame:frame];
    _btnBack.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerTopLeft);
    _btnBack.position = ccp(22, 22);
    _btnBack.background.opacity = 0;
    
    [_btnBack setTarget:self selector:@selector(pressedBack:)];
    [self addChild:_btnBack];
    
    // Prev button
    _btnPrev = [CCButton buttonWithTitle:NULL spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"Interface/btn-prev.png"]];
    _btnPrev.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerBottomLeft);
    _btnPrev.position = ccp(22, 22);
    _btnPrev.background.opacity = 0;
    
    [_btnPrev setTarget:self selector:@selector(pressedPrev:)];
    [self addChild:_btnPrev];
    
    // Next button
    _btnNext = [CCButton buttonWithTitle:NULL spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"Interface/btn-next.png"]];
    _btnNext.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerBottomRight);
    _btnNext.position = ccp(22, 22);
    _btnNext.background.opacity = 0;
    
    [_btnNext setTarget:self selector:@selector(pressedNext:)];
    [self addChild:_btnNext];
    
    // Reload button
    _btnReload = [CCButton buttonWithTitle:NULL spriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"Interface/btn-reload.png"]];
    _btnReload.positionType = CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitPoints, CCPositionReferenceCornerBottomLeft);
    _btnReload.position = ccp(0.5, 22);
    _btnReload.background.opacity = 0;
    
    [_btnReload setTarget:self selector:@selector(pressedReset:)];
    [self addChild:_btnReload];
    
    [self setupTestWithIndex:0];
    
    return self;
}

+ (CCScene *) sceneWithTestName:(NSString*)testName
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
  TestBase *node = [[NSClassFromString(testName) alloc] init];
  if(node == nil){
    NSAssert(NO, @"No class found with the name %@", testName);
  }
  
  node.testName = testName;
	
	// add layer as a child to scene
	[scene addChild: node];
    
	// return the scene
	return scene;
}

- (void) onEnterTransitionDidFinish
{
    // Fade buttons in
    [_btnBack.background runAction:[CCActionFadeIn actionWithDuration:0.3f]];
    [_btnPrev.background runAction:[CCActionFadeIn actionWithDuration:0.3f]];
    [_btnNext.background runAction:[CCActionFadeIn actionWithDuration:0.3f]];
    [_btnReload.background runAction:[CCActionFadeIn actionWithDuration:0.3f]];
    
    [super onEnterTransitionDidFinish];
}

- (void) onExitTransitionDidStart
{
    // Fade buttons out
    [_btnBack.background runAction:[CCActionFadeOut actionWithDuration:0.1f]];
    [_btnPrev.background runAction:[CCActionFadeOut actionWithDuration:0.1f]];
    [_btnNext.background runAction:[CCActionFadeOut actionWithDuration:0.1f]];
    [_btnReload.background runAction:[CCActionFadeOut actionWithDuration:0.1f]];
    
    [super onExitTransitionDidStart];
}

- (void) setUp{

}

- (void) pressedBack:(id)sender
{
    CCTransition* transition = [CCTransition transitionMoveInWithDirection:CCTransitionDirectionRight duration:0.3];
    [[CCDirector sharedDirector] replaceScene:[MainMenu scene] withTransition:transition];
}

- (void) pressedReset:(id)sender
{
    [self setupTestWithIndex:_currentTest];
}

- (void) pressedNext:(id) sender
{
    NSInteger newTest = _currentTest + 1;
    if (newTest >= self.testConstructors.count) newTest = 0;
    
    [self setupTestWithIndex:newTest];
}

- (void) pressedPrev:(id) sender
{
    NSInteger newTest = _currentTest - 1;
    if (newTest < 0) newTest = self.testConstructors.count - 1;
    
    [self setupTestWithIndex:newTest];
}

- (void) setupTestWithIndex:(NSInteger)testNum
{
    // Remove current test
    [self.contentNode removeAllChildrenWithCleanup:YES];
    
    // Find the new test
    NSString* constructorName = [[self testConstructors] objectAtIndex:testNum];
  
		if ([self respondsToSelector:@selector(setUp)])
		{
			[self setUp];
		}
	
    // Setup the new test
    SEL constructor = NSSelectorFromString(constructorName);
    if ([self respondsToSelector:constructor])
    {
        objc_msgSend(self, constructor);
    }
    
    _currentTest = testNum;
}

- (void) setSubTitle:(NSString *)subTitle
{
    _subTitle = subTitle;
    _lblSubTitle.string = subTitle;
}

- (NSArray*) testConstructors
{
	NSMutableArray *arr = [NSMutableArray array];
	
	unsigned int count = 0;
	Method *methods = class_copyMethodList(self.class, &count);
	
	for(int i=0; i<count; i++){
		Method m = methods[i];
		SEL sel = method_getName(m);
		NSString *name = NSStringFromSelector(sel);
		
		if([name hasPrefix:@"setup"] && [name hasSuffix:@"Test"]){
			[arr addObject:name];
		}
	}
	
	free(methods);
	return arr;
}

@end
