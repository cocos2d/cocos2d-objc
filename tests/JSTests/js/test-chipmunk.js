 /*
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 *
 * Chipmunk Demo code:
 *    Original Demo code written in C by Scott Lembcke
 *    Ported to JavaScript by Joseph Gentle
 *    Additions to the demo code by Ricardo Quesada
 */

//
// http://www.cocos2d-iphone.org
//
// Javascript + chipmunk tests
//

require("jsb_constants.js");

director = cc.Director.getInstance();
winSize = director.getWinSize();
centerPos = cc.p( winSize.width/2, winSize.height/2 );

var scenes = [];
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
	winSize = director.getWinSize();
	centerPos = cc.p( winSize.width/2, winSize.height/2 );

	var scene = new cc.Scene();
	scene.init();
	var layer = new scenes[ sceneIdx ]();

	scene.addChild( layer );

//	scene.walkSceneGraph(0);

	director.replaceScene( scene );
	__jsc__.dumpRoot();
    __jsc__.garbageCollect();
};

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
	var parent = cc.base(this);
	__associateObjWithNative( this, parent );
	this.init();

	this.title =  "No title";
	this.subtitle = "No Subtitle";

	// Menu to toggle debug physics on / off
    var item = cc.MenuItemFont.create("Physics On/Off", this, this.onToggleDebug);
    var menu = cc.Menu.create( item );
    this.addChild( menu );
    menu.setPosition( cc._p( winSize.width-100, winSize.height-80 )  );

    // Create the initial space
	this.space = new cp.Space();

	this.setupDebugNode();
};

cc.inherits(BaseLayer, cc.Layer );

BaseLayer.prototype.setupDebugNode = function()
{
    // debug only
	this._debugNode = cc.PhysicsDebugNode.create( this.space.handle );
	this._debugNode.setVisible( false );
	this.addChild( this._debugNode );
};

BaseLayer.prototype.onToggleDebug = function(sender) {
    var state = this._debugNode.getVisible();
    this._debugNode.setVisible( !state );
};

//
// Instance 'base' methods
// XXX: Should be defined after "cc.inherits"
//
BaseLayer.prototype.onEnter = function() {
	var label = cc.LabelTTF.create(this.title, "Arial", 28);
	this.addChild(label, 1);
	label.setPosition( cc.p(winSize.width / 2, winSize.height - 50));

	if (this.subtitle !== "") {
		var l = cc.LabelTTF.create(this.subtitle, "Thonburi", 16);
		this.addChild(l, 1);
		l.setPosition( cc.p(winSize.width / 2, winSize.height - 80));
	}

    // Menu
    var item1 = cc.MenuItemImage.create("b1.png", "b2.png", this, this.onBackCallback);
    var item2 = cc.MenuItemImage.create("r1.png", "r2.png", this, this.onRestartCallback);
    var item3 = cc.MenuItemImage.create("f1.png", "f2.png", this, this.onNextCallback);
    var item4 = cc.MenuItemFont.create("back", this, function() { require("js/main.js"); } );
    item4.setFontSize( 22 );

    var menu = cc.Menu.create(item1, item2, item3, item4 );

    menu.setPosition( cc.p(0,0) );
    item1.setPosition( cc.p(winSize.width / 2 - 100, 30));
    item2.setPosition( cc.p(winSize.width / 2, 30));
    item3.setPosition( cc.p(winSize.width / 2 + 100, 30));
    item4.setPosition( cc.p(winSize.width - 60, winSize.height - 30 ) );

	this.addChild(menu, 1);
};

BaseLayer.prototype.onCleanup = function() {
	// Not compulsory, but recommended: cleanup the scene
	this.unscheduleUpdate();
};

BaseLayer.prototype.onRestartCallback = function (sender) {
	this.onCleanup();
    restartSpriteTestAction();
};

BaseLayer.prototype.onNextCallback = function (sender) {
	this.onCleanup();
    nextSpriteTestAction();
};

BaseLayer.prototype.onBackCallback = function (sender) {
	this.onCleanup();
    backSpriteTestAction();
};

//------------------------------------------------------------------
//
// Chipmunk + Sprite
//
//------------------------------------------------------------------
var ChipmunkSpriteTest = function() {

	cc.base(this);

	this.addSprite = function( pos ) {
		var sprite =  this.createPhysicsSprite( pos );
		this.addChild( sprite );
	};

	this.title = 'Chipmunk Sprite Test';
	this.subtitle = 'Chipmunk + cocos2d sprites tests. Tap screen.';

	this.initPhysics();
};
cc.inherits( ChipmunkSpriteTest, BaseLayer );

//
// Instance 'base' methods
// XXX: Should be defined after "cc.inherits"
//

// init physics
ChipmunkSpriteTest.prototype.initPhysics = function() {
	var space = this.space ;
	var staticBody = space.getStaticBody();

	// Walls
	var walls = [ new cp.SegmentShape( staticBody, cp.v(0,0), cp.v(winSize.width,0), 0 ),				// bottom
			new cp.SegmentShape( staticBody, cp.v(0,winSize.height), cp.v(winSize.width,winSize.height), 0),	// top
			new cp.SegmentShape( staticBody, cp.v(0,0), cp.v(0,winSize.height), 0),				// left
			new cp.SegmentShape( staticBody, cp.v(winSize.width,0), cp.v(winSize.width,winSize.height), 0)	// right
			];
	for( var i=0; i < walls.length; i++ ) {
		var shape = walls[i];
		shape.setElasticity(1);
		shape.setFriction(1);
		space.addStaticShape( shape );
	}

	// Gravity
	space.gravity = cp.v(0, -100);
};

