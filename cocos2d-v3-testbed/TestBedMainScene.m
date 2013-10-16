/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 * Copyright (c) 2013 Lars Birkemose
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

#import "TestBedMainScene.h"

// -----------------------------------------------------------------
/**
 *  Defines an entry for a test
 *  To add a test, insert three string constants where you want the test to show up
 *  1) group is the name listed in the start scene of the test
 *     all tests with identical group names are accessed through the group
 *  2) title is the title of the individual test
 *  3) className is the name if the class to execute. It it executed through [[ClassName alloc]init]
 */
NSString *testSceneData[ ] = {
    @"group1",              @"title1",                              @"classNameA",
    @"group1",              @"title2",                              @"classNameB",
    @"group2",              @"title1",                              @"classNameC",
    @"group2",              @"title2",                              @"classNameD",
    @"group2",              @"title3",                              @"classNameD",
    nil
};

// -----------------------------------------------------------------

@implementation TestBedMainScene

// -----------------------------------------------------------------

+ (TestBedMainScene *)mainScene
{
    return([[self alloc] init]);
}

// -----------------------------------------------------------------

- (id)init
{
    self = [super init];
    
    CGSize size = [CCDirector sharedDirector].winSize;
    
    // **********
    //TODO:  Replace this rough menu with CCTableView when I figure out how it works
    // create the top testbed scene
    CCLabelTTF *caption = [CCLabelTTF labelWithString:@"Tests" fontName:@"Arial" fontSize:32];
    caption.position = ccp(size.width * 0.5, size.height * 0.9);
    [self addChild:caption];
    
    CCMenu *menu = [CCMenu menuWithItems:nil];
    menu.anchorPoint = CGPointZero;
    menu.position = CGPointZero;
    [self addChild:menu];
    
    float pos = 0.8f;
    for (NSString* group in [self groupList])
    {
        CCMenuItemLabel* item = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:group fontName:@"Arial" fontSize:24] target:self selector:@selector(runTest:)];
        item.position = ccp(size.width * 0.5, size.height * pos);
        [menu addChild:item];
        pos -= 0.1;
    }
    // **********
    

    
    
    
    

    
    
    // done
    return(self);
}

// -----------------------------------------------------------------

- (void)runTest:(id)sender
{
    CCMenuItemLabel* item = (CCMenuItemLabel *)sender;
    
    NSArray *titles = [self titleList:item.label.string];


    
    
    


}

// -----------------------------------------------------------------

- (NSArray *)groupList
{
    int index = 0;
    NSMutableArray *result = [NSMutableArray array];
    while (testSceneData[index])
    {
        NSString *group = testSceneData[index];
        if (![result containsObject:group]) [result addObject:group];
        index += 3;
    }
    return(result);
}

// -----------------------------------------------------------------

- (NSArray *)titleList:(NSString *)group
{
    int index = 0;
    NSMutableArray *result = [NSMutableArray array];
    while (testSceneData[index])
    {
        if ([group isEqualToString:testSceneData[index]]) [result addObject:testSceneData[index + 1]];
        index += 3;
    }
    return(result);
}

// -----------------------------------------------------------------

- (NSString *)className:(NSString *)group title:(NSString *)title
{
    int index = 0;
    while (testSceneData[index])
    {
        if (([group isEqualToString:testSceneData[index]]) && ([title isEqualToString:testSceneData[index + 1]])) return(testSceneData[index + 2]);
        index += 3;
    }
    NSAssert(NO, @"No title found for that group");
    return(nil);
}

// -----------------------------------------------------------------

@end
