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
var withTransition = false;

var nextSpriteTestAction = function () {
	currentScene = currentScene + 1;
	if( currentScene >= scenes.length )
		currentScene = 0;

	withTransition = true;
	loadScene(currentScene);
};
var backSpriteTestAction = function () {
	currentScene = currentScene -1;
	if( currentScene < 0 )
		currentScene = scenes.length -1;

	withTransition = true;
	loadScene(currentScene);
};
var restartSpriteTestAction = function () {
	loadScene( currentScene );
};

var loadScene = function (sceneIdx)
{
	_winSize = director.winSize();
	winSize = {width:_winSize[0], height:_winSize[1]};
	centerPos = cc.p( winSize.width/2, winSize.height/2 );

	var scene = new cc.Scene();
	scene.init();
	var layer = new scenes[ sceneIdx ]();

	scene.addChild( layer );

//	scene.walkSceneGraph(0);

	var transitions = [ cc.TransitionSplitCols, cc.TransitionSplitRows,
				cc.TransitionSlideInL, cc.TransitionSlideInR, cc.TransitionSlideInT, cc.TransitionSlideInB,
				cc.TransitionFade, cc.TransitionCrossFade,
				cc.TransitionFlipX, cc.TransitionFlipY,
				cc.TransitionProgressRadialCCW, cc.TransitionProgressRadialCW, cc.TransitionProgressVertical, cc.TransitionProgressHorizontal,
				cc.TransitionShrinkGrow,
				];
	var idx = Math.floor(  Math.random() * transitions.length );
	var transition = transitions[ idx ];

	if( withTransition == true )
		director.replaceScene( transition.create( 0.9, scene ) );
	else
		director.replaceScene( scene );

	withTransition = false;
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
	this.init( cc.c4(0,0,0,0), cc.c4(0,128,255,255));

	this.title =  "No title";
	this.subtitle = "No Subtitle";
	this.isMainTitle = false;

}
goog.inherits(BaseLayer, cc.LayerGradient );

//
// Instance 'base' methods
// XXX: Should be defined after "goog.inherits"
//
BaseLayer.prototype.onEnter = function() {

	var fontSize = 36;
	var tl = this.title.length;
	fontSize = (winSize.width / tl) * 1.60;
	if( fontSize/winSize.width > 0.09 ) {
		fontSize = winSize.width * 0.09;
	}

	this.label = cc.LabelTTF.create(this.title, "Gill Sans", fontSize);
	this.addChild(this.label, 1);

	var isMain = this.isMainTitle;

	if( isMain == true )
		this.label.setPosition( centerPos );
	else
		this.label.setPosition( cc.p(winSize.width / 2, winSize.height*11/12) );

	var subStr = this.subtitle;
	if (subStr != "") {
		tl = this.subtitle.length;
		var subfontSize = (winSize.width / tl) * 1.3;
		if( subfontSize > fontSize *0.6 ) {
			subfontSize = fontSize *0.6;
		}

		this.sublabel = cc.LabelTTF.create(subStr, "Thonburi", subfontSize);
		this.addChild(this.sublabel, 1);
		if( isMain )
			this.sublabel.setPosition( cc.p(winSize.width / 2, winSize.height*3/8 ));
		else
			this.sublabel.setPosition( cc.p(winSize.width / 2, winSize.height*5/6 ));
	} else
		this.sublabel = null;

	// WARNING: MenuItem API will change!
	var item1 = cc.MenuItemImage.itemWithNormalImageSelectedimageBlock("b1.png", "b2.png", this.backCallback);
	var item2 = cc.MenuItemImage.itemWithNormalImageSelectedimageBlock("r1.png", "r2.png", this.restartCallback);
	var item3 = cc.MenuItemImage.itemWithNormalImageSelectedimageBlock("f1.png", "f2.png", this.nextCallback);

	 [item1, item2, item3].forEach( function(item) {
		item.normalImage().setOpacity(15);
		item.selectedImage().setOpacity(15);
		} );

	var menu = cc.Menu.create( item1, item2, item3 );

	menu.setPosition( cc.p(0,0) );
	item1.setPosition( cc.p(winSize.width / 2 - 100, 30));
	item2.setPosition( cc.p(winSize.width / 2, 30));
	item3.setPosition( cc.p(winSize.width / 2 + 100, 30));

	this.addChild(menu, 1);
}

