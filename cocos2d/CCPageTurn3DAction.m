/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2009 Sindesso Pty Ltd http://www.sindesso.com/
 *
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */
#import "CCPageTurn3DAction.h"

@implementation CCPageTurn3D

/*
 * Update each tick
 * Time is the percentage of the way through the duration
 */
-(void)update:(ccTime)time
{
	float tt = MAX( 0, time - 0.25f );
	float deltaAy = ( tt * tt * 500);
	float ay = -100 - deltaAy;
	
	float deltaTheta = - (float) M_PI_2 * sqrtf( time) ;
	float theta = /*0.01f*/ + (float) M_PI_2 +deltaTheta;
	
	float sinTheta = sinf(theta);
	float cosTheta = cosf(theta);
	
	for( int i = 0; i <=gridSize.x; i++ )
	{
		for( int j = 0; j <= gridSize.y; j++ )
		{
			// Get original vertex
			ccVertex3F	p = [self originalVertex:ccg(i,j)];
			
			float R = sqrtf((p.x*p.x) + ((p.y - ay)*(p.y - ay)));
			float r = R * sinTheta;
			float alpha = asinf( p.x / R );
			float beta = alpha / sinTheta;
			float cosBeta = cosf( beta );
			
			// If beta > PI then we've wrapped around the cone
			// Reduce the radius to stop these points interfering with others
			if( beta <= M_PI)
			{
				p.x = ( r * sinf(beta));
				p.y = ( R + ay - ( r*(1 - cosBeta)*sinTheta));
				
				// We scale z here to avoid the animation being
				// too much bigger than the screen due to perspectve transform
				p.z = (r * ( 1 - cosBeta ) * cosTheta) / 100;
			}
			else
			{
				// Force X = 0 to stop wrapped
				// points
				p.x = 0;
				p.y = ( R + ay - ( r*(1 - cosBeta)*sinTheta));
				p.z = 0.001f;
			}
			
			//	Stop z coord from dropping beneath underlying page in a transition
			if( p.z<0.001f )
				p.z = 0.001f;
			
			// Set new coords
			[self setVertex:ccg(i,j) vertex:p];
			
		}
	}
}
@end
