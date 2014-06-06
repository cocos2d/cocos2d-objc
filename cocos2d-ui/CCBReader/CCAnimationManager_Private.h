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

@interface CCAnimationManager ()

// Sequence Array
@property (nonatomic,readonly) NSMutableArray* sequences;


// Auto play sequence id.
@property (nonatomic,assign) int autoPlaySequenceId;

// Base node.
@property (nonatomic,unsafe_unretained) CCNode* rootNode;

// (CCB) Optional owner
@property (nonatomic,unsafe_unretained) id owner;

// (CCB) Resolution and default container size.
@property (nonatomic,assign) CGSize rootContainerSize;

// (CCB) Node Management
- (CGSize) containerSize:(CCNode*)node;
- (void) addNode:(CCNode*)node andSequences:(NSDictionary*)seq;
- (void) moveAnimationsFromNode:(CCNode*)fromNode toNode:(CCNode*)toNode;

// Reset node state.
- (void) setBaseValue:(id)value forNode:(CCNode*)node propertyName:(NSString*)propName;

- (void) runAnimationsForSequenceId:(int)seqId tweenDuration:(float) tweenDuration;

- (void)timeSeekForSequenceId:(int)seqId time:(float)time;

#pragma mark Simple Sequence Builder
- (void)addKeyFramesForSequenceNamed:(NSString*)name propertyType:(CCBSequencePropertyType)propertyType frameArray:(NSArray*)frameArray node:(CCNode *)node loop:(BOOL)loop;

@end

