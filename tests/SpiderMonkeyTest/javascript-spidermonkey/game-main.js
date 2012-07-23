//
// http://www.cocos2d-iphone.org
// http://www.chipmunk-physics.org
//
// Watermelon with Me
// A JS game using cocos2d and Chipmunk
// 
//
// Physics code based on Space Patrol:
// https://github.com/slembcke/SpacePatrol
//
// Most of the comments in the physics code were copied+pased from Space Patrol
//
//
// LICENSE:
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

require("javascript-spidermonkey/helper.js");

// Z Orders (grouped by parent)

// parent is scroll batch node 
Z_WATERMELON = 5;
Z_COIN = 8;
Z_CHASSIS = 10;
Z_WHEEL = 11;
Z_FINISH = 15;

// parent is scroll node (parallax node)
Z_TERRAIN = 2;
Z_SPRITES = 0;
Z_MOUNTAINS = -1;
Z_DEBUG_PHYSICS = 50;

// parent is game layer
Z_SCROLL = 10;
Z_HUD = 15;
Z_LABEL = 20;
Z_DEBUG_MENU = 20;

// Game state
STATE_PAUSE = 0;
STATE_PLAYING = 1;
STATE_GAME_OVER = 2;
STATE_LEVEL_COMPLETE = 3;

audioEngine = cc.AudioEngine.getInstance();
director = cc.Director.getInstance();
_winSize = director.getWinSize();
winSize = {width:_winSize[0], height:_winSize[1]};
centerPos = cc.p( winSize.width/2, winSize.height/2 );

sizeRatio = winSize.width / 480;

//
// Levels
//
level0 = {'coins' : [ {x:1120,y:150}, {x:1160,y:140}, {x:1200,y:130}, {x:1240,y:120}, {x:1280,y:110}, ],

          'car' : {x:80, y:60}, 
          'finish' : {x:3400, y:20},

          // points in absolute position.
//          'segments' : [ {x0:0, y0:0, x1:100, y1:50}, ],
          'segments' : [],

          // points relatives to the previous point
          'lines' : [ {x:0,y:0}, {x:350,y:10}, {x:20, y:5}, {x:500, y:-20}, {x:200, y:80}, {x:100, y:-40}, {x:200,y:-10}, {x:400, y:-50}, {x:300,y:0}, {x:400,y:100}, {x:200,y:-100}, {x:400,y:0}, {x:20,y:15}, {x:20,y:-15}, {x:400,y:0}, ],
          'map' : 'map.png',
          };
//
// Physics constants
//

INFINITY = 1e50;

COLLISION_TYPE_CAR = 1;
COLLISION_TYPE_COIN = 2;
COLLISION_TYPE_WATERMELON = 3;
COLLISION_TYPE_FLOOR = 4;
COLLISION_TYPE_FINISH = 5;

// Create some collision rules for fancy layer based filtering.
// There is more information about how this works in the Chipmunk docs.
COLLISION_RULE_TERRAIN_BUGGY = 1 << 0;
COLLISION_RULE_BUGGY_ONLY = 1 << 1;

// Bitwise or the rules together to get the layers for a certain shape type.
COLLISION_LAYERS_TERRAIN = COLLISION_RULE_TERRAIN_BUGGY;
COLLISION_LAYERS_BUGGY = (COLLISION_RULE_TERRAIN_BUGGY | COLLISION_RULE_BUGGY_ONLY);

// Some constants for controlling the car and world:
GRAVITY =  1200.0;
WHEEL_MASS = 0.25;
CHASSIS_MASS = 0.7;
FRONT_SPRING = 150.0;
FRONT_DAMPING = 3.0;
COG_ADJUSTMENT = cp.v(0.0, -10.0);
REAR_SPRING = 100.0;
REAR_DAMPING = 3.0;
ROLLING_FRICTION = 5e2;
ENGINE_MAX_TORQUE = 6.0e4;
ENGINE_MAX_W = 60;
BRAKING_TORQUE = 3.0e4;
DIFFERENTIAL_TORQUE = 0.5;

