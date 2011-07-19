//
// Bug-1174
// http://code.google.com/p/cocos2d-iphone/issues/detail?id=1174
//

#import "Bug-1174.h"

#pragma mark -
#pragma mark MemBug

int check_for_error( CGPoint p1, CGPoint p2, CGPoint p3, CGPoint p4, float s, float t );

int check_for_error( CGPoint p1, CGPoint p2, CGPoint p3, CGPoint p4, float s, float t )
{
	//	the hit point is		p3 + t * (p4 - p3);
	//	the hit point also is	p1 + s * (p2 - p1);
	
	CGPoint p4_p3 = ccpSub( p4, p3);
	CGPoint p4_p3_t = ccpMult(p4_p3, t);
	CGPoint hitPoint1 = ccpAdd( p3, p4_p3_t);
	
	CGPoint p2_p1 = ccpSub( p2, p1);
	CGPoint p2_p1_s = ccpMult(p2_p1, s);
	CGPoint hitPoint2 = ccpAdd( p1, p2_p1_s);
	
	
	// Since float has rounding errors, only check if diff is < 0.05
	if( (fabs( hitPoint1.x - hitPoint2.x) > 0.1f) || ( fabs(hitPoint1.y - hitPoint2.y) > 0.1f) ) {
		NSLog(@"ERROR: (%f,%f) != (%f,%f)", hitPoint1.x, hitPoint1.y, hitPoint2.x, hitPoint2.y);
		
		return 1;
	}
	
	return 0;
}


@implementation Layer1
-(id) init
{
	if((self=[super init])) {
		
		// seed
		srand(0);
		
		CGPoint A,B,C,D,p1,p2,p3,p4;
		float s,t;
		
		int err=0;
		int ok=0;
		
		//
		// Test 1.
		//
		NSLog(@"Test1 - Start");
		for( int i=0; i < 10000; i++) {
			
			// A | b
			// -----
			// c | d
			float ax = CCRANDOM_0_1() * -5000;
			float ay = CCRANDOM_0_1() * 5000;

			// a | b
			// -----
			// c | D
			float dx = CCRANDOM_0_1() * 5000;
			float dy = CCRANDOM_0_1() * -5000;

			// a | B
			// -----
			// c | d
			float bx = CCRANDOM_0_1() * 5000;
			float by = CCRANDOM_0_1() * 5000;
			
			// a | b
			// -----
			// C | d
			float cx = CCRANDOM_0_1() * -5000;
			float cy = CCRANDOM_0_1() * -5000;
			
			A = ccp(ax,ay);
			B = ccp(bx,by);
			C = ccp(cx,cy);
			D = ccp(dx,dy);
			if( ccpLineIntersect( A, D, B, C, &s, &t) ) {
				if( check_for_error(A, D, B, C, s, t) )
					err++;
				else
					ok++;
			}
		}
		NSLog(@"Test1 - End. OK=%i, Err=%i", ok, err);
		
	
		//
		// Test 2.
		//
		NSLog(@"Test2 - Start");
		
		p1 = ccp(220,480);
		p2 = ccp(304,325);
		p3 = ccp(264,416);
		p4 = ccp(186,416);
		s = 0.0f;
		t = 0.0f;
		if( ccpLineIntersect(p1, p2, p3, p4, &s, &t) )
			check_for_error(p1, p2, p3, p4, s,t );

		NSLog(@"Test2 - End");

		
		//
		// Test 3
		//
		NSLog(@"Test3 - Start");
		
		ok=0;
		err=0;
		for( int i=0;i<10000;i++) {
			
			// A | b
			// -----
			// c | d
			float ax = CCRANDOM_0_1() * -500;
			float ay = CCRANDOM_0_1() * 500;
			p1 = ccp(ax,ay);
			
			// a | b
			// -----
			// c | D
			float dx = CCRANDOM_0_1() * 500;
			float dy = CCRANDOM_0_1() * -500;
			p2 = ccp(dx,dy);
			
			
			//////
			
			float y = ay - ((ay - dy) /2.0f);

			// a | b
			// -----
			// C | d
			float cx = CCRANDOM_0_1() * -500;
			p3 = ccp(cx,y);
			
			// a | B
			// -----
			// c | d
			float bx = CCRANDOM_0_1() * 500;
			p4 = ccp(bx,y);

			s = 0.0f;
			t = 0.0f;
			if( ccpLineIntersect(p1, p2, p3, p4, &s, &t) ) {
				if( check_for_error(p1, p2, p3, p4, s,t ) )
					err++;
				else
					ok++;
			}
		}
		
		NSLog(@"Test3 - End. OK=%i, err=%i", ok, err);

	}
    
	return self;
}
@end

// CLASS IMPLEMENTATIONS
@implementation AppController

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
	// CC_DIRECTOR_INIT()
	//
	// 1. Initializes an EAGLView with 0-bit depth format, and RGB565 render buffer
	// 2. EAGLView multiple touches: disabled
	// 3. creates a UIWindow, and assign it to the "window" var (it must already be declared)
	// 4. Parents EAGLView to the newly created window
	// 5. Creates Display Link Director
	// 5a. If it fails, it will use an NSTimer director
	// 6. It will try to run at 60 FPS
	// 7. Display FPS: NO
	// 8. Device orientation: Portrait
	// 9. Connects the director to the EAGLView
	//
	CC_DIRECTOR_INIT();
	
	// Obtain the shared director in order to...
	CCDirector *director = [CCDirector sharedDirector];

	// Turn on display FPS
	[director setDisplayFPS:YES];
	
	CCScene *scene = [CCScene node];	
	[scene addChild:[Layer1 node] z:0];
		
	[director runWithScene: scene];
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] pause];
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	[[CCDirector sharedDirector] resume];
}

// purge memroy
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCTextureCache sharedTextureCache] removeAllTextures];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window release];
	[super dealloc];
}

@end
