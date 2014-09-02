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

/// -----------------------------------------------------------------------
/// @name Methods Used by Sub-Classes
/// -----------------------------------------------------------------------

@interface CCControl (Subclass)

/**
 *  Used by sub-classes. This method is called to trigger an action callback. E.g. CCButton calls this method when the button is tapped.
 */
- (void) triggerAction;

/**
 *  Used by sub-classes. This method is called every time the control's state changes, it's default behavior is to call the needsLayout method.
 */
- (void) stateChanged;

/**
 *  Used by sub-classes. This method should be called whenever the control needs to update its layout. It will force a call to the layout method at the beginning of the next draw cycle.
 */
- (void) needsLayout;

/**
 *  Used by sub classes. Override this method to do any layout needed by the component. This can include setting positions or sizes of child labels or sprites as well as the compontents contentSize.
 */
- (void) layout;

/**
 *  Used by sub-classes. Override this method if you are using custom properties and need to set them by name using the setValue:forKey method. This is needed for integration with editors such as SpriteBuilder. When overriding this method, make sure to call its super method if you cannot handle the key.
 *
 *  @param value The value to set.
 *  @param key   The key to set the value for.
 *  @param state The state to set the value for.
 */
- (void) setValue:(id)value forKey:(NSString *)key state:(CCControlState) state;

/**
 *  Used by sub-classes. Override this method to return values of custom properties that are set by state.
 *  @see setValue:forKey:state:
 *
 *  @param key   The key to retrieve the value for.
 *  @param state The state to retrieve the value for.
 *
 *  @return The value for the specified key and value or `NULL` if no such value exist.
 */
- (id) valueForKey:(NSString *)key state:(CCControlState)state;

#if __CC_PLATFORM_IOS

/**
 *  Used by sub-classes. Called when a touch enters the component. By default this happes if the touch down is within the control, if the claimsUserEvents property is set to false this will also happen if the touch starts outside of the control.
 *
 *  @param touch Touch that entered the component.
 *  @param event Event associated with the touch.
 */
- (void) touchEntered:(CCTouch*) touch withEvent:(CCTouchEvent*)event;

/**
 *  Used by sub-classes. Called when a touch exits the component.
 *
 *  @param touch Touch that exited the component
 *  @param event Event associated with the touch.
 */
- (void) touchExited:(CCTouch*) touch withEvent:(CCTouchEvent*) event;

/**
 *  Used by sub-classes. Called when a touch that started inside the component is ended inside the component. E.g. for CCButton, this triggers the buttons callback action.
 *
 *  @param touch Touch that is released inside the component.
 *  @param event Event associated with the touch.
 */
- (void) touchUpInside:(CCTouch*) touch withEvent:(CCTouchEvent*) event;

/**
 *  Used by sub-classes. Called when a touch that started inside the component is ended outside the component. E.g. for CCButton, this doesn't trigger any callback action.
 *
 *  @param touch Touch that is release outside of the component.
 *  @param event Event associated with the touch.
 */
- (void) touchUpOutside:(CCTouch*) touch withEvent:(CCTouchEvent*) event;

#elif __CC_PLATFORM_MAC

/**
 *  Used by sub-classes. Called when a mouse down enters the component. By default this happes if the mouse down is within the control, if the claimsUserEvents property is set to false this will also happen if the mouse down starts outside of the control.
 *
 *  @param event Event associated with the mouse down.
 */
- (void) mouseDownEntered:(NSEvent*) event;

/**
 *  Used by sub-classes. Called when a mouse down exits the component.
 *
 *  @param event Event associated with the mouse down.
 */
- (void) mouseDownExited:(NSEvent*) event;

/**
 *  Used by sub-classes. Called when a mouse down that started inside the component is ended inside the component. E.g. for CCButton, this triggers the buttons callback action.
 *
 *  @param event Event associated with the mouse up.
 */
- (void) mouseUpInside:(NSEvent*) event;

/**
 *  Used by sub-classes. Called when a mouse down that started inside the component is ended outside the component. E.g. for CCButton, this doesn't trigger any callback action.
 *
 *  @param event Event associated with the mouse up.
 */
- (void) mouseUpOutside:(NSEvent*) event;


#endif

@end
