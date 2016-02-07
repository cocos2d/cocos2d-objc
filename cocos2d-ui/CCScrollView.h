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

@class CCTapDownGestureRecognizer;
@class CCScrollView;

/** Messages a CCScrollViewDelegate can implement to receive event information such as when the view begins or ends dragging or scrolling. */
@protocol CCScrollViewDelegate <NSObject>

@optional
/** Sent when the scroll view has stopped scrolling (moving).
 @param scrollView The scroll view the event originated from. */
- (void)scrollViewDidScroll:(CCScrollView *)scrollView;
/** Sent when the scroll view is about to be dragged.
 @param scrollView The scroll view the event originated from. */
- (void)scrollViewWillBeginDragging:(CCScrollView *)scrollView;
/** Sent when the scroll view is no longer being dragged. Depending on scroll view settings this may not coincide with
 end of scrolling as the scroll view may scroll to snapp in the intended place.
 @param scrollView The scroll view the event originated from.
 @param decelerate Whether the scroll view will decelerate, in other words whether it will continue to scroll in a given direction to snap in place. */
- (void)scrollViewDidEndDragging:(CCScrollView * )scrollView willDecelerate:(BOOL)decelerate;
/** Sent when the dragging ended but the scroll view still moves towards its designated location.
 @param scrollView The scroll view the event originated from. */
- (void)scrollViewWillBeginDecelerating:(CCScrollView *)scrollView;
/** Sent when the scroll view is no longer scrolling and has come to rest.
 @param scrollView The scroll view the event originated from. */
- (void)scrollViewDidEndDecelerating:(CCScrollView *)scrollView;

@end

/** A scroll view implementation similar to but technically unrelated to [UIScrollView](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIScrollView_Class/index.html).
 
 The scroll view supports pagination, where content snaps back to the nearest page when the user stopped dragging the content. The behavior is similar to flicking through photos in the iOS Photo Album app.
 
 If you initialize the CCScrollView with a contentNode, the scroll view's contentSize will be set to automatically scale with the content node's size. You can also set the scroll view's contentSize to a fixed
 size to limit where the scroll view reacts to touches, but this will not prevent the content node from drawing its contents over the bounds of the scroll view (ie CCScrollView is not combined with CCClippingNode
 behavior). Though you could use a clipping node as the content node, and add the actual content node to the clipping node if that's what you're looking for.
 
 In pagination mode, the contentNode must have a contentSize that's a multiple of the number of pages you want to display. Ie in a horizontal paging scroll view with width 350 points and 7 pages the content node's width must
 be 2450 points. If there's a mismatch you'll notice that as you flick through pages they won't be aligned perfectly with the rectangle defined by the scroll view's position and contentSize.

 A simple code example for a scroll view positioned at the center, extending 200 points to the right and up:
 
 **Objective-C:**
 
    CCSprite* contentNode = [CCSprite spriteWithImageNamed:@"Default.png"];
 
    CCScrollView* scrollView = [CCScrollView scrollViewWithContentNode:contentNode];
    scrollView.contentSizeType = CCSizeTypePoints;
    scrollView.contentSize = CGSizeMake(200, 200);
    CGSize viewSize = [CCDirector sharedDirector].viewSize;
    scrollView.position = CGPointMake(viewSize.width / 2.0, viewSize.height / 2.0);
    [self addChild:scrollView];
 
 **Swift:**
 
    let contentNode = CCSprite(imageNamed: "Default.png")
 
    let scrollView = CCScrollView(contentNode: contentNode)
    scrollView.contentSizeType = CCSizeType(widthUnit: .Points, heightUnit: .Points)
    scrollView.contentSize = CGSizeMake(200, 200)
    let viewSize = CCDirector.sharedDirector().viewSize()
    scrollView.position = CGPoint(x: viewSize.width / 2.0, y: viewSize.height / 2.0)
    addChild(scrollView)
 
 Notice that you have to change the contentSizeType if you want to feed point coordinates into the contentSize because the type defaults to CCSizeTypeNormalized.
 
 Refer to the [CCScrollViewTest](https://github.com/cocos2d/cocos2d-swift/blob/develop/cocos2d-ui-tests/tests/CCScrollViewTest.m) for more code examples.
 
 @note CCScrollView internally uses UIGestureRecognizer instances to control the scrolling. You may run into issues when using your own gesture recognizers while a CCScrollView is active.
 
 @warning You should not manually alter the contentNode's CCNode properties while it is part of a scroll view, specifically don't modify properties or run actions that affect its position, size and scale.
 
 @warning Contrary to its name, this node is **not supposed to be used to scroll game worlds**! Specifically it is not meant to scroll content based on the position of other objects, such as the player character's node.
 For this kind of scrolling, CCScrollView is inefficient and can have adverse side-effects. CCScrollView is supposed to be used for content that's scrolled directly through user interaction (dragging, flicking). For that,
 it captures user input, so one major issue would be to allow user interaction on the game world's contents and converting coordinates of touch input to the actual scroll location. For "correct" game world scrolling, please
 find a solution better suited to the purpose. For one such solution and more details about CCScrollView in general please refer to the [Learn SpriteBuilder book](http://www.apress.com/learn-spritebuilder-for-ios-game-development).
 */

