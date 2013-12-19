//
// cocos2d texture performance test
//

#import "PerformanceTextureTest.h"

static int sceneIdx=-1;
static NSString *tests[] = {
	@"TextureTest",
};

Class nextAction()
{
	
	sceneIdx++;
	sceneIdx = sceneIdx % ( sizeof(tests) / sizeof(tests[0]) );
	NSString *r = tests[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class backAction()
{
	sceneIdx--;
	int total = ( sizeof(tests) / sizeof(tests[0]) );
	if( sceneIdx < 0 )
		sceneIdx += total;	
	
	NSString *r = tests[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}

Class restartAction()
{
	NSString *r = tests[sceneIdx];
	Class c = NSClassFromString(r);
	return c;
}


float calculateDeltaTime( struct timeval *lastUpdate )
{
	struct timeval now;
	
	gettimeofday( &now, NULL);
	
	float dt = (now.tv_sec - lastUpdate->tv_sec) + (now.tv_usec - lastUpdate->tv_usec) / 1000000.0f;

	return dt;
}

@implementation PerformanceTextureTest

+(CCScene*) scene
{
	CCScene *scene = [CCScene node];
	PerformanceTextureTest *layer = [PerformanceTextureTest node];
	
	[scene addChild:layer];
	
	return scene;
}

-(id) init
{
	if( (self=[super init])) {
		
		CGSize s = [[CCDirector sharedDirector] viewSize];
		
		CCLabelTTF* label = [CCLabelTTF labelWithString:[self title] fontName:@"Arial" fontSize:32];
		[self addChild: label z:1];
		[label setPosition: ccp(s.width/2, s.height-50)];
		

		NSString *subtitle = [self subtitle];
		if( subtitle ) {
			CCLabelTTF* l = [CCLabelTTF labelWithString:subtitle fontName:@"Thonburi" fontSize:16];
			[self addChild:l z:101];
			[l setPosition:ccp(s.width/2, s.height-80)];
		}
		
		CCMenuItemImage *item1 = [CCMenuItemImage itemWithNormalImage:@"b1.png" selectedImage:@"b2.png" target:self selector:@selector(backCallback:)];
		CCMenuItemImage *item2 = [CCMenuItemImage itemWithNormalImage:@"r1.png" selectedImage:@"r2.png" target:self selector:@selector(restartCallback:)];
		CCMenuItemImage *item3 = [CCMenuItemImage itemWithNormalImage:@"f1.png" selectedImage:@"f2.png" target:self selector:@selector(nextCallback:)];
		
		CCMenu *menu = [CCMenu menuWithItems:item1, item2, item3, nil];
		
		menu.position = CGPointZero;
		item1.position = ccp( s.width/2 - 100,30);
		item2.position = ccp( s.width/2, 30);
		item3.position = ccp( s.width/2 + 100,30);
		[self addChild: menu z:1];	
		
		
		[self performTests];
	}
	
	return self;
}

-(NSString*) title
{
	return @"no title";
}

-(NSString*) subtitle
{
	return @"no subtitle";
}

-(void) performTests
{
	NSLog(@"override me");
}

-(void) restartCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [restartAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) nextCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [nextAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

-(void) backCallback: (id) sender
{
	CCScene *s = [CCScene node];
	[s addChild: [backAction() node]];
	[[CCDirector sharedDirector] replaceScene: s];
}

@end

#pragma mark -
#pragma mark TextureTest

@implementation TextureTest
-(void) performTestsPNG:(NSString*)filename
{
	struct timeval now;
	CCTexture2D *texture;
	CCTextureCache *cache = [CCTextureCache sharedTextureCache];

	printf("RGBA 8888");
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	gettimeofday(&now, NULL);	
	texture = [cache addImage:filename];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf(" ERROR\n");
	[cache removeTexture:texture];
	
	printf("RGBA 4444");
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA4444];
	gettimeofday(&now, NULL);	
	texture = [cache addImage:filename];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf(" ERROR\n");
	[cache removeTexture:texture];
	
	printf("RGBA 5551");
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB5A1];
	gettimeofday(&now, NULL);	
	texture = [cache addImage:filename];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf(" ERROR\n");
	[cache removeTexture:texture];
	
	printf("RGB 565");
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
	gettimeofday(&now, NULL);	
	texture = [cache addImage:filename];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf(" ERROR\n");
	[cache removeTexture:texture];
}

-(void) performTests
{
	CCTexture2D *texture;
	struct timeval now;
	CCTextureCache *cache = [CCTextureCache sharedTextureCache];
	
	printf("\n\n--------\n\n");
	
	printf("--- PNG 128x128 ---\n");
	[self performTestsPNG:@"test_image.png"];
	
	printf("--- PVR 128x128 ---\n");
	printf("RGBA 8888");
	gettimeofday(&now, NULL);	
	texture = [cache addImage:@"test_image_rgba8888.pvr"];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf("ERROR\n");
	[cache removeTexture:texture];

	printf("BGRA 8888");
	gettimeofday(&now, NULL);	
	texture = [cache addImage:@"test_image_bgra8888.pvr"];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf("ERROR\n");
	[cache removeTexture:texture];
	
	printf("RGBA 4444");
	gettimeofday(&now, NULL);	
	texture = [cache addImage:@"test_image_rgba4444.pvr"];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf("ERROR\n");
	[cache removeTexture:texture];

	printf("RGB 565");
	gettimeofday(&now, NULL);	
	texture = [cache addImage:@"test_image_rgb565.pvr"];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf("ERROR\n");
	[cache removeTexture:texture];
	
	
	printf("\n\n--- PNG 512x512 ---\n");
	[self performTestsPNG:@"texture512x512.png"];
	
	printf("--- PVR 512x512 ---\n");
	printf("RGBA 4444");
	gettimeofday(&now, NULL);	
	texture = [cache addImage:@"texture512x512_rgba4444.pvr"];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf("ERROR\n");
	[cache removeTexture:texture];
	
	//
	// ---- 1024X1024
	// RGBA4444
	// Empty image
	//

	printf("\n\nEMPTY IMAGE\n\n");
	printf("--- PNG 1024x1024 ---\n");
	[self performTestsPNG:@"texture1024x1024.png"];
	
	printf("--- PVR 1024x1024 ---\n");
	printf("RGBA 4444");
	gettimeofday(&now, NULL);	
	texture = [cache addImage:@"texture1024x1024_rgba4444.pvr"];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf("ERROR\n");
	[cache removeTexture:texture];

	printf("--- PVR.GZ 1024x1024 ---\n");
	printf("RGBA 4444");
	gettimeofday(&now, NULL);	
	texture = [cache addImage:@"texture1024x1024_rgba4444.pvr.gz"];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf("ERROR\n");
	[cache removeTexture:texture];

	printf("--- PVR.CCZ 1024x1024 ---\n");
	printf("RGBA 4444");
	gettimeofday(&now, NULL);	
	texture = [cache addImage:@"texture1024x1024_rgba4444.pvr.ccz"];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf("ERROR\n");
	[cache removeTexture:texture];

	//
	// ---- 1024X1024
	// RGBA4444
	// SpriteSheet images
	//
	
	printf("\n\nSPRITESHEET IMAGE\n\n");
	printf("--- PNG 1024x1024 ---\n");
	[self performTestsPNG:@"PlanetCute-1024x1024.png"];
	
	printf("--- PVR 1024x1024 ---\n");
	printf("RGBA 4444");
	gettimeofday(&now, NULL);	
	texture = [cache addImage:@"PlanetCute-1024x1024-rgba4444.pvr"];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf("ERROR\n");
	[cache removeTexture:texture];
	
	printf("--- PVR.GZ 1024x1024 ---\n");
	printf("RGBA 4444");
	gettimeofday(&now, NULL);	
	texture = [cache addImage:@"PlanetCute-1024x1024-rgba4444.pvr.gz"];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf("ERROR\n");
	[cache removeTexture:texture];
	
	printf("--- PVR.CCZ 1024x1024 ---\n");
	printf("RGBA 4444");
	gettimeofday(&now, NULL);	
	texture = [cache addImage:@"PlanetCute-1024x1024-rgba4444.pvr.ccz"];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf("ERROR\n");
	[cache removeTexture:texture];
	
	
	//
	// ---- 1024X1024
	// RGBA8888
	// Landscape Image
	//
	
	printf("\n\nLANDSCAPE IMAGE\n\n");

	printf("--- PNG 1024x1024 ---\n");
	[self performTestsPNG:@"landscape-1024x1024.png"];
	
	printf("--- PVR 1024x1024 ---\n");
	printf("RGBA 8888");
	gettimeofday(&now, NULL);	
	texture = [cache addImage:@"landscape-1024x1024-rgba8888.pvr"];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf("ERROR\n");
	[cache removeTexture:texture];
	
	printf("--- PVR.GZ 1024x1024 ---\n");
	printf("RGBA 8888");
	gettimeofday(&now, NULL);	
	texture = [cache addImage:@"landscape-1024x1024-rgba8888.pvr.gz"];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf("ERROR\n");
	[cache removeTexture:texture];
	
	printf("--- PVR.CCZ 1024x1024 ---\n");
	printf("RGBA 8888");
	gettimeofday(&now, NULL);	
	texture = [cache addImage:@"landscape-1024x1024-rgba8888.pvr.ccz"];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf("ERROR\n");
	[cache removeTexture:texture];

	
	//
	// 2048x2048
	// RGBA444
	//
	
	
	printf("\n\n--- PNG 2048x2048 ---\n");
	[self performTestsPNG:@"texture2048x2048.png"];
	
	printf("--- PVR 2048x2048 ---\n");
	printf("RGBA 4444");
	gettimeofday(&now, NULL);	
	texture = [cache addImage:@"texture2048x2048_rgba4444.pvr"];
	if( texture )
		printf("  ms:%f\n", calculateDeltaTime(&now) );
	else
		printf("ERROR\n");
	[cache removeTexture:texture];
}

-(NSString*) title
{
	return @"Texture Performance Test";
}
-(NSString*) subtitle
{
	return @"See console for results";
}
@end

