#import "TestBase.h"
#import "CCTextureCache.h"
#import "CCNodeColor.h"
//#import "CCNode_Private.h"

@interface CustomSprite : CCNode<CCShaderProtocol, CCTextureProtocol> @end
@implementation CustomSprite

-(id)init
{
	if((self = [super init])){
		// Set up a texture for rendering.
		// If you want to mix several textures, you need to make a shader and use CCNode.shaderUniforms.
		self.texture = [CCTexture textureWithFile:@"Tiles/05.png"];
		
		// Set a builtin shader that draws the node with a texture.
		// The default shader only draws the color of a node, ignoring it's texture.
		self.shader = [CCShader positionTextureColorShader];
	}
	
	return self;
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
	// What we want to do here is draw the texture from (0, 0) to (width, height) in the node's coordinates like a regular sprite.
	
	// 1) First we should check if our sprite will be onscreen or not, though this step is not required.
	// Given a bounding box in node coordinates and the node's transform, CCRenderCheckVisbility() can figure that out for us.
	
	// CCRenderCheckVisbility() takes an axis aligned bounding box expressed as a center and extents.
	// "extents" just means half the width and height of the bounding box.
	
	// Normally you'd want to do this outside of the draw method, but I'm trying to keep everything together.
	CGSize size = self.texture.contentSize;
	
	// The center and extents are easy to calculate in this case.
	// They are actually the same value in this case, but that won't normally be true.
	GLKVector2 center = GLKVector2Make(size.width/2.0, size.height/2.0);
	GLKVector2 extents = GLKVector2Make(size.width/2.0, size.height/2.0);
	
	// Now we just need to check if the sprite is visible.
	if(CCRenderCheckVisbility(transform, center, extents)){
		// 2) Now we can request a buffer from the renderer with enough space for 2 triangles and 4 vertexes.
		// Why two triangles instead of a rectangle? Modern GPUs really only draw triangles (and really bad lines/circles).
		// To draw a "fancy" shape like a rectangle to put our sprite on, we need to split it into two triangles.
		// self.renderState encapsulates the shader, shader uniforms, textures and blending modes set for this node.
		// You aren't required to pass self.renderState if you want to do something else.
		CCRenderBuffer buffer = [renderer enqueueTriangles:2 andVertexes:4 withState:self.renderState globalSortOrder:0];
		
		// 3) Next we make some vertexes to fill the buffer with. We need to make one for each corner of the sprite.
		// There are easier/shorter ways to fill in a CCVertex (See CCSprite.m for example), but this way is easy to read.
		
		CCVertex bottomLeft;
		// This is the position of the vertex in the node's coordinates.
		// Why are there 4 coordinates if this is a Cocos ->2D<- ?
		// You can probably guess, that the first two numbers are the x and y coordinates.
		// The 3rd is the z-coordinate in case you want to do 3D effects.
		// Always set the 4th coordinate to 1.0. (Google for "homogenous coordinates" if you want to learn what it is)
		bottomLeft.position = GLKVector4Make(0.0, 0.0, 0.0, 1.0);
		// This is the position of the vertex relative to the texture in normalized coordinates.
		// (0, 0) is the top left corner and (1, 1) is the bottom right.
		// This is actually upside down compared to the OpenGL convention.
		bottomLeft.texCoord1 = GLKVector2Make(0.0, 1.0);
		// Lastly we need to set a "pre-multiplied" RGBA color.
		// Premultiplied means that the RGB components have been multiplied by the alpha.
		bottomLeft.color = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
		
		// Now we are almost ready to put the vertex into the buffer, but there is one last step.
		// The positions of the vertexes need to be screen relative (OpenGL clip coordinates), but we made them node relative!
		// Fortunately, that's what the 'transform' variable is for. It lets you convert from node to screen coordinates.
		// CCVertexApplyTransform() will apply a transformation to an existing vertex's position.
		// Then we just need to use CCRenderBufferSetVertex() to store the vertex at index 0.
		CCRenderBufferSetVertex(buffer, 0, CCVertexApplyTransform(bottomLeft, transform));
		
		// Now to fill in the other 3 vertexes the same way.
		CCVertex bottomRight;
		bottomRight.position = GLKVector4Make(0.0, size.width, 0.0, 1.0);
		bottomRight.texCoord1 = GLKVector2Make(1.0, 1.0);
		bottomRight.color = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
		CCRenderBufferSetVertex(buffer, 1, CCVertexApplyTransform(bottomRight, transform));
		
		CCVertex topRight;
		topRight.position = GLKVector4Make(size.height, size.width, 0.0, 1.0);
		topRight.texCoord1 = GLKVector2Make(1.0, 0.0);
		topRight.color = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
		CCRenderBufferSetVertex(buffer, 2, CCVertexApplyTransform(topRight, transform));
		
		CCVertex topLeft;
		topLeft.position = GLKVector4Make(size.height, 0.0, 0.0, 1.0);
		topLeft.texCoord1 = GLKVector2Make(0.0, 0.0);
		topLeft.color = GLKVector4Make(1.0, 1.0, 1.0, 1.0);
		CCRenderBufferSetVertex(buffer, 3, CCVertexApplyTransform(topLeft, transform));
		
		// 4) Now that we are all done filling in the vertexes, we just need to make triangles with them.
		// This is pretty easy. The first number is the index of the triangle we are setting.
		// The last three numbers are the indexes of the vertexes set using CCRenderBufferSetVertex() to use for the corners.
		CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
		CCRenderBufferSetTriangle(buffer, 1, 0, 2, 3);
	}
}