// Groups
GROUP_BUGGY = 1;
GROUP_COIN = 2;

WATERMELON_MASS = 0.05;

// Node Tags (used by CocosBuilder)
SCORE_LABEL_TAG = 10;
TIME_LABEL_TAG = 11;

//
// Game Layer
//
var GameLayer = cc.LayerGradient.extend({

    _space:null,
    _motor:null,
    _frontBrake:null,
    _rearBrake:null,
    _rearWheel:null,
    _chassis:null,
    _batch:null,
    _shapesToRemove:[],
    _score:0,
    _scoreLabel:null,
    _time:0,
    _timeLabel:null,
    _state:STATE_PAUSE,
    _deferredState:null,
    _debugNode:null,
    _scrollNode:null,
    _terrain:null,
    _carSprite:null,

    ctor:function () {
                                
        var parent = new cc.LayerGradient();
        __associateObjWithNative(this, parent);
        this.init(cc.c4(0, 0, 0, 255), cc.c4(255, 255, 255, 255));

        this.scheduleUpdate();

        this.enableEvents( true );

        cc.MenuItemFont.setFontSize(16 * sizeRatio );
        var item1 = cc.MenuItemFont.create("Reset", this, this.onReset);
        var item2 = cc.MenuItemFont.create("Debug On/Off", this, this.onToggleDebug);
        var menu = cc.Menu.create( item1, item2 );
        menu.alignItemsVertically();
        this.addChild( menu, Z_DEBUG_MENU );
        menu.setPosition( cc._p( winSize.width-(40*sizeRatio), winSize.height-(80*sizeRatio) )  );
    
        var animCache = cc.AnimationCache.getInstance();
        animCache.addAnimationsWithFile("coins_animation.plist");

        // scrollng Node.. all game objects are children of this node (or one of its subchildre)
        var scroll = cc.ParallaxNode.create();
        this.addChild( scroll, Z_SCROLL );
        this._scrollNode = scroll;

        // coin only needed to obtain the texture for the Batch Node
        var coin = cc.Sprite.createWithSpriteFrameName("coin01.png");
        this._batch = cc.SpriteBatchNode.createWithTexture( coin.getTexture(), 100 );
        scroll.addChild( this._batch, Z_SPRITES, cc._p(1,1), cc.POINT_ZERO );

        // "endless" background image
        var background = cc.Sprite.create("Parallax.png", cc.rect(0,0,4096,512) );
        scroll.addChild(background, Z_MOUNTAINS , cc._p(0.2, 0.2), cc.POINT_ZERO);
        background.setAnchorPoint( cc.POINT_ZERO );
        background.getTexture().setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.CLAMP_TO_EDGE);

        // Terrain
        this._terrain = cc.DrawNode.create();
        scroll.addChild( this._terrain, Z_TERRAIN, cc._p(1,1), cc.POINT_ZERO );

        this._shapesToRemove = [];

        this.initHUD();

        this._score = 0;
        this._time = 0;
        this._state = STATE_PAUSE;

    },

    // HUD stuff
    initHUD:function() {
        var hud = cc.Reader.load("HUD.ccbi", this);
        this.addChild( hud, Z_HUD );
        this._scoreLabel = hud.getChildByTag( SCORE_LABEL_TAG );
        this._timeLabel = hud.getChildByTag( TIME_LABEL_TAG );

        // bug in cocosbuilder
        this._scoreLabel.setAnchorPoint( cc._p(1, 0.5) );
        this._timeLabel.setAnchorPoint( cc._p(0, 0.5) );
    },

    addScore:function(value) {
        this._score += value;
        this._scoreLabel.setString( this._score );
        this._scoreLabel.stopAllActions();

        var scaleUpTo = cc.ScaleTo.create(0.05, 1.2);
        var scaleDownTo = cc.ScaleTo.create(0.05, 1.0);
        var seq = cc.Sequence.create( scaleUpTo, scaleDownTo );
        this._scoreLabel.runAction( seq );

    },

    //
    // Events
    //
    onReset:function(sender) {
        run();
    },

    onToggleDebug:function(sender) {
        var state = this._debugNode.getVisible();
        this._debugNode.setVisible( !state );
    },

    onMouseDown:function(event) {
        this.setThrottle(1);
        return true;
    },
    onMouseUp:function(event) {
        this.setThrottle(0);
        return true;
    },
    onTouchesBegan:function( touches, event) {
        this.setThrottle(1);
        return true;
    },
    onTouchesEnded:function( touches, event) {
        this.setThrottle(0);
        return true;
    },

    onEnterTransitionDidFinish:function() {

        this.initPhysics();
        this.setupLevel(0);
        this._state = STATE_PLAYING;
    },

    onExit:function() {

        this.enableCollisionEvents( false );
        // XXX: Leak... all Shapes and Bodies should be freed
        cp.spaceFree( this._space );
    },

    // Coin and Car
	onCollisionBeginCoin : function ( arbiter, space ) {

		var bodies = cp.arbiterGetBodies( arbiter );
		var shapes = cp.arbiterGetShapes( arbiter );
		var collTypeA = cp.shapeGetCollisionType( shapes[0] );
		var collTypeB = cp.shapeGetCollisionType( shapes[1] );

        var shapeCoin =  (collTypeA == COLLISION_TYPE_COIN) ? shapes[0] : shapes[1];

        // XXX: hack to prevent double deletion... argh...
        // Since shapeCoin in 64bits is a typedArray and in 32-bits is an integer
        // a ad-hoc solution needs to be implemented
        if( this._shapesToRemove.length == 0 ) {
            // since Coin is a sensor, it can't be removed at PostStep.
            // PostStep is not called for Sensors
            this._shapesToRemove.push( shapeCoin );
            audioEngine.playEffect("pickup_coin.wav");

//            cc.log("Adding shape: " + shapeCoin[0] + " : " + shapeCoin[1] );
            cc.log("Adding shape: " + shapeCoin );
            this.addScore(1);
        }
        return true;
	},

    // Floor and Watermelon
	onCollisionBeginWatermelon : function ( arbiter, space ) {
        this.setThrottle(0);
        this.setGameStateDeferred( STATE_GAME_OVER );
        return true;
	},

    // Car and Finish line
	onCollisionBeginFinish : function ( arbiter, space ) {
        this.setThrottle(0);
        this.setGameStateDeferred( STATE_LEVEL_COMPLETE );
        return true;
	},

    update:function(dt) {

        // update state if necessary
        if( this._deferredState )
            this.setGameState( this._deferredState );

        if( this._state == STATE_PLAYING ) {
            // update time
            this._time += dt;
            this._timeLabel.setString( '' + this._time.toFixed(1) );
        }

        // Don't update physics on game over
        if( this._state != STATE_PAUSE )
            cp.spaceStep( this._space, dt);

        var l = this._shapesToRemove.length;

        for( var i=0; i < l; i++ ) {
            var shape = this._shapesToRemove[i];

//            cc.log("removing shape: " + shape[0] + " : " + shape[1] );
            cc.log("removing shape: " + shape );

            cp.spaceRemoveStaticShape( this._space, shape );
            cp.shapeFree( shape );

            var body = cp.shapeGetBody( shape );

            var sprite = cp.bodyGetUserData( body );
            sprite.removeFromParentAndCleanup(true);

            cp.bodyFree( body );

        }

        if( l > 0 )
            this._shapesToRemove = [];
    },

    //
    // Level Setup
    //
    setupLevel : function(lvl) {

        var x = 0;
        var y = 0;
        var width = winSize.width;
        var height = winSize.height;

        var level = level0;

        if( lvl == 0 )
            level = level0;
        
        // Coins
        var coins = level['coins']; 
        for( var i=0;i < coins.length; i++) {
            var coin = coins[i];
            this.createCoin( cc._p( coin.x, coin.y) ); 
        }

        // car
        var car = level['car'];
        this.createCar( cp.v( car.x, car.y) );

        // finish
        var finish = level['finish'];
        this.createFinish( cp._v(finish.x, finish.y) );

        // Segments
        var segments = level['segments']; 
        for( var i=0; i < segments.length; i++) {
            var segment = segments[i];
            this.createSegment( cp._v(segment.x0, segment.y0), cp._v(segment.x1, segment.y1) ); 
        }

        //lines  
        var poly = [];
        var p = {x:0, y:0};
        var lines = level['lines']; 
        for( var i=0; i < lines.length; i++) {
            var line = lines[i];
            if( i > 0 ) {
                this.createSegment( cp._v(p.x, p.y), cp._v( p.x+line.x, p.y+line.y )  ); 
            }

            p = {x:p.x+line.x, y:p.y+line.y};

            x = Math.min(x, p.x);
            y = Math.min(y, p.y);
            width = Math.max( width, p.x);
            height = Math.max( height, p.y);

            poly.push( cc.p(p.x, p.y) );
        }

        // Bug in CCDrawNode: No tesselation, so "fill" is disabled
        poly.unshift( cc.p(x,y) );
        poly.push( cc.p(width,y) );
        this._terrain.drawPoly( poly, cc.c4f(0.67, 0.16, 0.16, 0 ), 5, cc.c4f(0.82,0.41,0.04,1) );

        cc.log("World Boundary: " + x + " " + y + " " + width + " " + height );

        var rect = cc.rect(x,y,width,height); 
        var a = cc.Follow.create( this._carSprite, rect );
        this._scrollNode.runAction( a );

        this.createWorldBoundary( rect );
    },

    createWorldBoundary:function( rect ) {

		var staticBody = cp.spaceGetStaticBody( this._space );

        var x = rect[0];
        var y = rect[1];
        var w = rect[2];
        var h = rect[3];

		// Walls
		var walls =[cp.segmentShapeNew( staticBody, cp._v(x,y), cp._v(w,y), 0 ),   // bottom
			     	cp.segmentShapeNew( staticBody, cp._v(x,h), cp._v(w,h), 0),	    // top
                    cp.segmentShapeNew( staticBody, cp._v(x,y), cp._v(x,h), 0),     // left
                    cp.segmentShapeNew( staticBody, cp._v(w,y), cp._v(w,h), 0)  	// right
				];
		for( var i=0; i < walls.length; i++ ) {
			var wall = walls[i];
			cp.shapeSetElasticity(wall, 0);
			cp.shapeSetFriction(wall, 0);
            cp.shapeSetCollisionType(wall, COLLISION_TYPE_FLOOR);
			cp.spaceAddStaticShape( this._space, wall );
		}
    },

    //
    // Physics
    //
	initPhysics :  function() {
		this._space =  cp.spaceNew();

		// Gravity
		cp.spaceSetGravity( this._space, cp._v(0, -GRAVITY) );

        this.enableCollisionEvents( true );

        // debug only
        this._debugNode = cc.ChipmunkDebugNode.create( this._space );
        this._debugNode.setVisible( false );
        // Parallax ratio and offset
        this._scrollNode.addChild( this._debugNode, Z_DEBUG_PHYSICS, cc._p(1,1), cc.POINT_ZERO );
	},

    setThrottle : function( throttle ) {
        if(throttle > 0){
            // The motor is modeled like an electric motor where the torque decreases inversely as the rate approaches the maximum.
            // It's simple to code up and feels nice.

            // _motor.maxForce = cpfclamp01(1.0 - (_chassis.body.angVel - _rearWheel.body.angVel)/ENGINE_MAX_W)*ENGINE_MAX_TORQUE;
            var maxForce = cp.fclamp01(1.0 - ( (cp.bodyGetAngVel(this._chassis) - cp.bodyGetAngVel(this._rearWheel)) / ENGINE_MAX_W)) * ENGINE_MAX_TORQUE;
            cp.constraintSetMaxForce( this._motor, maxForce );
            cc.log(" MAX FORCE: " + maxForce );

            // Set the brakes to apply the baseline rolling friction torque.
            cp.constraintSetMaxForce( this._frontBrake, ROLLING_FRICTION );
            cp.constraintSetMaxForce( this._rearBrake, ROLLING_FRICTION );
        } else if(throttle < 0){
            // Disable the motor.
            cp.constraintSetMaxForce( this._motor, 0 );
            // It would be a pretty good idea to give the front and rear brakes different torques.
            // The buggy as is now has a tendency to tip forward when braking hard.
            cp.constraintSetMaxForce( this._frontBrake, BRAKING_TORQUE);
            cp.constraintSetMaxForce( this._rearBrake, BRAKING_TORQUE);
        } else {
            // Disable the motor.
            cp.constraintSetMaxForce( this._motor, 0 );
            // Set the brakes to apply the baseline rolling friction torque.
            cp.constraintSetMaxForce( this._frontBrake, ROLLING_FRICTION );
            cp.constraintSetMaxForce( this._rearBrake, ROLLING_FRICTION );
        }
    },

    createCar : function(pos) {
        var front = this.createWheel( cp.vadd(pos, cp._v(47,-25) ) );
        this._chassis = this.createChassis( cp.vadd( pos, COG_ADJUSTMENT ) );
        this._rearWheel = this.createWheel( cp.vadd( pos, cp._v(-35, -25) ) );
        this.createCarJoints( this._chassis, front, this._rearWheel );
        this.createCarFruits( pos );

        this.setThrottle( 0 );
    },

    createCarJoints: function( chassis, front, rear ) {

        // The front wheel strut telescopes, so we'll attach the center of the wheel to a groov joint on the chassis.
        // I created the graphics specifically to have a 45 degree angle. So it's easy to just fudge the numbers.
        var grv_a = cp.bodyWorld2Local( chassis, cp.bodyGetPos(front) );
        var grv_b = cp.vadd( grv_a, cp.vmult( cp._v(-1, 1), 7 ) );
        var frontJoint = cp.grooveJointNew( chassis, front, grv_a, grv_b, cp.vzero );

        // Create the front zero-length spring.
        var front_anchor =  cp.bodyWorld2Local( chassis, cp.bodyGetPos(front) );
        var frontSpring = cp.dampedSpringNew( chassis, front, front_anchor, cp.vzero, 0, FRONT_SPRING, FRONT_DAMPING );

        // The rear strut is a swinging arm that holds the wheel a at a certain distance from a pivot on the chassis.
        // A perfect fit for a pin joint conected between the chassis and the wheel's center.
        var rearJoint = cp.pinJointNew( chassis, rear, cp.vsub( cp._v(-14,-8), COG_ADJUSTMENT), cp.vzero );
        
    	// return cpvtoangle(cpvsub([_chassis.body local2world:_rearJoint.anchr1], _rearWheel.body.pos));
        var rearStrutRestAngle = cp.vtoangle( cp.vsub(
                                                cp.bodyLocal2World( chassis, cp.pinJointGetAnchr1(rearJoint) ),
                                                cp.bodyGetPos(rear) ) );

        // Create the rear zero-length spring.
        var rear_anchor = cp.bodyWorld2Local( chassis, cp.bodyGetPos( rear ) );
        var rearSpring = cp.dampedSpringNew( chassis, rear, rear_anchor, cp.vzero, 0, REAR_SPRING, REAR_DAMPING );

        // Attach a slide joint to the wheel to limit it's range of motion.
        var rearStrutLimit = cp.slideJointNew( chassis, rear, rear_anchor, cp.vzero, 0, 20 );
			
        // The main motor that drives the buggy.
        var motor = cp.simpleMotorNew( chassis, rear, ENGINE_MAX_W );
        cp.constraintSetMaxForce( motor, 0.0 );
			
        // I don't know if "differential" is the correct word, but it transfers a fraction of the rear torque to the front wheels.
        // In case the rear wheels are slipping. This makes the buggy less frustrating when climbing steep hills.
        var differential = cp.simpleMotorNew( rear, front, 0 );
        cp.constraintSetMaxForce( differential, ENGINE_MAX_TORQUE*DIFFERENTIAL_TORQUE );
			
        // Wheel brakes.
        // While you could reuse the main motor for the brakes, it's easier not to.
        // It won't cause a performance issue to have too many extra motors unless you have hundreds of buggies in the game.
        // Even then, the motor constraints would be the least of your performance worries.
        var frontBrake = cp.simpleMotorNew( chassis, front, 0 );
        cp.constraintSetMaxForce( frontBrake, ROLLING_FRICTION );
        var rearBrake = cp.simpleMotorNew( chassis, rear, 0 );
        cp.constraintSetMaxForce( rearBrake, ROLLING_FRICTION );

        cp.spaceAddConstraint(this._space, frontJoint );
        cp.spaceAddConstraint(this._space, rearJoint );
        cp.spaceAddConstraint(this._space, rearSpring );
        cp.spaceAddConstraint(this._space, motor );
        cp.spaceAddConstraint(this._space, differential );
        cp.spaceAddConstraint(this._space, frontBrake );
        cp.spaceAddConstraint(this._space, rearBrake );

        this._motor = motor;
        this._frontBrake = frontBrake;
        this._rearBrake = rearBrake;
    },

    createWheel : function( pos ) {
        var sprite = cc.ChipmunkSprite.createWithSpriteFrameName("Wheel.png");  
        var radius = 0.95 * sprite.getContentSize()[0] / 2;

		var body = cp.bodyNew(WHEEL_MASS, cp.momentForCircle(WHEEL_MASS, 0, radius, cp.vzero ) );
		cp.bodySetPos( body, pos );
        sprite.setBody( body );

        var shape = cp.circleShapeNew( body, radius, cp.vzero );
        cp.shapeSetFriction( shape, 1 );
        cp.shapeSetGroup( shape, GROUP_BUGGY );
        cp.shapeSetLayers( shape, COLLISION_LAYERS_BUGGY );
        cp.shapeSetCollisionType( shape, COLLISION_TYPE_CAR );

        cp.spaceAddBody( this._space, body );
        cp.spaceAddShape( this._space, shape );
        this._batch.addChild( sprite, Z_WHEEL);

        return body;
    },

    createChassis : function(pos) {
        var sprite = cc.ChipmunkSprite.createWithSpriteFrameName("Chassis.png"); 
        var anchor = cp.vadd( sprite.getAnchorPointInPoints(), COG_ADJUSTMENT );
        var cs = sprite.getContentSize();
        sprite.setAnchorPoint( cc.p(anchor[0] / cs[0], anchor[1]/cs[1]) );

        // XXX: Space Patrol uses a nice poly for the chassis.
        // XXX: Add something similar here, instead of a boxed chassis

        var body = cp.bodyNew( CHASSIS_MASS, cp.momentForBox(CHASSIS_MASS, cs[0], cs[1] ) );
        cp.bodySetPos( body, pos );
        sprite.setBody( body );

        cp.spaceAddBody( this._space, body );
        this._batch.addChild( sprite, Z_CHASSIS );
        this._carSprite = sprite;

        // bottom of chassis
        var shape = cp.boxShapeNew( body, cs[0], 15 );
		cp.shapeSetFriction(shape, 0.3);
		cp.shapeSetGroup( shape, GROUP_BUGGY );
		cp.shapeSetLayers( shape, COLLISION_LAYERS_BUGGY );
        cp.shapeSetCollisionType( shape, COLLISION_TYPE_CAR );

        cp.spaceAddShape( this._space, shape );

        // box for fruits (left)
        var shape = cp.boxShapeNew2( body, cp.bBNew(-50,0, -46,30) );
		cp.shapeSetFriction(shape, 0.3);
		cp.shapeSetGroup( shape, GROUP_BUGGY );
		cp.shapeSetLayers( shape, COLLISION_LAYERS_BUGGY );
        cp.shapeSetCollisionType( shape, COLLISION_TYPE_CAR );
        cp.spaceAddShape( this._space, shape );

        // box for fruits (right)
        var shape = cp.boxShapeNew2( body, cp.bBNew(8,0, 12,30) );
		cp.shapeSetFriction(shape, 0.3);
		cp.shapeSetGroup( shape, GROUP_BUGGY );
		cp.shapeSetLayers( shape, COLLISION_LAYERS_BUGGY );
        cp.shapeSetCollisionType( shape, COLLISION_TYPE_CAR );
        cp.spaceAddShape( this._space, shape );

        return body;
    },

    createCarFruits : function(pos) {
        // create some fruits
        for(var i=0; i < 4;i++) {
            var sprite = cc.ChipmunkSprite.createWithSpriteFrameName("watermelon.png");  
            var radius = 0.95 * sprite.getContentSize()[0] / 2;

            var body = cp.bodyNew(WATERMELON_MASS, cp.momentForCircle(WATERMELON_MASS, 0, radius, cp.vzero) );
            cp.bodySetPos( body, pos );
            sprite.setBody( body );

            var shape = cp.circleShapeNew( body, radius, cp.vzero );
            cp.shapeSetFriction( shape, 1 );
            cp.shapeSetCollisionType( shape, COLLISION_TYPE_WATERMELON);

            cp.spaceAddShape( this._space, shape );
            cp.spaceAddBody( this._space, body );
            this._batch.addChild( sprite, Z_WATERMELON );
        }
    },

    createCoin: function( pos ) {
        // coins are static bodies and sensors
        var sprite = cc.ChipmunkSprite.createWithSpriteFrameName("coin01.png");  
        var radius = 0.95 * sprite.getContentSize()[0] / 2;
        
        var body = cp.bodyNew(1, 1);
        cp.bodyInitStatic(body);
		cp.bodySetPos( body, pos );
        sprite.setBody( body );

        var shape = cp.circleShapeNew( body, radius, cp.vzero );
        cp.shapeSetFriction( shape, 1 );
        cp.shapeSetGroup( shape, GROUP_COIN );
        cp.shapeSetCollisionType( shape, COLLISION_TYPE_COIN );
        cp.shapeSetSensor( shape, true );

        cp.spaceAddStaticShape( this._space, shape );
        this._batch.addChild( sprite, Z_COIN);

        var animation = cc.AnimationCache.getInstance().getAnimationByName("coin");
        var animate = cc.Animate.create(animation); 
        var repeat = cc.RepeatForever.create( animate );
        sprite.runAction( repeat );

        // Needed for deletion
        cp.bodySetUserData( body, sprite );

        return body;
    },

    createFinish:function( pos ) {
        var sprite = cc.ChipmunkSprite.createWithSpriteFrameName("farmers-market.png"); 
        var cs = sprite.getContentSize();
        var body = cp.bodyNew( 1, 1);
        cp.bodyInitStatic( body );
        sprite.setBody( body );
        cp.bodySetPos( body, pos );

        var shape = cp.boxShapeNew( body, cs[0], cs[1] );
        cp.shapeSetCollisionType( shape, COLLISION_TYPE_FINISH );
        cp.shapeSetSensor( shape, true );

        cp.spaceAddStaticShape( this._space, shape );
        this._batch.addChild( sprite, Z_FINISH);
    },

    createSegment: function( src, dst) {
		var staticBody = cp.spaceGetStaticBody( this._space );
		var segment = cp.segmentShapeNew( staticBody, src, dst, 5 );
        cp.shapeSetElasticity(segment, 1);
        cp.shapeSetFriction(segment, 1);
        cp.shapeSetCollisionType(segment, COLLISION_TYPE_FLOOR);
        cp.spaceAddStaticShape( this._space, segment );
    },

    //
    // Game State
    //
    
    // call the 'deferred' option if you want to modify Chipmunk's state from a Chipmunk's callback
    setGameStateDeferred: function( state ) {
        this._deferredState = state; 
    },

    setGameState: function( state ) {
        if( state != this._state ) {

            if( state == STATE_GAME_OVER  ) {
                var label = cc.LabelBMFont.create("GAME OVER", "Abadi40.fnt" );
                label.setPosition( centerPos );
                this.addChild( label, Z_LABEL );

                this.enableEvents( false );
                this.enableCollisionEvents( false );

                audioEngine.playEffect("GameOver.wav");
            }

            else if (state == STATE_LEVEL_COMPLETE ) {
                var label = cc.LabelBMFont.create("LEVEL COMPLETE", "Abadi40.fnt" );
                label.setPosition( centerPos );
                this.addChild( label, Z_LABEL );

                this.enableEvents( false );
                this.enableCollisionEvents( false );

                audioEngine.playEffect("LevelComplete.wav");
            }

            this._state = state;
        }
        this._deferredState = null;
    },


    //
    // Helpers
    //
    enableEvents:function(enabled) {
        var platform = __getPlatform();
        if( platform.substring(0,7) == 'desktop' ) {
            this.setMouseEnabled( enabled );
        } else if( platform.substring(0,6) == 'mobile' ) {
            this.setTouchEnabled( enabled );
        }
    },

    enableCollisionEvents:function(enabled) {
        if( enabled ) {
            // collision handler
            cp.spaceAddCollisionHandler( this._space, COLLISION_TYPE_CAR, COLLISION_TYPE_COIN, this, this.onCollisionBeginCoin, null, null, null );
            cp.spaceAddCollisionHandler( this._space, COLLISION_TYPE_CAR, COLLISION_TYPE_FINISH, this, this.onCollisionBeginFinish, null, null, null );
            cp.spaceAddCollisionHandler( this._space, COLLISION_TYPE_FLOOR, COLLISION_TYPE_WATERMELON, this, this.onCollisionBeginWatermelon, null, null, null );
        } else {
            cp.spaceRemoveCollisionHandler( this._space, COLLISION_TYPE_FLOOR, COLLISION_TYPE_WATERMELON );
            cp.spaceRemoveCollisionHandler( this._space, COLLISION_TYPE_COIN, COLLISION_TYPE_CAR );
            cp.spaceRemoveCollisionHandler( this._space, COLLISION_TYPE_FINISH, COLLISION_TYPE_CAR );
        }
    },


});

