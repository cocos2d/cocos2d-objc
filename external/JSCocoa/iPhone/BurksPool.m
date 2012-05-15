//
//  BurksPool.m
//  iPhoneTest2
//
//  Created by Patrick Geiller on 19/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BurksPool.h"
#import "JSCocoaController.h"
#import "JSCocoaFFIArgument.h"
#import <objc/runtime.h>


// Parsed instance implementations for class 
// IMPs[encoding] = matchingIMP
static	id IMPs = nil;
static	id methodEncodings = nil;
// Imported from JSCocoaController
static	id jsFunctionHash = nil;


@implementation BurksPool


//
// Instance methods : JSCocoaController's addMethod uses their implementation as callbacks for new methods
//
- (id)id_
{
	JSContextRef ctx;
	JSValueRef r = [BurksPool callSelector:_cmd ofInstance:self writeContext:&ctx withArguments:NULL];
	return	[[JSCocoaController controllerFromContext:ctx] toObject:r];
}

- (void)v_
{
	[BurksPool callSelector:_cmd ofInstance:self writeContext:NULL withArguments:NULL];
}

- (void)v_id:(id)p1
{
	[BurksPool callSelector:_cmd ofInstance:self writeContext:NULL withArguments:&p1, NULL];
}

- (void)v_id:(id)p1 id:(id)p2
{
	[BurksPool callSelector:_cmd ofInstance:self writeContext:NULL withArguments:&p1, &p2, NULL];
}

- (int)i_id:(id)p1
{
	JSContextRef ctx;
	JSValueRef r = [BurksPool callSelector:_cmd ofInstance:self writeContext:&ctx withArguments:&p1, NULL];
	return [[JSCocoaController controllerFromContext:ctx] toInt:r];
}

- (int)i_id:(id)p1 i:(int)p2
{
	JSContextRef ctx;
	JSValueRef r = [BurksPool callSelector:_cmd ofInstance:self writeContext:&ctx withArguments:&p1, &p2, NULL];
	return [[JSCocoaController controllerFromContext:ctx] toInt:r];
}

- (id)i_id:(id)p1 id:(id)p2
{
	JSContextRef ctx;
	JSValueRef r = [BurksPool callSelector:_cmd ofInstance:self writeContext:&ctx withArguments:&p1, &p2, NULL];
	return [[JSCocoaController controllerFromContext:ctx] toObject:r];
}

- (void)drawRect:(CGRect)p1
{
	[BurksPool callSelector:_cmd ofInstance:self writeContext:NULL withArguments:&p1, NULL];
}



//
// From a key (class method), get a JSCocoaPrivateObject containing context + js function
//	(called by JSCocoaController)
//
+ (void)setJSFunctionHash:(id)hash
{
	jsFunctionHash = hash;
}

