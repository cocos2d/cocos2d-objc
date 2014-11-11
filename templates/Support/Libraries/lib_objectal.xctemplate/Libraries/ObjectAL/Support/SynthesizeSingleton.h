//
//  SynthesizeSingleton.h
//
// Modified by Karl Stenerud starting 16/04/2010.
// - Moved the swizzle code to allocWithZone so that non-default init methods may be
//   used to initialize the singleton.
// - Added "lesser" singleton which allows other instances besides sharedInstance to be created.
// - Added guard ifndef so that this file can be used in multiple library distributions.
// - Made singleton variable name class-specific so that it can be used on multiple classes
//   within the same compilation module.
//
//  Modified by CJ Hanson on 26/02/2010.
//  This version of Matt's code uses method_setImplementaiton() to dynamically
//  replace the +sharedInstance method with one that does not use @synchronized
//
//  Based on code by Matt Gallagher from CocoaWithLove
//
//  Created by Matt Gallagher on 20/10/08.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#ifndef SYNTHESIZE_SINGLETON_FOR_CLASS

#import <objc/runtime.h>


#pragma mark -
#pragma mark Singleton

/* Synthesize Singleton For Class
 *
 * Creates a singleton interface for the specified class with the following methods:
 *
 * + (MyClass*) sharedInstance;
 * + (void) purgeSharedInstance;
 *
 * Calling sharedInstance will instantiate the class and swizzle some methods to ensure
 * that only a single instance ever exists.
 * Calling purgeSharedInstance will destroy the shared instance and return the swizzled
 * methods to their former selves.
 *
 * 
 * Usage:
 *
 * MyClass.h:
 * ========================================
 *	#import "SynthesizeSingleton.h"
 *
 *	@interface MyClass: SomeSuperclass
 *	{
 *		...
 *	}
 *	SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(MyClass);
 *
 *	@end
 * ========================================
 *
 *
 *	MyClass.m:
 * ========================================
 *	#import "MyClass.h"
 *
 *	// This line is optional. Use it if you've enabled GCC_WARN_UNDECLARED_SELECTOR
 *	SYNTHESIZE_SINGLETON_FOR_CLASS_PROTOTYPE(MyClass);
 *
 *	@implementation MyClass
 *
 *	SYNTHESIZE_SINGLETON_FOR_CLASS(MyClass);
 *
 *	...
 *
 *	@end
 * ========================================
 *
 *
 * Note: Calling alloc manually will also initialize the singleton, so you
 * can call a more complex init routine to initialize the singleton like so:
 *
 * [[MyClass alloc] initWithParam:firstParam secondParam:secondParam];
 *
 * Just be sure to make such a call BEFORE you call "sharedInstance" in
 * your program.
 */

#define SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(SS_CLASSNAME)	\
	\
+ (SS_CLASSNAME*) sharedInstance;	\
+ (void) purgeSharedInstance;


#if __has_feature(objc_arc) // ARC Version

#define SYNTHESIZE_SINGLETON_FOR_CLASS_PROTOTYPE(SS_CLASSNAME)

