#import <XCTest/XCTest.h>
#import "cocos2d.h"

#import "CCTextureCache.h"
#import "CCBReader.h"
#import "AppDelegate.h"

@interface CCTextureTests : XCTestCase
@end

@implementation CCTextureTests


- (void)setUp
{
    [super setUp];

    [(AppController *)[UIApplication sharedApplication].delegate configureCocos2d];
}

-(void)testTextureCache
{
	__weak CCTexture *textures[4];
	__weak CCRenderState *renderStates[3];
	
	@autoreleasepool {
		// Load some cached textures
		for(int i=0; i<4; i++){
			NSString *name = [NSString stringWithFormat:@"Images/grossini_dance_0%d.png", i + 1];
			textures[i] = [CCTexture textureWithFile:name];
		}
		
		// Make sure the textures were loaded.
		for(int i=0; i<4; i++){
			XCTAssertNotNil(textures[i], @"Texture %d not loaded.", i);
		}
		
		// Create render states for the textures.
		CCBlendMode *blend = [CCBlendMode premultipliedAlphaMode];
		CCShader *shader = [CCShader positionColorShader];
		
		// A cached render state..
		renderStates[0] = [CCRenderState renderStateWithBlendMode:blend shader:shader mainTexture:textures[0]];
		// An uncached, immutable render state.
		NSDictionary *uniforms1 = @{@"SomeTexture": textures[1]};
		renderStates[1] = [CCRenderState renderStateWithBlendMode:blend shader:shader shaderUniforms:uniforms1 copyUniforms:YES];
		// An uncached, mutable render state.
		NSMutableDictionary *uniforms2 = [NSMutableDictionary dictionaryWithObject:textures[2] forKey:@"SomeTexture"];
		renderStates[2] = [CCRenderState renderStateWithBlendMode:blend shader:shader shaderUniforms:uniforms2 copyUniforms:NO];
		// Leave textures[3] unused.
		
		// Make sure the render states were loaded
		for(int i=0; i<3; i++){
			XCTAssertNotNil(renderStates[i], @"Render state %d not loaded.", i);
		}
	}
	
	// Flush the texture cache
	[[CCTextureCache sharedTextureCache] removeUnusedTextures];
	
	// Make sure the textures were unloaded.
	for(int i=0; i<4; i++){
		XCTAssertNil(textures[i], @"Texture %d still loaded.", i);
	}
}

@end
