/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2015 Cocos2D Authors
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

#import "CCScheduler.h"

@interface CCScheduler()

@property (nonatomic) BOOL actionsRunInFixedMode;

-(void) update:(CCTime)dt;

-(CCTimer *) scheduleBlock:(CCTimerBlock)block forTarget:(NSObject<CCSchedulableTarget> *)target withDelay:(CCTime)delay;

-(void) scheduleTarget:(NSObject<CCSchedulableTarget> *)target;
-(void) unscheduleTarget:(NSObject<CCSchedulableTarget> *)target;
-(BOOL) isTargetScheduled:(NSObject<CCSchedulableTarget> *)target;

-(void) setPaused:(BOOL)paused target:(NSObject<CCSchedulableTarget> *)target;
-(BOOL) isTargetPaused:(NSObject<CCSchedulableTarget> *)target;

-(NSArray *) timersForTarget:(NSObject<CCSchedulableTarget> *)target;


#pragma mark Actions
-(void)addAction:(CCAction *)action target:(NSObject<CCSchedulableTarget> *)target paused:(BOOL)paused;
-(void)removeAction:(CCAction*) action fromTarget:(NSObject<CCSchedulableTarget> *)target;
-(void)removeActionByName:(NSString *)name target:(NSObject<CCSchedulableTarget> *)target;
-(void)removeAllActionsFromTarget:(NSObject<CCSchedulableTarget> *)target;
-(CCAction *)getActionByName:(NSString *)name target:(NSObject<CCSchedulableTarget> *)target;
-(NSArray *)actionsForTarget:(NSObject<CCSchedulableTarget> *)target;

@end