ChipmunkSpriteTest.prototype.createPhysicsSprite = function( pos ) {
	var body = new cp.Body(1, cp.momentForBox(1, 48, 108) );
	body.setPos( pos );
	this.space.addBody( body );
	var shape = new cp.BoxShape( body, 48, 108);
	shape.setElasticity( 0.5 );
	shape.setFriction( 0.5 );
	this.space.addShape( shape );

	var sprite = cc.PhysicsSprite.create("grossini.png");
	sprite.setBody( body.handle );
	return sprite;
};

ChipmunkSpriteTest.prototype.onEnter = function () {

	cc.base(this, 'onEnter');

	this.scheduleUpdate();
	for(var i=0; i<10; i++) {
		this.addSprite( cp.v(winSize.width/2, winSize.height/2) );
	}

    var t = cc.config.deviceType;
    if( t == 'browser' )  {
        // this.setTouchEnabled(true);
        // this.setKeyboardEnabled(true);
    } else if( t == 'desktop' ) {
        this.setMouseEnabled(true);
    } else if( t == 'mobile' ) {
        this.setTouchEnabled(true);
    }
};

ChipmunkSpriteTest.prototype.update = function( delta ) {
	this.space.step( delta );
};

ChipmunkSpriteTest.prototype.onMouseDown = function( event ) {
	this.addSprite( event.getLocation() );
};

ChipmunkSpriteTest.prototype.onTouchesEnded = function( touches, event ) {
	var l = touches.length;
	for( var i=0; i < l; i++) {
		this.addSprite( touches[i].getLocation() );
	}
};

//------------------------------------------------------------------
//
// Chipmunk + Sprite + Batch
//
//------------------------------------------------------------------
var ChipmunkSpriteBatchTest = function() {

	cc.base(this);

	// batch node
	this.batch = cc.SpriteBatchNode.create('grossini.png', 50 );
	this.addChild( this.batch );

	this.addSprite = function( pos ) {
		var sprite =  this.createPhysicsSprite( pos );
		this.batch.addChild( sprite );
	};

	this.title = 'Chipmunk SpriteBatch Test';
	this.subtitle = 'Chipmunk + cocos2d sprite batch tests. Tap screen.';
};
cc.inherits( ChipmunkSpriteBatchTest, ChipmunkSpriteTest );


//------------------------------------------------------------------
//
// Chipmunk Collision Test
// Using Object Oriented API.
// Base your samples on the "Object Oriented" API.
//
//------------------------------------------------------------------
var ChipmunkCollisionTest = function() {

	cc.base(this);

	this.title = 'Chipmunk Collision test';
	this.subtitle = 'Using Object Oriented API. ** Use this API **';

	// init physics
	this.initPhysics = function() {
		var staticBody = this.space.staticBody;

		// Walls
		var walls = [ new cp.SegmentShape( staticBody, cp.v(0,0), cp.v(winSize.width,0), 0 ),				// bottom
				new cp.SegmentShape( staticBody, cp.v(0,winSize.height), cp.v(winSize.width,winSize.height), 0),	// top
				new cp.SegmentShape( staticBody, cp.v(0,0), cp.v(0,winSize.height), 0),				// left
				new cp.SegmentShape( staticBody, cp.v(winSize.width,0), cp.v(winSize.width,winSize.height), 0)	// right
				];
		for( var i=0; i < walls.length; i++ ) {
			var wall = walls[i];
			wall.setElasticity(1);
			wall.setFriction(1);
			this.space.addStaticShape( wall );
		}

		// Gravity:
		// testing properties
		this.space.gravity = cp.v(0,-100);
		this.space.iterations = 15;
	};

	this.createPhysicsSprite = function( pos, file, collision_type ) {
		var body = new cp.Body(1, cp.momentForBox(1, 48, 108) );
		body.setPos(pos);
		this.space.addBody(body);
		var shape = new cp.BoxShape( body, 48, 108);
		shape.setElasticity( 0.5 );
		shape.setFriction( 0.5 );
		shape.setCollisionType( collision_type );
		this.space.addShape( shape );

		var sprite = cc.PhysicsSprite.create(file);
		sprite.setBody( body.handle );
		return sprite;
	};

	this.onEnter = function () {
		cc.base(this, 'onEnter');

        this.initPhysics();
		this.scheduleUpdate();

		var sprite1 = this.createPhysicsSprite( cc.p(winSize.width/2, winSize.height-20), "grossini.png", 1);
		var sprite2 = this.createPhysicsSprite( cc.p(winSize.width/2, 50), "grossinis_sister1.png", 2);

		this.addChild( sprite1 );
		this.addChild( sprite2 );

		this.space.addCollisionHandler( 1, 2,
			this.collisionBegin.bind(this),
			this.collisionPre.bind(this),
			this.collisionPost.bind(this),
			this.collisionSeparate.bind(this)
			);
	};

	this.onExit = function() {
		this.space.removeCollisionHandler( 1, 2 );
	};

	this.update = function( delta ) {
		this.space.step( delta );
	};

	this.collisionBegin = function ( arbiter, space ) {

		if( ! this.messageDisplayed ) {
			var label = cc.LabelBMFont.create("Collision Detected", "bitmapFontTest5.fnt");
			this.addChild( label );
			label.setPosition( centerPos );
			this.messageDisplayed = true;
		}
		cc.log('collision begin');
		// var bodies = arbiter.getBodies();
		var shapes = arbiter.getShapes();
		var collTypeA = shapes[0].getCollisionType();
		var collTypeB = shapes[1].getCollisionType();
		cc.log( 'Collision Type A:' + collTypeA );
		cc.log( 'Collision Type B:' + collTypeB );
		return true;
	};

	this.collisionPre = function ( arbiter, space ) {
		cc.log('collision pre');
		return true;
	};

	this.collisionPost = function ( arbiter, space ) {
		cc.log('collision post');
	};

	this.collisionSeparate = function ( arbiter, space ) {
		cc.log('collision separate');
	};

};
cc.inherits( ChipmunkCollisionTest, BaseLayer );


