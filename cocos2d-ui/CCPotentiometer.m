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


#import "CCPotentiometer.h"
#import "CCControlSubclass.h"
#import "CCSprite.h"
#import "CCProgressNode.h"
#import "CCActionEase.h"
#import "CCActionTween.h"
#import "cocos2d.h"

@interface CCPotentiometer () 
@property (nonatomic, strong) CCSprite        *thumbSprite;
@property (nonatomic, strong) CCSprite        *trackSprite;
@property (nonatomic, strong) CCProgressNode  *progressTimer;
@property (nonatomic, assign) CGPoint         previousLocation;
@property (nonatomic, assign) float           animatedValue;

/** Factorize the event dispath into these methods. */
- (void)potentiometerBegan:(CGPoint)location;
- (void)potentiometerMoved:(CGPoint)location;
- (void)potentiometerEnded:(CGPoint)location;

/** Returns the distance between the point1 and point2. */
- (float)distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2;
/** Returns the angle in degree between line1 and line2. */
- (float)angleInDegreesBetweenLineFromPoint:(CGPoint)beginLineA 
                                    toPoint:(CGPoint)endLineA
                            toLineFromPoint:(CGPoint)beginLineB
                                    toPoint:(CGPoint)endLineB;

/** Layout the slider with the given value. */
- (void)layoutWithValue:(float)value;

@end

@implementation CCPotentiometer
@synthesize value            = _value;
@synthesize minimumValue     = _minimumValue;
@synthesize maximumValue     = _maximumValue;
@synthesize onThumbTintColor = _onThumbTintColor;
@synthesize thumbSprite      = _thumbSprite;
@synthesize progressTimer    = _progressTimer;
@synthesize previousLocation = _previousLocation;
@synthesize animatedValue    = _animatedValue;
@synthesize trackSprite      = _trackSprite;

+ (id)potentiometerWithTrackFile:(NSString *)backgroundFile progressFile:(NSString *)progressFile thumbFile:(NSString *)thumbFile
{
    // Prepare track for potentiometer
    CCSprite *backgroundSprite = [CCSprite spriteWithImageNamed:backgroundFile];
    
    // Prepare thumb for potentiometer
    CCSprite *thumbSprite = [CCSprite spriteWithImageNamed:thumbFile];
    
    // Prepare progress for potentiometer
    CCProgressNode *progressNode = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:progressFile]];
    progressNode.type = CCProgressNodeTypeRadial;

    return [[self alloc] initWithTrackSprite:backgroundSprite progressSprite:progressNode thumbSprite:thumbSprite];
}

- (id)initWithTrackSprite:(CCSprite *)trackSprite progressSprite:(CCProgressNode *)progressTimer thumbSprite:(CCSprite *)thumbSprite
{
    if ((self = [super init])) {
        self.progressTimer   = progressTimer ?: [[CCProgressNode alloc] init];
        self.thumbSprite     = thumbSprite   ?: [[CCSprite alloc] init];
        self.trackSprite     = trackSprite   ?: [[CCSprite alloc] init];
        thumbSprite.position = _progressTimer.position;
        
        [self addChild:_thumbSprite z:2];
        [self addChild:_progressTimer z:1];
        [self addChild:_trackSprite];
        
        self.contentSize = CGSizeMake(MAX(MAX(trackSprite.contentSize.width,
                                              thumbSprite.contentSize.width),
                                          progressTimer.contentSize.width),
                                      MAX(MAX(trackSprite.contentSize.height,
                                              thumbSprite.contentSize.height),
                                          progressTimer.contentSize.height));
        
        // Init default values
        _onThumbTintColor = [CCColor grayColor];
        _minimumValue     = 0.0f;
        _maximumValue     = 1.0f;
        self.value        = _minimumValue;
        self.userInteractionEnabled = YES;
    }
    return self;
}

#pragma mark Properties

- (void)setEnabled:(BOOL)enabled
{
    super.enabled = enabled;
    
    _thumbSprite.opacity = (enabled) ? 1.0f : 0.5f;
}

- (void)setValue:(float)value
{
    [self setValue:value animated:NO];
}

- (void)setAnimatedValue:(float)animatedValue
{
    [self layoutWithValue:animatedValue];
}