@end

@interface CCRendererTest : TestBase @end
@implementation CCRendererTest

-(id)init
{
	if((self = [super init])){
		// Delay setting the color until the first frame.
		// Otherwise the scene will not exist yet.
		[self scheduleBlock:^(CCTimer *timer){self.scene.color = [CCColor lightGrayColor];} delay:0];
		
		// Alternatively, set up some rotating colors.
//		float delay = 1.0f;
//		[self scheduleBlock:^(CCTimer *timer) {
//			GLKMatrix4 colorMatrix = GLKMatrix4MakeRotation(timer.invokeTime*1e0, 1, 1, 1);
//			GLKVector4 color = GLKMatrix4MultiplyVector4(colorMatrix, GLKVector4Make(1, 0, 0, 1));
//			self.scene.color = [CCColor colorWithGLKVector4:color];
//			
//			[timer repeatOnceWithInterval:delay];
//		} delay:delay];
	}
	
	return self;
}

//-(void)setupCustomSpriteTest
//{
//	CustomSprite *sprite = [CustomSprite node];
//	sprite.positionType = CCPositionTypeNormalized;
//	sprite.position = ccp(0.5, 0.5);
//	
//	[self.contentNode addChild:sprite];
//}

-(void)setupClippingNodeTest
{
	self.subTitle = @"ClippingNode test.";
	
	CGSize size = [CCDirector sharedDirector].designSize;
	
//	CCNode *parent = self.contentNode;
	
	CCRenderTexture *parent = [CCRenderTexture renderTextureWithWidth:size.width height:size.height pixelFormat:CCTexturePixelFormat_RGBA8888 depthStencilFormat:GL_DEPTH24_STENCIL8];
	parent.positionType = CCPositionTypeNormalized;
	parent.position = ccp(0.5, 0.5);
	parent.autoDraw = YES;
	parent.clearColor = [CCColor blackColor];
	parent.clearDepth = 1.0;
	parent.clearStencil = 0;
	parent.clearFlags = GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT;
	[self.contentNode addChild:parent];
	
	CCNodeGradient *grad = [CCNodeGradient nodeWithColor:[CCColor redColor] fadingTo:[CCColor blueColor] alongVector:ccp(1, 1)];
//	[parent addChild:grad];
	
	CCNode *stencil = [CCSprite spriteWithImageNamed:@"Sprites/grossini.png"];
//	[parent addChild:stencil];
	stencil.position = ccp(size.width/2, size.height/2);
	stencil.scale = 5.0;
	[stencil runAction:[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:1.0 angle:90.0]]];
	
	CCClippingNode *clip = [CCClippingNode clippingNodeWithStencil:stencil];
	[parent addChild:clip];
	clip.alphaThreshold = 0.5;
	[clip addChild:grad];
}