// Enable this if you want your node to trigger delegate calls on start and end of progamming animations
// Maybe useful in single-axis scroll views, mainly in UI.
#ifndef CC_ENABLE_DELEGATE_CALLS_DURING_ANIMATIONS
#define CC_ENABLE_DELEGATE_CALLS_DURING_ANIMATIONS 0
#endif

#if __CC_PLATFORM_IOS

// Class definition for iOS
@interface CCScrollView : CCNode <UIGestureRecognizerDelegate>

#elif __CC_PLATFORM_MAC

// Class definition for Mac
@interface CCScrollView : CCNode


#else

@interface CCScrollView : CCNode

#endif

{
#if __CC_PLATFORM_IOS
    UIPanGestureRecognizer* _panRecognizer;
    CCTapDownGestureRecognizer* _tapRecognizer;
#endif
    
    CGPoint _rawTranslationStart;
    CGPoint _startScrollPos;
    BOOL _isPanning;
    BOOL _animatingX;
    BOOL _animatingY;
    CGPoint _velocity;
}

/** @name Creating a Scroll View */


/** Creates a new scroll view with a content node.
 
 This also sets the scroll view's contentSize as normalized to (same size as) the contentNode's size:
 
 self.contentSize = CGSizeMake(1, 1);
 self.contentSizeType = CCSizeTypeNormalized;
 
 @param contentNode The node the scroll view will display. Must not be nil. */
+ (id) scrollViewWithContentNode:(CCNode*)contentNode;

/** Initializes a new scroll view with a content node.
 
 This also sets the scroll view's contentSize as normalized to (same size as) the contentNode's size:
 
    self.contentSize = CGSizeMake(1, 1);
    self.contentSizeType = CCSizeTypeNormalized;
 
 @param contentNode The node the scroll view will display. Must not be nil. */
- (id) initWithContentNode:(CCNode*)contentNode;

/** @name Assigning Content Node and Delegate */

/** An object that implements the CCScrollViewDelegate protocol. Use this to get informed about scroll view events. */
@property (nonatomic, weak) id<CCScrollViewDelegate> delegate;

/** The content node. Assigning a new content node will remove and replace the previous one.
 
 @note Assigning a new contentNode will not update the scroll view's [CCNode contentSize] and [CCNode contentSizeType] properties.
 If you need multiple views with varying sizes/pages you will also have to update these properties after assigning a new contentNode with different dimensions or pages. */
@property (nonatomic,strong) CCNode* contentNode;

/** @name Scrolling Properties */

