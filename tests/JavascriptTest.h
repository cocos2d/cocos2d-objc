
#import "BaseAppController.h"
#import "cocos2d.h"

//CLASS INTERFACE
@interface AppController : BaseAppController
@end

@interface JSTest: CCLayer
{
}

-(NSString*) title;
-(NSString*) subtitle;
-(void) setTitle:(NSString*)title;
-(void) setSubtitle:(NSString*)subtitle;

@end


@interface JSSprite : JSTest
{
	NSUInteger testIndex_;
	NSInteger numberOfTests_;
}

@property (readonly, nonatomic) NSUInteger testIndex;
@property (readwrite, nonatomic) NSInteger numberOfTests;
@end
