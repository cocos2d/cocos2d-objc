// http://www.cocos2d-iphone.org
//
// Javascript Action tests
// Test are coded using Javascript, with the exception of MenuCallback which uses Objective-J to handle the callbacks.
// 

//
// Helper functions
//
function ccp( x, y ) {
	return CGPointMake( x, y );
}

//
// Menu Callback
//
@implementation MenuCallback : NSObject
- (void)back:(id)sender
{
	currentScene = currentScene -1;
	if( currentScene < 0 )
		currentScene = scenes.length -1;
	
	this.loadScene( currentScene );
}
- (void)reset:(id)sender
{
	this.loadScene( currentScene );
}
- (void)forward:(id)sender
{
	currentScene = currentScene + 1;
	if( currentScene >= scenes.length )
		currentScene = 0;
	
	this.loadScene( currentScene );
}

-(void) loadScene:(int)sceneNumber
{
	// update winsize. It might have changed
	winSize = director.winSize;
	
	var scene = CCScene.node;
	var layer = CCLayer.node;
	
	scene.addChild( layer );
	
	var t = scenes[ sceneNumber ];
	
	add_menu( layer );
	add_titles( layer, t.title, t.subtitle );
	t.test( layer );
	
//	scene.walkSceneGraph(0);
	
	director.replaceScene( scene );
	__jsc__.garbageCollect
}
@end


// globals
var director = CCDirector.sharedDirector;
var winSize = director.winSize;
var scenes = []
var currentScene = 0;
var callback = MenuCallback.instance;

//
// Sprite: Tap screen
//

@implementation MyLayer : CCLayer
-(id) init
{
	[super init];
	
	this.js_proxy = '';
	
	return this;
}

-(BOOL) ccMouseUp:(NSEvent*)event
{
	var location = director.convertEventToGL( event );
	this.js_proxy.ccMouseUp( location );

	return YES;
}
@end

function test_sprite_add_sprite() {
	this.title = "Sprite: Click on the screen";
	this.subtitle = "Javascript test: sprites + actions + clicks";
}

test_sprite_add_sprite.prototype.test = function( parent ) {
	
	var newParent = CCNode.node;
	parent.addChild( newParent );
	this.parent = newParent;

	var layer = MyLayer.node;
	layer.isMouseEnabled = true;
	layer.js_proxy = this;
	parent.addChild( layer );

	this.add_new_sprite_with_coords( ccp( winSize.width/2, winSize.height/2) );
}

test_sprite_add_sprite.prototype.add_new_sprite_with_coords = function( coords ) {

	var idx = Math.floor( Math.random() * 14 );
	
	var x = (idx%5);
	var y = Math.floor( idx/5 );

	x = x * 85;
	y = y * 121;

	var sprite = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(x,y,85,121) );
	this.parent.addChild( sprite );
	
	sprite.position = coords;
	
	var rand = Math.random();
	
	var action;

	if( rand < 0.20 ) {
		action = CCScaleBy.actionWithDuration_scale(3, 2 );
	} else if(rand < 0.40) {
		action = CCRotateBy.actionWithDuration_angle(3, 360 );
	} else if( rand < 0.60) {
		action = CCBlink.actionWithDuration_blinks(1, 3 );
	} else if( rand < 0.8 ) {
		action = CCTintBy.actionWithDuration_red_green_blue(2, 0, -255, -255 );
	} else {
		action = CCFadeOut.actionWithDuration( 2 );
	}

	var action_back = action.reverse;
		
	var seq = CCSequence.actionWithArray( [action, action_back] );
	
	sprite.runAction( CCRepeatForever.actionWithAction( seq ) );
}

test_sprite_add_sprite.prototype.ccMouseUp = function( location ) {

	this.add_new_sprite_with_coords( location );
	
	return true;
}

scenes.push( new test_sprite_add_sprite() );

//
// SpriteBatch: Tap screen
//


function test_sprite_add_sprite_batch() {
	this.title = "Batched Sprite: Click on the screen";
	this.subtitle = "Javascript test: batched sprites + actions + clicks";
}

test_sprite_add_sprite_batch.prototype.test = function( parent ) {
	
	var newParent = CCSpriteBatchNode.batchNodeWithFile_capacity( "grossini_dance_atlas.png", 1);

	parent.addChild( newParent );
	this.parent = newParent;
	
	var layer = MyLayer.node;
	layer.isMouseEnabled = true;
	layer.js_proxy = this;	
	parent.addChild( layer );

	this.add_new_sprite_with_coords( ccp( winSize.width/2, winSize.height/2) );
}

