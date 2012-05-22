

#import "js_bindings_NSObject.h"

#pragma mark - ProxyJS_NSObject

@implementation ProxyJS_NSObject

@synthesize jsObj = _jsObj;
@synthesize realObj = _realObj;
@synthesize initialized = _initialized;

+(void) createClassWithContext:(JSContext*)cx object:(JSObject*)globalObj name:(NSString*)name
{
}

-(id) initWithJSObject:(JSObject*)object andRealObject:(id)realObject
{
	self = [super init];
	if( self )
	{
		_jsObj = object;
		_realObj = [realObject retain];
		_initialized = NO;
	}
	
	return self;
}

-(void) dealloc
{
//	CCLOGINFO(@"deallocing: %@", self);
	
	[_realObj release];
	
	[super dealloc];
}

@end
