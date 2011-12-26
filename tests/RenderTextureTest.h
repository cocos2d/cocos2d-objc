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
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	CGPoint		lastLocation;
#endif
}
@end

@interface RenderTextureIssue937 : RenderTextureTest
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


