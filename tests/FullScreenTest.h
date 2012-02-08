#import "cocos2d.h"
#import "BaseAppController.h"

@interface AppController : BaseAppController
@end

@interface FullScreenDemo: CCLayer
{
}
-(NSString*) title;
-(NSString*) subtitle;
@end


@interface FullScreenScale : FullScreenDemo
{}
-(void) addNewSpriteWithCoords:(CGPoint)p;
@end


@interface FullScreenNoScale : FullScreenDemo
{}
-(void) addNewSpriteWithCoords:(CGPoint)p;
@end



@interface FullScreenIssue1071Test : FullScreenDemo
{
	//weak ref
	CCMenuItemFont *issueTestItem_;
}

@end
