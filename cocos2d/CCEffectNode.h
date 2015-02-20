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


/**
 CCEffectNode allows the user to apply effects to the effect node's child nodes.
 
 Inherits from CCRenderTexture, implements the CCEffectProtocol.
 */

@interface CCEffectNode : CCRenderTexture <CCEffectProtocol>

/// -----------------------------------------------------------------------
/// @name Creating a Effect Node
/// -----------------------------------------------------------------------

/**
 *  Creates a CCEffectNode object with width and height in points, the default color format and no depth-stencil buffer.
 *
 *  @param w      Width of render target.
 *  @param h      Height of render target.
 *
 *  @return An initialized CCRenderTarget object.
 */
+(instancetype)effectNodeWithWidth:(int)w height:(int)h;

/**
 *  Creates a CCEffectNode object with width and height in points and depthStencil format
 *
 *  @param w                  Width of render target.
 *  @param h                  Height of render target.
 *  @param depthStencilFormat Stencil format of render target.
 *
 *  @return An initialized CCRenderTarget object.
 *  @see CCTexturePixelFormat
 */
+(instancetype)effectNodeWithWidth:(int)w height:(int)h depthStencilFormat:(GLuint)depthStencilFormat;

/**
 *  Initializes a CCEffectNode object with the specified parameters.
 * 
 *  @param w The width of the effect node in points.
 *  @param h The height of the effect node in points.
 *
 *  @return The CCEffectNode object.
 */
-(instancetype)initWithWidth:(int)w height:(int)h;

/**
 *  Initializes a CCEffectNode object with width and height in Points and depthStencil format
 *
 *  @param w                  Width of render target.
 *  @param h                  Height of render target.
 *  @param depthStencilFormat Stencil format of render target.
 *
 *  @return An initialized CCRenderTarget object.
 *  @see CCTexturePixelFormat
 */
-(id)initWithWidth:(int)w height:(int)h depthStencilFormat:(GLuint)depthStencilFormat;

/** @name Assigning an Effect */

/** Effect which will be applied to this sprite, NOTE: effect will overwrite any custom CCShader settings.
 @see CCEffect */
@property (nonatomic, strong) CCEffect* effect;

@end
