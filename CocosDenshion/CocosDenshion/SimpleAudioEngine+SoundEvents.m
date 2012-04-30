//
//  SimpleAudioEngine+SoundEvents.m
//  ClockPhysics
//
//  Created by Jon Manning on 29/02/12.
//  Copyright (c) 2012 Secret Lab. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "SimpleAudioEngine+SoundEvents.h"

NSString* const SimpleAudioEngineQueueModeAlways = @"always";
NSString* const SimpleAudioEngineQueueModeNever = @"never";

static NSDictionary* _soundEvents = nil; // dictionary mapping event strings to sound info
static NSTimer* _voiceoverTimer = nil; // timer that indicates when to play the next queued voiceover sound
static NSMutableArray* _voiceoverQueue = nil; // array of queued voiceover lines

@implementation SimpleAudioEngine (SoundEvents)

// Return the dictionary describing all sound events.
// This will first try to load a file in the Documents directory 
// called SoundEvents.json. If it can't find it, it will look in
// the main bundle.

+ (NSDictionary*)soundEvents {
    if (_soundEvents == nil) {
        
        NSError* error = nil;
        
        // Try and load the file from documents
        NSString* documentsDirectory = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
        NSString* fileName = [documentsDirectory stringByAppendingPathComponent:@"SoundEvents.json"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
            NSData* data = [NSData dataWithContentsOfFile:fileName];
            _soundEvents = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if (error) {
                NSLog(@"Error loading SoundEvents.json: %@", error);
                return nil;
            }
        }
        
        if (_soundEvents == nil)  {
            NSString* fileName = [[NSBundle mainBundle] pathForResource:@"SoundEvents" ofType:@"json"];
            NSData* data = [NSData dataWithContentsOfFile:fileName];
            _soundEvents = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error) {
                NSLog(@"Error loading SoundEvents.json: %@", error);
                return nil;
            }

        }
        
        if (_soundEvents == nil) {
            NSLog(@"Couldn't find SoundEvents.json in either the bundle or in the Documents directory; check to see if it's added to the target and is named correctly!");
        }
    }
    
    return _soundEvents;
}

// Returns (and creates, if necessary) the queue of voiceover sounds.
+ (NSMutableArray*)voiceoverQueue {
    if (_voiceoverQueue == nil)
        _voiceoverQueue = [NSMutableArray array];
    return _voiceoverQueue;
}

// Empties the voiceover queue. No currently playing voiceover lines will be stopped.
- (void) removeAllItemsFromVoiceoverQueue {
    [[SimpleAudioEngine voiceoverQueue] removeAllObjects];
}

// Plays the next item in the voiceover queue, and removes that item from the queue.
- (void) playNextItemInQueue {
    // Only do work if there's something in the queue.
    if ([[SimpleAudioEngine voiceoverQueue] count] <= 0)
        return;
    
    NSString* nextEvent = [[SimpleAudioEngine voiceoverQueue] objectAtIndex:0];
    [[SimpleAudioEngine voiceoverQueue] removeObjectAtIndex:0];
    
    [self playSoundForEvent:nextEvent];
}

// Adds an item to the voiceover queue.
- (void) addEffectToQueue:(NSString*)effect {
    [[SimpleAudioEngine voiceoverQueue] addObject:effect];
}

// Works out the location of a sound file, first by looking in the 
// Documents folder, and then in the main bundle.
+ (NSString*) pathForFileNamed:(NSString*)fileName {
    
    // If the filename doesn't have an extension, append ".wav" to it.
    if ([[fileName pathExtension] isEqualToString:@""])
        fileName = [fileName stringByAppendingPathExtension:@"wav"];
    
    NSString* path = nil;
    
    // Try and find the file in documents
    NSString* documentsDirectory = [[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject] path];
    path = [documentsDirectory stringByAppendingPathComponent:fileName];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return path;
    }
    
    // Else try and play it from resources
    path = [[NSBundle mainBundle] pathForResource:[fileName stringByDeletingPathExtension] ofType:[fileName pathExtension]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return path;
    }
        
    // Else just give up
    NSLog(@"Can't find sound file %@ in either the bundle or the Documents directory!", fileName);
    return nil;
}