//------------------------------------------------------------------
//
// Chipmunk Collision Test
// Using "C" API.
// XXX  DO NOT USE THE "C" API.
// XXX  IT WAS ADDED FOR TESTING PURPOSES ONLY
//
//------------------------------------------------------------------
var ChipmunkCollisionTestB = function() {

	cc.base(this);

	this.messageDisplayed = false;

	this.title = 'Chipmunk Collision Test';
	this.subtitle = 'using "C"-like API. ** DO NOT USE THIS API **';

	// init physics
	this.initPhysics = function() {
		this.space =  cp.spaceNew();

		// update Physics Debug Node with new space
		this._debugNode.setSpace(this.space);

		var staticBody = cp.spaceGetStaticBody( this.space );

		// Walls using "C" API. DO NO USE THIS API
		var walls = [cp.segmentShapeNew( staticBody, cp.v(0,0), cp.v(winSize.width,0), 0 ),				// bottom
				cp.segmentShapeNew( staticBody, cp.v(0,winSize.height), cp.v(winSize.width,winSize.height), 0),	// top
				cp.segmentShapeNew( staticBody, cp.v(0,0), cp.v(0,winSize.height), 0),				// left
				cp.segmentShapeNew( staticBody, cp.v(winSize.width,0), cp.v(winSize.width,winSize.height), 0)	// right
				];

		for( var i=0; i < walls.length; i++ ) {
			// 'properties' using "C" API. DO NO USE THIS API
			var wall = walls[i];
			cp.shapeSetElasticity(wall, 1);
			cp.shapeSetFriction(wall, 1);
			cp.spaceAddStaticShape( this.space, wall );
		}

		// Gravity
		cp.spaceSetGravity( this.space, cp.v(0, -30) );
	};

	this.createPhysicsSprite = function( pos, file, collision_type ) {
		// using "C" API. DO NO USE THIS API
		var body = cp.bodyNew(1, cp.momentForBox(1, 48, 108) );
		cp.bodySetPos( body, pos );
		cp.spaceAddBody( this.space, body );
		var shape = cp.boxShapeNew( body, 48, 108);
		cp.shapeSetElasticity( shape, 0.5 );
		cp.shapeSetFriction( shape, 0.5 );
		cp.shapeSetCollisionType( shape, collision_type );
		cp.spaceAddShape( this.space, shape );

		var sprite = cc.PhysicsSprite.create(file);
		sprite.setBody( body );
		return sprite;
	};

	this.onEnter = function () {
		cc.base(this, 'onEnter');

        this.initPhysics();
		this.scheduleUpdate();

		var sprite1 = this.createPhysicsSprite( cc.p(winSize.width/2, winSize.height-20), "grossini.png", 1);
		var sprite2 = this.createPhysicsSprite( cc.p(winSize.width/2, 50), "grossinis_sister1.png", 2);

		this.addChild( sprite1 );
		this.addChild( sprite2 );

		cp.spaceAddCollisionHandler( this.space, 1, 2,
			this.collisionBegin.bind(this),
			this.collisionPre.bind(this),
			this.collisionPost.bind(this),
			this.collisionSeparate.bind(this) );
	};

	this.onExit = function() {
		cp.spaceRemoveCollisionHandler( this.space, 1, 2 );
        cp.spaceFree( this.space );
	};

	this.update = function( delta ) {
		cp.spaceStep( this.space, delta );
	};

	this.collisionBegin = function ( arbiter, space ) {

		if( ! this.messageDisplayed ) {
			var label = cc.LabelBMFont.create("Collision Detected", "bitmapFontTest5.fnt");
			this.addChild( label );
			label.setPosition( centerPos );
			this.messageDisplayed = true;
		}
		cc.log('collision begin');
		var bodies = cp.arbiterGetBodies( arbiter );
		var shapes = cp.arbiterGetShapes( arbiter );
		var collTypeA = cp.shapeGetCollisionType( shapes[0] );
		var collTypeB = cp.shapeGetCollisionType( shapes[1] );
		cc.log( 'Collision Type A:' + collTypeA );
		cc.log( 'Collision Type B:' + collTypeB );
		return true;
	};

	this.collisionPre = function ( arbiter, space ) {
		cc.log('collision pre');
		return true;
	};

	this.collisionPost = function ( arbiter, space ) {
		cc.log('collision post');
	};

	this.collisionSeparate = function ( arbiter, space ) {
		cc.log('collision separate');
	};

};
cc.inherits( ChipmunkCollisionTestB, BaseLayer );


//------------------------------------------------------------------
//
// Chipmunk Collision Memory Leak Test
//
//------------------------------------------------------------------
var ChipmunkCollisionMemoryLeakTest = function() {

	cc.base(this);

	this.title = 'Chipmunk Memory Leak Test';
	this.subtitle = 'Testing possible memory leak on the collision handler. No visual feedback';

	this.collisionBegin = function ( arbiter, space ) {
		return true;
	};

	this.collisionPre = function ( arbiter, space ) {
		return true;
	};

	this.collisionPost = function ( arbiter, space ) {
		cc.log('collision post');
	};

	this.collisionSeparate = function ( arbiter, space ) {
		cc.log('collision separate');
	};

    this.onEnter = function() {
        cc.base(this, 'onEnter');

        for( var i=1 ; i < 100 ; i++ )
            this.space.addCollisionHandler( i, i+1,
				this.collisionBegin.bind(this),
				this.collisionPre.bind(this),
				this.collisionPost.bind(this),
				this.collisionSeparate.bind(this)
				);

    };

	this.onExit = function() {

        for( var i=1 ; i < 100 ; i++ )
            this.space.removeCollisionHandler( i, i+1 );
	};
};
cc.inherits( ChipmunkCollisionMemoryLeakTest, BaseLayer );