//
// Call the iPhone js function given a class and method 
//
+ (JSValueRef)callSelector:(SEL)sel ofInstance:(id)o writeContext:(JSContextRef*)_ctx withArguments:(void*)firstArg, ...
{
	id keyForClassAndMethod	= [NSString stringWithFormat:@"%@ %@", [o class], NSStringFromSelector(sel)];
	id encodings			= [methodEncodings objectForKey:keyForClassAndMethod];
	id privateObject		= [jsFunctionHash objectForKey:keyForClassAndMethod];
	
//	NSLog(@"Call %@ encoding=%@", keyForClassAndMethod, [self flattenEncoding:encodings]);

	if (!encodings)		return	NSLog(@"No encodings found for %@", keyForClassAndMethod), NULL;
	if (!privateObject)	return	NSLog(@"No js function found for %@", keyForClassAndMethod), NULL;

	JSContextRef ctx = [privateObject ctx];
	if (_ctx) *_ctx = ctx;

	// One to skip return value, 2 to skip common ObjC message parameters (instance, selector)
	int effectiveArgumentCount = [encodings count]-1-2;
	int idx = 2+1;

	// Convert arguments
	JSValueRef*	args = NULL;
	if (effectiveArgumentCount)
	{
		args = malloc(effectiveArgumentCount*sizeof(JSValueRef));

		va_list	vaargs;
		va_start(vaargs, firstArg);
		for (int i=0; i<effectiveArgumentCount; i++, idx++)
		{
			// +1 to skip return value
			id encodingObject = [encodings objectAtIndex:idx];

			id arg = [[JSCocoaFFIArgument alloc] init];
			char encoding = [encodingObject typeEncoding];
			
			void* currentArg;
			if (i == 0)	currentArg = firstArg;
			else
			{
				currentArg = va_arg(vaargs, void*);
			}
			
			if (encoding == '{')	[arg setStructureTypeEncoding:[encodingObject structureTypeEncoding] withCustomStorage:*(void**)&currentArg];
			else					[arg setTypeEncoding:[encodingObject typeEncoding] withCustomStorage:currentArg];
			
			args[i] = NULL;
			[arg toJSValueRef:&args[i] inContext:ctx];
			if (!args[i])	args[i] = JSValueMakeUndefined(ctx);
			
			[arg release];
		}
		va_end(vaargs);
	}
	
	
	// Create 'this'
//	JSObjectRef jsThis = [JSCocoaController boxedJSObject:o inContext:ctx];
	id jsc = [JSCocoaController controllerFromContext:ctx];
	JSObjectRef jsThis = [jsc boxObject:o];

	// Call !
	JSValueRef	exception			= NULL;
	JSObjectRef jsFunctionObject	= JSValueToObject(ctx, [privateObject jsValueRef], NULL);
	JSValueRef	returnValue = JSObjectCallAsFunction(ctx, jsFunctionObject, jsThis, effectiveArgumentCount, args, &exception);
	
	if (effectiveArgumentCount)	free(args);
	if (exception)	NSLog(@"%@", [[JSCocoaController controllerFromContext:ctx] formatJSException:exception]);

	return returnValue;
}


//
// Flatten an encoding array to a string
//
+ (id)flattenEncoding:(id)encodings
{
	id fullEncodingArray = [NSMutableArray array];
	for (JSCocoaFFIArgument* arg in encodings)
	{
		if ([arg typeEncoding] == '{')	[fullEncodingArray addObject:[arg structureTypeEncoding]];
		else							[fullEncodingArray addObject:[NSString stringWithFormat:@"%c", [arg typeEncoding]]];
	}
	id fullEncoding = [fullEncodingArray componentsJoinedByString:@""];
	return	fullEncoding;
}

//
// Gather instance method implementations, removing ObjC indices ( - (id)method -> @8@0:4 -> @@:)
//
+ (void)gatherIMPs
{
	IMPs = [[NSMutableDictionary alloc] init];
	unsigned int methodCount;
	Method* methods = class_copyMethodList([self class], &methodCount);
	for (int i=0; i<methodCount; i++)
	{
		Method m = methods[i];
		IMP imp = method_getImplementation(m);
		id encoding = [self flattenEncoding:[JSCocoaController parseObjCMethodEncoding:method_getTypeEncoding(m)]];
//		NSLog(@"(Gathering %d) sel=%s enc=%s ENC2=%@", i, method_getName(m), method_getTypeEncoding(m), encoding);
		[IMPs setObject:[NSValue valueWithPointer:imp] forKey:encoding];
	}
	free(methods);
}

//
//  Given a type encoding, retrieve a method implementation
//
+ (IMP)IMPforTypeEncodings:(NSArray*)encodings
{
	if (!IMPs)	[self gatherIMPs];
	
	id encoding = [self flattenEncoding:encodings];
	
	NSValue* IMPvalue = [IMPs objectForKey:encoding];
//	NSLog(@"enc=%@*** IMP=%@", encoding, IMPnumber);
	if (IMPvalue)	return (IMP)[IMPvalue pointerValue];
	return	nil;
}

//
// Register encoding (this is only for cache, this could be removed and encodings gotten at runtime like the Mac code does)
//
+ (BOOL)addMethod:(NSString*)methodName class:(Class)class jsFunction:(JSValueRefAndContextRef)valueAndContext encodings:(id)encodings
{
//	NSLog(@"Adding %@.%@", class, methodName);
	id keyForClassAndMethod = [NSString stringWithFormat:@"%@ %@", class, methodName];
//	id keyForFunction = [NSString stringWithFormat:@"%x", valueAndContext.value];
	if (!methodEncodings)	methodEncodings = [[NSMutableDictionary alloc] init];
	[methodEncodings setObject:encodings forKey:keyForClassAndMethod];
	return	YES;
}



@end
