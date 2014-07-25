//
//  CCEffectNode.h
//  cocos2d-ios
//
//  Created by Oleg Osin on 3/26/14.
//
//

#import <Foundation/Foundation.h>

#import "ccMacros.h"
#import "CCNode.h"
#import "CCRenderTexture.h"
#import "CCSprite.h"
#import "CCTexture.h"


#ifdef __CC_PLATFORM_IOS
#import <UIKit/UIKit.h>
#endif // iPHone


/**
 * CCEffectNode allows the user to apply effects to the collection of nodes that
 * are its children.
 */

@interface CCEffectNode : CCRenderTexture <CCEffectProtocol>

/// -----------------------------------------------------------------------
/// @name Initializing a CCEffectNode object
/// -----------------------------------------------------------------------

/**
 *  Initializes a CCEffectNode object with the specified parameters.
 * 
 *  @param w The width of the effect node in points.
 *  @param h The height of the effect node in points.
 *
 *  @return The CCEffectNode object.
 */
-(id)initWithWidth:(int)w height:(int)h;

@end