/** This is essentially the content node's position relative to the scroll view's origin. 
 
 @note Due to the way scrolling works, the content node's position is inversed, meaning if scrollPosition is `{0, 300}` the contentNode.position is actually `{0, -300}`. */
@property (nonatomic,assign) CGPoint scrollPosition;

/** Sets the scrollPosition property, except that you can optionally specify whether the position change should be animated. Animated of course means the view will scroll
 to this new location. 
 
 @note The scrolling speed depends on the relative distance between the current and new position, but its maximum duration is clamped to the snap duration (currently: 0.4 seconds).
 @warning Running this method with animation multiple times in short sequence can lead to glitches as any previous scrolling operation (ie move action) is not interrupted, thus
 you can potentially end up stacking multiple move actions that run simultaneously with unpredictable results.
 
 @param newPos The new scroll position.
 @param animated If YES, the view will scroll to the new position. Otherwise it will snap to the new position instantly. */
- (void) setScrollPosition:(CGPoint)newPos animated:(BOOL)animated;

/** Determines whether scrolling horizontally is allowed or not. */
@property (nonatomic,assign) BOOL horizontalScrollEnabled;
/** Determines whether scrolling vertically is allowed or not. */
@property (nonatomic,assign) BOOL verticalScrollEnabled;

// purposefully not documented, calculated values of little use to user, mainly for internal use.
@property (nonatomic,readonly) float minScrollX;
@property (nonatomic,readonly) float maxScrollX;
@property (nonatomic,readonly) float minScrollY;
@property (nonatomic,readonly) float maxScrollY;

/** Whether the Y coordinates for position and velocity calculations should be inversed. Defaults to YES.
 
 This is intended to allow switching between "natural" scroll direction where scrolling down moves the content down, which is most natural for touch input.
 However for non-touch input such as a mouse drag operation or the mouse wheel you'll find that "natural" scroll direction isn't so natural after all. In that
 case you may want to reset flipYCoordinates to NO. */
@property (nonatomic,assign) BOOL flipYCoordinates;


/** @name Paging Properties */

/** Whether paging is enabled. With paging enabled, the contentNode's contentSize is assumed to have a multiple of the scroll view's contentSize, so that
 each page aligns perfectly on the rectangle defined by the scroll view's position and contentSize. */
@property (nonatomic,assign) BOOL pagingEnabled;
/** Whether one can drag the contents of the scroll view past the bounds. This will create a snap-back effect with animation like in UIScrollView. Defaults to YES. */
@property (nonatomic,assign) BOOL bounces;

/** Zero-based index of the currently displayed horizontal page. */
@property (nonatomic,assign) int horizontalPage;
/** Zero-based index of the currently displayed vertical page. */
@property (nonatomic,assign) int verticalPage;
/** The highest page index or "count" for horizontal pages. */
@property (nonatomic,readonly) int numHorizontalPages;
/** The highest page index or "count" for vertical pages. */
@property (nonatomic,readonly) int numVerticalPages;

/** Sets the horizontalPage property, except that you can optionally animate the change. 
 Internally calls setScrollPosition:animated: so all caveats (scroll speed, stacking move actions) apply here as well.
 @param horizontalPage The index of the horizontal page to scroll or snap to. Index must be in the range 0 to (numHorizontalPages - 1).
 @param animated If YES, the view will scroll to the page. Otherwise it will instantly snap to the page. */
- (void) setHorizontalPage:(int)horizontalPage animated:(BOOL)animated;
/** Sets the verticalPage property, except that you can optionally animate the change.
 Internally calls setScrollPosition:animated: so all caveats (scroll speed, stacking move actions) apply here as well.
 @param verticalPage The index of the vertical page to scroll or snap to. Index must be in the range 0 to (numVerticalPages - 1).
 @param animated If YES, the view will scroll to the page. Otherwise it will instantly snap to the page. */
- (void) setVerticalPage:(int)verticalPage animated:(BOOL)animated;

@end
