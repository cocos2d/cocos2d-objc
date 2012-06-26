//
// http://www.cocos2d-iphone.org
//
// Javascript + chipmunk tests
//

require("javascript-spidermonkey/helper.js");

var director = cc.Director.getInstance();
var _winSize = director.winSize();
var winSize = {width:_winSize[0], height:_winSize[1]};
var centerPos = cc.p( winSize.width/2, winSize.height/2 );

var scenes = []
var currentScene = 0;

var nextSpriteTestAction = function () {
    currentScene = currentScene + 1;
    if( currentScene >= scenes.length )
        currentScene = 0;

    loadScene(currentScene);
};
var backSpriteTestAction = function () {
    currentScene = currentScene -1;
    if( currentScene < 0 )
        currentScene = scenes.length -1;

    loadScene(currentScene);
};
var restartSpriteTestAction = function () {
    loadScene( currentScene );
};

var loadScene = function (sceneIdx)
{
    var scene = new cc.Scene();
    scene.init();
    var layer = new scenes[ sceneIdx ]();

    scene.addChild( layer );

//	scene.walkSceneGraph(0);

    director.replaceScene( scene );
//    __jsc__.garbageCollect();
}

//------------------------------------------------------------------
//
// BaseLayer
//
//------------------------------------------------------------------
var BaseLayer = function() {

	//
	// VERY IMPORTANT
	//
	// Only subclasses of a native classes MUST call __associateObjectWithNative
	// Failure to do so, it will crash.
	//
	var parent = goog.base(this);
	__associateObjWithNative( this, parent );
	this.init();

	this.title = function () {
	    return "No title";
	}

	this.subtitle = function () {
	    return "No Subtitle";
	}

}
goog.inherits(SpriteTestDemo, cc.Layer );

//
// Instance 'base' methods
// XXX: Should be defined after "goog.inherits"
//
BaseLayer.prototype.onEnter = function() {
	var label = cc.LabelTTF.labelWithStringFontnameFontsize(this.title(), "Arial", 28);
	this.addChild(label, 1);
	label.setPosition( cc.p(winSize.width / 2, winSize.height - 50));

	var strSubtitle = this.subtitle();
	if (strSubtitle != "") {
	    var l = cc.LabelTTF.labelWithStringFontnameFontsize(strSubtitle, "Thonburi", 16);
	    this.addChild(l, 1);
	    l.setPosition( cc.p(winSize.width / 2, winSize.height - 80));
	}

	// WARNING: MenuItem API will change!
	var item1 = cc.MenuItemImage.itemWithNormalImageSelectedimageBlock("b1.png", "b2.png", this.backCallback);
	var item2 = cc.MenuItemImage.itemWithNormalImageSelectedimageBlock("r1.png", "r2.png", this.restartCallback);
	var item3 = cc.MenuItemImage.itemWithNormalImageSelectedimageBlock("f1.png", "f2.png", this.nextCallback);

	var menu = cc.Menu.create( item1, item2, item3 );

	menu.setPosition( cc.p(0,0) );
	item1.setPosition( cc.p(winSize.width / 2 - 100, 30));
	item2.setPosition( cc.p(winSize.width / 2, 30));
	item3.setPosition( cc.p(winSize.width / 2 + 100, 30));

	this.addChild(menu, 1);
}

BaseLayer.prototype.restartCallback = function (sender) {
    cc.log("restart called");
    restartSpriteTestAction();
}

BaseLayer.prototype.nextCallback = function (sender) {
    cc.log("next called");
    nextSpriteTestAction();
}

BaseLayer.prototype.backCallback = function (sender) {
    cc.log("back called");
    backSpriteTestAction();
}


