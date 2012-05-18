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
// Manual Test
//
function test_manual_properties() {
	this.title = "Manual Properties";
	this.subtitle = "Setting sprite properties manually";	
}

test_manual_properties.prototype.test = function( parent ) {
	
	// create sprite
	var tamara = CCSprite.spriteWithFile('grossinis_sister1.png');
	parent.addChild( tamara );
	tamara.scaleX = 2.5;
	tamara.scaleY = -1.0;
	tamara.position = ccp(100,70);
	tamara.opacity = 128;
	
	var grossini = CCSprite.spriteWithFile('grossini.png');
	parent.addChild( grossini );
	grossini.rotation = 120;
	grossini.position = ccp(winSize.width/2, winSize.height/2);
	grossini.color =  ccc3( 255,0,0 );
	
	
	var kathia = CCSprite.spriteWithFile('grossinis_sister2.png');
	parent.addChild( kathia );
	kathia.position = ccp(winSize.width-100, winSize.height/2);
	kathia.color = ccc3(0,0,255);
};

scenes.push( new test_manual_properties() );


//
// Action Move
//
function test_move() {
	this.title = "MoveTo / MoveBy";
	this.subtitle = "Testing MoveTo and MoveBy";	
}

test_move.prototype.test = function( parent ) {
	
	var array = create_sprites( parent, 3 );
	var grossini = array[0];
	var tamara = array[1];
	var kathia = array[2];
	
	var actionTo = CCMoveTo.actionWithDuration_position(2, ccp(winSize.width-40, winSize.height-40) );
	
	var actionBy = CCMoveBy.actionWithDuration_position(2, ccp(80,80) );
	var actionByBack = actionBy.reverse;
//	
	tamara.runAction( actionTo );
	grossini.runAction( CCSequence.actionsWithArray( [actionBy, actionByBack] ) );
	kathia.runAction( CCMoveTo.actionWithDuration_position( 1, ccp(40,40) ) );
}

scenes.push( new test_move() );

//
// Action Rotate
//
function test_rotate() {
	this.title = "RotateTo / RotateBy";
	this.subtitle = "Testing RotateTo / RotateBy actions";	
}

test_rotate.prototype.test = function( parent ) {
	
	var array = create_sprites( parent, 3 );
	var grossini = array[0];
	var tamara = array[1];
	var kathia = array[2];
	
	var actionTo = CCRotateTo.actionWithDuration_angle(2, 45 );
	var actionTo0 = CCRotateTo.actionWithDuration_angle(2, 0 );
	tamara.runAction( CCSequence.actionsWithArray( [actionTo, actionTo0] ) );
	
	var actionBy = CCRotateBy.actionWithDuration_angle( 2, 360 );
	var actionByBack = actionBy.reverse;
	grossini.runAction( CCSequence.actionsWithArray( [actionBy, actionByBack] ) );

	var actionTo2 = CCRotateTo.actionWithDuration_angle(2, -45 );
	kathia.runAction( CCSequence.actionsWithArray( [actionTo2, actionTo0.copy.autorelease ] ) );
}

scenes.push( new test_rotate() );

//
// Action Scale
//
function test_scale() {
	this.title = "ScaleTo / ScaleBy";
	this.subtitle = "Testing ScaleTo / ScaleBy actions";	
}

test_scale.prototype.test = function( parent ) {
	
	var array = create_sprites( parent, 3 );
	var grossini = array[0];
	var tamara = array[1];
	var kathia = array[2];
	
	var actionTo = CCScaleTo.actionWithDuration_scale(2, 0.5 );
	var actionBy = CCScaleBy.actionWithDuration_scaleX_scaleY(2, 1, 10 );
	var actionBy2 = CCScaleBy.actionWithDuration_scaleX_scaleY(2, 5, 1 );
	
	grossini.runAction( actionTo );
	tamara.runAction( CCSequence.actionsWithArray( [actionBy, [actionBy reverse] ] ) );
	
	kathia.runAction( CCSequence.actionsWithArray( [actionBy2, [actionBy2 reverse] ] ) );
}

scenes.push( new test_scale() );

//
// Action Skew
//
function test_skew() {
	this.title = "SkewTo / SkewBy";
	this.subtitle = "Testing SkewTo / SkewBy actions";	
}

