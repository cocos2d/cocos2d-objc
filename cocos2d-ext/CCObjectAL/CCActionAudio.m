//
//  CCActionAudio.m
//  cocos2d-tests
//
//  Created by Andrey Volodin on 10.02.16.
//  Copyright © 2016 Cocos2d. All rights reserved.
//

#import "CCActionAudio.h"
#import "OALSimpleAudio.h"

@implementation CCActionSoundEffect

+ (id)actionWithSoundFile:(NSString*)f pitch:(float)pi pan:(float) pa gain:(float)ga
{
    return [[CCActionSoundEffect alloc] initWithSoundFile:f pitch:pi pan:pa gain:ga];
}

- (id)initWithSoundFile:(NSString*)file pitch:(float)pi pan:(float) pa gain:(float)ga
{
    self = [super init];
    if (!self) return NULL;
    
    _soundFile = [file copy];
    _pitch = pi;
    _pan = pa;
    _gain = ga;
    
    return self;
}


- (void)update:(CCTime)time
{
    [[OALSimpleAudio sharedInstance] playEffect:_soundFile volume:_gain pitch:_pitch pan:_pan loop:NO];
}

- (id)copyWithZone:(NSZone*)zone
{
    CCSpriteFrame *copy = [[[self class] allocWithZone: zone] initWithSoundFile:_soundFile pitch:_pitch pan:_pan gain:_gain];
    return copy;
}

@end
