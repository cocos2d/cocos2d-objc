/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 *
 * Idea taken from: http://stackoverflow.com/a/3940757
 *
 */


#import "NSThread+performBlock.h"
#import "../ccMacros.h"

typedef void (^BlockWithParam)(id param);
@interface CCObjectWith2Params : NSObject
{
@public
	BlockWithParam block;
	id param;
}
@property (nonatomic,copy) BlockWithParam block;
@property (nonatomic,readwrite,strong) id param;
@end

@implementation CCObjectWith2Params
@synthesize block, param;
- (void)dealloc {
	CCLOG(@"cocos2d: deallocing %@", self);

}
@end

@implementation NSThread (sendBlockToBackground)

- (void) performBlock: (void (^)(void))block;
{
	return [self performBlock:block waitUntilDone:NO];
}

- (void) performBlock:(void (^)(void))block waitUntilDone:(BOOL)wait
{
    [self performSelector:@selector(executeBlock:) 
                 onThread:self
			   withObject: [block copy]
			waitUntilDone: wait];
}

- (void) performBlock:(void (^)(id param))block withObject:(id)object waitUntilDone:(BOOL)wait
{
	CCObjectWith2Params * obj = [[CCObjectWith2Params alloc] init];
	obj.block = block;
	obj.param = object;
	
    [self performSelector:@selector(executeBlock2:) 
                 onThread:self
			   withObject:obj
			waitUntilDone:wait];	
}

- (void) executeBlock: (void (^)(void))block;
{
	block();
}

- (void) executeBlock2:(CCObjectWith2Params*)object
{
	BlockWithParam block = object.block;
	block( object.param );
}

@end