//------------------------------------------------------------------
//
// Chipmunk + Sprite
//
//------------------------------------------------------------------
var ChipmunkSpriteTest = function() {

	goog.base(this);

	this.addSprite = function( pos ) {
		var sprite =  this.createPhysicsSprite( pos );
		this.addChild( sprite );
	}

	this.title = function() {
		return 'Chipmunk Sprite Test';
	}

	this.subtitle = function() {
		return 'Chipmunk + cocos2d sprites tests. Tap screen.';
	}

	this.initPhysics();
}
goog.inherits( ChipmunkSpriteTest, BaseLayer );

//
// Instance 'base' methods
// XXX: Should be defined after "goog.inherits"
//

// init physics
ChipmunkSpriteTest.prototype.initPhysics = function() {
	this.space =  cp.spaceNew();
	var staticBody = cp.spaceGetStaticBody( this.space );

	// Walls
	var walls = [cp.segmentShapeNew( staticBody, cp.v(0,0), cp.v(winSize.width,0), 0 ),				// bottom
			cp.segmentShapeNew( staticBody, cp.v(0,winSize.height), cp.v(winSize.width,winSize.height), 0),	// top
			cp.segmentShapeNew( staticBody, cp.v(0,0), cp.v(0,winSize.height), 0),				// left
			cp.segmentShapeNew( staticBody, cp.v(winSize.width,0), cp.v(winSize.width,winSize.height), 0)	// right
			];
	for( var i=0; i < walls.length; i++ ) {
		var wall = walls[i];
		cp.shapeSetElasticity(wall, 1);
		cp.shapeSetFriction(wall, 1);
		cp.spaceAddStaticShape( this.space, wall );
	}

	// Gravity
	cp.spaceSetGravity( this.space, cp.v(0, -100) );
}

ChipmunkSpriteTest.prototype.createPhysicsSprite = function( pos ) {
	var body = cp.bodyNew(1, cp.momentForBox(1, 48, 108) );
	cp.bodySetPos( body, pos );
	cp.spaceAddBody( this.space, body );
	var shape = cp.boxShapeNew( body, 48, 108);
	cp.shapeSetElasticity( shape, 0.5 );
	cp.shapeSetFriction( shape, 0.5 );
	cp.spaceAddShape( this.space, shape );

	var sprite = cc.ChipmunkSprite.create("grossini.png");
	sprite.setBody( body );
	return sprite;
}

ChipmunkSpriteTest.prototype.onEnter = function () {

	goog.base(this, 'onEnter');

	this.scheduleUpdate();
	for(var i=0; i<10; i++) {
		this.addSprite( cp.v(winSize.width/2, winSize.height/2) );
	}

	// Mac only
	this.setIsMouseEnabled( true );
}

ChipmunkSpriteTest.prototype.update = function( delta ) {
	cp.spaceStep( this.space, delta );
}

ChipmunkSpriteTest.prototype.onMouseDown = function( event ) {
	pos = director.convertEventToGL( event );
	cc.log("Mouse Down:" + pos );
	this.addSprite( pos );
}


//------------------------------------------------------------------
//
// Chipmunk + Sprite
//
//------------------------------------------------------------------
var ChipmunkSpriteBatchTest = function() {

	goog.base(this);

	// batch node
	this.batch = cc.SpriteBatchNode.create('grossini.png', 50 );
	this.addChild( this.batch );

	this.addSprite = function( pos ) {
		var sprite =  this.createPhysicsSprite( pos );
		this.batch.addChild( sprite );
	}

	this.title = function() {
		return 'Chipmunk SpriteBatch Test';
	}

	this.subtitle = function() {
		return 'Chipmunk + cocos2d sprite batch tests. Tap screen.';
	}
}
goog.inherits( ChipmunkSpriteBatchTest, ChipmunkSpriteTest );


//
// Order of tests
//
scenes.push( ChipmunkSpriteTest ); scenes.push( ChipmunkSpriteBatchTest );


//------------------------------------------------------------------
//
// Main entry point
//
//------------------------------------------------------------------
function run()
{
    var scene = new cc.Scene();
    scene.init();
    var layer = new scenes[currentScene]();
    scene.addChild( layer );

    director.runWithScene( scene );
}

run();
