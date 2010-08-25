//
//  cocos2dmacAppDelegate.h
//  cocos2d-mac
//
//  Created by Ricardo Quesada on 8/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "cocos2d.h"

@interface MyLayer : CCLayer
@end

@interface cocos2dmacAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow	*window_;
	MacGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet MacGLView	*glView;

@end
