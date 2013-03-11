#import "Cocos2d.h"
#import "BaseAppController.h"

@interface AppController : BaseAppController
@end

@interface RenderTextureTest : CCLayer
{}
-(NSString*) title;
-(NSString*) subtitle;
@end

@interface RenderTextureSave : RenderTextureTest
{
	CCRenderTexture* target;
	CCSprite* brush;

#ifdef __CC_PLATFORM_IOS
#elif defined(__CC_PLATFORM_MAC)
	CGPoint		lastLocation;
#endif
}
@end

@interface RenderTextureIssue937 : RenderTextureTest
{}
@end

@interface RenderTextureIssue1464 : RenderTextureTest
{}
@end


@interface RenderTextureZbuffer : RenderTextureTest
{
	CCSprite *sp1;
	CCSprite *sp2;
	CCSprite *sp3;
	CCSprite *sp4;
	CCSprite *sp5;
	CCSprite *sp6;
	CCSprite *sp7;
	CCSprite *sp8;
	CCSprite *sp9;

	CCSpriteBatchNode *mgr;
}
-(void)renderScreenShot;
@end

@interface RenderTextureTestDepthStencil : RenderTextureTest
@end

@interface RenderTextureTargetNode : RenderTextureTest {
	CCSprite *_sprite1, *_sprite2;
	CCRenderTexture *_renderTexture;
}
@end

@class SimpleSprite;
@interface SpriteRenderTextureBug : RenderTextureTest
{}
-(SimpleSprite*) addNewSpriteWithCoords:(CGPoint)p;
@end
