/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Jason Booth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


// virtual joystick class
//
// Creates a virtual touch joystick within the bounds passed in. 
// Default mode is that any press begin in the bounds area becomes
// the center of the joystick. Call setCenter if you want a static
// joystick center position instead. Querry getCurrentVelocity
// for an X,Y offset value, or getCurrentDegreeVelocity for a
// degree and velocity value.
//
// You initialize the joystick with a rect defining it's area
// and you have to forward touch events to the joystick via
// it's touch event handlers. They will return YES if the touch
// is handled.

#import <Foundation/Foundation.h>

@interface Joystick : NSObject 
{
  bool staticCenter;
  CGPoint center;
  CGPoint curPosition;
  CGPoint velocity;
  CGRect bounds;
  bool active;
  int touchAddress;
}

@property (readwrite, assign) bool staticCenter;

-(id)initWithRect:(CGRect)rect;
-(bool)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
-(bool)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
-(bool)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
-(CGPoint)getCurrentVelocity;
-(CGPoint)getCurrentDegreeVelocity;
-(void)setStaticCenter:(float)x y:(float)y;

@end
