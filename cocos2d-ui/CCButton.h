/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 * 
 * Copyright (c) 2013 Apportable Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CCControl.h"

@class CCSprite9Slice;
@class CCLabelTTF;
@class CCSpriteFrame;

/** A button represents an area of the screen that reacts to touches/clicks. The button creates a CCSprite9Slice node for its background
 image and a CCLabelTTF for its text.
 
 The button is presented with a stretchable background image and/or a title label. 
 Different images, colors and opacity can be set for each of the button's different states.
 
 Methods for setting callbacks for the button are inherited from CCControl, see [CCControl setTarget:selector:] and [CCControl setBlock:].
 
 @note It is worth noting that background and label are optional. If you hide both, you can have an invisible button that still reacts to touches.
 
 @note You should not add child nodes to a button, nor remove the existing background and label nodes.
 */
@interface CCButton : CCControl
{
    NSMutableDictionary* _backgroundSpriteFrames;
    NSMutableDictionary* _backgroundColors;
    NSMutableDictionary* _backgroundOpacities;
    NSMutableDictionary* _labelColors;
    NSMutableDictionary* _labelOpacities;
    float _originalScaleX;
    float _originalScaleY;
    
    float _originalHitAreaExpansion;
}

/// -----------------------------------------------------------------------
/// @name Creating a Button
/// -----------------------------------------------------------------------

/**
 *  Creates a new button with a title and no background. Uses default font and font size.
 *
 *  @param title The title text of the button.
 *
 *  @return A new button.
 */
+ (id) buttonWithTitle:(NSString*) title;

/**
 *  Creates a new button with a title and no background.
 *
 *  @param title    The title text of the button.
 *  @param fontName Name of the TTF font to use for the title label.
 *  @param size     Font size for the title label.
 *
 *  @return A new button.
 */
+ (id) buttonWithTitle:(NSString*) title fontName:(NSString*)fontName fontSize:(float)size;

/**
 *  Creates a new button with the specified title for the label and sprite frame for its background.
 *
 *  @param title       The title text of the button.
 *  @param spriteFrame Stretchable background image.
 *
 *  @return A new button.
 *  @see CCSpriteFrame
 */
+ (id) buttonWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame;

/**
 *  Creates a new button with the speicified title for the label, sprite frames for its background in different states.
 *
 *  @param title       The title text of the button.
 *  @param spriteFrame Stretchable background image for the normal state.
 *  @param highlighted Stretchable background image for the highlighted state.
 *  @param disabled    Stretchable background image for the disabled state.
 *
 *  @return A new button.
 *  @see CCSpriteFrame
 */
+ (id) buttonWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame highlightedSpriteFrame:(CCSpriteFrame*) highlighted disabledSpriteFrame:(CCSpriteFrame*) disabled;

/**
 *  Initializes a new button with a title and no background. Uses default font and font size.
 *
 *  @param title The title text of the button.
 *
 *  @return A new button.
 */
- (id) initWithTitle:(NSString*) title;

/**
 *  Initializes a new button with a title and no background.
 *
 *  @param title    The title text of the button.
 *  @param fontName Name of the TTF font to use for the title label.
 *  @param size     Font size for the title label.
 *
 *  @return A new button.
 */
- (id) initWithTitle:(NSString *)title fontName:(NSString*)fontName fontSize:(float)size;

/**
 *  Initializes a new button with the specified title for the label and sprite frame for its background.
 *
 *  @param title       The title text of the button.
 *  @param spriteFrame Stretchable background image.
 *
 *  @return A new button.
 *  @see CCSpriteFrame
 */
- (id) initWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame;

/**
 *  Initializes a new button with the speicified title for the label, sprite frames for its background in different states.
 *
 *  @param title       The title text of the button.
 *  @param spriteFrame Stretchable background image for the normal state.
 *  @param highlighted Stretchable background image for the highlighted state.
 *  @param disabled    Stretchable background image for the disabled state.
 *
 *  @return A new button.
 *  @see CCSpriteFrame
 */
- (id) initWithTitle:(NSString*) title spriteFrame:(CCSpriteFrame*) spriteFrame highlightedSpriteFrame:(CCSpriteFrame*) highlighted disabledSpriteFrame:(CCSpriteFrame*) disabled;

/// -----------------------------------------------------------------------
/// @name Button Child Nodes
/// -----------------------------------------------------------------------

/** The CCSprite9Slice instance used as the button's background.
 @see CCSprite9Slice */
