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

#import "cocos2d.h"
#import "cocos2d-ui.h"

@interface TestBase : CCNode
{
    CCLabelTTF* _lblTitle;
    CCLabelTTF* _lblSubTitle;
    
    CCButton* _btnBack;
    
    CCButton* _btnPrev;
    CCButton* _btnNext;
    CCButton* _btnReload;
    
    NSInteger _currentTest;
}

@property (nonatomic,strong) CCNode* contentNode;
@property (nonatomic,strong) NSString* subTitle;
@property (nonatomic,strong) NSString* testName;

+ (CCScene *) sceneWithTestName:(NSString*)testName;

- (NSArray*) testConstructors;

// Only if you need to do fancy overrides
- (void) pressedNext:(id) sender;
- (void) pressedPrev:(id) sender;
- (void) pressedReset:(id)sender;
- (void) pressedBack:(id)sender;
- (void) setupTestWithIndex:(NSInteger)testNum;

// Provide a setUp method called for each test that is run, same as XCode unit tests.
- (void) setUp;


@end