test_sprite_add_sprite_batch.prototype.add_new_sprite_with_coords = test_sprite_add_sprite.prototype.add_new_sprite_with_coords;

test_sprite_add_sprite_batch.prototype.ccMouseUp = test_sprite_add_sprite.prototype.ccMouseUp;

scenes.push( new test_sprite_add_sprite_batch() );

//
// Sprite: Color + Opacity
//
function test_sprite_color_opacity() {
	this.title = "Sprite: Color + Opacity";
	this.subtitle = "Javascript test: Sprite with color and opacity";	
}

test_sprite_color_opacity.prototype.test = function( parent ) {
	
	var sprite1 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*0, 121*1, 85, 121) );
	var sprite2 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*1, 121*1, 85, 121) );
	var sprite3 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*2, 121*1, 85, 121) );
	var sprite4 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*3, 121*1, 85, 121) );
	
	var sprite5 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*0, 121*1, 85, 121) );
	var sprite6 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*1, 121*1, 85, 121) );
	var sprite7 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*2, 121*1, 85, 121) );
	var sprite8 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*3, 121*1, 85, 121) );
	
	sprite1.position = ccp( (winSize.width/5)*1, (winSize.height/3)*1);
	sprite2.position = ccp( (winSize.width/5)*2, (winSize.height/3)*1);
	sprite3.position = ccp( (winSize.width/5)*3, (winSize.height/3)*1);
	sprite4.position = ccp( (winSize.width/5)*4, (winSize.height/3)*1);
	sprite5.position = ccp( (winSize.width/5)*1, (winSize.height/3)*2);
	sprite6.position = ccp( (winSize.width/5)*2, (winSize.height/3)*2);
	sprite7.position = ccp( (winSize.width/5)*3, (winSize.height/3)*2);
	sprite8.position = ccp( (winSize.width/5)*4, (winSize.height/3)*2);
	
	var action = CCFadeIn.actionWithDuration( 2 );
	var action_back = action.reverse;
	var fade = CCRepeatForever.actionWithAction( CCSequence.actionsWithArray( [action, action_back] ) );
	
	var tintred = CCTintBy.actionWithDuration_red_green_blue(2,0,-255,-255);
	var tintred_back = tintred.reverse;
	var red = CCRepeatForever.actionWithAction( CCSequence.actionsWithArray( [tintred, tintred_back] ) );
	
	var tintgreen = CCTintBy.actionWithDuration_red_green_blue(2,-255,0,-255);
	var tintgreen_back = tintgreen.reverse;
	var green = CCRepeatForever.actionWithAction( CCSequence.actionsWithArray( [tintgreen, tintgreen_back] ) );
	
	var tintblue = CCTintBy.actionWithDuration_red_green_blue(2,-255,-255,0);
	var tintblue_back = tintblue.reverse;
	var blue = CCRepeatForever.actionWithAction( CCSequence.actionsWithArray( [tintblue, tintblue_back] ) );
	
	
	sprite5.runAction( red );
	sprite6.runAction( green );
	sprite7.runAction( blue );
	sprite8.runAction( fade );
	
	// late add: test dirtyColor and dirtyPosition
	parent.addChild( sprite1 );
	parent.addChild( sprite2 );
	parent.addChild( sprite3 );
	parent.addChild( sprite4 );
	parent.addChild( sprite5 );
	parent.addChild( sprite6 );
	parent.addChild( sprite7 );
	parent.addChild( sprite8 );
}
scenes.push( new test_sprite_color_opacity() );


//
// SpriteBatch: Color + Opacity
//
function test_spritebatch_color_opacity() {
	this.title = "Batched Sprites: Color + Opacity";
	this.subtitle = "Javascript test: Batched sprites with color and opacity";	
}

