/*
 Copyright (c) 2011 Steve Oldmeadow
 
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


#import "ccTypes.h"
#import "CocosDenshion.h"
@class CDXSoundSequencer;
@interface CDXSoundStep : NSObject {
	id nextStep_;
	id previousStep_;
	CDXSoundSequencer* _sequencer;//weak link
	int tag_;
	int soundId_;
}
@property (readwrite, nonatomic, assign) id nextStep;
@property (readwrite, nonatomic, assign) id previousStep;
@property (readwrite, nonatomic) int tag;
@property (readwrite, nonatomic) int soundId;

/** Called by sequencer when step should start */
-(void) stepStart:(CDXSoundSequencer*) sequencer;
/** return YES to tell sequencer step is complete */
-(BOOL) stepIsComplete;
/** Called periodically by sequencer so step can update */
-(void) update:(ccTime) dt;

@end

@interface CDXSoundStepRewind : CDXSoundStep
{
	int rewindTotal_;
	int rewindStepDistance_;
	int _rewindCount;
}

@property (readwrite, nonatomic) int rewindTotal;
@property (readwrite, nonatomic) int rewindStepDistance;

/**
 * @param rewindTotal - the number of times to rewind
 * @param rewindStepDistance - the number of steps to rewind, not including this step i.e. a distance of 1 will rewind to the prior step
 */
-(id) initWithRewindTotal:(int) rewindTotal rewindStepDistance:(int) rewindStepDistance;

@end


typedef enum {
	kCDX_StepModeStopOnDuration, //! step stops when elapsed time equals duration 
	kCDX_StepModeStopOnSoundCompletion,  //! step stops when sound has finished playing
	kCDX_StepModeStopOnFirstEvent, //! step stops when either elapsed time equals duration or sound has finished
	kCDX_StepModeStopOnLastEvent //! step stops when bot elapsed time equals duration or sound has finished

} tCDXSoundStepMode;


@interface CDXSoundStepPlay : CDXSoundStep {
	//Properties
	float pitch_;
	float pan_;
	float gain_;
	float duration_;
	tCDXSoundStepMode mode_;
	//Private
	float _elapsedTime;
}
@property (readwrite, nonatomic) float pitch;
@property (readwrite, nonatomic) float pan;
@property (readwrite, nonatomic) float gain;
@property (readwrite, nonatomic) float duration;
@property (readwrite, nonatomic) tCDXSoundStepMode mode;

-(id) initWithSound:(int) soundId;

@end

@class CDXSoundSequencer;

@protocol CDXSoundSequencerDelegate <NSObject>
@optional
/** The sound source completed playing */
- (void) cdStepDidFinish:(CDXSoundStep *) soundStep;
- (void) cdSequenceDidFinish:(CDXSoundSequencer*) sequencer;
@end

/**
 * Plays sequences of sound steps. Useful for chaining together sounds, for example when doing 
 * dynamically generated spoken phrases. A delegate can be assigned for notification of the completion
 * of each sequence step - this could be useful for something like narration in a childrens book where you 
 * want to synch to each word or phrase.
 */
@interface CDXSoundSequencer : NSObject {
	CDXSoundStep* _headStep;
	CDXSoundStep* _tailStep;
	CDXSoundStep* _currentStep;
	CDSoundSource* soundSource_;
	id<CDXSoundSequencerDelegate> delegate_;
	BOOL _newStep;
}
@property (nonatomic, readwrite, retain) id<CDXSoundSequencerDelegate> delegate;
@property (readonly) CDSoundSource* soundSource;
-(id) initWithSoundSource:(CDSoundSource*) soundSource;
-(void) update:(ccTime) dt;
-(void) pushStep:(CDXSoundStep*) step;
-(void) popStep;
-(void) rewindSteps:(int) stepCount;

@end
