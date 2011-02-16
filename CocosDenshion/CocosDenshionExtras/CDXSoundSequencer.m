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

#import "CDXSoundSequencer.h"
@implementation CDXSoundStep

@synthesize nextStep = nextStep_;
@synthesize previousStep = previousStep_;
@synthesize soundId = soundId_;
@synthesize tag = tag_;

-(void) stepStart:(CDXSoundSequencer*) sequencer {
	_sequencer = sequencer;
}	

-(BOOL) stepIsComplete {
	//Override
	return YES;
}	

-(void) update:(ccTime) dt {
	//Override
}

@end

@implementation CDXSoundStepRewind
@synthesize rewindTotal = rewindTotal_;
@synthesize	rewindStepDistance = rewindStepDistance_;

-(id) initWithRewindTotal:(int) rewindTotal rewindStepDistance:(int) rewindStepDistance {
	
	if ((self = [super init])) {
		rewindTotal_ = rewindTotal;
		rewindStepDistance_ = rewindStepDistance;
		_rewindCount = 0;
	}	
	return self;
}	

-(void) stepStart:(CDXSoundSequencer*) sequencer {
	CDLOG(@"Rewind step: %i",_rewindCount);
	[super stepStart:sequencer];
	if (_rewindCount < rewindTotal_) {
		[sequencer rewindSteps:rewindStepDistance_];
		_rewindCount++;
	}	
}	

//If this ever gets called then the step is completed
-(BOOL) stepIsComplete {
	_rewindCount = 0;
	return YES;
}	

@end

@implementation CDXSoundStepPlay

@synthesize pitch = pitch_;
@synthesize pan = pan_;
@synthesize gain = gain_;
@synthesize duration = duration_;
@synthesize mode = mode_;

-(id) initWithSound:(int) soundId {
	if((self=[super init])) {
		soundId_ = soundId;
		pitch_ = kCD_PitchDefault;
		pan_ = kCD_PanDefault;
		gain_ = kCD_GainDefault;
		mode_ = kCDX_StepModeStopOnSoundCompletion;
	}
	return self;
}	

-(void) dealloc {
	CDLOGINFO(@"Denshion::CDXSoundStepPlay deallocated");
	[super dealloc];
}	

-(void) stepStart:(CDXSoundSequencer*) sequencer {
	[super stepStart:sequencer];
	CDSoundSource* theSoundSource = _sequencer.soundSource;
	[theSoundSource stop];
	theSoundSource.soundId = soundId_;
	theSoundSource.pitch = pitch_;
	theSoundSource.gain = gain_;
	theSoundSource.pan = pan_;
	_elapsedTime = 0.0f;
	[theSoundSource play];
}	

-(void) update:(ccTime) dt {
	_elapsedTime += dt;
}

-(BOOL) stepIsComplete {
	switch (mode_) {
		case kCDX_StepModeStopOnSoundCompletion:
			return (!_sequencer.soundSource.isPlaying);
			
		case kCDX_StepModeStopOnDuration:
			return (_elapsedTime >= duration_);
			
		case kCDX_StepModeStopOnFirstEvent:
			//Either duration has elapsed or sound has stopped
			return (_elapsedTime >= duration_) || (!_sequencer.soundSource.isPlaying);

		case kCDX_StepModeStopOnLastEvent:
			//Duration has elapsed and sound must have completed
			return (_elapsedTime >= duration_) && (!_sequencer.soundSource.isPlaying);
	}
	return YES;
}	
@end

@implementation CDXSoundSequencer

@synthesize delegate = delegate_;
@synthesize soundSource = soundSource_;

-(id) initWithSoundSource:(CDSoundSource*) soundSource {
	if((self=[super init])) {
		CDLOGINFO(@"Denshion::CDXSoundSequencer initialising");
		soundSource_ = soundSource;
	}
	return self;
}	

-(void) dealloc {
	CDLOGINFO(@"Denshion::CDXSoundSequencer deallocating");
	CDXSoundStep* thisStep = _headStep;
	while (thisStep) {
		[thisStep autorelease];
		thisStep = thisStep.nextStep;
	}	
	self.delegate = nil;
	[super dealloc];
}	

-(void) setCurrentStep:(CDXSoundStep*) step {
	_currentStep = step;
	_newStep = YES;
}	

-(void) rewindSteps:(int) stepCount {
	int rewindCount = 0;
	while (_currentStep.previousStep != nil && rewindCount < stepCount) {
		[self setCurrentStep:_currentStep.previousStep];
		rewindCount++;
	}
}	

-(void) update:(ccTime) dt {
	if (_currentStep) {
		if (_newStep) {
			_newStep = NO;//Make sure this is always before stepStart as that method may start a new step
			[_currentStep stepStart:self];
		} else {	
			[_currentStep update:dt];
			if ([_currentStep stepIsComplete]) {
				if (delegate_ && [delegate_ respondsToSelector:@selector(cdStepDidFinish:)]) {
					//Inform delegate
					[delegate_ cdStepDidFinish:_currentStep];
				}	
				//Move to next step if there is one
				if (_currentStep.nextStep) {
					[self setCurrentStep:_currentStep.nextStep];
				} else {
					//Sequence is finished
					_currentStep = nil;
					if (delegate_ && [delegate_ respondsToSelector:@selector(cdSequenceDidFinish:)]) {
						[delegate_ cdSequenceDidFinish:self];
					}	
				}	
			}	
		}	
	}	
}	

-(void) pushStep:(CDXSoundStep*) step {
	if (_headStep == nil) {
		//This is the first step
		_headStep = step;
		step.previousStep = nil;
		[self setCurrentStep:step];
	}
	
	if (_tailStep == nil) {
		_tailStep = step;
		_tailStep.nextStep = nil;
	} else {
		_tailStep.nextStep = step;
		step.previousStep = _tailStep;
		_tailStep = step;
		_tailStep.nextStep = nil;
	}
	[step retain];//take ownership we will release when deallocated or step is popped
}

-(void) popStep {
	//TODO: implement
}	

@end