test_spritebatch_color_opacity.prototype.test = function( parent ) {
	
	var batch = CCSpriteBatchNode.batchNodeWithFile_capacity( "grossini_dance_atlas.png", 1);
	parent.addChild( batch );

	var sprite1 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*0, 121*1, 85, 121) );
	var sprite2 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*1, 121*1, 85, 121) );
	var sprite3 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*2, 121*1, 85, 121) );
	var sprite4 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*3, 121*1, 85, 121) );
	
	var sprite5 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*0, 121*1, 85, 121) );
	var sprite6 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*1, 121*1, 85, 121) );
	var sprite7 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*2, 121*1, 85, 121) );
	var sprite8 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*3, 121*1, 85, 121) );
	
	sprite1.position = ccp( (winSize.width/5)*1, (winSize.height/3)*1);
	sprite2.position = ccp( (winSize.width/5)*2, (winSize.height/3)*1);
	sprite3.position = ccp( (winSize.width/5)*3, (winSize.height/3)*1);
	sprite4.position = ccp( (winSize.width/5)*4, (winSize.height/3)*1);
	sprite5.position = ccp( (winSize.width/5)*1, (winSize.height/3)*2);
	sprite6.position = ccp( (winSize.width/5)*2, (winSize.height/3)*2);
	sprite7.position = ccp( (winSize.width/5)*3, (winSize.height/3)*2);
	sprite8.position = ccp( (winSize.width/5)*4, (winSize.height/3)*2);
	
	var action = CCFadeIn.actionWithDuration( 2 );
	var action_back = action.reverse;
	var fade = CCRepeatForever.actionWithAction( CCSequence.actionsWithArray( [action, action_back] ) );
	
	var tintred = CCTintBy.actionWithDuration_red_green_blue(2,0,-255,-255);
	var tintred_back = tintred.reverse;
	var red = CCRepeatForever.actionWithAction( CCSequence.actionsWithArray( [tintred, tintred_back] ) );
	
	var tintgreen = CCTintBy.actionWithDuration_red_green_blue(2,-255,0,-255);
	var tintgreen_back = tintgreen.reverse;
	var green = CCRepeatForever.actionWithAction( CCSequence.actionsWithArray( [tintgreen, tintgreen_back] ) );
	
	var tintblue = CCTintBy.actionWithDuration_red_green_blue(2,-255,-255,0);
	var tintblue_back = tintblue.reverse;
	var blue = CCRepeatForever.actionWithAction( CCSequence.actionsWithArray( [tintblue, tintblue_back] ) );
	
	
	sprite5.runAction( red );
	sprite6.runAction( green );
	sprite7.runAction( blue );
	sprite8.runAction( fade );
	
	// late add: test dirtyColor and dirtyPosition
	batch.addChild( sprite1 );
	batch.addChild( sprite2 );
	batch.addChild( sprite3 );
	batch.addChild( sprite4 );
	batch.addChild( sprite5 );
	batch.addChild( sprite6 );
	batch.addChild( sprite7 );
	batch.addChild( sprite8 );
}
scenes.push( new test_spritebatch_color_opacity() );

//
// Sprite: Anchor Point
//
function test_sprite_anchorpoint() {
	this.title = "Sprite: Anchor Point";
	this.subtitle = "Javascript test: Sprite with different anchor points";	
}

test_sprite_anchorpoint.prototype.test = function( parent ) {
	
	var rotate = CCRotateBy.actionWithDuration_angle(10, 360);
	var action = CCRepeatForever.actionWithAction( rotate );

	var i=0;
	for(i=0;i<3;i++) {
		var sprite = CCSprite.spriteWithFile_rect( "grossini_dance_atlas.png", CGRectMake(85*i, 121*1, 85, 121) );
		sprite.position = ccp( winSize.width/4*(i+1), winSize.height/2);
		
		var point = CCSprite.spriteWithFile( "r1.png" );
		point.scale = 0.25;
		point.position = sprite.position;
		parent.addChild_z(point, 10 );
		
		if( i==0) {
			sprite.anchorPoint = ccp(0,0);
		}
		else if( i == 1 ) {
			sprite.anchorPoint = ccp(0.5, 0.5);
		}
		else if( i == 2 ) {
			sprite.anchorPoint = ccp(1,1);
		}
		
		point.position = sprite.position;
		
		var copy = action.copy.autorelease;
		sprite.runAction( copy );
		parent.addChild_z( sprite, i );
	}
}
scenes.push( new test_sprite_anchorpoint() );


//
// Sprite Batch: Anchor Point
//
function test_spritebatch_anchorpoint() {
	this.title = "SpriteBatch: Anchor Point";
	this.subtitle = "Javascript test: SpriteBatch with different anchor points";	
}

