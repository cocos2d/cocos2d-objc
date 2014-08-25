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

/**
 *  Initializes a CCEffectNode object with width and height in Points and a pixel format( only RGB and RGBA formats are valid ) and no depth-stencil buffer.
 *
 *  @param w                  Width of render target.
 *  @param h                  Height of render target.
 *  @param format             Pixel format of render target.
 *
 *  @return An initialized CCRenderTarget object.
 */
-(id)initWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat)format;

/**
 *  Initializes a CCEffectNode object with width and height in Points and a pixel format( only RGB and RGBA formats are valid ) and depthStencil format
 *
 *  @param w                  Width of render target.
 *  @param h                  Height of render target.
 *  @param format             Pixel format of render target.
 *  @param depthStencilFormat Stencil format of render target.
 *
 *  @return An initialized CCRenderTarget object.
 */
-(id)initWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat)format depthStencilFormat:(GLuint)depthStencilFormat;


/// -----------------------------------------------------------------------
/// @name Creating a CCEffectNode object
/// -----------------------------------------------------------------------

/**
 *  Creates a CCEffectNode object with width and height in points, the default color format and no depth-stencil buffer.
 *
 *  @param w      Width of render target.
 *  @param h      Height of render target.
 *
 *  @return An initialized CCRenderTarget object.
 */
+(id)effectNodeWithWidth:(int)w height:(int)h;

/**
 *  Creates a CCEffectNode object with width and height in Points and a pixel format( only RGB and RGBA formats are valid ) and no depth-stencil buffer.
 *
 *  @param w                  Width of render target.
 *  @param h                  Height of render target.
 *  @param format             Pixel format of render target.
 *
 *  @return An initialized CCRenderTarget object.
 */
+(id)effectNodeWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat)format;

/**
 *  Creates a CCEffectNode object with width and height in Points and a pixel format( only RGB and RGBA formats are valid ) and depthStencil format
 *
 *  @param w                  Width of render target.
 *  @param h                  Height of render target.
 *  @param format             Pixel format of render target.
 *  @param depthStencilFormat Stencil format of render target.
 *
 *  @return An initialized CCRenderTarget object.
 */
+(id)effectNodeWithWidth:(int)w height:(int)h pixelFormat:(CCTexturePixelFormat)format depthStencilFormat:(GLuint)depthStencilFormat;


@end
