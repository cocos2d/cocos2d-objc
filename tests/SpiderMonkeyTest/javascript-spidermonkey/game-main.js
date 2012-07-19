//
// http://www.cocos2d-iphone.org
// http://www.chipmunk-physics.org
//
// Physics code from on Space Patrol:
// https://github.com/slembcke/SpacePatrol
//
// All the comments in the physics code were copied+pased from Space Patrol
//
// A JS game using cocos2d and Chipmunk
//


require("javascript-spidermonkey/helper.js");

audioEngine = cc.AudioEngine.getInstance();
director = cc.Director.getInstance();
_winSize = director.winSize();
winSize = {width:_winSize[0], height:_winSize[1]};
centerPos = cc.p( winSize.width/2, winSize.height/2 );

//
// Physics constants
//

INFINITY = 1e50;

COLLISION_TYPE_CAR = 1;
COLLISION_TYPE_COIN = 2;

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
CHASSIS_MASS = 1.0;
FRONT_SPRING = 150.0;
FRONT_DAMPING = 3.0;
COG_ADJUSTMENT = cp.v(5.0, -10.0);
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

// Node Tags (used by CocosBuilder)
SCORE_LABEL_TAG = 10;

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

    ctor:function () {
                                
        var parent = new cc.LayerGradient();
        __associateObjWithNative(this, parent);
        this.init(cc.c4(0, 0, 0, 255), cc.c4(255, 255, 255, 255));

        this.scheduleUpdate();

        var platform = __getPlatform();
        if( platform.substring(0,7) == 'desktop' ) {
            this.setMouseEnabled( true );
        } else if( platform.substring(0,6) == 'mobile' ) {
            this.setTouchEnabled( true );
        }


        cc.MenuItemFont.setFontSize(16);
        var menuItem = cc.MenuItemFont.create("Reset", this, this.reset );
        var menu = cc.Menu.create( menuItem );
        this.addChild( menu );
        menu.setPosition( cc._p( 40,60)  );
    
        var animCache = cc.AnimationCache.getInstance();
        animCache.addAnimationsWithFile("coins_animation.plist");

        // coin only needed to obtain the texture for the Batch Node
        var coin = cc.Sprite.createWithSpriteFrameName("coin01.png");
        this._batch = cc.SpriteBatchNode.createWithTexture( coin.getTexture(), 100 );
        this.addChild( this._batch );

        this._shapesToRemove = [];

        this.initHUD();

        this._score = 0;
    },

    // HUD stuff
    initHUD:function() {
        var hud = cc.Reader.nodeGraphFromFile("HUD.ccbi", this);
        this.addChild( hud );
        this._scoreLabel = hud.getChildByTag( SCORE_LABEL_TAG );
    },

    reset:function() {
        run();
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

    // Events
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

    onEnter:function () {
        // DO NOT CALL this._super()
//        this._super();

        this.initPhysics();
        this.setupLevel("level0.txt");
    },

    onExit:function() {
        // XXX: Leak... all Shapes and Bodies should be freed
        cp.spaceFree( this._space );
    },

	onCollisionBegin : function ( arbiter, space ) {

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

            cc.log("Adding shape: " + shapeCoin[0] + " : " + shapeCoin[1] );
            this.addScore(1);
        }
        return true;
	},

    update:function(dt) {
        cp.spaceStep( this._space, dt);

        var l = this._shapesToRemove.length;

        for( var i=0; i < l; i++ ) {
            var shape = this._shapesToRemove[i];

            cc.log("removing shape: " + shape[0] + " : " + shape[1] );

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
    setupLevel : function(levelname) {
        for( var i=1; i < 15; i++ ) {
            this.createCoin( cc._p(winSize.width/2 + i*35, 60 + i*3) );
        }
    },

    //
    // Physics
    //
	initPhysics :  function() {
		this._space =  cp.spaceNew();
		var staticBody = cp.spaceGetStaticBody( this._space );

		// Walls
		var walls = [cp.segmentShapeNew( staticBody, cp.v(0,0), cp.v(winSize.width,50), 0 ),				    // bottom
				cp.segmentShapeNew( staticBody, cp.v(0,winSize.height), cp.v(winSize.width,winSize.height), 0),	// top
				cp.segmentShapeNew( staticBody, cp.v(0,0), cp.v(0,winSize.height), 0),				            // left
				cp.segmentShapeNew( staticBody, cp.v(winSize.width,0), cp.v(winSize.width,winSize.height), 0)	// right
				];
		for( var i=0; i < walls.length; i++ ) {
			var wall = walls[i];
			cp.shapeSetElasticity(wall, 1);
			cp.shapeSetFriction(wall, 1);
			cp.spaceAddStaticShape( this._space, wall );
		}

		// Gravity
		cp.spaceSetGravity( this._space, cp.v(0, -GRAVITY) );

        // create Car
        this.createCar();

        // collision handler
		cp.spaceAddCollisionHandler( this._space, COLLISION_TYPE_CAR, COLLISION_TYPE_COIN, this, this.onCollisionBegin, null, null, null );
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

    createCar : function() {
        var pos = cp.v(winSize.width*0.20, 100);
        var front = this.createWheel( cp.vadd(pos, cp._v(47,-20) ) );
        this._chassis = this.createChassis( cp.vadd( pos, COG_ADJUSTMENT ) );
        this._rearWheel = this.createWheel( cp.vadd( pos, cp._v(-41, -20) ) );
        this.createFrontJoint( this._chassis, front, this._rearWheel );

        this.setThrottle( 0 );
    },

    createFrontJoint : function( chassis, front, rear ) {

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
        this._batch.addChild( sprite, 10 );

        return body;
    },

    createChassis : function(pos) {
        var sprite = cc.ChipmunkSprite.createWithSpriteFrameName("Chassis.png"); 
//        var anchor = cp.vadd( sprite.getAnchorPointInPoints, COG_ADJUSTMENT );
        var cs = sprite.getContentSize();
//        sprite.setAnchorPoint( anchor[0] / cs[0], anchor[1]/cs[1] );

        // XXX: Space Patrol uses a nice poly for the chassis.
        // XXX: Add something similar here, instead of a boxed chassis

        var body = cp.bodyNew( CHASSIS_MASS, cp.momentForBox(CHASSIS_MASS, cs[0], cs[1] ) );
        cp.bodySetPos( body, pos );
        sprite.setBody( body );

        var shape = cp.boxShapeNew( body, cs[0], cs[1] );
		cp.shapeSetFriction(shape, 0.3);
		cp.shapeSetGroup( shape, GROUP_BUGGY );
		cp.shapeSetLayers( shape, COLLISION_LAYERS_BUGGY );
        cp.shapeSetCollisionType( shape, COLLISION_TYPE_CAR );

        cp.spaceAddBody( this._space, body );
        cp.spaceAddShape( this._space, shape );
        this._batch.addChild( sprite );

        return body;
    },

    createCoin: function( pos ) {
        // coins are static bodies and sensors
        var sprite = cc.ChipmunkSprite.createWithSpriteFrameName("coin01.png");  
        var radius = 0.95 * sprite.getContentSize()[0] / 2;

        var body = cp.bodyNew(1, 1);
        cp.bodyInitStatic(body);
//		var body = cp.spaceGetStaticBody( this._space );
		cp.bodySetPos( body, pos );
        sprite.setBody( body );

        var shape = cp.circleShapeNew( body, radius, cp.vzero );
        cp.shapeSetFriction( shape, 1 );
        cp.shapeSetGroup( shape, GROUP_COIN );
        cp.shapeSetCollisionType( shape, COLLISION_TYPE_COIN );
        cp.shapeSetSensor( shape, true );

//        cp.spaceAddBody( this._space, body );
        cp.spaceAddStaticShape( this._space, shape );
        this._batch.addChild( sprite, 10 );

        var animation = cc.AnimationCache.getInstance().getAnimationByName("coin");
        var animate = cc.Animate.create(animation); 
        var repeat = cc.RepeatForever.create( animate );
        sprite.runAction( repeat );

        // Needed for deletion
        cp.bodySetUserData( body, sprite );

        return body;
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
        var node = cc.Reader.nodeGraphFromFile("MainMenu.ccbi", this, _winSize);
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
    _winSize = director.winSize();
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


