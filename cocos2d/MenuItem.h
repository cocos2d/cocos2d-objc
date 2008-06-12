//
//  MenuItem.h
//  cocos2d
//

#import <UIKit/UIKit.h>

#import "CocosNode.h"

@class Label;

#define kItemSize 32

/** A MenuItem */
@interface MenuItem : CocosNode
{
	Label *label;
	NSInvocation *invocation;	
}

/** creates a menu item from a string */
+(id) itemFromString: (NSString*) value receiver:(id) r selector:(SEL) s;

/** initializes a menu item from a string */
-(id) initFromString: (NSString*) value receiver:(id) r selector:(SEL) s;

/** returns the outside box */
-(CGRect) rect;

/** activate the item */
-(void) activate;

/** returns the height of the item */
-(unsigned int) height;
@end
