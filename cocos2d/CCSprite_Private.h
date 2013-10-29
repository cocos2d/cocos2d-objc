//
//  CCSprite_Private.h
//  cocos2d-ios
//
//  Created by Viktor on 10/29/13.
//
//

#import "CCSprite.h"

@interface CCSprite ()

/** whether or not the Sprite needs to be updated in the Atlas */
@property (nonatomic,readwrite) BOOL dirty;

/** the quad (tex coords, vertex coords and color) information */
@property (nonatomic,readonly) ccV3F_C4B_T2F_Quad quad;

/** The index used on the TextureAtlas. Don't modify this value unless you know what you are doing */
@property (nonatomic,readwrite) NSUInteger atlasIndex;

/** weak reference of the CCTextureAtlas used when the sprite is rendered using a CCSpriteBatchNode */
@property (nonatomic,readwrite,unsafe_unretained) CCTextureAtlas *textureAtlas;

/** weak reference to the CCSpriteBatchNode that renders the CCSprite */
@property (nonatomic,readwrite,unsafe_unretained) CCSpriteBatchNode *batchNode;

#pragma mark CCSprite - BatchNode methods

/** updates the quad according the the rotation, position, scale values.
 */
-(void)updateTransform;

/** set the vertex rect.
 It will be called internally by setTextureRect. Useful if you want to create 2x images from SD images in Retina Display.
 Do not call it manually. Use setTextureRect instead.
 */
-(void)setVertexRect:(CGRect)rect;

#pragma mark CCSprite - Animation

/** changes the display frame with animation name and index.
 The animation name will be get from the CCAnimationCache
 @since v0.99.5
 */
-(void) setSpriteFrameWithAnimationName:(NSString*)animationName index:(int) frameIndex;

@end
