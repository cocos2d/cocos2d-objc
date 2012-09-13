
#import "BaseAppController.h"
#import "cocos2d.h"

#import "ThoMoServerStub.h"

@interface AppController : BaseAppController <ThoMoServerDelegateProtocol>
{
	ThoMoServerStub *thoMoServer;
}
@end