- (void)setMinimumValue:(float)minimumValue
{
    _minimumValue = minimumValue;
    
    if (_minimumValue >= _maximumValue) {
        _maximumValue = _minimumValue + 1.0f;
    }
    
    self.value = _maximumValue;
}

- (void)setMaximumValue:(float)maximumValue
{
    _maximumValue = maximumValue;
    
    if (_maximumValue <= _minimumValue) {
        _minimumValue = _maximumValue - 1.0f;
    }
    
    self.value = _minimumValue;
}

#pragma mark CCTargetedTouch Delegate Methods

-(BOOL)hitTestWithWorldPos:(CGPoint)pos {
    CGPoint touchLocation = [self convertToNodeSpace:pos];
    
    float distance = [self distanceBetweenPoint:_progressTimer.position andPoint:touchLocation];
    
    return distance < MIN(self.contentSize.width / 2, self.contentSize.height / 2);
    
}

#if __CC_PLATFORM_IOS
-(void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    
    _previousLocation = [touch locationInNode:self];
    
    [self potentiometerBegan:_previousLocation];
}

-(void)touchMoved:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    
    CGPoint location = [touch locationInNode:self];
    
    [self potentiometerMoved:location];
}

-(void)touchEnded:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    [self potentiometerEnded:CGPointZero];
}

-(void)touchCancelled:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    [self touchEnded:touch withEvent:event];
}

#endif

#pragma mark -
#pragma mark CCControlPotentiometer Public Methods

- (void)setValue:(float)value animated:(BOOL)animated
{
    // set new value with sentinel
    if (value < _minimumValue) {
        value = _minimumValue;
    }
	
    if (value > _maximumValue) {
        value = _maximumValue;
    }
    
    if (animated) {
        [self runAction:
         [CCActionEaseInOut actionWithAction:[CCActionTween actionWithDuration:0.2f key:@"animatedValue" from:_value to:value]
                                  rate:1.5f]];
    }
    else {
        [self layoutWithValue:value];
    }
    
    _value = value;
}

#pragma mark CCControlPotentiometer Private Methods

- (float)distanceBetweenPoint:(CGPoint)point1 andPoint:(CGPoint)point2
{
    CGFloat dx = point1.x - point2.x;
    CGFloat dy = point1.y - point2.y;
    return sqrt(dx*dx + dy*dy);
}

- (float)angleInDegreesBetweenLineFromPoint:(CGPoint)beginLineA 
                                    toPoint:(CGPoint)endLineA
                            toLineFromPoint:(CGPoint)beginLineB
                                    toPoint:(CGPoint)endLineB;
{
    CGFloat a = endLineA.x - beginLineA.x;
    CGFloat b = endLineA.y - beginLineA.y;
    CGFloat c = endLineB.x - beginLineB.x;
    CGFloat d = endLineB.y - beginLineB.y;
    
    CGFloat atanA = atan2(a, b);
    CGFloat atanB = atan2(c, d);
    
    // convert radiants to degrees
    return (atanA - atanB) * 180 / M_PI;
}

- (void)potentiometerBegan:(CGPoint)location
{
    self.selected          = YES;
    self.thumbSprite.color = _onThumbTintColor;
}

- (void)potentiometerMoved:(CGPoint)location
{
    CGFloat angle = [self angleInDegreesBetweenLineFromPoint:_progressTimer.position
                                                           toPoint:location 
                                                   toLineFromPoint:_progressTimer.position
                                                           toPoint:_previousLocation];
    
    // fix value, if the 12 o'clock position is between location and previousLocation
    if (angle > 180) {
        angle -= 360;
    }
    else if (angle < -180) {
        angle += 360;
    }

    self.value += angle / 360.0f * (_maximumValue - _minimumValue);
    
    _previousLocation = location;
    
    if (self.continuous)
        [self triggerAction];
}

- (void)potentiometerEnded:(CGPoint)location
{
    self.thumbSprite.color = [CCColor whiteColor];
    self.selected          = NO;
    
    [self triggerAction];
}

- (void)layoutWithValue:(float)value
{
    // Update thumb and progress position for new value
    float percent             = (value - _minimumValue) / (_maximumValue - _minimumValue);
    _progressTimer.percentage = percent * 100.0f;
    _thumbSprite.rotation     = percent * 360.0f;
}

@end
