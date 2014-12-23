//
// Texture loading tests
// http://www.cocos2d-iphone.org
//
//  Created by Andy Korth on 12/10/13.
//

#import "cocos2d.h"
#import "TestBase.h"

#import "CCTextureCache.h"
#import "CCTexture_Private.h"
#import "CCFile_Private.h"
#import "CCTexture+PVR.h"

@interface TextureTest : TestBase @end

// Included images generated using PVRTexTool:
// http://www.imgtec.com/powervr/insider/powervr-pvrtextool.asp

@implementation TextureTest

- (CCSprite *) loadAndDisplayImageNamed:(NSString*) fileName withTitle:(NSString*) title{

	self.subTitle = title;
	
	CGSize s = [[CCDirector sharedDirector] viewSize];
	
	CCSprite *img = [CCSprite spriteWithImageNamed:fileName];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
	[self.contentNode addChild:img];
	return img;
}

-(void) setupPNGLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image.png" withTitle: @"PNG loading example (has alpha)"];
}

-(void) setupPNGLoadingRedoverlayTest
{
	CCSprite * img = [self loadAndDisplayImageNamed: @"test_image.png" withTitle: @"PNG loading example (With red color overlay)"];
	[img setColor:[CCColor redColor]];
}

-(void) setupBMPLoadingTest
{
	[self loadAndDisplayImageNamed:	@"test_image.bmp" withTitle: @"BMP loading example (no alpha)"];
}

-(void) setupJPEGLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image.jpeg" withTitle: @"JPEG loading example (no alpha, white spots)"];
}

-(void) setupTIFFLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image.tiff" withTitle: @"TIFF loading example (has alpha)"];
}

-(void) setupPVRa8LoadingTest
{
    CCSprite * img = [self loadAndDisplayImageNamed: @"test_image_a8.pvr" withTitle: @"8 bit PVR, single channel (greyscale intensity)."];
    [img setShader:[CCShader positionTextureA8ColorShader]];
}

-(void) setupPVRa8v3LoadingTest
{
    CCSprite * img = [self loadAndDisplayImageNamed: @"test_image_a8_v3.pvr" withTitle: @"8 bit PVR v3, single channel (greyscale intensity)."];
    [img setShader:[CCShader positionTextureA8ColorShader]];
}

-(void) setupPVRa88LoadingTest
{
	// I expected an alpha channel..?
	[self loadAndDisplayImageNamed: @"test_image_ai88.pvr" withTitle: @"8+8 bit PVR, greyscale."];

}
-(void) setupPVRa88v3LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_ai88_v3.pvr" withTitle: @"8+8 bit PVR v3, alpha + greyscale."];
}

// PVRTC on iOS only.
#if __CC_PLATFORM_IOS
-(void) setupPVRLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image.pvr" withTitle: @"PVR loading example (no alpha)"];
}

-(void) setupPvrtc2bppLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_pvrtc2bpp.pvr" withTitle: @"pvrtc 2 bits per pixel"];
}

-(void) setupPvrtc2bpp_v3LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_pvrtc2bpp_v3.pvr" withTitle: @"pvrtc 2 bits per pixel formatVersion 3 (with alpha)"];
}

-(void) setupPvrtc4bppLoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_pvrtc4bpp.pvr" withTitle: @"pvrtc 4 bits per pixel"];
}

-(void) setupPvrtc4bpp_v3LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_pvrtc4bpp_v3.pvr" withTitle: @"pvrtc 4 bits per pixel formatVersion 3  (with alpha)"];
}

// TODO: PVRTC2 currently unsupported.
//-(void) setupTest_image_pvrtcii2bpp_v3LoadingTest
//{
//	[self loadAndDisplayImageNamed: @"test_image_pvrtcii2bpp_v3.pvr" withTitle: @"PVRTCII (PVRTC2) 2 bits per pixel"];
//}
//
//-(void) setupTest_image_pvrtcii4bpp_v3LoadingTest
//{
//	[self loadAndDisplayImageNamed: @"test_image_pvrtcii4bpp_v3.pvr" withTitle: @"PVRTCII (PVRTC2) 4 bits per pixel"];
//}
#endif