//
// Base class for Chipmunk Demo
//
// Chipmunk Demos from Chipmunk-JS project
// https://github.com/josephg/chipmunk-js
//

var v = cp.v;
var ctx;
var GRABABLE_MASK_BIT = 1<<31;
var NOT_GRABABLE_MASK = ~GRABABLE_MASK_BIT;

var ChipmunkDemo = function() {

	cc.base(this);

	this.remainder = 0;

	// debug only
	this._debugNode.setVisible( true );

	this.scheduleUpdate();
};
cc.inherits( ChipmunkDemo, BaseLayer );

ChipmunkDemo.prototype.update = function(dt) {
	this.space.step(dt);
};

ChipmunkDemo.prototype.addFloor = function() {
	var space = this.space;
	var floor = space.addShape(new cp.SegmentShape(space.staticBody, v(0, 0), v(640, 0), 0));
	floor.setElasticity(1);
	floor.setFriction(1);
	floor.setLayers(NOT_GRABABLE_MASK);
};

ChipmunkDemo.prototype.addWalls = function() {
	var space = this.space;
	var wall1 = space.addShape(new cp.SegmentShape(space.staticBody, v(0, 0), v(0, 480), 0));
	wall1.setElasticity(1);
	wall1.setFriction(1);
	wall1.setLayers(NOT_GRABABLE_MASK);

	var wall2 = space.addShape(new cp.SegmentShape(space.staticBody, v(640, 0), v(640, 480), 0));
	wall2.setElasticity(1);
	wall2.setFriction(1);
	wall2.setLayers(NOT_GRABABLE_MASK);
};

//------------------------------------------------------------------
//
// Chipmunk Demo: Pyramid Stack
//
//------------------------------------------------------------------
var PyramidStack = function() {

	cc.base(this);
	this.title = 'Chipmunk Demo';
	this.subtitle = 'Pyramid Stack';

	var space = this.space;
	//space.iterations = 30;
	space.gravity = v(0, -100);
	space.sleepTimeThreshold = 0.5;
	space.collisionSlop = 0.5;

	var body, staticBody = space.staticBody;
	var shape;
	
	this.addFloor();
	this.addWalls();
	
	// Add lots of boxes.
	for(var i=0; i<14; i++){
		for(var j=0; j<=i; j++){
			body = space.addBody(new cp.Body(1, cp.momentForBox(1, 30, 30)));
			body.setPos(v(j*32 - i*16 + 320, 540 - i*32));
			
			shape = space.addShape(new cp.BoxShape(body, 30, 30));
			shape.setElasticity(0);
			shape.setFriction(0.8);
		}
	}
	
	// Add a ball to make things more interesting
	var radius = 15;
	body = space.addBody(new cp.Body(10, cp.momentForCircle(10, 0, radius, v(0,0))));
	body.setPos(v(320, radius+5));

	shape = space.addShape(new cp.CircleShape(body, radius, v(0,0)));
	shape.setElasticity(0);
	shape.setFriction(0.9);
};
cc.inherits( PyramidStack, ChipmunkDemo );


//------------------------------------------------------------------
//
// Chipmunk Demo: Pyramid Topple
//
//------------------------------------------------------------------
var PyramidTopple = function() {

	cc.base(this);
	this.title = 'Chipmunk Demo';
	this.subtitle = 'Pyramid Topple';

	var WIDTH = 4;
	var HEIGHT = 30;

	var space = this.space;
	
	var add_domino = function(pos, flipped)
	{
		var mass = 1;
		var moment = cp.momentForBox(mass, WIDTH, HEIGHT);
		
		var body = space.addBody(new cp.Body(mass, moment));
		body.setPos(pos);

		var shape = (flipped ? new cp.BoxShape(body, HEIGHT, WIDTH) : new cp.BoxShape(body, WIDTH, HEIGHT));
		space.addShape(shape);
		shape.setElasticity(0);
		shape.setFriction(0.6);
	};

	space.iterations = 30;
	space.gravity = v(0, -300);
	space.sleepTimeThreshold = 0.5;
	space.collisionSlop = 0.5;
	
	this.addFloor();
	
	// Add the dominoes.
	var n = 12;
	for(var i=0; i<n; i++){
		for(var j=0; j<(n - i); j++){
			var offset = v(320 + (j - (n - 1 - i)*0.5)*1.5*HEIGHT, (i + 0.5)*(HEIGHT + 2*WIDTH) - WIDTH);
			add_domino(offset, false);
			add_domino(cp.v.add(offset, v(0, (HEIGHT + WIDTH)/2)), true);
			
			if(j === 0){
				add_domino(cp.v.add(offset, v(0.5*(WIDTH - HEIGHT), HEIGHT + WIDTH)), false);
			}
			
			if(j != n - i - 1){
				add_domino(cp.v.add(offset, v(HEIGHT*0.75, (HEIGHT + 3*WIDTH)/2)), true);
			} else {
				add_domino(cp.v.add(offset, v(0.5*(HEIGHT - WIDTH), HEIGHT + WIDTH)), false);
			}
		}
	}
};

cc.inherits( PyramidTopple, ChipmunkDemo );

