
#import "BaseAppController.h"
#import "cocos2d.h"

#ifdef __CC_PLATFORM_IOS

@interface AppController : BaseAppController
{
	ThoMoServerStub *thoMoServer;
}
@end

#elif defined( __CC_PLATFORM_MAC )
#import "ThoMoServerStub.h"

@interface AppController : BaseAppController <ThoMoServerDelegateProtocol>
{
	ThoMoServerStub *thoMoServer;
}
- (void)initThoMoServer;
@end

#endif // __CC_PLATFORM_IOS
