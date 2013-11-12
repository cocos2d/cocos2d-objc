//
//  ALContext.h
//  ObjectAL
//
//  Created by Karl Stenerud on 10-01-09.
//
//  Copyright (c) 2009 Karl Stenerud. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall remain in place
// in this source code.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Attribution is not required, but appreciated :)
//

#import <Foundation/Foundation.h>
#import <OpenAL/alc.h>
#import "ALListener.h"
#import "ALSource.h"
#import "OALSuspendHandler.h"


@class ALDevice;


#pragma mark ALContext

/**
 * A context encompasses a single listener and a series of sources.
 * A context is created from a device, and many contexts may be created
 * (though multiple contexts would be unusual in an iOS app). <br>
 *
 * Note: Some property values are only valid if this context is the current
 * context.
 *
 * @see ObjectAL.currentContext
 */
@interface ALContext : NSObject <OALSuspendManager>
{
	ALCcontext* context;
	/** All sound sources associated with this context. */
	NSMutableArray* sources;
	ALListener* listener;
	bool suspended;
	/** This context's attributes. */
	NSMutableArray* attributes;
	
	/** Handles suspending and interrupting for this object. */
	OALSuspendHandler* suspendHandler;
}


#pragma mark Properties

/** OpenAL version string in format
 * “[spec major number].[spec minor number] [optional vendor version information]”
 * Only valid when this is the current context.
 */
@property(nonatomic,readonly,retain) NSString* alVersion;

/** The current context's attribute list.
 * Only valid when this is the current context.
 */
@property(nonatomic,readonly,retain) NSArray* attributes;

/** The OpenAL context pointer. */
@property(nonatomic,readonly,assign) ALCcontext* context;

/** The device this context was opened on. */
@property(nonatomic,readonly,retain) ALDevice* device;

/** The current distance model.
 * Legal values are AL_NONE, AL_INVERSE_DISTANCE, AL_INVERSE_DISTANCE_CLAMPED,
 * AL_LINEAR_DISTANCE, AL_LINEAR_DISTANCE_CLAMPED, AL_EXPONENT_DISTANCE,
 * and AL_EXPONENT_DISTANCE_CLAMPED. See the OpenAL spec for detailed information. <br>
 * Only valid when this is the current context.
 */
@property(nonatomic,readwrite,assign) ALenum distanceModel;

/** Exaggeration factor for Doppler effect.
 * Only valid when this is the current context.
 */
@property(nonatomic,readwrite,assign) float dopplerFactor;

/** List of available extensions (NSString*).
 * Only valid when this is the current context.
 */
@property(nonatomic,readonly,retain) NSArray* extensions;

/** This context's listener. */
@property(nonatomic,readonly,retain) ALListener* listener;

/** Information about the specific renderer.
 * Only valid when this is the current context.
 */
@property(nonatomic,readonly,retain) NSString* renderer;

/** All sources associated with this context (ALSource*). */
@property(nonatomic,readonly,retain) NSArray* sources;

/** Speed of sound in same units as velocities.
 * Only valid when this is the current context.
 */
@property(nonatomic,readwrite,assign) float speedOfSound;

/** Name of the vendor.
 * Only valid when this is the current context.
 */
@property(nonatomic,readonly,retain) NSString* vendor;


#pragma mark Object Management

/** Create a new context on the specified device.
 *
 * @param device The device to open the context on.
 * @param attributes An array of NSNumber in ordered pairs (attribute id followed by integer value).
 * Posible attributes: ALC_FREQUENCY, ALC_REFRESH, ALC_SYNC, ALC_MONO_SOURCES, ALC_STEREO_SOURCES
 * @return A new context.
 */
+ (id) contextOnDevice:(ALDevice *) device attributes:(NSArray*) attributes;

/** Create a new context on the specified device with attributes.
 *
 * @param device The device to open the context on.
 * @param outputFrequency The frequency to mix all sources to before outputting (ignored by iOS).
 * @param refreshIntervals The number of passes per second used to mix the audio sources.
 *        For games this can be 5-15. For audio intensive apps, it should be higher (ignored by iOS).
 * @param synchronousContext If true, this context runs on the main thread and depends on you
 *        calling alcUpdateContext (ignored by iOS).
 * @param monoSources A hint indicating how many sources should support mono (default 28 on iOS).
 * @param stereoSources A hint indicating how many sources should support stereo (default 4 on iOS).
 * @return A new context.
 */
+ (id) contextOnDevice:(ALDevice*) device
	   outputFrequency:(int) outputFrequency
	  refreshIntervals:(int) refreshIntervals 
	synchronousContext:(bool) synchronousContext
		   monoSources:(int) monoSources
		 stereoSources:(int) stereoSources;


/** Initialize this context on the specified device with attributes.
 *
 * @param device The device to open the context on.
 * @param outputFrequency The frequency to mix all sources to before outputting (ignored by iOS).
 * @param refreshIntervals The number of passes per second used to mix the audio sources.
 *        For games this can be 5-15. For audio intensive apps, it should be higher (ignored by iOS).
 * @param synchronousContext If true, this context runs on the main thread and depends on you
 *        calling alcUpdateContext (ignored by iOS).
 * @param monoSources A hint indicating how many sources should support mono (default 28 on iOS).
 * @param stereoSources A hint indicating how many sources should support stereo (default 4 on iOS).
 * @return The initialized context.
 */
- (id) initOnDevice:(ALDevice*) device
	outputFrequency:(int) outputFrequency
   refreshIntervals:(int) refreshIntervals 
 synchronousContext:(bool) synchronousContext
		monoSources:(int) monoSources
	  stereoSources:(int) stereoSources;


/** Initialize this context for the specified device and attributes.
 *
 * @param device The device to open the context on.
 * @param attributes An array of NSNumber in ordered pairs (attribute id followed by integer value).
 * Posible attributes: ALC_FREQUENCY, ALC_REFRESH, ALC_SYNC, ALC_MONO_SOURCES, ALC_STEREO_SOURCES
 * @return The initialized context.
 */
- (id) initOnDevice:(ALDevice *) device attributes:(NSArray*) attributes;


#pragma mark Utility

/** Process this context.
 */
- (void) process;

/** Stop all sound sources in this context.
 */
- (void) stopAllSounds;

/** Clear all buffers being used by sources in this context.
 */
- (void) clearBuffers;

/** Make sure this context is the current context.
 * This method is used to work around iOS 4.0 and 4.2 bugs
 * that could cause the context to be lost.
 */
- (void) ensureContextIsCurrent;

#pragma mark Extensions

/** Check if the specified extension is present in this context.
 * Only valid when this is the current context.
 *
 * @param name The name of the extension to check.
 * @return TRUE if the extension is present in this context.
 */
- (bool) isExtensionPresent:(NSString*) name;

/** Get the address of the specified procedure (C function address).
 * Only valid when this is the current context. <br>
 * <strong>Note:</strong> The OpenAL implementation is free to return
 * a pointer even if it is not valid for this context. Always call isExtensionPresent
 * first.
 *
 * @param functionName the name of the procedure to get.
 * @return the procedure's address, or NULL if it wasn't found.
 */
- (void*) getProcAddress:(NSString*) functionName;


#pragma mark Internal Use

/** \cond */
/** (INTERNAL USE) Used by ALSource to announce initialization.
 *
 * @param source the source that is initializing.
 */
- (void) notifySourceInitializing:(ALSource*) source;

/** (INTERNAL USE) Used by ALSource to announce deallocation.
 *
 * @param source the source that is deallocating.
 */
- (void) notifySourceDeallocating:(ALSource*) source;
/** \endcond */

@end
