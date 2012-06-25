// http://www.cocos2d-iphone.org
//
// Javascript Action tests
// Test are coded using Javascript, with the exception of MenuCallback which uses Objective-J to handle the callbacks.
//

require("javascript-spidermonkey/helper.js");

var director = cc.Director.sharedDirector();
var _winSize = director.winSize();
var winSize = {width:_winSize[0], height:_winSize[1]};

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
// SpriteTestDemo
//
//------------------------------------------------------------------
var SpriteTestDemo = function(file) {

	//
	// Init
	//
	var parent = goog.base(this);
	__associateObjWithNative( this, parent );
	this.init();

	//
	// Instanced mehtods
	//

	this.title = function () {
	    return "No title";
	}

	this.subtitle = function () {
	    return "No Subtitle";
	}

}
goog.inherits(SpriteTestDemo, cc.Layer );

SpriteTestDemo.prototype.onEnter = function() {
	var label = cc.LabelTTF.labelWithStringFontnameFontsize(this.title(), "Arial", 28);
	this.addChild(label, 1);
	label.setPosition( cc.p(winSize.width / 2, winSize.height - 50));

	var strSubtitle = this.subtitle();
	if (strSubtitle != "") {
	    var l = cc.LabelTTF.labelWithStringFontnameFontsize(strSubtitle, "Thonburi", 16);
	    this.addChild(l, 1);
	    l.setPosition( cc.p(winSize.width / 2, winSize.height - 80));
	}

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

SpriteTestDemo.prototype.restartCallback = function (sender) {
    cc.log("restart called");
    restartSpriteTestAction();
}

SpriteTestDemo.prototype.nextCallback = function (sender) {
    cc.log("next called");
    nextSpriteTestAction();
}

SpriteTestDemo.prototype.backCallback = function (sender) {
    cc.log("back called");
    backSpriteTestAction();
}



//------------------------------------------------------------------
//
// SpriteColorOpacity
//
//------------------------------------------------------------------
var SpriteColorOpacity = function(file) {
	cc.log("SpriteColorOpacity.init");

	goog.base(this);

	var sprite1 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 0, 121 * 1, 85, 121));
	var sprite2 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 1, 121 * 1, 85, 121));
	var sprite3 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 2, 121 * 1, 85, 121));
	var sprite4 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 3, 121 * 1, 85, 121));
	var sprite5 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 0, 121 * 1, 85, 121));
	var sprite6 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 1, 121 * 1, 85, 121));
	var sprite7 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 2, 121 * 1, 85, 121));
	var sprite8 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 3, 121 * 1, 85, 121));

	sprite1.setPosition(cc.p((winSize.width / 5) * 1, (winSize.height / 3) * 1));
	sprite2.setPosition(cc.p((winSize.width / 5) * 2, (winSize.height / 3) * 1));
	sprite3.setPosition(cc.p((winSize.width / 5) * 3, (winSize.height / 3) * 1));
	sprite4.setPosition(cc.p((winSize.width / 5) * 4, (winSize.height / 3) * 1));
	sprite5.setPosition(cc.p((winSize.width / 5) * 1, (winSize.height / 3) * 2));
	sprite6.setPosition(cc.p((winSize.width / 5) * 2, (winSize.height / 3) * 2));
	sprite7.setPosition(cc.p((winSize.width / 5) * 3, (winSize.height / 3) * 2));
	sprite8.setPosition(cc.p((winSize.width / 5) * 4, (winSize.height / 3) * 2));

	var action = cc.FadeIn.create(2);
	var action_back = action.reverse();
	var fade = cc.RepeatForever.create( cc.Sequence.create( action, action_back ) );

	var tintRed = cc.TintBy.create(2, 0, -255, -255);
//	var tintRed = cc.RotateBy.create(2, 360 );
	var tintRedBack = tintRed.reverse();
	var red = cc.RepeatForever.create(cc.Sequence.create( tintRed, tintRedBack ) );

	var tintGreen = cc.TintBy.create(2, -255, 0, -255);
	var tintGreenBack = tintGreen.reverse();
	var green = cc.RepeatForever.create(cc.Sequence.create( tintGreen, tintGreenBack ) );

	var tintBlue = cc.TintBy.create(2, -255, -255, 0);
	var tintBlueBack = tintBlue.reverse();
	var blue = cc.RepeatForever.create(cc.Sequence.create( tintBlue, tintBlueBack ) );

	sprite5.runAction(red);
	sprite6.runAction(green);
	sprite7.runAction(blue);
	sprite8.runAction(fade);

	// late add: test dirtyColor and dirtyPosition
	this.addChild(sprite1);
	this.addChild(sprite2);
	this.addChild(sprite3);
	this.addChild(sprite4);
	this.addChild(sprite5);
	this.addChild(sprite6);
	this.addChild(sprite7);
	this.addChild(sprite8);