test_spritebatch_anchorpoint.prototype.test = function( parent ) {
	
	var batch = CCSpriteBatchNode.batchNodeWithFile_capacity("grossini_dance_atlas.png",1);
	parent.addChild( batch );

	var rotate = CCRotateBy.actionWithDuration_angle(10, 360);
	var action = CCRepeatForever.actionWithAction( rotate );
	
	var i=0;
	for(i=0;i<3;i++) {
		var sprite = CCSprite.spriteWithFile_rect( "grossini_dance_atlas.png", CGRectMake(85*i, 121*1, 85, 121) );
		sprite.position = ccp( winSize.width/4*(i+1), winSize.height/2);
		
		var point = CCSprite.spriteWithFile( "r1.png" );
		point.scale = 0.25;
		point.position = sprite.position;
		parent.addChild_z(point, 10 );
		
		if( i==0) {
			sprite.anchorPoint = ccp(0,0);
		}
		else if( i == 1 ) {
			sprite.anchorPoint = ccp(0.5, 0.5);
		}
		else if( i == 2 ) {
			sprite.anchorPoint = ccp(1,1);
		}
		
		point.position = sprite.position;
		
		var copy = action.copy.autorelease;
		sprite.runAction( copy );
		batch.addChild_z( sprite, i );
	}
}
scenes.push( new test_spritebatch_anchorpoint() );


//
// Sprite: Anchor Point + Skew + Scale
//
function test_sprite_anchorpoint_skew_scale() {
	this.title = "Sprite: Anchor + Skew + Scale";
	this.subtitle = "Javascript test: Sprite anchor point + skew + scale";	
}

test_sprite_anchorpoint_skew_scale.prototype.test = function( parent ) {

	var cache = CCSpriteFrameCache.sharedSpriteFrameCache;
	cache.addSpriteFramesWithFile( "animations/grossini.plist" );
	cache.addSpriteFramesWithFile_textureFilename( "animations/grossini_gray.plist", "animations/grossini_gray.png" );

	var i=0;
	for(i=0;i<3;i++) {
		
		//
		// Animation
		//
		var sprite = CCSprite.spriteWithSpriteFrameName( "grossini_dance_01.png" );
		sprite.position = ccp( winSize.width/4*(i+1), winSize.height/2);
		
		var point = CCSprite.spriteWithFile( "r1.png" );
		point.scale = 0.25;
		point.position = sprite.position;
		parent.addChild_z( point, 1 );
		
		if( i == 0 ) {
			sprite.anchorPoint = ccp(0,0);
		}
		else if( i == 1 ) {
			sprite.anchorPoint = ccp(0.5, 0.5);
		}
		else if (i == 2 ) {
			sprite.anchorPoint = ccp(1,1);
		}
		
		point.position = sprite.position;
		
		var animFrames = NSMutableArray.array;
		
		var j=0;
		for(j = 0; j < 14; j++) {
			var prefix = (j+1<10) ? '0' : '';
			var name = 'grossini_dance_' + prefix + (j+1) + '.png';
			var frame = cache.spriteFrameByName( name );
			animFrames.addObject( frame );
		}
		var animation = CCAnimation.animationWithSpriteFrames_delay(animFrames, 0.3 );
		sprite.runAction( CCRepeatForever.actionWithAction( CCAnimate.actionWithAnimation( animation ) ) );
		
		// Skew
		var skewX = CCSkewBy.actionWithDuration_skewX_skewY(2, 45, 0 );
		var skewX_back = skewX.reverse;
		var skewY = CCSkewBy.actionWithDuration_skewX_skewY(2, 0 , 45 );
		var skewY_back = skewY.reverse;
		
		var seq_skew = CCSequence.actionsWithArray( [skewX, skewX_back, skewY, skewY_back] );
		sprite.runAction( CCRepeatForever.actionWithAction( seq_skew ) );
		
		// Scale
		var scale = CCScaleBy.actionWithDuration_scale(2, 2);
		var scale_back = scale.reverse;
		var seq_scale = CCSequence.actionsWithArray( [scale, scale_back] );
		sprite.runAction( CCRepeatForever.actionWithAction( seq_scale ) );
		
		parent.addChild_z(sprite, 0);
	}
}
scenes.push( new test_sprite_anchorpoint_skew_scale() );


//
// SpriteBatch: Anchor Point + Skew + Scale
//
function test_spritebatch_anchorpoint_skew_scale() {
	this.title = "SpriteBatch: Anchor + Skew + Scale";
	this.subtitle = "Javascript test: SpriteBatch anchor point + skew + scale";	
}