test_skew.prototype.test = function( parent ) {
	
	var array = create_sprites( parent, 3 );
	var grossini = array[0];
	var tamara = array[1];
	var kathia = array[2];

	var actionTo = CCSkewTo.actionWithDuration_skewX_skewY(2, 37.2, -37.2);
	var actionToBack = CCSkewTo.actionWithDuration_skewX_skewY(2, 0, 0 );
	var actionBy = CCSkewBy.actionWithDuration_skewX_skewY(2, 0, -90.0 );
	var actionBy2 = CCSkewBy.actionWithDuration_skewX_skewY(2, 45, 45.0 );
	var actionByBack = actionBy.reverse;
	
	tamara.runAction( CCSequence.actionsWithArray( [actionTo, actionToBack] ) );
	grossini.runAction( CCSequence.actionsWithArray( [actionBy, actionByBack ] ) );
	kathia.runAction( CCSequence.actionsWithArray( [actionBy2, [actionBy2 reverse] ] ) );
}

scenes.push( new test_skew() );


//
// CatmullRom
//
function test_catmullrom() {
	this.title = "CatmullRomTo / CatmullRomBy";
	this.subtitle = "Testing CatmullRomTo / CatmullRomBy actions";	
}

test_catmullrom.prototype.test = function( parent ) {
	
	var array = create_sprites( parent, 2 );
	var grossini = array[0];
	var tamara = array[1];
	var kathia = array[2];

	
	//
	// sprite 1 (By)
	//
	// startPosition can be any coordinate, but since the movement
	// is relative to the Catmull Rom curve, it is better to start with (0,0).
	//

	tamara.position = ccp(50,50);

	var array = CCPointArray.arrayWithCapacity( 20 );

	array.addControlPoint( ccp(0,0) );
	array.addControlPoint( ccp(80,80) );
	array.addControlPoint( ccp(winSize.width-80,80) );
	array.addControlPoint( ccp(winSize.width-80,winSize.height-80) );
	array.addControlPoint( ccp(80,winSize.height-80) );
	array.addControlPoint( ccp(80,80) );
	array.addControlPoint( ccp( winSize.width/2, winSize.height/2) );

	var action = CCCatmullRomBy.actionWithDuration_points( 3, array );
	var reverse = action.reverse;

	var seq = CCSequence.actionsWithArray( [action, reverse] );

	tamara.runAction( seq );

	//
	// sprite 2 (To)
	//
	// The startPosition is not important here, because it uses a "To" action.
	// The initial position will be the 1st point of the Catmull Rom path
	//

	var array2 = CCPointArray.arrayWithCapacity( 20 );

	array2.addControlPoint( ccp(winSize.width/2, 30) );
	array2.addControlPoint( ccp(winSize.width-80,30) );
	array2.addControlPoint( ccp(winSize.width-80, winSize.height-80) );
	array2.addControlPoint( ccp(winSize.width/2, winSize.height-80) );
	array2.addControlPoint( ccp(winSize.width/2, 30) );


	var action2 = CCCatmullRomTo.actionWithDuration_points(2, array2 );
	var reverse2 = action2.reverse;

	var seq2 = CCSequence.actionsWithArray( [action2, reverse2] );

	kathia.runAction( seq2 );
}

scenes.push( new test_catmullrom() );

//
// Helper functions
//
function create_sprites( parent, numberOfSprites )
{
	var grossini = CCSprite.spriteWithFile('grossini.png');
	var sister1 = CCSprite.spriteWithFile('grossinis_sister1.png');
	var sister2 = CCSprite.spriteWithFile('grossinis_sister2.png');
	
	parent.addChild( grossini );
	parent.addChild( sister1 );
	parent.addChild( sister2 );
	
	if( numberOfSprites == 0 ) {
		sister1.visible = false;
		sister2.visible = false;
		grossini.visible = false;
	} else if( numberOfSprites == 1 ) {
		sister1.visible = false;
		sister2.visible = false;
		grossini.position = ccp(winSize.width/2, winSize.height/2);
	} else if( numberOfSprites == 2 ) {
		sister2.position = ccp(winSize.width/3, winSize.height/2);
		sister1.position = ccp(2*winSize.width/3, winSize.height/2);
		grossini.visible = false;
	} else if( numberOfSprites == 3 ) {
		grossini.position = ccp(winSize.width/2, winSize.height/2);
		sister1.position = ccp(2*winSize.width/3, winSize.height/2);
		sister2.position = ccp(winSize.width/3, winSize.height/2);
	}
	
	return [grossini, sister1, sister2];
}

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

version = cocos2dVersion();
log('Using cocos2d version:' + version );

//
run();
