#import <Foundation/Foundation.h>

@interface CCPackageCocos2dEnabler : NSObject

// Enables packages by adding to cocos2d's search path and loading sprite sheets and filename lookups
- (void)enablePackages:(NSArray *)packages;

// Disables packages by removing them fromcocos2d's search path after that reloading sprite sheets and filename lookups of remaining search paths.
- (void)disablePackages:(NSArray *)array;

@end