// Given a sound event name, work out what sound we should play, and 
// how it should be played.
// Returns YES if the sound is playing or queued, NO if otherwise.
- (BOOL) playSoundForEvent:(NSString *)eventName {
    
    // Get the event from the sound events dictionary. It can 
    // be an NSString or NSDictionary.
    id event = [[SimpleAudioEngine soundEvents] objectForKey:eventName];
    
    // Set up the default settings. The sound event data may override these.
    NSString* fileName = nil;
    BOOL background = NO;
    BOOL looping = NO;
    NSString* queueMode;
    CGFloat gain = 1.0;
    CGFloat pitch = 1.0;
    
    // If the event is an NSString, we're just playing a straight sound,
    // so just set the filename. If it's an NSDictionary, get additional
    // data about the sound.
    if ([event isKindOfClass:[NSString class]]) {
        
        fileName = [SimpleAudioEngine pathForFileNamed:event];
    } else if ([event isKindOfClass:[NSDictionary class]]) {
        
        fileName = [SimpleAudioEngine pathForFileNamed:[event objectForKey:@"file"]];
        background = [[event objectForKey:@"background"] boolValue];
        
        if (background) {
            looping = [[event objectForKey:@"loop"] boolValue];
        }
        
        if ([event objectForKey:@"gain"]) {
            gain = [[event objectForKey:@"gain"] floatValue];
            if (gain < 0) gain = 0;
            if (gain > 1) gain = 1;
        }
        
        queueMode = [event objectForKey:@"queue"];
        
        if ([event objectForKey:@"pitch-variability"]) {
            CGFloat variability = [[event objectForKey:@"pitch-variability"] floatValue];
            CGFloat randomNumber = (random() % 10000 / 10000.0);
            pitch += randomNumber * (variability + variability) - variability;
            
        }
        
    }
    
    if (fileName == nil) {
        return NO;
    }
        
    if (background)  {
        // If it's a background effect, play it in the background!
        [self playBackgroundMusic:fileName loop:looping];
        return YES;
    } else {
        
        // It's not a background effect, so figure out if we need to worry about
        // the queue and then act on that.
        
        // No queue mode set? Go ahead and play it!
        // (It will overlap with any currently playing sound.)
        if (queueMode == nil) {
            [self playEffect:fileName pitch:pitch pan:0 gain:gain];
            return YES;
        }
        
        // Is the voiceover timer running? If it is, a queued sound is playing
        if (_voiceoverTimer != nil) {
            
            // If the effect is "never queue", drop it
            if ([queueMode isEqualToString:SimpleAudioEngineQueueModeNever]) {
                NSLog(@"Dropping effect %@, which is set to never queue.", eventName);
                return NO;
            }
            
            // If the effect is "always queue", queue it up
            else if ([queueMode isEqualToString:SimpleAudioEngineQueueModeAlways]) {
                NSLog(@"Queueing effect %@.", eventName);
                [self addEffectToQueue:eventName];
                return YES;
            }
            
            // Otherwise, the queue mode is invalid and we should log a warning
            else {
                NSLog(@"Sound event %@ has invalid queue mode %@!", eventName, queueMode);
                return NO;
            }
                
        } else {
            // The timer is not running. Start it up!
            
            // First, get the duration of this effect.
            float timerDuration = [self durationForEffect:fileName];
            if (timerDuration <= 0) {
                NSLog(@"Sound event %@ tried to be queued, but its duration was reported to be <= 0!", eventName);
                return NO;
            }
            
            NSLog(@"Playing queued sound %@ (%.1fs long)", eventName, timerDuration);

            // Start the timer.
            _voiceoverTimer = [NSTimer scheduledTimerWithTimeInterval:timerDuration target:^{
                _voiceoverTimer = nil;
                NSLog(@"Reached the end of playing %@", eventName);
                [self playNextItemInQueue];
            } selector:@selector(invoke) userInfo:nil repeats:NO];
            
            // Finally, actually start the thing playing!
            [self playEffect:fileName pitch:pitch pan:0 gain:gain];
            return YES;
        }
    } 
    
}

// Stops the background music track, and cancels any pending voiceover clips.
- (void)stopSounds {
    [self stopBackgroundMusic];
    [self removeAllItemsFromVoiceoverQueue];
}

@end