PyramidTopple.prototype.update = function(dt)
{
	var steps = 3;
	dt /= steps;
	for (var i = 0; i < 3; i++){
		this.space.step(dt);
	}
};

//------------------------------------------------------------------
//
// Chipmunk Demo: Joints
//
//------------------------------------------------------------------
var Joints = function() {
	cc.base(this);
	this.title = 'Chipmunk Demo';
	this.subtitle = 'Joints';

	var space = this.space;
	var boxOffset;

	var addBall = function(pos)
	{
		var radius = 15;
		var mass = 1;
		var body = space.addBody(new cp.Body(mass, cp.momentForCircle(mass, 0, radius, v(0,0))));
		body.setPos(v.add(pos, boxOffset));
		
		var shape = space.addShape(new cp.CircleShape(body, radius, v(0,0)));
		shape.setElasticity(0);
		shape.setFriction(0.7);
		
		return body;
	};

	var addLever = function(pos)
	{
		var mass = 1;
		var a = v(0,  15);
		var b = v(0, -15);
		
		var body = space.addBody(new cp.Body(mass, cp.momentForSegment(mass, a, b)));
		body.setPos(v.add(pos, v.add(boxOffset, v(0, -15))));
		
		var shape = space.addShape(new cp.SegmentShape(body, a, b, 5));
		shape.setElasticity(0);
		shape.setFriction(0.7);
		
		return body;
	};

	var addBar = function(pos)
	{
		var mass = 2;
		var a = v(0,  30);
		var b = v(0, -30);
		
		var body = space.addBody(new cp.Body(mass, cp.momentForSegment(mass, a, b)));
		body.setPos(v.add(pos, boxOffset));
		
		var shape = space.addShape(new cp.SegmentShape(body, a, b, 5));
		shape.setElasticity(0);
		shape.setFriction(0.7);
		
		return body;
	};

	var addWheel = function(pos)
	{
		var radius = 15;
		var mass = 1;
		var body = space.addBody(new cp.Body(mass, cp.momentForCircle(mass, 0, radius, v(0,0))));
		body.setPos(v.add(pos, boxOffset));
		
		var shape = space.addShape(new cp.CircleShape(body, radius, v(0,0)));
		shape.setElasticity(0);
		shape.setFriction(0.7);
		shape.group = 1; // use a group to keep the car parts from colliding
		
		return body;
	};

	var addChassis = function(pos)
	{
		var mass = 5;
		var width = 80;
		var height = 30;
		
		var body = space.addBody(new cp.Body(mass, cp.momentForBox(mass, width, height)));
		body.setPos(v.add(pos, boxOffset));
		
		var shape = space.addShape(new cp.BoxShape(body, width, height));
		shape.setElasticity(0);
		shape.setFriction(0.7);
		shape.group = 1; // use a group to keep the car parts from colliding
		
		return body;
	};

	space.iterations = 10;
	space.gravity = v(0, -100);
	space.sleepTimeThreshold = 0.5;
	
	var staticBody = space.staticBody;
	var shape;
	
	for(var y = 480; y >= 0; y -= 120) {
		shape = space.addShape(new cp.SegmentShape(staticBody, v(0,y), v(640,y), 0));
		shape.setElasticity(1);
		shape.setFriction(1);
		shape.layers = NOT_GRABABLE_MASK;
	}

	for(var x = 0; x <= 640; x += 160) {
		shape = space.addShape(new cp.SegmentShape(staticBody, v(x,0), v(x,480), 0));
		shape.setElasticity(1);
		shape.setFriction(1);
		shape.layers = NOT_GRABABLE_MASK;
	}
	
	var body1, body2;
	
	var posA = v( 50, 60);
	var posB = v(110, 60);
	
	var POS_A = function() { return v.add(boxOffset, posA); };
	var POS_B = function() { return v.add(boxOffset, posB); };
	//#define POS_A vadd(boxOffset, posA)
	//#define POS_B vadd(boxOffset, posB)
	
	this.labels = labels = [];
	var label = function(text) {
		labels.push({text:text, pos:boxOffset});
	};

	// Pin Joints - Link shapes with a solid bar or pin.
	// Keeps the anchor points the same distance apart from when the joint was created.
	boxOffset = v(0, 0);
	label('Pin Joint');
	body1 = addBall(posA);
	body2 = addBall(posB);
	body2.setAngle(Math.PI);
	space.addConstraint(new cp.PinJoint(body1, body2, v(15,0), v(15,0)));
	
	// Slide Joints - Like pin joints but with a min/max distance.
	// Can be used for a cheap approximation of a rope.
	boxOffset = v(160, 0);
	label('Slide Joint');
	body1 = addBall(posA);
	body2 = addBall(posB);
	body2.setAngle(Math.PI);
	space.addConstraint(new cp.SlideJoint(body1, body2, v(15,0), v(15,0), 20, 40));
	
	// Pivot Joints - Holds the two anchor points together. Like a swivel.
	boxOffset = v(320, 0);
	label('Pivot Joint');
	body1 = addBall(posA);
	body2 = addBall(posB);
	body2.setAngle(Math.PI);
	// cp.PivotJoint(a, b, v) takes it's anchor parameter in world coordinates. The anchors are calculated from that
	// Alternately, specify two anchor points using cp.PivotJoint(a, b, anch1, anch2)
	space.addConstraint(new cp.PivotJoint(body1, body2, v.add(boxOffset, v(80,60))));
	
	// Groove Joints - Like a pivot joint, but one of the anchors is a line segment that the pivot can slide in
	boxOffset = v(480, 0);
	label('Groove Joint');
	body1 = addBall(posA);
	body2 = addBall(posB);
	space.addConstraint(new cp.GrooveJoint(body1, body2, v(30,30), v(30,-30), v(-30,0)));
	
	// Damped Springs
	boxOffset = v(0, 120);
	label('Damped Spring');
	body1 = addBall(posA);
	body2 = addBall(posB);
	body2.setAngle(Math.PI);
	space.addConstraint(new cp.DampedSpring(body1, body2, v(15,0), v(15,0), 20, 5, 0.3));
	
	// Damped Rotary Springs
	boxOffset = v(160, 120);
	label('Damped Rotary Spring');
	body1 = addBar(posA);
	body2 = addBar(posB);
	// Add some pin joints to hold the circles in place.
	space.addConstraint(new cp.PivotJoint(body1, staticBody, POS_A()));
	space.addConstraint(new cp.PivotJoint(body2, staticBody, POS_B()));
	space.addConstraint(new cp.DampedRotarySpring(body1, body2, 0, 3000, 60));
	
	// Rotary Limit Joint
	boxOffset = v(320, 120);
	label('Rotary Limit Joint');
	body1 = addLever(posA);
	body2 = addLever(posB);
	// Add some pin joints to hold the circles in place.
	space.addConstraint(new cp.PivotJoint(body1, staticBody, POS_A()));
	space.addConstraint(new cp.PivotJoint(body2, staticBody, POS_B()));
	// Hold their rotation within 90 degrees of each other.
	space.addConstraint(new cp.RotaryLimitJoint(body1, body2, -Math.PI/2, Math.PI/2));
	
	// Ratchet Joint - A rotary ratchet, like a socket wrench
	boxOffset = v(480, 120);
	label('Ratchet Joint');
	body1 = addLever(posA);
	body2 = addLever(posB);
	// Add some pin joints to hold the circles in place.
	space.addConstraint(new cp.PivotJoint(body1, staticBody, POS_A()));
	space.addConstraint(new cp.PivotJoint(body2, staticBody, POS_B()));
	// Ratchet every 90 degrees
	space.addConstraint(new cp.RatchetJoint(body1, body2, 0, Math.PI/2));
	
	// Gear Joint - Maintain a specific angular velocity ratio
	boxOffset = v(0, 240);
	label('Gear Joint');
	body1 = addBar(posA);
	body2 = addBar(posB);
	// Add some pin joints to hold the circles in place.
	space.addConstraint(new cp.PivotJoint(body1, staticBody, POS_A()));
	space.addConstraint(new cp.PivotJoint(body2, staticBody, POS_B()));
	// Force one to sping 2x as fast as the other
	space.addConstraint(new cp.GearJoint(body1, body2, 0, 2));
	
	// Simple Motor - Maintain a specific angular relative velocity
	boxOffset = v(160, 240);
	label('Simple Motor');
	body1 = addBar(posA);
	body2 = addBar(posB);
	// Add some pin joints to hold the circles in place.
	space.addConstraint(new cp.PivotJoint(body1, staticBody, POS_A()));
	space.addConstraint(new cp.PivotJoint(body2, staticBody, POS_B()));
	// Make them spin at 1/2 revolution per second in relation to each other.
	space.addConstraint(new cp.SimpleMotor(body1, body2, Math.PI));
	
	// Make a car with some nice soft suspension
	boxOffset = v(320, 240);
	var wheel1 = addWheel(posA);
	var wheel2 = addWheel(posB);
	var chassis = addChassis(v(80, 100));
	
	space.addConstraint(new cp.GrooveJoint(chassis, wheel1, v(-30, -10), v(-30, -40), v(0,0)));
	space.addConstraint(new cp.GrooveJoint(chassis, wheel2, v( 30, -10), v( 30, -40), v(0,0)));
	
	space.addConstraint(new cp.DampedSpring(chassis, wheel1, v(-30, 0), v(0,0), 50, 20, 10));
	space.addConstraint(new cp.DampedSpring(chassis, wheel2, v( 30, 0), v(0,0), 50, 20, 10));
};

