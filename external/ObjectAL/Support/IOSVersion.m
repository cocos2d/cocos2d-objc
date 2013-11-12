//
//  IOSVersion.m
//  ObjectiveGems
//
//  Created by Karl Stenerud on 10-11-07.
//

#import "IOSVersion.h"
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#import <UIKit/UIKit.h>
#endif

SYNTHESIZE_SINGLETON_FOR_CLASS_PROTOTYPE(IOSVersion);


@implementation IOSVersion

SYNTHESIZE_SINGLETON_FOR_CLASS(IOSVersion);

- (id) init
{
	if(nil != (self = [super init]))
	{
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
		NSString* versionStr = [[UIDevice currentDevice] systemVersion];
		unichar ch = [versionStr characterAtIndex:0];
		if(ch < '0' || ch > '9' || [versionStr characterAtIndex:1] != '.')
		{
			NSLog(@"Error: %s: Cannot parse iOS version string \"%@\"", __PRETTY_FUNCTION__, versionStr);
		}
		
		version = (float)(ch - '0');
		
		float multiplier = 0.1f;
		unsigned int vLength = [versionStr length];
		for(unsigned int i = 2; i < vLength; i++)
		{
			ch = [versionStr characterAtIndex:i];
			if(ch >= '0' && ch <= '9')
			{
				version += (ch - '0') * multiplier;
				multiplier /= 10;
			}
			else if('.' != ch)
			{
				break;
			}
		}
#else
        version = 5;
#endif
	}
	return self;
}

@synthesize version;

@end
