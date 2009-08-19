//
//  Box2DView.h
//  Box2D OpenGL View
//
//  Box2D iPhone port by Simon Oliver - http://www.simonoliver.com - http://www.handcircus.com
//


#import <UIKit/UIKit.h>

#import "cocos2d.h"

#import "iPhoneTest.h"
#import "Delegates.h"


@interface MenuLayer : Layer
{    
	int		entryID;	
}
+(id) menuWithEntryID:(int)entryId;
-(id) initWithEntryID:(int)entryId;
@end

@interface Box2DView : Layer {
    
	TestEntry* entry;
	Test* test;
	int		entryID;
	
	int doubleClickValidCountdown;
}
+(id) viewWithEntryID:(int)entryId;
-(id) initWithEntryID:(int)entryId;
@end