-(void)setupInfiniteWindowTest
{
	self.subTitle = @"Should draw an infinite window";
	
	CCNode *contentNode = self.contentNode;
	CGSize size = [CCDirector sharedDirector].designSize;
	
	CCNode *node = [CCNode node];
	[self.contentNode addChild:node];
	
	[node scheduleBlock:^(CCTimer *timer) {
		CCRenderTexture *rt = [CCRenderTexture renderTextureWithWidth:size.width height:size.height];
		
		[rt begin];
			[[CCDirector sharedDirector].runningScene visit];
		[rt end];
		
		// Remove the old sprite
		[contentNode removeChildByName:@"zoom"];
		
		CGImageRef image = [rt newCGImage];
		CCTexture *texture = [[CCTexture alloc] initWithCGImage:image contentScale:rt.contentScale];
		CGImageRelease(image);
		
		CCSprite *sprite = [CCSprite spriteWithTexture:texture];
		sprite.scale = 0.9;
		sprite.position = ccp(size.width/2.0, size.height/2.0);
		sprite.name = @"zoom";
		
		[contentNode addChild:sprite];
				
		[timer repeatOnceWithInterval:0.125];
	} delay:0.0];
}

-(CCSprite *)simpleShaderTestHelper
{
	CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
	sprite.positionType = CCPositionTypeNormalized;
	[self.contentNode addChild:sprite];
	
	return sprite;
}

-(void)setupSimpleShaderTest
{
	self.subTitle = @"Global and node shader uniforms.";
	
	// Normally you'd load shaders from a file using the [CCShader shaderNamed:] method to use the shader cache.
	// Embedding shaders in the source code is handy when they are short though.
	CCShader *shader = [[CCShader alloc] initWithFragmentShaderSource:CC_GLSL(
		uniform lowp mat4 u_ColorMatrix;
		
		void main(void){
			gl_FragColor = u_ColorMatrix*texture2D(cc_MainTexture, cc_FragTexCoord1);
		}
	)];
	
	CCSprite *sprite1 = [self simpleShaderTestHelper];
	sprite1.position = ccp(0.3, 0.4);
	sprite1.shader = shader;
	
	CCSprite *sprite2 = [self simpleShaderTestHelper];
	sprite2.position = ccp(0.3, 0.6);
	sprite2.shader = shader;
	
	CCLabelTTF *label1 = [CCLabelTTF labelWithString:@"Using CCDirector.globalShaderUniforms" fontName:@"Helvetica" fontSize:10.0];
	label1.positionType = CCPositionTypeNormalized;
	label1.position = ccp(0.3, 0.3);
	[self.contentNode addChild:label1];
	
	CCSprite *sprite3 = [self simpleShaderTestHelper];
	sprite3.position = ccp(0.7, 0.5);
	sprite3.shader = shader;
	
	CCLabelTTF *label2 = [CCLabelTTF labelWithString:@"Using CCNode.shaderUniforms" fontName:@"Helvetica" fontSize:10.0];
	label2.positionType = CCPositionTypeNormalized;
	label2.position = ccp(0.7, 0.3);
	[self.contentNode addChild:label2];
	
	[self scheduleBlock:^(CCTimer *timer) {
		// Set up a global uniform matrix to rotate colors counter-clockwise.
		GLKMatrix4 colorMatrix1 = GLKMatrix4MakeRotation(2.0f*timer.invokeTime, 1.0f, 1.0f, 1.0f);
		[CCDirector sharedDirector].globalShaderUniforms[@"u_ColorMatrix"] = [NSValue valueWithGLKMatrix4:colorMatrix1];
		
		// Set just sprite3's matrix to rotate colors clockwise.
		GLKMatrix4 colorMatrix2 = GLKMatrix4MakeRotation(-4.0f*timer.invokeTime, 1.0f, 1.0f, 1.0f);
		sprite3.shaderUniforms[@"u_ColorMatrix"] = [NSValue valueWithGLKMatrix4:colorMatrix2];
		
		[timer repeatOnceWithInterval:1.0/60.0];
	} delay:0.0f];
}