//
// Main Menu
//
var MainMenu = cc.Layer.extend({

    ctor:function () {
                                
        var parent = new cc.Layer();
        __associateObjWithNative(this, parent);
        this.init();


        // background
        var node = cc.Reader.load("MainMenu.ccbi", this, _winSize);
        this.addChild( node );
    },

    buttonA:function( sender) {
        run();
    },

    buttonB:function( sender) {
        var scene = cc.Scene.create();
        var layer = new GameLayer();
        scene.addChild( layer );
        director.replaceScene( cc.TransitionSplitCols.create(1, scene) );
    },

    buttonC:function( sender ) {
        var hi = cc.LabelTTF.create("Callbacks are working", "Arial", 28 );
        this.addChild( hi );
        hi.setPosition(  centerPos );
    },

});
//------------------------------------------------------------------
//
// Main entry point
//
//------------------------------------------------------------------
function run()
{
    // update globals
    _winSize = director.getWinSize();
    winSize = {width:_winSize[0], height:_winSize[1]};
    centerPos = cc.p( winSize.width/2, winSize.height/2 );

    var scene = cc.Scene.create();

    // main menu
    var menu = new MainMenu();
    scene.addChild( menu);

    // game
//    var layer = new GameLayer();
//    scene.addChild( layer );

    var runningScene = director.getRunningScene();
    if( runningScene == null )
        director.runWithScene( scene );
    else
        director.replaceScene( cc.TransitionFade.create(0.5, scene ) );
}

run();


