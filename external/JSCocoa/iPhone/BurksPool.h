//
//  BurksPool.h
//  iPhoneTest2
//
//  Created by Patrick Geiller on 19/08/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "../JSCocoaController.h"


/*

	Tim Burks http://stackoverflow.com/questions/219653/ruby-on-iphone

	In the iPhone OS, mprotect() will fail if you try to use it to mark writable sections of memory as executable. This breaks bridges like RubyCocoa (and probably MacRuby) that use libffi to create Objective-C method handlers at runtime. I believe that this is by design because it was not always the case.

	Ultimately, this is more a matter of platform politics than technology, but a technical workaround for this exists. Instead of generating custom method handlers at runtime, precompile a pool of reconfigurable ones that are assigned as needed, essentially making the bridging process entirely data-driven. As far as I know, this is not yet being done in RubyCocoa or MacRuby.

	Another significant thing to consider is that the compiled Ruby and RubyCocoa runtimes can be significantly larger than compiled Objective-C apps. If these libraries were available on the iPhone, this wouldn't be an issue, but for now, even if you had RubyCocoa working, you might not want to use it for apps that you distribute.
	
*/
@interface BurksPool : NSObject {

}

+ (void)setJSFunctionHash:(id)jsFunctionHash;
+ (IMP)IMPforTypeEncodings:(NSArray*)encodings;
+ (BOOL)addMethod:(NSString*)methodName class:(Class)class jsFunction:(JSValueRefAndContextRef)valueAndContext encodings:(id)encodings;
+ (JSValueRef)callSelector:(SEL)sel ofInstance:(id)o writeContext:(JSContextRef*)_ctx withArguments:(void*)firstArg, ...;
+ (id)flattenEncoding:(id)encodings;

@end