-(void)renderTextureHelper:(CCNode *)stage size:(CGSize)size
{
	CCColor *color = [CCColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:0.5];
	CCNode *node = [CCNodeColor nodeWithColor:color width:128 height:128];
	[stage addChild:node];
	
	CCNodeColor *colorNode = [CCNodeColor nodeWithColor:[CCColor greenColor] width:32 height:32];
	colorNode.anchorPoint = ccp(0.5, 0.5);
	colorNode.position = ccp(size.width, 0);
	[colorNode runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
		[CCActionMoveTo actionWithDuration:1.0 position:ccp(0, size.height)],
		[CCActionMoveTo actionWithDuration:1.0 position:ccp(size.width, 0)],
		nil
	]]];
	[node addChild:colorNode];
	
	CCSprite *sprite = [CCSprite spriteWithImageNamed:@"Sprites/bird.png"];
	sprite.opacity = 0.5;
	[sprite runAction:[CCActionRepeatForever actionWithAction:[CCActionSequence actions:
		[CCActionMoveTo actionWithDuration:1.0 position:ccp(size.width, size.height)],
		[CCActionMoveTo actionWithDuration:1.0 position:ccp(0, 0)],
		nil
	]]];
	[node addChild:sprite];
}

-(void)setupRenderTextureTest
{
	self.subTitle = @"Testing CCRenderTexture.";
	
	CGSize size = CGSizeMake(128, 128);
	
	CCNode *stage = [CCNode node];
	stage.contentSize = size;
	stage.anchorPoint = ccp(0.5, 0.5);
	stage.positionType = CCPositionTypeNormalized;
	stage.position = ccp(0.25, 0.5);
	[self.contentNode addChild:stage];
	
	[self renderTextureHelper:stage size:size];
	
	CCRenderTexture *renderTexture = [CCRenderTexture renderTextureWithWidth:size.width height:size.height pixelFormat:CCTexturePixelFormat_RGBA8888];
	renderTexture.positionType = CCPositionTypeNormalized;
	renderTexture.position = ccp(0.75, 0.5);
	renderTexture.clearFlags = GL_COLOR_BUFFER_BIT;
	renderTexture.clearColor = [CCColor clearColor];
	[self.contentNode addChild:renderTexture];
    
    // TODO: allow render texture to allow content size changes
    //[self scheduleBlock:^(CCTimer *timer){renderTexture.contentSize = CGSizeMake(256, 256);} delay:3];
	
	[self renderTextureHelper:renderTexture size:size];
	renderTexture.autoDraw = YES;
}

-(void)setupShader1Test
{
	self.subTitle = @"Useless fragment shader.";
	
	CCNodeColor *node = [CCNodeColor nodeWithColor:[CCColor blueColor]];
	node.contentSizeType = CCSizeTypeNormalized;
	node.contentSize = CGSizeMake(1.0, 1.0);
	node.shader = [CCShader shaderNamed:@"TrippyTriangles"];
	
	[self.contentNode addChild:node];
}

- (void)setupMotionStreakNodeTest
{
	self.subTitle = @"Testing CCMotionStreak";
	
	CCNode *stage = [CCNode node];
	stage.anchorPoint = ccp(0.5, 0.5);
	stage.positionType = CCPositionTypeNormalized;
	stage.position = ccp(0.5, 0.5);
	stage.contentSizeType = CCSizeTypeNormalized;
	stage.contentSize = CGSizeMake(0.75, 0.75);
	[self.contentNode addChild:stage];
	
	// Maybe want to find a better texture than a random tile graphic?
	{
		CCMotionStreak *streak = [CCMotionStreak streakWithFade:15.0 minSeg:5 width:3 color:[CCColor whiteColor] textureFilename:@"Tiles/05.png"];
		[stage addChild:streak];
		
		[streak scheduleBlock:^(CCTimer *timer) {
			CCTime t = timer.invokeTime;
			CGSize size = stage.contentSizeInPoints;
			
			streak.position = ccp(size.width*(0.5 + 0.5*sin(3.1*t)), size.height*(0.5 + 0.5*cos(4.3*t)));
			
			[timer repeatOnceWithInterval:0.01];
		} delay:0.0];
	}{
		CCMotionStreak *streak = [CCMotionStreak streakWithFade:0.5 minSeg:5 width:3 color:[CCColor redColor] textureFilename:@"Tiles/05.png"];
		[stage addChild:streak];
		
		[streak scheduleBlock:^(CCTimer *timer) {
			CCTime t = timer.invokeTime;
			CGSize size = stage.contentSizeInPoints;
			
			streak.position = ccp(size.width*(0.5 + 0.5*sin(1.6*t)), size.height*(0.5 + 0.5*cos(5.1*t)));
			
			[timer repeatOnceWithInterval:0.01];
		} delay:0.0];
	}
}

