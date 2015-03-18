//
//  CCViewportNode.h
//  cocos2d-ios
//
//  Created by Andy Korth on 12/10/14.

#import <Foundation/Foundation.h>

#import "ccMacros.h"
#import "CCNode.h"
#import "CCProjectionDelegate.h"

@class CCCamera;

/**
 *  CCViewportNode
 *
 *  @since v4.0 and later
 */
@interface CCViewportNode : CCNode

/**
 *  Node that controls the camera's transform (position/rotation/zoom)
 @since v4.0 and later
 */
@property(nonatomic, readonly) CCNode *camera;

/**
 *  User assignable node that holds the content that the viewport will show.
 *  @since v4.0 and later
 */
@property(nonatomic, strong) CCNode *contentNode;

/**
 *  Create a viewport with the size of the screen and an empty contentNode.
 *  @since v4.0 and later
 */
-(instancetype)init;

/**
 *  Create a viewport with the given size and content node. Uses a orthographic projection. Initially the viewport is screen-sized.
 *
 *  @param contentNode Provide the content node. Its children are drawn into the viewport.
 *
 *  @return The CCViewportNode
 *  @since v4.0 and later
 */
-(instancetype)initWithContentNode:(CCNode *)contentNode;

// Convenience constructors to create screen sized viewports.
+(instancetype)centered:(CGSize)designSize;
+(instancetype)scaleToFill:(CGSize)designSize;
+(instancetype)scaleToFit:(CGSize)designSize;
+(instancetype)scaleToFitWidth:(CGSize)designSize;
+(instancetype)scaleToFitHeight:(CGSize)designSize;

// Power user functionality.

// Delegate that is responsible for calculating the projection each frame.
@property(nonatomic, strong) id<CCProjectionDelegate> projectionDelegate;

// Setting the projection explicitly is an error if the projectionDelegate is non-nil;
@property(nonatomic, assign) GLKMatrix4 projection;

@end


/**
 Creates a projection that can be used to do parallax layers.
 The CCNode.vertexZ property determines the parallax motion rate of a node. When vertexZ = 1, the object will not move at all, when it equals 0 it will move normally.
 */
@interface CCParallaxProjection : NSObject<CCProjectionDelegate>

/**
 Initialize a parallax projection delegate that is associated with a specific viewport node's camera.

 @param viewport Viewport node whose camera the parallax is locked to.

 @since 4.0.0
 */
-(instancetype)initWithViewportNode:(CCViewportNode *)viewport;

@end
