//
//  Action.h
//  test-opengl2
//
//  Created by Ricardo Quesada on 30/05/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#include <sys/time.h>

@class CocosNode;
@interface Action : NSObject {
	CocosNode *target;	
}

@property (readwrite,retain) CocosNode *target;

+(id) action;
-(id) init;

-(void) start;
-(BOOL) isDone;
-(void) stop;
-(void) step;
-(void) update: (double) time;

@end