test_spritebatch_anchorpoint_skew_scale.prototype.test = function( parent ) {
	
	var cache = CCSpriteFrameCache.sharedSpriteFrameCache;
	cache.addSpriteFramesWithFile( "animations/grossini.plist" );
	cache.addSpriteFramesWithFile_textureFilename( "animations/grossini_gray.plist", "animations/grossini_gray.png" );
	
	
	var spritebatch = CCSpriteBatchNode.batchNodeWithFile( "animations/grossini.pvr.gz" );
	parent.addChild( spritebatch );

	var i=0;
	for(i=0;i<3;i++) {
		
		//
		// Animation
		//
		var sprite = CCSprite.spriteWithSpriteFrameName( "grossini_dance_01.png" );
		sprite.position = ccp( winSize.width/4*(i+1), winSize.height/2);
		
		var point = CCSprite.spriteWithFile( "r1.png" );
		point.scale = 0.25;
		point.position = sprite.position;
		parent.addChild_z( point, 1 );
		
		if( i == 0 ) {
			sprite.anchorPoint = ccp(0,0);
		}
		else if( i == 1 ) {
			sprite.anchorPoint = ccp(0.5, 0.5);
		}
		else if (i == 2 ) {
			sprite.anchorPoint = ccp(1,1);
		}
		
		point.position = sprite.position;
		
		var animFrames = NSMutableArray.array;
		
		var j=0;
		for(j = 0; j < 14; j++) {
			var prefix = (j+1<10) ? '0' : '';
			var name = 'grossini_dance_' + prefix + (j+1) + '.png';
			var frame = cache.spriteFrameByName( name );
			animFrames.addObject( frame );
		}
		var animation = CCAnimation.animationWithSpriteFrames_delay(animFrames, 0.3 );
		sprite.runAction( CCRepeatForever.actionWithAction( CCAnimate.actionWithAnimation( animation ) ) );
		
		// Skew
		var skewX = CCSkewBy.actionWithDuration_skewX_skewY(2, 45, 0 );
		var skewX_back = skewX.reverse;
		var skewY = CCSkewBy.actionWithDuration_skewX_skewY(2, 0 , 45 );
		var skewY_back = skewY.reverse;
		
		var seq_skew = CCSequence.actionsWithArray( [skewX, skewX_back, skewY, skewY_back] );
		sprite.runAction( CCRepeatForever.actionWithAction( seq_skew ) );
		
		// Scale
		var scale = CCScaleBy.actionWithDuration_scale(2, 2);
		var scale_back = scale.reverse;
		var seq_scale = CCSequence.actionsWithArray( [scale, scale_back] );
		sprite.runAction( CCRepeatForever.actionWithAction( seq_scale ) );
		
		spritebatch.addChild_z(sprite, 0);
	}
}
scenes.push( new test_spritebatch_anchorpoint_skew_scale() );


//
// Helper functions
//
function add_menu( parent )
{
	var item1 = CCMenuItemImage.itemWithNormalImage_selectedImage("b1.png", "b2.png");
	var item2 = CCMenuItemImage.itemWithNormalImage_selectedImage("r1.png", "r2.png");
	var item3 = CCMenuItemImage.itemWithNormalImage_selectedImage("f1.png", "f2.png");
	
	item1.setTarget_selector( callback, 'back:');
	item2.setTarget_selector( callback, 'reset:');
	item3.setTarget_selector( callback, 'forward:');
	
	var menu = CCMenu.menuWithArray( [item1, item2, item3] );
	
	menu.position = ccp(0,0);
	item1.position = ccp( winSize.width/2 - item2.contentSize.width*2, item2.contentSize.height/2);
	item2.position = ccp( winSize.width/2, item2.contentSize.height/2);
	item3.position = ccp( winSize.width/2 + item2.contentSize.width*2, item2.contentSize.height/2);
	
	parent.addChild( menu );
}

function add_titles( parent, title, subtitle )
{
	// title
	var label = CCLabelTTF.labelWithString_fontName_fontSize( title, "Arial", 32);
	parent.addChild( label );
	
	label.position = ccp(winSize.width/2, winSize.height-50);
	
	// subtitle
	var l = CCLabelTTF.labelWithString_fontName_fontSize( subtitle, "Thonburi", 16 );
	parent.addChild( l );
	l.position = ccp(winSize.width/2, winSize.height-80);
}

function run()
{
	var scene = CCScene.node;
	var layer = CCLayer.node;
	
	scene.addChild( layer );
	
	var t = scenes[ currentScene ];
	
	add_menu( layer );
	add_titles( layer, t.title, t.subtitle );
	t.test( layer );
	
	director.runWithScene( scene );
}


//
run();