cc.inherits( Joints, ChipmunkDemo );


//------------------------------------------------------------------
//
// Chipmunk Demo: Balls
//
//------------------------------------------------------------------
var Balls = function() {
	cc.base(this);
	this.title = 'Chipmunk Demo';
	this.subtitle = 'Balls';

	var space = this.space;
	space.iterations = 60;
	space.gravity = v(0, -500);
	space.sleepTimeThreshold = 0.5;
	space.collisionSlop = 0.5;
	space.sleepTimeThreshold = 0.5;

	this.addFloor();
	this.addWalls();

	var width = 50;
	var height = 60;
	var mass = width * height * 1/1000;
	var rock = space.addBody(new cp.Body(mass, cp.momentForBox(mass, width, height)));
	rock.setPos(v(500, 100));
	rock.setAngle(1);
	shape = space.addShape(new cp.BoxShape(rock, width, height));
	shape.setFriction(0.3);
	shape.setElasticity(0.3);

	for (var i = 1; i <= 10; i++) {
		var radius = 20;
		mass = 3;
		var body = space.addBody(new cp.Body(mass, cp.momentForCircle(mass, 0, radius, v(0, 0))));
		body.setPos(v(200 + i, (2 * radius + 5) * i));
		var circle = space.addShape(new cp.CircleShape(body, radius, v(0, 0)));
		circle.setElasticity(0.8);
		circle.setFriction(1);
	}
/*
 * atom.canvas.onmousedown = function(e) {
      radius = 10;
      mass = 3;
      body = space.addBody(new cp.Body(mass, cp.momentForCircle(mass, 0, radius, v(0, 0))));
      body.setPos(v(e.clientX, e.clientY));
      circle = space.addShape(new cp.CircleShape(body, radius, v(0, 0)));
      circle.setElasticity(0.5);
      return circle.setFriction(1);
    };
*/

	// this.ctx.strokeStyle = "black";

	var ramp = space.addShape(new cp.SegmentShape(space.staticBody, v(100, 100), v(300, 200), 10));
	ramp.setElasticity(1);
	ramp.setFriction(1);
	ramp.setLayers(NOT_GRABABLE_MASK);
};
cc.inherits( Balls, ChipmunkDemo );