static float
ProgressPercent(CCTime t)
{
	return 100.0*fmod(t, 1.0);
}

- (void)setupProgressNodeTest
{
	self.subTitle = @"Testing various CCProgressNode setups.";
	
	// Radial timer
	{
		NSString *image = @"Tiles/06.png";
		CGPoint position = ccp(0.1, 0.25);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeRadial;
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.percentage = ProgressPercent(timer.invokeTime);
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
	
	// Radial timer with animating midpoint.
	{
		NSString *image = @"Tiles/06.png";
		CGPoint position = ccp(0.1, 0.5);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeRadial;
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.midpoint = ccpAdd(ccp(0.5, 0.5), ccpMult(ccpForAngle(timer.invokeTime), 0.25));
			progress.percentage = ProgressPercent(timer.invokeTime);
			
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
	
	{
		NSString *image = @"Tiles/06.png";
		CGPoint position = ccp(0.2, 0.25);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeBar;
		progress.midpoint = ccp(0.5, 0);
		progress.barChangeRate = ccp(0, 1);
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.percentage = ProgressPercent(timer.invokeTime);
			
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
	
	{
		NSString *image = @"Tiles/06.png";
		CGPoint position = ccp(0.2, 0.5);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeBar;
		progress.midpoint = ccp(0, 0.5);
		progress.barChangeRate = ccp(1, 0);
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.percentage = ProgressPercent(timer.invokeTime);
			
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
	
	{
		NSString *image = @"Tiles/06.png";
		CGPoint position = ccp(0.3, 0.25);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeBar;
		progress.midpoint = ccp(1, 0.5);
		progress.barChangeRate = ccp(1, 0);
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.percentage = ProgressPercent(timer.invokeTime);
			
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
	
	{
		NSString *image = @"Tiles/06.png";
		CGPoint position = ccp(0.3, 0.5);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeBar;
		progress.midpoint = ccp(0.5, 1);
		progress.barChangeRate = ccp(0, 1);
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.percentage = ProgressPercent(timer.invokeTime);
			
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
	
	{
		NSString *image = @"Tiles/06.png";
		CGPoint position = ccp(0.4, 0.25);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeBar;
		progress.midpoint = ccp(0.5, 0.5);
		progress.barChangeRate = ccp(1, 1);
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.percentage = ProgressPercent(timer.invokeTime);
			
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
	
	{
		NSString *image = @"Tiles/06.png";
		CGPoint position = ccp(0.4, 0.5);
		CCTime interval = 1.0/60.0;
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeBar;
		progress.midpoint = ccp(0.5, 0.5);
		progress.barChangeRate = ccp(0, 0);
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.percentage = ProgressPercent(timer.invokeTime);
			
			[timer repeatOnceWithInterval:interval];
		} delay:interval];
	}
	
	{
		NSString *image = @"Tiles/06.png";
		CGPoint position = ccp(0.5, 3.0/8.0);
		
		CCSprite *sprite = [CCSprite spriteWithImageNamed:image];
		sprite.positionType = CCPositionTypeNormalized;
		sprite.position = position;
		sprite.color = [CCColor grayColor];
		[self.contentNode addChild:sprite];
		
		CCProgressNode *progress = [CCProgressNode progressWithSprite:[CCSprite spriteWithImageNamed:image]];
		progress.type = CCProgressNodeTypeBar;
		progress.midpoint = ccp(0.5, 0.5);
		progress.barChangeRate = ccp(1, 1);
		progress.positionType = CCPositionTypeNormalized;
		progress.position = position;
		progress.percentage = 50;
		[self.contentNode addChild:progress];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.sprite = [CCSprite spriteWithImageNamed:@"Tiles/06.png"];
			[timer repeatOnceWithInterval:1.0];
		} delay:0.5];
		
		[self scheduleBlock:^(CCTimer *timer) {
			progress.sprite = [CCSprite spriteWithImageNamed:@"Tiles/05.png"];
			[timer repeatOnceWithInterval:1.0];
		} delay:1.0];
	}
}

- (void)setupDrawNodeTest
{
	self.subTitle = @"Testing CCDrawNode";
	
	CCDrawNode *draw = [CCDrawNode node];
	
	[draw drawDot:ccp(100, 100) radius:50 color:[CCColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:0.75]];
	
	// This yellow dot should not be visible.
	[draw drawDot:ccp(150, 150) radius:50 color:[CCColor colorWithRed:0.5 green:0.5 blue:0.0 alpha:0.0]];
	
	[draw drawSegmentFrom:ccp(100, 200) to:ccp(200, 200) radius:25 color:[CCColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:0.75]];
	
	CGPoint points1[] = {
		{300, 100},
		{350,  50},
		{400, 100},
		{400, 200},
		{350, 250},
		{300, 200},
	};
	[draw drawPolyWithVerts:points1 count:sizeof(points1)/sizeof(*points1) fillColor:[CCColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:0.75] borderWidth:5.0 borderColor:[CCColor whiteColor]];
	
	CGPoint points2[] = {
		{325, 125},
		{375, 125},
		{350, 200},
	};
	[draw drawPolyWithVerts:points2 count:sizeof(points2)/sizeof(*points2) fillColor:[CCColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.75] borderWidth:0.0 borderColor:[CCColor whiteColor]];
	
	[self.contentNode addChild:draw];
}

- (void)setupColorNodeTest
{
	self.subTitle = @"Testing CCNodeColor/CCNodeGradient";
	
	// Solid Colors
	{ // Red
		CCNodeColor *node = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:0.25] width:100 height:100];
		node.positionType = CCPositionTypeNormalized;
		node.position = ccp(0.25, 0.3);
		node.anchorPoint = ccp(0.5, 0.5);
		
		[self.contentNode addChild:node];
	}
	
	{ // Green
		CCNodeColor *node = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:0.25] width:100 height:100];
		node.positionType = CCPositionTypeNormalized;
		node.position = ccp(0.50, 0.3);
		node.anchorPoint = ccp(0.5, 0.5);
		
		[self.contentNode addChild:node];
	}
	
	{ // Blue
		CCNodeColor *node = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:0.25] width:100 height:100];
		node.positionType = CCPositionTypeNormalized;
		node.position = ccp(0.75, 0.3);
		node.anchorPoint = ccp(0.5, 0.5);
		
		[self.contentNode addChild:node];
	}
	
	CCColor *clearWhite = [CCColor colorWithRed:1 green:1 blue:1 alpha:0];
	
	// Gradients
	{ // Red
		CCNodeGradient *node = [CCNodeGradient nodeWithColor:[CCColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0] width:100 height:100];
		node.endColor = clearWhite;
		node.vector = ccp(1, 1);
		node.positionType = CCPositionTypeNormalized;
		node.position = ccp(0.25, 0.7);
		node.anchorPoint = ccp(0.5, 0.5);
		
		[self.contentNode addChild:node];
	}
	
	{ // Green
		CCNodeGradient *node = [CCNodeGradient nodeWithColor:[CCColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0] width:100 height:100];
		node.endColor = clearWhite;
		node.vector = ccp(0, 1);
		node.positionType = CCPositionTypeNormalized;
		node.position = ccp(0.50, 0.7);
		node.anchorPoint = ccp(0.5, 0.5);
		
		[self.contentNode addChild:node];
	}
	
	{ // Blue
		CCNodeGradient *node = [CCNodeGradient nodeWithColor:[CCColor colorWithRed:0.0 green:0.0 blue:0.5 alpha:1.0] width:100 height:100];
		node.endColor = clearWhite;
		node.vector = ccp(-1, 1);
		node.positionType = CCPositionTypeNormalized;
		node.position = ccp(0.75, 0.7);
		node.anchorPoint = ccp(0.5, 0.5);
		
		[self.contentNode addChild:node];
	}
}

@end

