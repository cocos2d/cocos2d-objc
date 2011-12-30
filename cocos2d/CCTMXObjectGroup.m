/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2010 Neophit
 *
 * Copyright (c) 2010 Ricardo Quesada
 * Copyright (c) 2011 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *
 * TMX Tiled Map support:
 * http://www.mapeditor.org
 *
 */

#import "CCTMXObjectGroup.h"
#import "CCTMXXMLParser.h"
#import "ccMacros.h"
#import "Support/CGPointExtension.h"


#pragma mark -
#pragma mark TMXObjectGroup

@implementation CCTMXObjectGroup

@synthesize groupName = groupName_;
@synthesize objects = objects_;
@synthesize positionOffset = positionOffset_;
@synthesize properties = properties_;

-(id) init
{
	if (( self=[super init] )) {
		self.groupName = nil;
		self.positionOffset = CGPointZero;
		self.objects = [NSMutableArray arrayWithCapacity:10];
		self.properties = [NSMutableDictionary dictionaryWithCapacity:5];
	}
	return self;
}

-(void) dealloc
{
	CCLOGINFO( @"cocos2d: deallocing %@", self );

	[groupName_ release];
	[objects_ release];
	[properties_ release];
	[super dealloc];
}

-(NSMutableDictionary*) objectNamed:(NSString *)objectName
{
	for( id object in objects_ ) {
		if( [[object valueForKey:@"name"] isEqual:objectName] )
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
