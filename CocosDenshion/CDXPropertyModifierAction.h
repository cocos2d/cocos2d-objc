/*
 Copyright (c) 2010 Steve Oldmeadow

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

 $Id$
 */

#import "cocos2d.h"
#import "SimpleAudioEngine.h"

/** Base class for actions that modify audio properties
 @since v 1.0
 */
@interface CDXPropertyModifierAction : CCActionInterval {
	CDPropertyModifier *modifier;
	float lastSetValue;
}
/** creates the action */
+(id) actionWithDuration:(ccTime)t modifier:(CDPropertyModifier*) aModifier;

/** initializes the action */
-(id) initWithDuration:(ccTime)t modifier:(CDPropertyModifier*) aModifier;

+(void) fadeSoundEffects:(ccTime)t finalVolume:(float)endVol curveType:(tCDInterpolationType)curve shouldStop:(BOOL) stop;
+(void) fadeSoundEffect:(ccTime)t finalVolume:(float)endVol curveType:(tCDInterpolationType)curve shouldStop:(BOOL) stop effect:(CDSoundSource*) effect;
+(void) fadeBackgroundMusic:(ccTime)t finalVolume:(float)endVol curveType:(tCDInterpolationType) curve shouldStop:(BOOL) stop;

@end
