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
 A slider is a control where the user drags a handle to set a slider value in the range 0.0 to 1.0.
 
 The slider orientation is horizontal, but it can be changed to vertical (or any) orientation by changing the
 slider's rotation property.
 
 The slider automatically adds a background (the slider range) CCSprite9Slice and a handle CCSprite (what the user grabs). You should not
 remove these nodes nor should you add custom nodes to the slider.
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

#pragma mark Creating Sliders

/// -----------------------------------------------------------------------
/// @name Creating a Slider
/// -----------------------------------------------------------------------

/**
 * Initializes a new slider with a specified sprite frames for its background and handle.
 *
 *  @param background Stretchable background image which represents the track bar for the normal state.
 *  @param handle     Handle image for the normal state.
 *  @see CCSpriteFrame
 */
- (id) initWithBackground:(CCSpriteFrame*)background andHandleImage:(CCSpriteFrame*)handle;


/// -----------------------------------------------------------------------
/// @name Slider Child Nodes
/// -----------------------------------------------------------------------

/** The background sprite.
 @see CCSprite9Slice */
@property (nonatomic,readonly) CCSprite9Slice* background;
/** The handle sprite.
 @see CCSprite */
@property (nonatomic,readonly) CCSprite* handle;

/// -----------------------------------------------------------------------
/// @name Slider Value
/// -----------------------------------------------------------------------

/**
 Contains the slider's current value. Setting this property causes the receiver to redraw itself using the new value.
 The default value of this property is 0.0.
 
 @note If you try to set a value below 0.0 or above 1.0, the value is clamped to 0.0 or 1.0 respectively.
 */
@property (nonatomic,assign) float sliderValue;

#pragma mark Customizing the Appearance of the Slider

/// -----------------------------------------------------------------------
/// @name Customizing Slider Appearance
/// -----------------------------------------------------------------------

/**
 Sets the background's sprite frame for the specified state. The sprite frame will be stretched to the preferred size
 of the label. If set to `nil` no background will be drawn.
 
 @param spriteFrame Sprite frame to use for drawing the background.
 @param state       State to set the background for.
 @see CCSpriteFrame
 @see CCControlState
 */
- (void) setBackgroundSpriteFrame:(CCSpriteFrame*)spriteFrame forState:(CCControlState)state;

/**
 *  Gets the background's sprite frame for the specified state.
 *
 *  @param state State to get the sprite frame for.
 *
 *  @return Background sprite frame.
 *  @see CCSpriteFrame
 *  @see CCControlState
 */
- (CCSpriteFrame*) backgroundSpriteFrameForState:(CCControlState)state;

/**
 *  Sets the handle's sprite frame for the specified state. If set to `nil` no handle will be drawn.
 *
 *  @param spriteFrame Sprite frame to use for drawing the handle.
 *  @param state       State to set the handle for.
 *  @see CCSpriteFrame
 *  @see CCControlState
 */
- (void) setHandleSpriteFrame:(CCSpriteFrame*)spriteFrame forState:(CCControlState)state;

/**
 *  Gets the handle's sprite frame for the specified state.
 *
 *  @param state State to get the sprite frame for.
 *
 *  @return Handle sprite frame.
 *  @see CCSpriteFrame
 *  @see CCControlState
 */
- (CCSpriteFrame*) handleSpriteFrameForState:(CCControlState)state;

@end