-(void) setupPvr_rgb565_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgb565.pvr" withTitle: @"PVR uncompressed rgb565"];
}
-(void) setupPvr_rgb565_v3_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgb565_v3.pvr" withTitle: @"PVR uncompressed rgb565 v3"];
}
-(void) setupPvr_rgb888_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgb888.pvr" withTitle: @"PVR uncompressed rgb888"];
}
-(void) setupPvr_rgb888_v3_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgb888_v3.pvr" withTitle: @"PVR uncompressed rgb888 v3"];
}
-(void) setupPvr_rgba4444_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgba4444.pvr" withTitle: @"PVR uncompressed rgba4444"];
}
-(void) setupPvr_rgba4444_v3_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgba4444_v3.pvr" withTitle: @"PVR uncompressed rgba4444 v3"];
}
-(void) setupPvr_rgba4444_mipmapped_oadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgba4444_mipmap.pvr" withTitle: @"PVR uncompressed rgba4444 mipmapped"];
}
-(void) setupPvr_rgba4444_gzipped_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgba4444.pvr.gz" withTitle: @"PVR gzipped rgba4444"];
}
-(void) setupPvr_rgba4444_ccz_LoadingTest
{
	[self loadAndDisplayImageNamed: @"test_image_rgba4444.pvr.ccz" withTitle: @"PVR gzipped.ccz rgba4444"];
}

-(void) setupNonPowerOfTwoTextureTest
{
	[self loadAndDisplayImageNamed: @"test_1021x1024.png" withTitle: @"1021x1024 png. Watch for memory leaks with Instruments. See http://www.cocos2d-iphone.org/forum/topic/31092"];
}

-(void) setupGLRepeatTest
{
	self.subTitle = @"Texture Repeat with Blocky Filtering";
	
	CGSize s = [[CCDirector sharedDirector] viewSize];

	// TODO can make this go away once we have the new CCFileUtils implemented.
    CGFloat contentScale = 1.0;
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:@"test_image.png" contentScale:&contentScale];
    CCFile *file = [[CCFile alloc] initWithName:@"Foo" url:[NSURL fileURLWithPath:path] contentScale:contentScale];
    CCImage *image = [[CCImage alloc] initWithCCFile:file options:nil];
    
	CCTexture* texture = [[CCTexture alloc] initWithImage:image options:@{
        CCTextureOptionMagnificationFilter: @(CCTextureFilterNearest),
        CCTextureOptionAddressModeX: @(CCTextureAddressModeRepeat),
        CCTextureOptionAddressModeY: @(CCTextureAddressModeRepeat),
    }];
	
	CCSprite *img = [CCSprite spriteWithTexture:texture rect:CGRectMake(0, 0, 800, 600)];
	img.position = ccp( s.width/2.0f, s.height/2.0f);
    img.scale = 2.0;

	[self.contentNode addChild:img];
}


-(void) setupGenerateMipMapTest
{
	self.subTitle = @"Mipmap Generation:\nLeft pixels should 'swim', right should not.";
	
	// TODO can make this go away once we have the new CCFileUtils implemented.
    CGFloat contentScale = 1.0;
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:@"test_image.png" contentScale:&contentScale];
    CCFile *file = [[CCFile alloc] initWithName:@"Foo" url:[NSURL fileURLWithPath:path] contentScale:contentScale];
    CCImage *image = [[CCImage alloc] initWithCCFile:file options:nil];
    
	CCTexture* texture = [[CCTexture alloc] initWithImage:image options:@{
        CCTextureOptionMinificationFilter: @(CCTextureFilterNearest),
        CCTextureOptionAddressModeX: @(CCTextureAddressModeRepeat),
        CCTextureOptionAddressModeY: @(CCTextureAddressModeRepeat),
    }];
	
	CCTexture* textureWithMipmap = [[CCTexture alloc] initWithImage:image options:@{
        CCTextureOptionGenerateMipmaps: @(YES),
        CCTextureOptionMipmapFilter: @(CCTextureFilterLinear),
        CCTextureOptionMinificationFilter: @(CCTextureFilterNearest),
        CCTextureOptionAddressModeX: @(CCTextureAddressModeRepeat),
        CCTextureOptionAddressModeY: @(CCTextureAddressModeRepeat),
    }];
	
    CCNode *node = [CCNode node];
    node.contentSizeInPoints = self.contentNode.contentSizeInPoints;
    [self.contentNode addChild:node];
    
    [node runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
        [CCActionMoveBy actionWithDuration:1.0 position:ccp( 1, 0)],
        [CCActionMoveBy actionWithDuration:1.0 position:ccp(-1, 0)],
        nil
    ]]];
    
	CCSprite *sprite1 = [CCSprite spriteWithTexture:texture rect:CGRectMake(0, 0, 1024, 1024)];
    sprite1.positionType = CCPositionTypeNormalized;
	sprite1.position = ccp(0.3, 0.5);
    sprite1.scale = 1.0/16.0;
	[node addChild:sprite1];
    
	CCSprite *sprite2 = [CCSprite spriteWithTexture:textureWithMipmap rect:CGRectMake(0, 0, 1024, 1024)];
    sprite2.positionType = CCPositionTypeNormalized;
	sprite2.position = ccp(0.7, 0.5);
    sprite2.scale = 1.0/16.0;
	[node addChild:sprite2];
}

