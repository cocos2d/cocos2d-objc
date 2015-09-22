//
//  CCColorTests.m
//  cocos2d-tests
//
//  Created by Richard Groves on 07/May/2015.
//  Copyright (c) 2015 Cocos2d. All rights reserved.
//


#import <XCTest/XCTest.h>

#import "cocos2d.h"

@interface CCColorTests : XCTestCase
@end

@implementation CCColorTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInitWithWhiteAndAlpha
{
    CCColor* testColor = [[CCColor alloc] initWithWhite:0.5 alpha:0.25];
    XCTAssert(testColor.red == 0.5, @"Red component of CCColor should match white component value");
    XCTAssert(testColor.green == 0.5, @"Green component of CCColor should match white component value");
    XCTAssert(testColor.blue == 0.5, @"Blue component of CCColor should match white component value");
    XCTAssert(testColor.alpha == 0.25, @"Alpha component of CCColor should match match alpha component value");
}

- (void)testInitWith3Components
{
    CCColor* testColor = [[CCColor alloc] initWithRed:0.25 green:0.5 blue:0.75];
    XCTAssert(testColor.red == 0.25, @"Red component of CCColor should match red component value");
    XCTAssert(testColor.green == 0.5, @"Green component of CCColor should match green component value");
    XCTAssert(testColor.blue == 0.75, @"Blue component of CCColor should match blue component value");
    XCTAssert(testColor.alpha == 1.0, @"Alpha component of CCColor should match be 1 when not specified in initialiser");
}

- (void)testInitWith4Components
{
    CCColor* testColor = [[CCColor alloc] initWithRed:0.25 green:0.5 blue:0.75 alpha:0.0];
    XCTAssert(testColor.red == 0.25, @"Red component of CCColor should match red component value");
    XCTAssert(testColor.green == 0.5, @"Green component of CCColor should match green component value");
    XCTAssert(testColor.blue == 0.75, @"Blue component of CCColor should match blue component value");
    XCTAssert(testColor.alpha == 0.0, @"Alpha component of CCColor should match alpha component value");
}

#if __CC_PLATFORM_IOS
- (void)testInitWithCGColor
{
    UIColor* uiColor= [UIColor colorWithRed:0.0 green:0.5 blue:0.75 alpha:1.0];
    CGColorRef cgColor = uiColor.CGColor;
    
    CCColor* testColor = [[CCColor alloc] initWithCGColor:cgColor];
    
    XCTAssert(testColor.red == 0.0, @"Red component of CCColor should match red component of UIColor");
    XCTAssert(testColor.green == 0.5, @"Green component of CCColor should match green component of UIColor");
    XCTAssert(testColor.blue == 0.75, @"Blue component of CCColor should match blue component of UIColor");
    XCTAssert(testColor.alpha == 1.0, @"Alpha component of CCColor should match alpha component of UIColor");
}
#endif

#if __CC_PLATFORM_IOS
- (void)testInitWithUIColor
{
    // NB: Watch out for small floating point inaccuracies here.
    UIColor* uiColor= [UIColor colorWithRed:0.0 green:0.5 blue:0.75 alpha:1.0];
    
    CCColor* testColor = [[CCColor alloc] initWithUIColor:uiColor];
    
    XCTAssert(testColor.red == 0.0, @"Red component of CCColor should match red component of UIColor");
    XCTAssert(testColor.green == 0.5, @"Green component of CCColor should match green component of UIColor");
    XCTAssert(testColor.blue == 0.75, @"Blue component of CCColor should match blue component of UIColor");
    XCTAssert(testColor.alpha == 1.0, @"Alpha component of CCColor should match alpha component of UIColor");
    
    // Check the CGColor is also correct
    CGColorRef cgColor = testColor.CGColor;
    
    const CGFloat* cgComponents = CGColorGetComponents(cgColor);
    
    XCTAssert(cgComponents[0] == 0.0, @"Red component of CCColor.CGColor should match red component of UIColor");
    XCTAssert(cgComponents[1] == 0.5, @"Green component of CCColor.CGColor should match green component of UIColor");
    XCTAssert(cgComponents[2] == 0.75, @"Blue component of CCColor.CGColor should match blue component of UIColor");
    XCTAssert(cgComponents[3] == 1.0, @"Alpha component of CCColor.CGColor should match alpha component of UIColor");
}
#endif