BaseLayer.prototype.createBulletList = function () {
	var str = "";
	for(var i=0; i<arguments.length; i++)
	{
		if(i != 0)
			str += "\n";
		str += '- ' + arguments[i];
	}

	cc.log( str );

	var fontSize = winSize.height*0.07;
	var bullets = cc.LabelTTF.create( str, "Gill Sans", fontSize );
	bullets.setPosition( centerPos );
	this.addChild( bullets );
}

BaseLayer.prototype.createImage = function( file ) {
	var sprite = cc.Sprite.create( file );
	sprite.setPosition( centerPos );
	this.addChild( sprite );

	return sprite;
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
// Intro Page
//
//------------------------------------------------------------------
var IntroPage = function() {

	goog.base(this);

	this.title = 'cocos2d + JS'
	this.subtitle = 'Prototyping, Faster development, Web Integration';
	this.isMainTitle = true;
}
goog.inherits( IntroPage, BaseLayer );

//------------------------------------------------------------------
//
// FeaturesPage Page
//
//------------------------------------------------------------------
var FeaturesPage = function() {

	goog.base(this);

	this.title = 'Features';
	this.subtitle = '';
	this.isMainTitle = false;

	this.createBulletList( 'Automatic generated JS bindings',
				'same JS API as cocos2d-html5',
				'Works on iOS and Mac',
				'Faster development',
				'Great prototyping tool');
}
goog.inherits( FeaturesPage, BaseLayer );

//------------------------------------------------------------------
//
// Sprites Page
//
//------------------------------------------------------------------
var SpritesPage = function() {

	goog.base(this);

	this.title = 'Sprites';
	this.subtitle = ''

	var fontSize = winSize.height * 0.05;

	var label = cc.LabelTTF.create('cc.Sprite.create("grossini.png");', 'CourierNewPSMT', fontSize );
	label.setPosition( cc.p( winSize.width/2, winSize.height*1/5) );
	this.addChild( label );

	var sprite1 = cc.Sprite.create("grossinis_sister1.png");
	sprite1.setPosition( cc.p( winSize.width*1/4, winSize.height/2) );

	var sprite2 = cc.Sprite.create("grossini.png");
	sprite2.setPosition( cc.p( winSize.width*2/4, winSize.height/2) );

	var sprite3 = cc.Sprite.create("grossinis_sister2.png");
	sprite3.setPosition( cc.p( winSize.width*3/4, winSize.height/2) );

	this.addChild( sprite1 );
	this.addChild( sprite2 );
	this.addChild( sprite3 );
}
goog.inherits( SpritesPage, BaseLayer );


//------------------------------------------------------------------
//
// Actions Page
//
//------------------------------------------------------------------
var ActionsPage = function() {

	goog.base(this);

	this.title = 'Actions';
	this.subtitle = ''

	var fontSize = winSize.height * 0.05;

	var label = cc.LabelTTF.create('cc.RotateBy.create(8, 360);', 'CourierNewPSMT', fontSize );
	label.setPosition( cc.p( winSize.width/2, winSize.height*1/5) );
	this.addChild( label );

	this.sprite = cc.Sprite.create("grossini.png");
	this.sprite.setPosition( cc.p( winSize.width*2/4, winSize.height/2) );
	this.addChild( this.sprite );

	this.onEnterTransitionDidFinish = function() {
		var action = cc.RotateBy.create(8, 360);
		this.sprite.runAction( action );
	}
}
goog.inherits( ActionsPage, BaseLayer );

//------------------------------------------------------------------
//
// Labels Page
//
//------------------------------------------------------------------
var LabelsPage = function() {

	goog.base(this);

	this.title = 'Labels';
	this.subtitle = ''

	var fontSize = winSize.height * 0.03;

	var label = cc.LabelTTF.create('cc.LabelTTF.create("Hello JS World", "Marker Felt", 32);\ncc.LabelBMFont.create("Hello World", "font.fnt")', 'CourierNewPSMT', fontSize );
	label.setPosition( cc.p( winSize.width/2, winSize.height*1/5) );
	this.addChild( label );


	var labelTTF = cc.LabelTTF.create('Label TTF', 'Marker Felt', 48 );
	labelTTF.setPosition( cc.p( winSize.width*1/4, winSize.height/2) );
	this.addChild( labelTTF );

	var labelBM = cc.LabelBMFont.create('Label BMFont', 'futura-48.fnt');
	labelBM.setPosition( cc.p( winSize.width*3/4, winSize.height/2) );
	this.addChild( labelBM );

//	var labelAtlas = cc.LabelAtlas.create('Atlas', 'tuffy_bold_italic-charmap.plist');
//	labelAtlas.setPosition( cc.p( winSize.width*3/5, winSize.height/2) );
//	this.addChild( labelAtlas );

}
goog.inherits( LabelsPage, BaseLayer );

//------------------------------------------------------------------
//
// Actions 2 Page
//
//------------------------------------------------------------------
var Actions2Page = function() {

	goog.base(this);

	this.title = 'Complex Actions';
	this.subtitle = ''

	var fontSize = winSize.height * 0.05;

	var label = cc.LabelTTF.create('cc.Sequence.create(action1, action2,...);', 'CourierNewPSMT', fontSize );
	label.setPosition( cc.p( winSize.width/2, winSize.height*1/5) );
	this.addChild( label );

	this.sprite = cc.Sprite.create("grossini.png");
	this.sprite.setPosition( cc.p( winSize.width*2/4, winSize.height/2) );
	this.addChild( this.sprite );

	this.onEnterTransitionDidFinish = function() {
		var rot = cc.RotateBy.create(1, 360);
		var rot_back = rot.reverse();
		var scale = cc.ScaleBy.create(1, 7);
		var scale_back = scale.reverse();
		var seq = cc.Sequence.create( rot, scale, rot_back, scale_back );

		this.sprite.runAction( cc.RepeatForever.create( seq ) );
	}
}
goog.inherits( Actions2Page, BaseLayer );

//------------------------------------------------------------------
//
// ParserFeaturesPage Page
//
//------------------------------------------------------------------
var ParserFeaturesPage = function() {

	goog.base(this);

	this.title = 'Parser Features';
	this.subtitle = '';
	this.isMainTitle = false;

	this.createBulletList( 'Generates robust JS bindings',
				'No need to modify generated code',
				'No need to modify parsed library',
				'Easy to maintain',
				'Powerful config file' );
}
goog.inherits( ParserFeaturesPage, BaseLayer );

//------------------------------------------------------------------
//
// Internals
//
//------------------------------------------------------------------
var InternalsPage = function() {

	goog.base(this);

	this.title = 'Internals I';
	this.subtitle = '';
	this.isMainTitle = false;

	this.onEnterTransitionDidFinish = function() {
		// super onEnter
//		goog.base( this, 'onEnterTransitionDidFinish' );

		var spr = this.createImage( 'Presentation/proxy_model.png' );
		spr.setScale( 0.1 );
		var scaleAction = cc.ScaleTo.create( 0.7, 1);
		spr.runAction( scaleAction );
	}
}
goog.inherits( InternalsPage, BaseLayer );

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

	this.title = 'Chipmunk Sprite Test';
	this.subtitle = 'Chipmunk + cocos2d sprites tests. Tap screen.';

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

	var platform = __getPlatform();
	if( platform == 'OSX' )
		this.setIsMouseEnabled( true );
	else if( platform == 'iOS' )
		this.setIsTouchEnabled( true );
}