#define SYNTHESIZE_SINGLETON_FOR_CLASS(SS_CLASSNAME)	\
\
static volatile SS_CLASSNAME* _##SS_CLASSNAME##_sharedInstance = nil;	\
\
+ (SS_CLASSNAME*) sharedInstanceNoSynch	\
{	\
    SS_CLASSNAME* instance = (SS_CLASSNAME*) _##SS_CLASSNAME##_sharedInstance; \
    return instance;	\
}	\
\
+ (SS_CLASSNAME*) sharedInstanceSynch	\
{	\
    @synchronized(self)	\
    {	\
        if(nil == _##SS_CLASSNAME##_sharedInstance)	\
        {	\
            _##SS_CLASSNAME##_sharedInstance = [[self alloc] init];	\
        }	\
    }	\
    return (SS_CLASSNAME*) _##SS_CLASSNAME##_sharedInstance;	\
}	\
\
+ (SS_CLASSNAME*) sharedInstance	\
{	\
    return [self sharedInstanceSynch]; \
}	\
\
+ (id)allocWithZone:(NSZone*) zone	\
{	\
    @synchronized(self)	\
    {	\
        if (nil == _##SS_CLASSNAME##_sharedInstance)	\
        {	\
            _##SS_CLASSNAME##_sharedInstance = [super allocWithZone:zone];	\
            if(nil != _##SS_CLASSNAME##_sharedInstance)	\
            {	\
                Method newSharedInstanceMethod = class_getClassMethod(self, @selector(sharedInstanceNoSynch));	\
                method_setImplementation(class_getClassMethod(self, @selector(sharedInstance)), method_getImplementation(newSharedInstanceMethod));	\
            }	\
        }	\
    }	\
    SS_CLASSNAME* instance = (SS_CLASSNAME*) _##SS_CLASSNAME##_sharedInstance; \
    return instance;	\
}	\
\
+ (void)purgeSharedInstance	\
{	\
    @synchronized(self)	\
    {	\
        if(nil != _##SS_CLASSNAME##_sharedInstance)	\
        {	\
            Method newSharedInstanceMethod = class_getClassMethod(self, @selector(sharedInstanceSynch));	\
            method_setImplementation(class_getClassMethod(self, @selector(sharedInstance)), method_getImplementation(newSharedInstanceMethod));	\
            _##SS_CLASSNAME##_sharedInstance = nil;	\
        }	\
    }	\
}	\
\
- (id)copyWithZone:(NSZone *)zone	\
{	\
    _Pragma ( "unused(zone)" ) \
    return self;	\
}	\
\

#else // Non-ARC Version

#define SYNTHESIZE_SINGLETON_FOR_CLASS_PROTOTYPE(SS_CLASSNAME) \
@interface SS_CLASSNAME (SynthesizeSingletonPrivate)	\
- (NSUInteger)retainCountDoNothing;	\
- (NSUInteger)retainCountDoSomething;	\
- (oneway void)releaseDoNothing;	\
- (oneway void)releaseDoSomething;	\
- (id)autoreleaseDoNothing;	\
- (id)autoreleaseDoSomething; \
@end

#define SYNTHESIZE_SINGLETON_FOR_CLASS(SS_CLASSNAME)	\
	\
static volatile SS_CLASSNAME* _##SS_CLASSNAME##_sharedInstance = nil;	\
	\
+ (SS_CLASSNAME*) sharedInstanceNoSynch	\
{	\
    SS_CLASSNAME* instance = (SS_CLASSNAME*) _##SS_CLASSNAME##_sharedInstance; \
    return instance;	\
}	\
	\
+ (SS_CLASSNAME*) sharedInstanceSynch	\
{	\
	@synchronized(self)	\
	{	\
		if(nil == _##SS_CLASSNAME##_sharedInstance)	\
		{	\
			_##SS_CLASSNAME##_sharedInstance = [[self alloc] init];	\
		}	\
	}	\
	return (SS_CLASSNAME*) _##SS_CLASSNAME##_sharedInstance;	\
}	\
	\
+ (SS_CLASSNAME*) sharedInstance	\
{	\
	return [self sharedInstanceSynch]; \
}	\
	\
+ (id)allocWithZone:(NSZone*) zone	\
{	\
	@synchronized(self)	\
	{	\
		if (nil == _##SS_CLASSNAME##_sharedInstance)	\
		{	\
			_##SS_CLASSNAME##_sharedInstance = [super allocWithZone:zone];	\
			if(nil != _##SS_CLASSNAME##_sharedInstance)	\
			{	\
				Method newSharedInstanceMethod = class_getClassMethod(self, @selector(sharedInstanceNoSynch));	\
				method_setImplementation(class_getClassMethod(self, @selector(sharedInstance)), method_getImplementation(newSharedInstanceMethod));	\
				method_setImplementation(class_getInstanceMethod(self, @selector(retainCount)), class_getMethodImplementation(self, @selector(retainCountDoNothing)));	\
				method_setImplementation(class_getInstanceMethod(self, @selector(release)), class_getMethodImplementation(self, @selector(releaseDoNothing)));	\
				method_setImplementation(class_getInstanceMethod(self, @selector(autorelease)), class_getMethodImplementation(self, @selector(autoreleaseDoNothing)));	\
			}	\
		}	\
	}	\
    SS_CLASSNAME* instance = (SS_CLASSNAME*) _##SS_CLASSNAME##_sharedInstance; \
    return instance;	\
}	\
	\
+ (void)purgeSharedInstance	\
{	\
	@synchronized(self)	\
	{	\
		if(nil != _##SS_CLASSNAME##_sharedInstance)	\
		{	\
			Method newSharedInstanceMethod = class_getClassMethod(self, @selector(sharedInstanceSynch));	\
			method_setImplementation(class_getClassMethod(self, @selector(sharedInstance)), method_getImplementation(newSharedInstanceMethod));	\
			method_setImplementation(class_getInstanceMethod(self, @selector(retainCount)), class_getMethodImplementation(self, @selector(retainCountDoSomething)));	\
			method_setImplementation(class_getInstanceMethod(self, @selector(release)), class_getMethodImplementation(self, @selector(releaseDoSomething)));	\
			method_setImplementation(class_getInstanceMethod(self, @selector(autorelease)), class_getMethodImplementation(self, @selector(autoreleaseDoSomething)));	\
			[_##SS_CLASSNAME##_sharedInstance release];	\
			_##SS_CLASSNAME##_sharedInstance = nil;	\
		}	\
	}	\
}	\
	\
- (id)copyWithZone:(NSZone *)zone	\
{	\
    _Pragma ( "unused(zone)" ) \
	return self;	\
}	\
	\
- (id)retain	\
{	\
	return self;	\
}	\
	\
- (NSUInteger)retainCount	\
{	\
	NSAssert1(1==0, @"SynthesizeSingleton: %@ ERROR: -(NSUInteger)retainCount method did not get swizzled.", self);	\
	return NSUIntegerMax;	\
}	\
	\
- (NSUInteger)retainCountDoNothing	\
{	\
	return NSUIntegerMax;	\
}	\
- (NSUInteger)retainCountDoSomething	\
{	\
	return [super retainCount];	\
}	\
	\
- (oneway void)release	\
{	\
	NSAssert1(1==0, @"SynthesizeSingleton: %@ ERROR: -(void)release method did not get swizzled.", self);	\
}	\
	\
- (oneway void)releaseDoNothing{}	\
	\
- (oneway void)releaseDoSomething	\
{	\
	@synchronized(self)	\
	{	\
		[super release];	\
	}	\
}	\
	\
- (id)autorelease	\
{	\
	NSAssert1(1==0, @"SynthesizeSingleton: %@ ERROR: -(id)autorelease method did not get swizzled.", self);	\
	return self;	\
}	\
	\
- (id)autoreleaseDoNothing	\
{	\
	return self;	\
}	\
	\
- (id)autoreleaseDoSomething	\
{	\
	return [super autorelease];	\
}

#endif


#pragma mark -
#pragma mark Lesser Singleton

/* A lesser singleton has a shared instance, but can also be instantiated on its own.
 *
 * For a lesser singleton, you still use SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(),
 * but use SYNTHESIZE_LESSER_SINGLETON_FOR_CLASS() in the implementation file.
 * You must specify which creation methods are to initialize the shared instance
 * (besides "sharedInstance") via CALL_LESSER_SINGLETON_INIT_METHOD()
 *
 * Example:
 *
 * MyClass.h:
 * ========================================
 *	#import "SynthesizeSingleton.h"
 *
 *	@interface MyClass: SomeSuperclass
 *	{
 *		int value;
 *		...
 *	}
 *	SYNTHESIZE_SINGLETON_FOR_CLASS_HEADER(MyClass);
 *
 *	+ (void) initSharedInstanceWithValue:(int) value;
 *
 * - (id) initWithValue:(int) value;
 *
 *	@end
 * ========================================
 *
 *
 *	MyClass.m:
 * ========================================
 *	#import "MyClass.h"
 *
 *	// This line is optional. Use it if you've enabled GCC_WARN_UNDECLARED_SELECTOR
 *	SYNTHESIZE_SINGLETON_FOR_CLASS_PROTOTYPE(MyClass);
 *
 *	@implementation MyClass
 *
 *	SYNTHESIZE_LESSER_SINGLETON_FOR_CLASS(MyClass);
 *
 *	+ (void) initSharedInstanceWithValue:(int) value
 *	{
 *		CALL_LESSER_SINGLETON_INIT_METHOD(MyClass, initWithValue:value);
 *	}
 *
 *	...
 *
 *	@end
 * ========================================
 *
 *
 * Note: CALL_LESSER_SINGLETON_INIT_METHOD() will not work if your
 * init call contains commas. If you need commas (such as for varargs),
 * or other more complex initialization, use the PRE and POST macros:
 *
 *	+ (void) initSharedInstanceComplex
 *	{
 *		CALL_LESSER_SINGLETON_INIT_METHOD_PRE(MyClass);
 *
 *		int firstNumber = [self getFirstNumberSomehow];
 *		_sharedInstance = [[self alloc] initWithValues:firstNumber, 2, 3, 4, -1];
 *
 *		CALL_LESSER_SINGLETON_INIT_METHOD_POST(MyClass);
 *	}
 */

#define SYNTHESIZE_LESSER_SINGLETON_FOR_CLASS(SS_CLASSNAME)	\
	\
static volatile SS_CLASSNAME* _##SS_CLASSNAME##_sharedInstance = nil;	\
	\
+ (SS_CLASSNAME*) sharedInstanceNoSynch	\
{	\
    SS_CLASSNAME* instance = (SS_CLASSNAME*) _##SS_CLASSNAME##_sharedInstance; \
	return instance;	\
}	\
	\
+ (SS_CLASSNAME*) sharedInstanceSynch	\
{	\
	@synchronized(self)	\
	{	\
		if(nil == _##SS_CLASSNAME##_sharedInstance)	\
		{	\
			_##SS_CLASSNAME##_sharedInstance = [[self alloc] init];	\
			if(_##SS_CLASSNAME##_sharedInstance)	\
			{	\
				Method newSharedInstanceMethod = class_getClassMethod(self, @selector(sharedInstanceNoSynch));	\
				method_setImplementation(class_getClassMethod(self, @selector(sharedInstance)), method_getImplementation(newSharedInstanceMethod));	\
			}	\
		}	\
	}	\
    SS_CLASSNAME* instance = (SS_CLASSNAME*) _##SS_CLASSNAME##_sharedInstance; \
    return instance;	\
}	\
	\
+ (SS_CLASSNAME*) sharedInstance	\
{	\
	return [self sharedInstanceSynch]; \
}	\
	\
+ (void)purgeSharedInstance	\
{	\
	@synchronized(self)	\
	{	\
		Method newSharedInstanceMethod = class_getClassMethod(self, @selector(sharedInstanceSynch));	\
		method_setImplementation(class_getClassMethod(self, @selector(sharedInstance)), method_getImplementation(newSharedInstanceMethod));	\
		[_##SS_CLASSNAME##_sharedInstance release];	\
		_##SS_CLASSNAME##_sharedInstance = nil;	\
	}	\
}


#define CALL_LESSER_SINGLETON_INIT_METHOD_PRE(SS_CLASSNAME) \
	@synchronized(self)	\
	{	\
		if(nil == _##SS_CLASSNAME##_sharedInstance)	\
		{


#define CALL_LESSER_SINGLETON_INIT_METHOD_POST(SS_CLASSNAME) \
			if(_##SS_CLASSNAME##_sharedInstance)	\
			{	\
				Method newSharedInstanceMethod = class_getClassMethod(self, @selector(sharedInstanceNoSynch));	\
				method_setImplementation(class_getClassMethod(self, @selector(sharedInstance)), method_getImplementation(newSharedInstanceMethod));	\
			}	\
		}	\
	}


#define CALL_LESSER_SINGLETON_INIT_METHOD(SS_CLASSNAME,__INIT_CALL__) \
	CALL_LESSER_SINGLETON_INIT_METHOD_PRE(SS_CLASSNAME); \
	_##SS_CLASSNAME##_sharedInstance = [[self alloc] __INIT_CALL__];	\
	CALL_LESSER_SINGLETON_INIT_METHOD_POST(SS_CLASSNAME)

#endif /* SYNTHESIZE_SINGLETON_FOR_CLASS */