//	this.scheduleUpdate();

	//
	// Instance methods
	//
	this.title = function () {
		return "Sprite: Color & Opacity";
	}

	this.subtitle = function () {
		return "testing opacity and color";
	}

	this.update = function(delta) {
		cc.log("delta: " + delta );
	}
}
goog.inherits(SpriteColorOpacity, SpriteTestDemo );
scenes.push( SpriteColorOpacity );

//------------------------------------------------------------------
//
// SpriteBatchColorOpacity
//
//------------------------------------------------------------------
var SpriteBatchColorOpacity = function(file) {

	goog.base(this);

	var batch = cc.SpriteBatchNode.create('grossini_dance_atlas.png', 10);
	var sprite1 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 0, 121 * 1, 85, 121));
	var sprite2 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 1, 121 * 1, 85, 121));
	var sprite3 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 2, 121 * 1, 85, 121));
	var sprite4 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 3, 121 * 1, 85, 121));
	var sprite5 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 0, 121 * 1, 85, 121));
	var sprite6 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 1, 121 * 1, 85, 121));
	var sprite7 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 2, 121 * 1, 85, 121));
	var sprite8 = cc.Sprite.create('grossini_dance_atlas.png', cc.rect(85 * 3, 121 * 1, 85, 121));

	sprite1.setPosition(cc.p((winSize.width / 5) * 1, (winSize.height / 3) * 1));
	sprite2.setPosition(cc.p((winSize.width / 5) * 2, (winSize.height / 3) * 1));
	sprite3.setPosition(cc.p((winSize.width / 5) * 3, (winSize.height / 3) * 1));
	sprite4.setPosition(cc.p((winSize.width / 5) * 4, (winSize.height / 3) * 1));
	sprite5.setPosition(cc.p((winSize.width / 5) * 1, (winSize.height / 3) * 2));
	sprite6.setPosition(cc.p((winSize.width / 5) * 2, (winSize.height / 3) * 2));
	sprite7.setPosition(cc.p((winSize.width / 5) * 3, (winSize.height / 3) * 2));
	sprite8.setPosition(cc.p((winSize.width / 5) * 4, (winSize.height / 3) * 2));

	var action = cc.FadeIn.create(2);
	var action_back = action.reverse();
	var fade = cc.RepeatForever.create( cc.Sequence.create( action, action_back ) );

	var tintRed = cc.TintBy.create(2, 0, -255, -255);
//	var tintRed = cc.RotateBy.create(2, 360 );
	var tintRedBack = tintRed.reverse();
	var red = cc.RepeatForever.create(cc.Sequence.create( tintRed, tintRedBack ) );

	var tintGreen = cc.TintBy.create(2, -255, 0, -255);
	var tintGreenBack = tintGreen.reverse();
	var green = cc.RepeatForever.create(cc.Sequence.create( tintGreen, tintGreenBack ) );

	var tintBlue = cc.TintBy.create(2, -255, -255, 0);
	var tintBlueBack = tintBlue.reverse();
	var blue = cc.RepeatForever.create(cc.Sequence.create( tintBlue, tintBlueBack ) );

	sprite5.runAction(red);
	sprite6.runAction(green);
	sprite7.runAction(blue);
	sprite8.runAction(fade);

	// late add: test dirtyColor and dirtyPosition
	this.addChild(batch);
	batch.addChild(sprite1);
	batch.addChild(sprite2);
	batch.addChild(sprite3);
	batch.addChild(sprite4);
	batch.addChild(sprite5);
	batch.addChild(sprite6);
	batch.addChild(sprite7);
	batch.addChild(sprite8);

//	this.scheduleUpdate();

	//
	// Instance methods
	//
	this.title = function () {
		return "Sprite Batch: Color & Opacity";
	}

	this.subtitle = function () {
		return "testing opacity and color with batches";
	}

	this.update = function(delta) {
		cc.log("delta: " + delta );
	}
}
goog.inherits(SpriteBatchColorOpacity, SpriteTestDemo );
scenes.push( SpriteBatchColorOpacity );

//------------------------------------------------------------------
//
// Chipmunk + Sprite
//
//------------------------------------------------------------------
var ChipmunkSpriteTest = function(file) {

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
goog.inherits( ChipmunkSpriteTest, SpriteTestDemo );

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
	cc.log('Position: ' + pos);
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

scenes.push( ChipmunkSpriteTest );

//------------------------------------------------------------------
//
// Chipmunk + Sprite
//
//------------------------------------------------------------------
var ChipmunkSpriteBatchTest = function(file) {

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
scenes.push( ChipmunkSpriteBatchTest );


function run()
{
    var scene = new cc.Scene();
    scene.init();
    var layer = new scenes[currentScene]();
    scene.addChild( layer );

    director.runWithScene( scene );
}

run();
