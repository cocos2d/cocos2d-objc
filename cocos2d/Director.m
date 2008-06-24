/* cocos2d-iphone
 *
 * Copyright (C) 2008 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3 or (it is your choice) any later
 * version. 
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.
 *
 */


#import "glu.h"
#import "OpenGL_Internal.h"

#import "Director.h"
#import "Camera.h"

#define kDefaultFPS		30.0	// 30 frames per second

@implementation Director

@synthesize animationInterval;
@synthesize window;
@synthesize runningScene;
@synthesize eventHandler;
//
// singleton stuff
//
static Director *sharedDirector;

+ (Director *)sharedDirector
{
	@synchronized(self)
	{
		if (!sharedDirector)
			[[Director alloc] init];
		
		return sharedDirector;
	}
	// to avoid compiler warning
	return nil;
}

+(id)alloc
{
	@synchronized(self)
	{
		NSAssert(sharedDirector == nil, @"Attempted to allocate a second instance of a singleton.");
		sharedDirector = [super alloc];
		return sharedDirector;
	}
	// to avoid compiler warning
	return nil;
}

- (id) init
{
	//Create a full-screen window
	winSize = [[UIScreen mainScreen] bounds];
	
	window = [[UIWindow alloc] initWithFrame:winSize];

	if( ! [super initWithFrame:[window bounds] pixelFormat:kEAGLColorFormatRGB565] )
		return nil;

	[window addSubview:self];
	
	// scenes
	runningScene = nil;
	nextScene = nil;
	scenes = [[NSMutableArray arrayWithCapacity:10] retain];
	
	animationInterval = 1.0 / kDefaultFPS;
	eventHandler = nil;
	
	[self setAlphaBlending: YES];
	[self setDepthTest: YES];
	[self setDefaultProjection];

	// set other opengl default values
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	// landscape
	landscape = NO;
	
	//Show window
	[window makeKeyAndVisible];	
	return self;
}

- (void) dealloc {
	NSLog( @"deallocing %@", self);

	[runningScene release];
	[scenes release];
	[window release];
	
	[super dealloc];
}

- (void) setDefaultProjection
{
	[self set3Dprojection];
}
-(void) set2Dprojection
{
	//Setup OpenGL projection matrix
	glViewport(0, 0, winSize.size.width, winSize.size.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0, winSize.size.width, 0, winSize.size.height, -100, 100);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}

-(void) set3Dprojection
{
	glViewport(0, 0, winSize.size.width, winSize.size.height);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(60, (GLfloat)winSize.size.width/winSize.size.height, 0.5f, 1500.0f);
	
	glMatrixMode(GL_MODELVIEW);	
	glLoadIdentity();
	gluLookAt( winSize.size.width/2, winSize.size.height/2, [Camera getZEye],
			  winSize.size.width/2, winSize.size.height/2, 0,
			  0.0f, 1.0f, 0.0f
			  );
}

-(CGPoint) convertCoordinate: (CGPoint) p
{
	int newY = winSize.size.height - p.y;

	CGPoint ret = CGPointMake( p.x, newY );
	if( ! landscape )
		return ret;
	
	ret.x = p.y;
	ret.y = p.x;
	
	return ret;
}

//
// custom properties
//
- (CGRect) winSize
{
	CGRect r = winSize;
	if( landscape ) {
		// swap x,y in landscape mode
		r.size.width = winSize.size.height;
		r.size.height = winSize.size.width;
	}
	return r;
}

-(CGRect) displaySize
{
	return winSize;
}

- (BOOL) landscape
{
	return landscape;
}

- (void) setLandscape: (BOOL) on
{
	if( on != landscape ) {
		landscape = on;
//		[self setDefaultProjection];
	}
	return;
}

- (void) setAlphaBlending: (BOOL) on
{
	if (on) {
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	} else
		glDisable(GL_BLEND);
}

- (void) setTexture2D: (BOOL) on
{
	if (on)
		glEnable(GL_TEXTURE_2D);
	else
		glDisable(GL_TEXTURE_2D);
}

- (void) setDepthTest: (BOOL) on
{
	if (on) {
		glClearDepthf(1.0f);
		glEnable(GL_DEPTH_TEST);
		glDepthFunc(GL_LEQUAL);
		glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
	} else
		glDisable( GL_DEPTH_TEST );
}

- (void)runScene:(Scene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
		
	[self pushScene: scene];
	[self startAnimation];
}

-(void) replaceScene: (Scene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");
	
	nextScene = [scene retain];
}

- (void) pushScene: (Scene*) scene
{
	NSAssert( scene != nil, @"Argument must be non-nil");

	[scenes addObject: scene];
	nextScene = [scene retain];		// retained twice
}

-(void) popScene
{	
	NSAssert( [scenes count]!=0, @"Abnormal error in director scene stack.");
	
	[scenes removeLastObject];
	int c = [scenes count];
	if( c == 0 ) {
		[self end];
	} else {
		nextScene = [[scenes objectAtIndex:c-1] retain];
	}
}

-(void) end
{
	[scenes release];
	scenes = nil;
	[runningScene onExit];
	[runningScene release];
	runningScene = nil;
	[self stopAnimation];

	if( [[UIApplication sharedApplication] respondsToSelector:@selector(terminate)] )
		[[UIApplication sharedApplication] performSelector:@selector(terminate)];
}

- (void)startAnimation
{
	animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(drawScene) userInfo:nil repeats:YES];
}

- (void)stopAnimation
{
	[animationTimer invalidate];
	animationTimer = nil;
}


- (void)setAnimationInterval:(NSTimeInterval)interval
{
	animationInterval = interval;
	
	if(animationTimer) {
		[self stopAnimation];
		[self startAnimation];
	}
}

-(void) applyLandscape
{
	if( landscape ) {
		glTranslatef(160,240,0);
		glRotatef(-90,0,0,1);
		glTranslatef(-240,-160,0);
	}	
}

- (void) drawScene
{
	/* clear window */
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	/* new scene */
	if( nextScene ) {
		[self setNextScene];
	}

	glPushMatrix();

	[self applyLandscape];
	
	/* draw the scene */
	[runningScene visit];
	
	glPopMatrix();
	
	/* swap buffers */
	[self swapBuffers];
	
	CHECK_GL_ERROR();
	
}

-(void) setNextScene
{
	[runningScene onExit];
	[runningScene release];
	
	[nextScene onEnter];
	runningScene = nextScene;

	nextScene = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( eventHandler && [eventHandler respondsToSelector:_cmd] )
		[eventHandler touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( eventHandler && [eventHandler respondsToSelector:_cmd] )
		[eventHandler touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if( eventHandler && [eventHandler respondsToSelector:_cmd] )
		[eventHandler touchesEnded:touches withEvent:event];
}

@end
