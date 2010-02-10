/* CocosDenshion Configuration
 *
 * Copyright (C) 2010 Steve Oldmeadow
 *
 * For independent entities this program is free software; you can redistribute
 * it and/or modify it under the terms of the 'cocos2d for iPhone' license with
 * the additional proviso that 'cocos2D for iPhone' must be credited in a manner
 * that can be be observed by end users, for example, in the credits or during
 * start up. Failure to include such notice is deemed to be acceptance of a 
 * non independent license (see below).
 *
 * For the purpose of this software non independent entities are defined as 
 * those where the annual revenue of the entity employing, partnering, or 
 * affiliated in any way with the Licensee is greater than $250,000 USD annually.
 *
 * Non independent entities may license this software or a derivation of it
 * by a donation of $500 USD per application to the cocos2d for iPhone project. 
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 */

/**
 If enabled code useful for debugging such as parameter check assertions will be performed.
 If you experience any problems you should enable this and test your code with a debug build.
 */
//#define CD_DEBUG 1

/**
 The total number of sounds/buffers that can be loaded assuming memory is sufficient
 */
#define CD_MAX_BUFFERS 64 

/**
 If enabled, OpenAL code will use static buffers. When static buffers are used the audio
 data is managed outside of OpenAL, this eliminates a memcpy operation which leads to 
 higher performance when loading sounds.
 
 However, the downside is that when the audio data is freed you must
 be certain that it is no longer being accessed otherwise your app will crash. Testing on OS 2.2.1
 and 3.1.2 has shown that this may occur if a buffer is being used by a source with state = AL_PLAYING
 when the buffer is deleted. If the data is freed too quickly after the source is stopped then
 a crash will occur. The implemented workaround is that when static buffers are used the unloadBuffer code will wait for
 any playing sources to finish playing before the associated buffer and data are deleted, however, this delay may negate any 
 performance gains that are achieved during loading.
 
 Performance tests on a 1st gen iPod running OS 2.2.1 loading the CocosDenshionDemo sounds were ~0.14 seconds without
 static buffers and ~0.12 seconds when using static buffers.

 */
//#define CD_USE_STATIC_BUFFERS 1

/**
 If enabled, it indicates your application is not intended to run on a pre 3.0 OS version
 */
//#define CD_OS_3_PLUS 1