//------------------------------------------------------------------
//
// Buoyancy
//
//------------------------------------------------------------------

var FLUID_DENSITY = 0.00014;
var FLUID_DRAG = 2.0;

var Buoyancy = function() {
	cc.base(this);
	this.title = 'Chipmunk Demo';
	this.subtitle = 'Buoyancy';

	var space = this.space;
	space.iterations = 30;
	space.gravity = cp.v(0,-500);
//	cpSpaceSetDamping(space, 0.5);
	space.sleepTimeThreshold = 0.5;
	space.collisionSlop = 0.5;
	
	var staticBody = space.staticBody;
	
	// Create segments around the edge of the screen.
	var shape = space.addShape( new cp.SegmentShape(staticBody, cp.v(0,0), cp.v(0,480), 0.0));
	shape.setElasticity(1.0);
	shape.setFriction(1.0);
	shape.setLayers(NOT_GRABABLE_MASK);

	shape = space.addShape( new cp.SegmentShape(staticBody, cp.v(640,0), cp.v(640,480), 0.0));
	shape.setElasticity(1.0);
	shape.setFriction(1.0);
	shape.setLayers(NOT_GRABABLE_MASK);

	shape = space.addShape( new cp.SegmentShape(staticBody, cp.v(0,0), cp.v(640,0), 0.0));
	shape.setElasticity(1.0);
	shape.setFriction(1.0);
	shape.setLayers(NOT_GRABABLE_MASK);
	
	shape = space.addShape( new cp.SegmentShape(staticBody, cp.v(0,480), cp.v(640,480), 0.0));
	shape.setElasticity(1.0);
	shape.setFriction(1.0);
	shape.setLayers(NOT_GRABABLE_MASK);
	
	// {
		// Add the edges of the bucket
		var bb = new cp.BB(20, 40, 420, 240);
		var radius = 5.0;
		
		shape = space.addShape( new cp.SegmentShape(staticBody, cp.v(bb.l, bb.b), cp.v(bb.l, bb.t), radius));
		shape.setElasticity(1.0);
		shape.setFriction(1.0);
		shape.setLayers(NOT_GRABABLE_MASK);

		shape = space.addShape( new cp.SegmentShape(staticBody, cp.v(bb.r, bb.b), cp.v(bb.r, bb.t), radius));
		shape.setElasticity(1.0);
		shape.setFriction(1.0);
		shape.setLayers(NOT_GRABABLE_MASK);

		shape = space.addShape( new cp.SegmentShape(staticBody, cp.v(bb.l, bb.b), cp.v(bb.r, bb.b), radius));
		shape.setElasticity(1.0);
		shape.setFriction(1.0);
		shape.setLayers(NOT_GRABABLE_MASK);
		
		// Add the sensor for the water.
		shape = space.addShape( new cp.BoxShape2(staticBody, bb) );
		shape.setSensor(true);
		shape.setCollisionType(1);
	// }


	// {
		var width = 200.0;
		var height = 50.0;
		var mass = 0.3*FLUID_DENSITY*width*height;
		var moment = cp.momentForBox(mass, width, height);
		
		body = space.addBody( new cp.Body(mass, moment));
		body.setPos( cp.v(270, 140));
		body.setVel( cp.v(0, -100));
		body.setAngVel( 1 );
		
		shape = space.addShape( new cp.BoxShape(body, width, height));
		shape.setFriction(0.8);
	// }
	
	// {
		width = 40.0;
		height = width*2;
		mass = 0.3*FLUID_DENSITY*width*height;
		moment = cp.momentForBox(mass, width, height);
		
		body = space.addBody( new cp.Body(mass, moment));
		body.setPos(cp.v(120, 190));
		body.setVel(cp.v(0, -100));
		body.setAngVel(1);
		
		shape = space.addShape(new cp.BoxShape(body, width, height));
		shape.setFriction(0.8);
	// }
	
	space.addCollisionHandler( 1, 0, null, this.waterPreSolve, null, null);
};
cc.inherits( Buoyancy, ChipmunkDemo );

Buoyancy.prototype.update = function(dt)
{
	var steps = 3;
	dt /= steps;
	for (var i = 0; i < 3; i++){
		this.space.step(dt);
	}
};

