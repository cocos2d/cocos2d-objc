/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import "CCFileUtils.h"
#import "CCDirector.h"

@implementation CCFileUtils
+(NSString*) fullPathFromRelativePath:(NSString*) relPath
{
	// do not convert an absolute path (starting with '/')
	if(([relPath length] > 0) && ([relPath characterAtIndex:0] == '/'))
	{
		return relPath;
	}
	
	NSMutableArray *imagePathComponents = [NSMutableArray arrayWithArray:[relPath pathComponents]];
	NSString *file = [imagePathComponents lastObject];
	
	[imagePathComponents removeLastObject];
	NSString *imageDirectory = [NSString pathWithComponents:imagePathComponents];
	
	NSString *fullpath = [[CCDirector sharedDirector].loadingBundle pathForResource:file
														 ofType:nil
													inDirectory:imageDirectory];
	if (fullpath == nil)
		fullpath = relPath;
	
	return fullpath;	
}

@end
