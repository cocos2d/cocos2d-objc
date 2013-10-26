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

#import "CCNode.h"

/**
 The possible states for a CCControl.
 */
typedef NS_ENUM(NSUInteger, CCControlState)
{
    /** The normal, or default state of a control — that is, enabled but neither selected nor highlighted. */
    CCControlStateNormal       = 1 << 0,
    
    /** Highlighted state of a control. A control enters this state when a touch down, drag inside or drag enter is performed. You can retrieve and set this value through the highlighted property. */
    CCControlStateHighlighted  = 1 << 1,
    
    /** Disabled state of a control. This state indicates that the control is currently disabled. You can retrieve and set this value through the enabled property. */
    CCControlStateDisabled     = 1 << 2,
    
    /** Selected state of a control. This state indicates that the control is currently selected. You can retrieve and set this value through the selected property. */
    CCControlStateSelected     = 1 << 3
};


/**
 CCControl is the abstract base class of the Cocos2d components that handles touches or mouse events. You cannot instantiate it directly, instead use one of its sub-classes, such as CCButton. If you need to create a new sort of component you should make a sub-class of this class.
 
 The control class handles events and its sub-classes will use child nodes to draw itself in the node heirarchy.
 
 *Important:* If you are sub-classing CCControl you will need to include the CCControlSubclass.h file as it includes methods that are otherwise not exposed.
 */
@interface CCControl : CCNode
{
    /** Needs layout is set to true if the control has changed and needs to re-layout itself. */
    BOOL _needsLayout;
}


/// -----------------------------------------------------------------------
/// @name Controlling Content Size
/// -----------------------------------------------------------------------

/** The preferred (and minimum) size that the component will attempt to layout to. If its contents are larger it may have a larger size. */
@property (nonatomic,assign) CGSize preferredSize;

/** The content size type that the preferredSize is using. Please refer to the CCNode documentation on how to use content size types. */
@property (nonatomic,assign) CCContentSizeType preferredSizeType;

/** The maximum size that the component will layout to, the component will not be larger than this size and will instead shrink its content if needed. */
@property (nonatomic,assign) CGSize maxSize;

/** The content size type that the preferredSize is using. Please refer to the CCNode documentation on how to use content size types. */
@property (nonatomic,assign) CCContentSizeType maxSizeType;


/// -----------------------------------------------------------------------
/// @name Setting and Getting Control Attributes
/// -----------------------------------------------------------------------

/** Sets or retrieves the current state of the control. It's often easier to use the enabled, highlighted and selected properties to indirectly set or read this property. This property is stored as a bit-mask. */
@property (nonatomic,assign) CCControlState state;

/** Determines if the control is currently enabled. */
@property (nonatomic,assign) BOOL enabled;

/** Determines if the control is currently selected. E.g. this is used by toggle buttons to handle the on state. */
@property (nonatomic,assign) BOOL selected;

/** Determines if the control is currently highlighted. E.g. this corresponds to the down state of a button */
@property (nonatomic,assign) BOOL highlighted;

/** True if the control continously should generate events when it's value is changed. E.g. this can be used by slider controls. */
@property (nonatomic,assign) BOOL continuous;

/** True if the control is currently tracking touches or mouse events. That is, if the user has touched down in the component but not lifted his finger (the actual touch may be outside the component). */
@property (nonatomic,readonly) BOOL tracking;

/** True if the control currently has a touch or a mouse event within its bounds. */
@property (nonatomic,readonly) BOOL touchInside;


/// -----------------------------------------------------------------------
/// @name Receiving Action Callbacks
/// -----------------------------------------------------------------------

/** A block that handles action callbacks sent by the control. Use either the block property or the setTarget:selector: method to receive actions from controls. */
@property (nonatomic,copy) void(^block)(id sender);

/**
 *  Sets a target and selector that should be called when an action is triggered by the control. Actions are generated when buttons are clicked, sliders are dragged etc. You can also set the action callback using the block property.
 *
 *  @param target   The target object.
 *  @param selector Selector to call on the target object.
 */
-(void) setTarget:(id)target selector:(SEL)selector;

@end
