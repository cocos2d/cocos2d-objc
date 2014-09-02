//
//  CCFileUtilTests
//
//  Created by Andy Korth on December 6th, 2013.
//
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"

#import "CCRenderer_private.h"

@interface CCRendererTests : XCTestCase
@end

@implementation CCRendererTests

-(void)testBlendModeCacheInterning
{
	NSDictionary *options = @{
		CCBlendFuncSrcColor: @(GL_ONE),
		CCBlendFuncDstColor: @(GL_ZERO),
		CCBlendEquationColor: @(GL_FUNC_ADD),
		CCBlendFuncSrcAlpha: @(GL_ONE),
		CCBlendFuncDstAlpha: @(GL_ZERO),
		CCBlendEquationAlpha: @(GL_FUNC_ADD),
	};
	
	CCBlendMode *blendMode1 = [CCBlendMode blendModeWithOptions:[options mutableCopy]];
	CCBlendMode *blendMode2 = [CCBlendMode blendModeWithOptions:[options mutableCopy]];
	
	// The two returned blend modes should be interned and equal as object references too
	XCTAssertEqualObjects(blendMode1, blendMode2, @"");
	XCTAssertEqual(blendMode1, blendMode2, @"");
	
	// Should also be equal to the disabled mode
	XCTAssertEqual(blendMode1, [CCBlendMode disabledMode], @"");
}

-(void)testBlendModeDefaults
{
	{
		CCBlendMode *mode = [CCBlendMode blendModeWithOptions:@{
			CCBlendFuncSrcColor: @(GL_SRC_ALPHA),
			CCBlendFuncDstColor: @(GL_ONE_MINUS_SRC_ALPHA),
			CCBlendEquationColor: @(GL_FUNC_ADD),
			CCBlendFuncSrcAlpha: @(GL_SRC_ALPHA),
			CCBlendFuncDstAlpha: @(GL_ONE_MINUS_SRC_ALPHA),
			CCBlendEquationAlpha: @(GL_FUNC_ADD),
		}];
		XCTAssertEqual([CCBlendMode alphaMode], mode, @"");
	}{
		CCBlendMode *mode = [CCBlendMode blendModeWithOptions:@{
			CCBlendFuncSrcColor: @(GL_ONE),
			CCBlendFuncDstColor: @(GL_ONE_MINUS_SRC_ALPHA),
			CCBlendEquationColor: @(GL_FUNC_ADD),
			CCBlendFuncSrcAlpha: @(GL_ONE),
			CCBlendFuncDstAlpha: @(GL_ONE_MINUS_SRC_ALPHA),
			CCBlendEquationAlpha: @(GL_FUNC_ADD),
		}];
		XCTAssertEqual([CCBlendMode premultipliedAlphaMode], mode, @"");
	}{
		CCBlendMode *mode = [CCBlendMode blendModeWithOptions:@{
			CCBlendFuncSrcColor: @(GL_ONE),
			CCBlendFuncDstColor: @(GL_ONE),
			CCBlendEquationColor: @(GL_FUNC_ADD),
			CCBlendFuncSrcAlpha: @(GL_ONE),
			CCBlendFuncDstAlpha: @(GL_ONE),
			CCBlendEquationAlpha: @(GL_FUNC_ADD),
		}];
		XCTAssertEqual([CCBlendMode addMode], mode, @"");
	}{
		CCBlendMode *mode = [CCBlendMode blendModeWithOptions:@{
			CCBlendFuncSrcColor: @(GL_DST_COLOR),
			CCBlendFuncDstColor: @(GL_ZERO),
			CCBlendEquationColor: @(GL_FUNC_ADD),
			CCBlendFuncSrcAlpha: @(GL_DST_COLOR),
			CCBlendFuncDstAlpha: @(GL_ZERO),
			CCBlendEquationAlpha: @(GL_FUNC_ADD),
		}];
		XCTAssertEqual([CCBlendMode multiplyMode], mode, @"");
	}
}

-(void)testRenderStateCacheFlush
{
	__weak CCRenderState *renderState = nil;
	
	@autoreleasepool {
		CCBlendMode *mode = [CCBlendMode alphaMode];
		CCShader *shader = [CCShader positionColorShader];
		CCTexture *texture = [CCTexture textureWithFile:@"Images/grossini_dance_01.png"];
		
		renderState = [CCRenderState renderStateWithBlendMode:mode shader:shader mainTexture:texture];
		XCTAssertNotNil(renderState, @"Render state was not created.");
	}
	
	[CCRENDERSTATE_CACHE flush];
	
	XCTAssertNil(renderState, @"Render state was not released.");
}

@end
