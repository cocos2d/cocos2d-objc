/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright 2009 lhunath (Maarten Billemont)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */

#import <Foundation/Foundation.h>
#import "CCIntervalAction.h"

/** CCPropertyAction
 
 CCPropertyAction is an action that lets you update any property of an object.
 For example, if you want to modify the "width" property of a target from 200 to 300 in 2 senconds, then:
 
	id modifyWidth = [CCPropertyAction actionWithDuration:2 key:@"width" from:200 to:300];
	[target runAction:modifyWidth];
 

 Another example: CCScaleTo action could be rewriten using CCPropertyAction:
 
	// scaleA and scaleB are equivalents
	id scaleA = [CCScaleTo actionWithDuration:2 scale:3];
	id scaleB = [CCPropertyAction actionWithDuration:2 key:@"scale" from:1 to:3];

 
 @since v0.99.2
 */
@interface CCPropertyAction : CCIntervalAction {

	NSString		*key_;
    
	float			from_, to_;
	float			delta_;
}

/** creates an initializes the action with the property name (key), and the from and to parameters. */
+ (id)actionWithDuration:(ccTime)aDuration key:(NSString *)key from:(float)from to:(float)to;

/** initializes the action with the property name (key), and the from and to parameters. */
- (id)initWithDuration:(ccTime)aDuration key:(NSString *)key from:(float)from to:(float)to;
    
@end