@property (nonatomic,readonly) CCSprite9Slice* background;
/** The CCLabelTTFF instance used as the button's text label.
 @warning Setting the [CCLabelTTF setString:] directly will prevent the button from resizing if the label's dimensions change.
 Instead use the title property to change the button's label text.
 @see CCLabelTTF
 @see title */
@property (nonatomic,readonly) CCLabelTTF* label;

/// -----------------------------------------------------------------------
/// @name Button Behavior
/// -----------------------------------------------------------------------

/** If YES, will slightly enlarge the button while the button is highlighted (mouse/finger "hovering" over button).
 Similar to what CCMenuItem did. */
@property (nonatomic,assign) BOOL zoomWhenHighlighted;
/** If YES, changes the button to a toggle button that toggles between turned on (pressed) and off (normal) states every time
 it is tapped/clicked. */
@property (nonatomic,assign) BOOL togglesSelectedState;

/// -----------------------------------------------------------------------
/// @name Padding and Title
/// -----------------------------------------------------------------------

/** Adds horizontal padding to both sides of the label, increasing its width by 2x horizontalPadding. */
@property (nonatomic,assign) float horizontalPadding;
/** Adds vertical padding to both sides of the label, increasing its height by 2x verticalPadding. */
@property (nonatomic,assign) float verticalPadding;
/** The button's title. Use this to change the label.
 @warning Setting the [CCLabelTTF setString:] directly will prevent the button from resizing if the label's dimensions change. */
@property (nonatomic,strong) NSString* title;

/// -----------------------------------------------------------------------
/// @name Background Properties
/// -----------------------------------------------------------------------

/**
 *  Sets the background color for the specified state. The color is multiplied into the background sprite frame.
 *
 *  @param color Color applied to background image.
 *  @param state State to apply the color to.
 *  @see CCColor
 *  @see CCControlState
 */
- (void) setBackgroundColor:(CCColor*) color forState:(CCControlState) state;

/**
 *  Gets the background color for the specified state.
 *
 *  @param state State to get the color for.
 *
 *  @return Background color.
 *  @see CCColor
 *  @see CCControlState
 */
- (CCColor*) backgroundColorForState:(CCControlState)state;

/**
 *  Sets the background's opacity for the specified state.
 *
 *  @param opacity Opacity to apply to the background image
 *  @param state   State to apply the opacity to.
 *  @see CCControlState
 */
- (void) setBackgroundOpacity:(CGFloat) opacity forState:(CCControlState) state;

/**
 *  Gets the background opacity for the specified state.
 *
 *  @param state State to get the opacity for.
 *
 *  @return Opacity.
 *  @see CCControlState
 */
- (CGFloat) backgroundOpacityForState:(CCControlState)state;

/**
 *  Sets the background's sprite frame for the specified state. The sprite frame will be stretched to the preferred size of the label. If set to `NULL` no background will be drawn.
 *
 *  @param spriteFrame Sprite frame to use for drawing the background.
 *  @param state       State to set the background for.
 *  @see CCSpriteFrame
 *  @see CCControlState
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

/// -----------------------------------------------------------------------
/// @name Label Properties
/// -----------------------------------------------------------------------

/**
 *  Will set the label's color for the normal state.
 *
 *  @param color Color applied to the label.
 *  @see CCColor
 */
- (void) setColor:(CCColor *)color;

/**
 *  Sets the label's color for the specified state.
 *
 *  @param color Color applied to the label.
 *  @param state State to set the color for.
 *  @see CCColor
 *  @see CCControlState
 */
- (void) setLabelColor:(CCColor*) color forState:(CCControlState) state;

/**
 *  Gets the label's color for the specified state.
 *
 *  @param state State to get the color for.
 *
 *  @return Label color.
 *  @see CCColor
 *  @see CCControlState
 */
- (CCColor*) labelColorForState:(CCControlState) state;

/**
 *  Sets the label's opacity for the specified state.
 *
 *  @param opacity Opacity applied to the label.
 *  @param state   State to set the opacity for.
 *  @see CCControlState
 */
- (void) setLabelOpacity:(CGFloat) opacity forState:(CCControlState) state;

/**
 *  Gets the label's opacity for the specified state.
 *
 *  @param state State to get the opacity for.
 *
 *  @return Label opacity.
 *  @see CCControlState
 */
- (CGFloat) labelOpacityForState:(CCControlState) state;

@end
