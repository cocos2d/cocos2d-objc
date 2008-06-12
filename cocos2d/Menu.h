//
//  Menu.h
//  cocos2d
//

#import <UIKit/UIKit.h>

#import "MenuItem.h"
#import "Layer.h"

/** A Menu */
@interface Menu : Layer
{
}

/** creates a menu with it's items */
+ (id) menuWithItems: (MenuItem*) item, ... NS_REQUIRES_NIL_TERMINATION;
/** initializes a menu with it's items */
- (id) initWithItems: (MenuItem*) item vaList: (va_list) args;

/** align items */
-(void) alignItems;

@end