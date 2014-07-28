//
//  CCDirectorAndroid.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 5/22/14.
//
//

#import "../../ccMacros.h"

#if __CC_PLATFORM_ANDROID

#import "../../CCDirector.h"


@interface CCDirector (AndroidExtension)

@end

@interface CCDirectorAndroid : CCDirector

@end

/* DisplayLinkDirector is a Director that synchronizes timers with the refresh rate of the display.
 *
 * Features and Limitations:
 * - Scheduled timers & drawing are synchronizes with the refresh rate of the display
 * - Only supports animation intervals of 1/60 1/30 & 1/15
 *
 */

@interface CCDirectorDisplayLink : CCDirectorAndroid
{
	NSTimer* _displayLink;
	CFTimeInterval	_lastDisplayTime;
}

-(void) mainLoop:(id)sender;

@end


#endif