Buoyancy.prototype.waterPreSolve = function(arb, space, ptr) {
	
	var shapes = arb.getShapes();
	var water = shapes[0];
	var poly = shapes[1];

	var body = poly.getBody();

	// Get the top of the water sensor bounding box to use as the water level.
	var level = water.getBB().t;

	// Clip the polygon against the water level
	var count = poly.getNumVerts();

	var clipped = [];

	var j=count-1;
	for(var i=0; i<count; i++) {
		var a = body.local2World( poly.getVert(j));
		var b = body.local2World( poly.getVert(i));

		if(a.y < level){
			clipped.push( a.x );
			clipped.push( a.y );
		}
		
		var a_level = a.y - level;
		var b_level = b.y - level;
		
		if(a_level*b_level < 0.0){
			var t = Math.abs(a_level)/(Math.abs(a_level) + Math.abs(b_level));
			
			var v = cp.v.lerp(a, b, t);
			clipped.push(v.x);
			clipped.push(v.y);
		}
		j=i;
	}

	// Calculate buoyancy from the clipped polygon area
	var clippedArea = cp.areaForPoly(clipped);

	var displacedMass = clippedArea*FLUID_DENSITY;
	var centroid = cp.centroidForPoly(clipped);
	var r = cp.v.sub(centroid, body.getPos());

	var dt = space.getCurrentTimeStep();
	var g = space.gravity;
	
	// Apply the buoyancy force as an impulse.
	body.applyImpulse( cp.v.mult(g, -displacedMass*dt), r);
	
	// Apply linear damping for the fluid drag.
	var v_centroid = cp.v.add(body.v, cp.v.mult(cp.v.perp(r), body.w));
	var k = 1; //k_scalar_body(body, r, cp.v.normalize_safe(v_centroid));
	var damping = clippedArea*FLUID_DRAG*FLUID_DENSITY;
	var v_coef = Math.exp(-damping*dt*k); // linear drag
//	var v_coef = 1.0/(1.0 + damping*dt*cp.v.len(v_centroid)*k); // quadratic drag
	body.applyImpulse( cp.v.mult(cp.v.sub(cp.v.mult(v_centroid, v_coef), v_centroid), 1.0/k), r);
	
	// Apply angular damping for the fluid drag.
	var w_damping = cp.momentForPoly(FLUID_DRAG*FLUID_DENSITY*clippedArea, clipped, cp.v.neg(body.p));
	body.w *= Math.exp(-w_damping*dt* (1/body.i));
	
	return true;
};

//------------------------------------------------------------------
//
// Planet
//
//------------------------------------------------------------------

var Planet = function() {
	cc.base(this);
	this.title = 'Chipmunk Demo';
	this.subtitle = 'Planet';

	var space = this.space;

	// global
	this.gravityStrength = 5.0e6;

	// Create a rouge body to control the planet manually.
	var planetBody = this.planetBody = new cp.BodyStatic();
	planetBody.setAngVel(0.2);
	planetBody.setPos( centerPos );
	
	space.iterations = 20;
	
	for(var i=0; i<30; i++)
		this.add_box();
	
	var shape = space.addShape(new cp.CircleShape(planetBody, 70.0, cp.vzero));
	shape.setElasticity(1.0);
	shape.setFriction(1.0);
	shape.setLayers(NOT_GRABABLE_MASK);
};
cc.inherits( Planet, ChipmunkDemo );

Planet.prototype.update = function(dt)
{
	var steps = 1;
	dt /= steps;
	for (var i = 0; i < 3; i++){
		this.space.step(dt);

		// Update the static body spin so that it looks like it's rotating.
		this.planetBody.updatePosition(dt);
	}
};

Planet.prototype.planetGravityVelocityFunc = function(body, gravity, damping, dt)
{
	// Gravitational acceleration is proportional to the inverse square of
	// distance, and directed toward the origin. The central planet is assumed
	// to be massive enough that it affects the satellites but not vice versa.
	var p = body.getPos();
	var sqdist = cp.v.lengthsq(p);
	var g = cp.v.mult(p, -this.gravityStrength / (sqdist * Math.sqrt(sqdist)));
	
	body.updateVelocity(g, damping, dt);
};


Planet.prototype.rand_pos = function(radius)
{
	var v;
	do {
		v = cp.v(Math.random()*(640 - 2*radius) - (320 - radius), Math.random()*(480 - 2*radius) - (240 - radius));
	} while(cp.v.len(v) < 85.0);
	
	return v;
};


Planet.prototype.add_box = function()
{
	var size = 10.0;
	var mass = 1.0;
	
	var verts = [
		-size,-size,
		-size, size,
		size, size,
		size,-size
	];
	
	var radius = cp.v.len(cp.v(size, size));
	var pos = this.rand_pos(radius);
	
	var body = this.space.addBody( new cp.Body(mass, cp.momentForPoly(mass, verts, cp.vzero)));
	body.velocity_func = this.planetGravityVelocityFunc;
	body.setPos( cp.v.add(pos, centerPos));

	// Set the box's velocity to put it into a circular orbit from its
	// starting position.
	var r = cp.v.len(pos);
	var v = Math.sqrt(this.gravityStrength / r) / r;
	body.setVel( cp.v.mult(cp.v.perp(pos), v));

	// Set the box's angular velocity to match its orbital period and
	// align its initial angle with its position.
	body.setAngVel(v);
	body.setAngle( Math.atan2(pos.y, pos.x));

	var shape = this.space.addShape( new cp.PolyShape(body, verts, cp.vzero));
	shape.setElasticity(0.0);
	shape.setFriction(0.7);
};


//
// Order of tests
//

// Chipmunk Demos
scenes.push( Planet );
scenes.push( Buoyancy );
scenes.push( PyramidStack );
scenes.push( PyramidTopple );
scenes.push( Joints );
scenes.push( Balls );

// Tests
scenes.push( ChipmunkSpriteTest ); scenes.push( ChipmunkSpriteBatchTest );
scenes.push( ChipmunkCollisionTest ); scenes.push( ChipmunkCollisionTestB );
scenes.push( ChipmunkCollisionMemoryLeakTest );


//------------------------------------------------------------------
//
// Main entry point
//
//------------------------------------------------------------------
function run()
{
    var scene = cc.Scene.create();
    var layer = new scenes[currentScene]();
    scene.addChild( layer );

    var runningScene = director.getRunningScene();
    if( runningScene === null )
        director.runWithScene( scene );
    else
        director.replaceScene( cc.TransitionFade.create(0.5, scene ) );
}

run();
