//
//  CCSlider.h
//  cocos2d-ios
//
//  Created by Viktor on 10/25/13.
//
//

#import "CCControl.h"
#import "cocos2d.h"

/**
 *  A CCSlider object is a visual control used to select a single value from a continuous range of values. An indicator, or an handle, notes the current value of the slider and can be moved by the user to change the setting.
 */
@interface CCSlider : CCControl
{
    NSMutableDictionary* _backgroundSpriteFrames;
    NSMutableDictionary* _handleSpriteFrames;
    
    BOOL _draggingHandle;
    CGPoint _handleStartPos;
    CGPoint _dragStartPos;
    float _dragStartValue;
}
/** The background's sprite 9 slice. */
@property (nonatomic,readonly) CCSprite9Slice* background;
/** The handle's sprite. */
@property (nonatomic,readonly) CCSprite* handle;
/**
 Contains the receiver’s current value. Setting this property causes the
 receiver to redraw itself using the new value.
 If you try to set a value that is below 0.0f or above 1.0f, the minimum
 or maximum value is set instead. The default value of this property is 0.0.
 */
@property (nonatomic,assign) float sliderValue;

#pragma mark Creating Sliders

/**
 * Initializes a new slider with a specified sprite frames for its background and handle.
 *
 *  @param background Stretchable background image which represents the track bar for the normal state.
 *  @param handle     Handle image for the normal state.
 */
- (id) initWithBackground:(CCSpriteFrame*)background andHandleImage:(CCSpriteFrame*)handle;

#pragma mark Customizing the Appearance of the Slider

/**
 *  Sets the background's sprite frame for the specified state. The sprite frame will be stretched to the preferred size of the label. If set to `NULL` no background will be drawn.
 *
 *  @param spriteFrame Sprite frame to use for drawing the background.
 *  @param state       State to set the background for.
 */
- (void) setBackgroundSpriteFrame:(CCSpriteFrame*)spriteFrame forState:(CCControlState)state;

/**
 *  Gets the background's sprite frame for the specified state.
 *
 *  @param state State to get the sprite frame for.
 *
 *  @return Background sprite frame.
 */
- (CCSpriteFrame*) backgroundSpriteFrameForState:(CCControlState)state;

/**
 *  Sets the handle's sprite frame for the specified state. If set to `NULL` no handle will be drawn.
 *
 *  @param spriteFrame Sprite frame to use for drawing the handle.
 *  @param state       State to set the handle for.
 */
- (void) setHandleSpriteFrame:(CCSpriteFrame*)spriteFrame forState:(CCControlState)state;

/**
 *  Gets the handle's sprite frame for the specified state.
 *
 *  @param state State to get the sprite frame for.
 *
 *  @return Handle sprite frame.
 */
- (CCSpriteFrame*) handleSpriteFrameForState:(CCControlState)state;

@end