-(void)showCubemap:(CCTexture *)cubemap
{
	CCSprite *sprite = [CCSprite spriteWithTexture:cubemap];
    sprite.positionType = CCPositionTypeNormalized;
    sprite.position = ccp(0.5, 0.5);
	[self.contentNode addChild:sprite];
    
    sprite.shaderUniforms[@"cube"] = sprite.texture;
    sprite.shader = [[CCShader alloc] initWithFragmentShaderSource:CC_GLSL(
        uniform samplerCube cube;
        void main(){
            float t = cc_Time[0];
            vec3 forward = vec3(cos(t), 1.0*cos(0.3*t), sin(t));
            vec3 up = vec3(cos(0.26*t), 2.0, sin(0.31*t));
            vec3 right = cross(forward, up);

            mat3 rotate = mat3(
                normalize(right),
                normalize(cross(right, forward)),
                normalize(forward)
            );
            
            float bias = 0.5 + 0.5*sin(4.0*t);
            
            vec3 coord = rotate*vec3(2.0*cc_FragTexCoord1 - 1.0, 0.5);
            gl_FragColor = cc_FragColor*textureCube(cube, coord, 9.0*bias);
        }
    )];
}

-(void) setupPVRCubemapTest
{
	self.subTitle = @"PVR (RGBA8) Cubemap";
    
    CGFloat contentScale = 1.0;
    NSString *name = @"Cubemap/Cubemap.pvr.gz";
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:name contentScale:&contentScale];
    CCFile *file = [[CCFile alloc] initWithName:name url:[NSURL fileURLWithPath:path] contentScale:contentScale];
    
    CCTexture *cubemap = [[CCTexture alloc] initPVRWithCCFile:file options:@{
        CCTextureOptionGenerateMipmaps: @(YES), // ?? What to do with this flag for PVRs that already have mipmaps?
        CCTextureOptionMipmapFilter: @(CCTextureFilterLinear),
        CCTextureOptionMinificationFilter: @(CCTextureFilterNearest),
    }];
    
    [self showCubemap:cubemap];
}

#if __CC_PLATFORM_IOS
-(void) setupPVRTCCubemapTest
{
	self.subTitle = @"PVR (pvrtc 2bpp) Cubemap";
    
    CGFloat contentScale = 1.0;
    NSString *name = @"Cubemap/Cubemap-pvrtc.pvr.gz";
    NSString *path = [[CCFileUtils sharedFileUtils] fullPathForFilename:name contentScale:&contentScale];
    CCFile *file = [[CCFile alloc] initWithName:name url:[NSURL fileURLWithPath:path] contentScale:contentScale];
    
    CCTexture *cubemap = [[CCTexture alloc] initPVRWithCCFile:file options:@{
        CCTextureOptionGenerateMipmaps: @(YES), // ?? What to do with this flag for PVRs that already have mipmaps?
        CCTextureOptionMipmapFilter: @(CCTextureFilterLinear),
        CCTextureOptionMinificationFilter: @(CCTextureFilterNearest),
    }];
    
    [self showCubemap:cubemap];
}
#endif

@end
