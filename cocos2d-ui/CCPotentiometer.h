/*
 * CCControlPotentiometer.h
 *
 * Copyright 2015 Volodin Andrey. All rights reserved.
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
 *
 */
#import "CCControl.h"

@class CCProgressNode, CCSprite, CCColor;

/** 
 * Potentiometer control for Cocos2D.
 *
 * A CCPotentiometer object is a visual control used to select a 
 * single value in a circular motion from a continuous range of values.
 * An indicator notes the current value of the potentiometer and can be
 * moved by the user to change the setting.
 */
@interface CCPotentiometer : CCControl {
@public
    float _value;
    float _minimumValue;
    float _maximumValue;
    
@protected
    CCSprite        *_thumbSprite;
    CCSprite        *_trackSprite;
    CCProgressNode  *_progressTimer;
}
#pragma mark Contructors - Initializers
/** @name Creating Potentiometers */

/** 
 * Initializes a potentiometer with a track sprite and a progress bar.
 *
 * @param trackSprite   CCSprite, that is used as a background.
 * @param progressTimer CCProgressTimer, that is used as a progress bar.
 * @param thumbSprite   CCSprite, that is used as a thumb.
 */
- (id)initWithTrackSprite:(CCSprite *)trackSprite progressSprite:(CCProgressNode *)progressTimer thumbSprite:(CCSprite *)thumbSprite;

/**
 * Creates potentiometer with a track filename and a progress filename.
 *
 * @see initWithTrackSprite:progressSprite:thumbSprite:
 */
+ (id)potentiometerWithTrackFile:(NSString *)backgroundFile progressFile:(NSString *)progressFile thumbFile:(NSString *)thumbFile;

#pragma mark - Properties
#pragma mark Accessing the Potentiometer’s Value
/** @name Accessing the Potentiometer’s Value */
/**
 * @abstract Contains the receiver’s current value.
 * @discussion Setting this property causes the receiver to redraw itself
 * using the new value. To render an animated transition from the current
 * value to the new value, you should use the setValue:animated: method
 * instead.
 *
 * If you try to set a value that is below the minimum or above the maximum
 * value, the minimum or maximum value is set instead. The default value of
 * this property is 0.0.
 */
@property (nonatomic, assign) float value;

/**
 * @abstract Sets the receiver’s current value, allowing you to animate the
 * change visually.
 *
 * @param value The new value to assign to the value property.
 * @param animated Specify YES to animate the change in value when the
 * receiver is redrawn; otherwise, specify NO to draw the receiver with the
 * new value only. Animations are performed asynchronously and do not block
 * the calling thread.
 * @discussion If you try to set a value that is below the minimum or above
 * the maximum value, the minimum or maximum value is set instead. The
 * default value of this property is 0.0.
 * @see value
 */
- (void)setValue:(float)value animated:(BOOL)animated;

#pragma mark Accessing the Potentiometer’s Value Limits
/** @name Accessing the Potentiometer’s Value Limits */
/** Contains the minimum value of the receiver.
 * The default value of this property is 0.0. */
@property (nonatomic, assign) float minimumValue;
/** Contains the maximum value of the receiver.
 * The default value of this property is 1.0. */
@property (nonatomic, assign) float maximumValue;

#pragma mark Customizing the Appearance of the Slider
/** @name Customizing the Appearance of the Slider */

/**
 * @abstract The color used to tint the appearance of the thumb when the
 * potentiometer is pushed.
 * @discussion The default color is ccGRAY.
 */
@property(nonatomic, assign) CCColor* onThumbTintColor;

#pragma mark - Public Methods

@end