- (void)testColorEquality
{
    CCColor* testColor1 = [[CCColor alloc] initWithRed:0.25 green:0.5 blue:0.75 alpha:0.0];
    XCTAssert([testColor1 isEqual:testColor1], @"A CColor should pass isEqual with itself");
    
    CCColor* testColor2 = [[CCColor alloc] initWithRed:0.25 green:0.5 blue:0.75 alpha:1.0];
    XCTAssert([testColor1 isEqual:testColor2] == NO, @"Different colors should not be equal to each other");
    
    NSString* testString = @"test string";
    XCTAssert([testColor1 isEqual:testString] == NO, @"A color is not equal to a non-CCColor object");
}

- (void)testGetComponents
{
    CCColor* ccColor = [[CCColor alloc] initWithRed:0.25 green:0.5 blue:0.75 alpha:0.0];
    
    float r,g,b,a; // NB: float not CGFloat
    [ccColor getRed:&r green:&g blue:&b alpha:&a];
    
    XCTAssert(r == 0.25, @"Red component of CCColor should match red component value");
    XCTAssert(g == 0.5, @"Green component of CCColor should match green component value");
    XCTAssert(b == 0.75, @"Blue component of CCColor should match blue component value");
    XCTAssert(a == 0.0, @"Alpha component of CCColor should match alpha component value");
}

- (void)testGetWhiteAndAlpha
{
    CCColor* ccColor = [[CCColor alloc] initWithRed:0.25 green:0.5 blue:0.75 alpha:0.0];
    
    float white, alpha; // NB: float not CGFloat
    [ccColor getWhite:&white alpha:&alpha];
    
    XCTAssert(white == 0.5, @"White value is an average of the RGB components of the CCColor");
    XCTAssert(alpha == 0.0, @"Alpha component of CCColor should match alpha component value");
}

- (void)testInterpolateTo
{
    CCColor* testColor1 = [[CCColor alloc] initWithRed:0.25 green:0.5 blue:0.75 alpha:0.0];
    CCColor* testColor2 = [[CCColor alloc] initWithRed:0.75 green:1.0 blue:0.0 alpha:1.0];
    
    CCColor* testColor3 = [testColor1 interpolateTo:testColor2 alpha:0.0]; // NB: 'alpha' is how far to interpolate
    XCTAssert([testColor3 isEqual:testColor1], @"InterpolateTo with 'alpha' of 0 should equal first color");

    CCColor* testColor4 = [testColor1 interpolateTo:testColor2 alpha:1.0]; // NB: 'alpha' is how far to interpolate
    XCTAssert([testColor4 isEqual:testColor2], @"InterpolateTo with 'alpha' of 1 should equal second color");

    CCColor* testColor5 = [testColor1 interpolateTo:testColor2 alpha:0.5]; // NB: 'alpha' is how far to interpolate
    XCTAssert(testColor5.red == 0.5, @"Component of interpolateTo color should be  c1 + (c2-c1)*a");
    XCTAssert(testColor5.green == 0.75, @"Component of interpolateTo color should be  c1 + (c2-c1)*a");
    XCTAssert(testColor5.blue == 0.75*0.5, @"Component of interpolateTo color should be  c1 + (c2-c1)*a");
    XCTAssert(testColor5.alpha == 0.5, @"Component of interpolateTo color should be  c1 + (c2-c1)*a");
}

#if __CC_PLATFORM_IOS
- (void)testGetUIColor
{
    CCColor* ccColor = [[CCColor alloc] initWithRed:0.25 green:0.5 blue:0.75 alpha:0.0];
    
    UIColor* testColor = ccColor.UIColor;
    
    CGFloat r,g,b,a;
    [testColor getRed:&r green:&g blue:&b alpha:&a];
    XCTAssert(r == ccColor.red, @"Red component of UIColor should match red component of CCColor");
    XCTAssert(g == ccColor.green, @"Green component of UIColor should match green component of CCColor");
    XCTAssert(b == ccColor.blue, @"Blue component of UIColor should match blue component of CCColor");
    XCTAssert(a == ccColor.alpha, @"Alpha component of UIColor should match alpha component of CCColor");
}
#endif

@end
