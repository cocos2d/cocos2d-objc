/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 Lam Pham
 *
 * Copyright (c) 2012 Ricardo Quesada
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

#import "CCTransition.h"

@class CCProgressTimer;

@interface CCTransitionProgress : CCTransitionScene
{
	float to_, from_;
	CCScene *sceneToBeModified_;
}
// Needed for BridgeSupport
-(CCProgressTimer*) progressTimerNodeWithRenderTexture:(CCRenderTexture*)texture;
@end

/** CCTransitionRadialCCW transition.
 A counter clock-wise radial transition to the next scene
 */
@interface CCTransitionProgressRadialCCW : CCTransitionProgress
{}
// Needed for BridgeSupport
-(CCProgressTimer*) progressTimerNodeWithRenderTexture:(CCRenderTexture*)texture;
@end

/** CCTransitionRadialCW transition.
 A counter clock-wise radial transition to the next scene
*/
@interface CCTransitionProgressRadialCW : CCTransitionProgress
{}
// Needed for BridgeSupport
-(CCProgressTimer*) progressTimerNodeWithRenderTexture:(CCRenderTexture*)texture;
@end

/** CCTransitionProgressHorizontal transition.
 A  clock-wise radial transition to the next scene
 */
@interface CCTransitionProgressHorizontal : CCTransitionProgress
{}
// Needed for BridgeSupport
-(CCProgressTimer*) progressTimerNodeWithRenderTexture:(CCRenderTexture*)texture;
@end

@interface CCTransitionProgressVertical : CCTransitionProgress
{}
// Needed for BridgeSupport
-(CCProgressTimer*) progressTimerNodeWithRenderTexture:(CCRenderTexture*)texture;
@end

@interface CCTransitionProgressInOut : CCTransitionProgress
{}
// Needed for BridgeSupport
-(CCProgressTimer*) progressTimerNodeWithRenderTexture:(CCRenderTexture*)texture;
@end

@interface CCTransitionProgressOutIn : CCTransitionProgress
{}
// Needed for BridgeSupport
-(CCProgressTimer*) progressTimerNodeWithRenderTexture:(CCRenderTexture*)texture;
@end
