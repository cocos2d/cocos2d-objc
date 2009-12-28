/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 * TMX Tiled Map support:
 * http://www.mapeditor.org
 *
 */

#import "CCTMXObjectGroup.h"
#import "CCTMXXMLParser.h"
#import "Support/CGPointExtension.h"


#pragma mark -
#pragma mark TMXObjectGroup

@implementation CCTMXObjectGroup

@synthesize groupName=groupName_;
@synthesize objects=objects_;
@synthesize properties=properties_;

-(id) init
{
	if (( self=[super init] )) {
		self.groupName = nil;
		self.objects = [NSMutableArray arrayWithCapacity:10];
		self.properties = [NSMutableDictionary dictionaryWithCapacity:5];
	}
	return self;
}

-(void) dealloc
{
	CCLOG( @"cocos2d: deallocing %@", self );
		
	[groupName_ release];
	[objects_ release];
	[properties_ release];
	[super dealloc];
}

-(id) objectNamed:(NSString *)objectName
{
	for( id object in objects_ ) {
		if( [[object valueForKey:@"objectName"] isEqual:objectName] )
			return object;
		}

	// object not found
	return nil;
}

-(id) propertyNamed:(NSString *)propertyName 
{
	return [properties_ valueForKey:propertyName];
}

@end

#pragma mark -
#pragma mark TMXObject

@implementation CCTMXObject

@synthesize name=name_;
@synthesize properties=properties_;

-(id) init
{
	if (( self=[super init] )) {
		self.name = nil;
		self.properties = [NSMutableDictionary dictionaryWithCapacity:5];
	}
	return self;
}

-(void) dealloc
{
	CCLOG( @"cocos2d: deallocing %@", self );
	
	[name_ release];
	[properties_ release];
	[super dealloc];
}

-(id) propertyNamed:(NSString *)propertyName 
{
	return [properties_ valueForKey:propertyName];
}

@end
