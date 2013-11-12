//
//  IOSVersion.h
//  ObjectiveGems
//
//  Created by Karl Stenerud on 10-11-07.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

/**
 * Reports the version of iOS being run on the current device.
 */
@interface IOSVersion : NSObject
{
    /** Holds the current iOS version */
	float version;
}
/** The version of iOS being run on the current device as a float in the format x.yy */
@property(nonatomic,readonly,assign) float version;

/** Singleton implementation providing "sharedInstance" and "purgeSharedInstance" methods.
 *
 * <b>- (IOSVersion*) sharedInstance</b>: Get the shared singleton instance. <br>
 * <b>- (void) purgeSharedInstance</b>: Purge (deallocate) the shared instance.
 */
SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(IOSVersion);

@end
