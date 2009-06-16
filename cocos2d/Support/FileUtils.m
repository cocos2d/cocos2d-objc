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

#import "FileUtils.h"

@implementation FileUtils
+(NSString*) fullPathFromRelativePath:(NSString*) relPath
{
	NSMutableArray *imagePathComponents = [NSMutableArray arrayWithArray:[relPath pathComponents]];
	NSString *file = [imagePathComponents lastObject];
	
	[imagePathComponents removeLastObject];
	NSString *imageDirectory = [NSString pathWithComponents:imagePathComponents];
	
	NSString *fullpath = [[NSBundle mainBundle] pathForResource:file
														 ofType:nil
													inDirectory:imageDirectory];
	if (fullpath == nil)
		fullpath = relPath;

	return fullpath;	
}
@end