ChipmunkSpriteTest.prototype.update = function( delta ) {
	cp.spaceStep( this.space, delta );
}

ChipmunkSpriteTest.prototype.onMouseDown = function( event ) {
	pos = director.convertEventToGL( event );
	cc.log("Mouse Down:" + pos );
	this.addSprite( pos );
}

ChipmunkSpriteTest.prototype.onTouchesEnded = function( touches, event ) {
	var l = touches.length;
	for( var i=0; i < l; i++) {
		pos = director.convertTouchToGL( touches[i] );
		this.addSprite( pos );
	}
}

//------------------------------------------------------------------
//
// Chipmunk + Sprite + Batch
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

	this.title = 'Chipmunk SpriteBatch Test';
	this.subtitle = 'Chipmunk + cocos2d sprite batch tests. Tap screen.';
}
goog.inherits( ChipmunkSpriteBatchTest, ChipmunkSpriteTest );




//
// Order of tests
//
scenes.push( IntroPage );
scenes.push( FeaturesPage );
scenes.push( SpritesPage );
scenes.push( LabelsPage );
scenes.push( ActionsPage );
scenes.push( Actions2Page );
scenes.push( ParserFeaturesPage );
scenes.push( InternalsPage );
scenes.push( ChipmunkSpriteBatchTest );



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
