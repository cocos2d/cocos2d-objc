// http://www.cocos2d-iphone.org
//
// Javascript Action tests

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
	var scene = CCScene.node;
	var layer = CCLayer.node;
	
	scene.addChild( layer );
	
	var t = scenes[ sceneNumber ];

	add_menu( layer );
	add_titles( layer, t.title, t.subtitle );
	t.test( layer );
	
	scene.walkSceneGraph(0);
	
	director.replaceScene( scene );
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
//	grossini.color = ccc3( 255,0,0);
	
	
	var kathia = CCSprite.spriteWithFile('grossinis_sister2.png');
	parent.addChild( kathia );
	kathia.position = ccp(winSize.width-100, winSize.height/2);
//	kathia.color = ccBLUE;
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

	scene.walkSceneGraph(0);
	
	director.runWithScene( scene );
}


//
run();
