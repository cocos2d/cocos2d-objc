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

@protocol CCScrollViewDelegate <NSObject>

@optional
- (void)scrollViewDidScroll:(CCScrollView *)scrollView;
- (void)scrollViewWillBeginDragging:(CCScrollView *)scrollView;
- (void)scrollViewDidEndDragging:(CCScrollView * )scrollView willDecelerate:(BOOL)decelerate;
- (void)scrollViewWillBeginDecelerating:(CCScrollView *)scrollView;
- (void)scrollViewDidEndDecelerating:(CCScrollView *)scrollView;

@end

#ifdef __CC_PLATFORM_IOS

// Class definition for iOS
@interface CCScrollView : CCNode <UIGestureRecognizerDelegate>

#elif defined(__CC_PLATFORM_MAC)

// Class definition for Mac
@interface CCScrollView : CCNode

#endif

{
#ifdef __CC_PLATFORM_IOS
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

@property (nonatomic, weak) id<CCScrollViewDelegate> delegate;

@property (nonatomic,strong) CCNode* contentNode;

@property (nonatomic,assign) BOOL flipYCoordinates;

@property (nonatomic,assign) BOOL horizontalScrollEnabled;
@property (nonatomic,assign) BOOL verticalScrollEnabled;

@property (nonatomic,assign) CGPoint scrollPosition;

@property (nonatomic,assign) BOOL pagingEnabled;
@property (nonatomic,assign) int horizontalPage;
@property (nonatomic,assign) int verticalPage;
@property (nonatomic,readonly) int numVerticalPages;
@property (nonatomic,readonly) int numHorizontalPages;

@property (nonatomic,readonly) float minScrollX;
@property (nonatomic,readonly) float maxScrollX;
@property (nonatomic,readonly) float minScrollY;
@property (nonatomic,readonly) float maxScrollY;

@property (nonatomic,assign) BOOL bounces;

- (id) initWithContentNode:(CCNode*)contentNode;

- (void) setScrollPosition:(CGPoint)newPos animated:(BOOL)animated;

- (void) setHorizontalPage:(int)horizontalPage animated:(BOOL)animated;
- (void) setVerticalPage:(int)verticalPage animated:(BOOL)animated;
@end
