//
//  CCEffect.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 3/29/14.
//
//

#import <Foundation/Foundation.h>
#import "CCSprite.h"
#import "CCShader.h"
#import "ccConfig.h"
#import "ccTypes.h"


/**
 * CCEffect is the foundation of the Cocos2D effects system. Subclasses of CCEffect can be
 * used to easily add exciting visual effects such has blur, bloom, reflection, refraction, and
 * other image processing filters to your applications.
 *
 */

@interface CCEffect : NSObject

/// -----------------------------------------------------------------------
/// @name Accessing Effect Attributes
/// -----------------------------------------------------------------------

/** An identifier for debugging effects. */
@property (nonatomic, copy) NSString *debugName;

@end
