//
// http://www.cocos2d-iphone.org
//
// Javascript + chipmunk tests
//

require("jsb_constants.js");

director = cc.Director.getInstance();
_winSize = director.getWinSize();
winSize = {width:_winSize[0], height:_winSize[1]};
centerPos = cc.p( winSize.width/2, winSize.height/2 );

var scenes = []
var currentScene = 0;
var withTransition = false;

var nextScene = function( t ) {
	currentScene = currentScene + 1;
	if( currentScene >= scenes.length )
		currentScene = 0;

	withTransition = true;
	loadScene(currentScene, t);
};
var previousScene = function( t ) {
	currentScene = currentScene -1;
	if( currentScene < 0 )
		currentScene = scenes.length -1;

	withTransition = true;
	loadScene(currentScene, t);
};
var restartScene = function() {

	withTransition = false;
	loadScene( currentScene, null );
};

var loadScene = function (sceneIdx, transition)
{
	_winSize = director.getWinSize();
	winSize = {width:_winSize[0], height:_winSize[1]};
	centerPos = cc.p( winSize.width/2, winSize.height/2 );

	var scene = new cc.Scene();
	scene.init();
	var layer = new scenes[ sceneIdx ]();

	scene.addChild( layer );

//	scene.walkSceneGraph(0);

	if( withTransition == true )
		director.replaceScene( transition.create( 0.5, scene ) );
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
	this.init( cc.c4b(0,0,0,255), cc.c4b(0,128,255,255));

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
	this.addChild(this.label, 100);

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
		this.addChild(this.sublabel, 90);
		if( isMain )
			this.sublabel.setPosition( cc.p(winSize.width / 2, winSize.height*3/8 ));
		else
			this.sublabel.setPosition( cc.p(winSize.width / 2, winSize.height*4/5 ));
	} else
		this.sublabel = null;

    // Menu
    var item1 = cc.MenuItemImage.create("b1.png", "b2.png", this, this.backCallback);
    var item2 = cc.MenuItemImage.create("r1.png", "r2.png", this, this.restartCallback);
    var item3 = cc.MenuItemImage.create("f1.png", "f2.png", this, this.nextCallback);
    var item4 = cc.MenuItemFont.create("back", this, function() { require("js/main.js"); } );
    item4.setFontSize( 22 );

	 [item1, item2, item3 ].forEach( function(item) {
		item.normalImage().setOpacity(45);
		item.selectedImage().setOpacity(45);
		} );

	var menu = cc.Menu.create( item1, item2, item3, item4 );

	menu.setPosition( cc.p(0,0) );
	item1.setPosition( cc.p(winSize.width / 2 - 100, 30));
	item2.setPosition( cc.p(winSize.width / 2, 30));
	item3.setPosition( cc.p(winSize.width / 2 + 100, 30));
    item4.setPosition( cc.p(winSize.width - 60, winSize.height - 30 ) );

	this.addChild(menu, 80);
}

BaseLayer.prototype.prevTransition = function () {
    return cc.TransitionSlideInL;
}

BaseLayer.prototype.nextTransition = function () {
    return cc.TransitionSlideInR;
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
	this.addChild( bullets, 80 );
}

BaseLayer.prototype.createImage = function( file ) {
	var sprite = cc.Sprite.create( file );
	sprite.setPosition( centerPos );
	this.addChild( sprite, 70 );

	return sprite;
}


BaseLayer.prototype.restartCallback = function (sender) {
	restartScene();
}

BaseLayer.prototype.nextCallback = function (sender) {
	nextScene( this.nextTransition() );
}

BaseLayer.prototype.backCallback = function (sender) {
	previousScene( this.prevTransition() );
}

//------------------------------------------------------------------
//
// Intro Page
//
//------------------------------------------------------------------
var IntroPage = function() {

	goog.base(this);

	this.background1 = this.createImage( 'Official-cocos2d-Icon-Angry.png');
	this.background2 = this.createImage( 'Official-cocos2d-Icon-Happy.png');

	this.background1.setOpacity( 0 );
	this.background2.setOpacity( 0 );

	// Not working setZOrder() ??
//	sprite.setZOrder( -200 );

	this.title = 'GDK'
	this.subtitle = 'Game Development Kit';
	this.isMainTitle = true;

	this.onEnterTransitionDidFinish2 =  function() {
		var fade_out1 = cc.FadeOut.create( 2 );
		var fade_in1 = fade_out1.reverse();
		var delay1 = cc.DelayTime.create(4);

		var seq1 = cc.Sequence.create( fade_out1, fade_in1, delay1 );
		this.background1.runAction( cc.RepeatForever.create( seq1 ) );

		var delay2 = cc.DelayTime.create(4);
		var fade_out2 = cc.FadeOut.create( 2 );
		var fade_in2 = fade_out2.reverse();

		var seq2 = cc.Sequence.create( delay2, fade_in2, fade_out2 );
		this.background2.runAction( cc.RepeatForever.create( seq2 ) );
	}
}
goog.inherits( IntroPage, BaseLayer );

//------------------------------------------------------------------
//
// Goal Page
//
//------------------------------------------------------------------
var GoalPage = function() {

	goog.base(this);

	this.title = 'GDK Goals';
	this.subtitle = '';
	this.isMainTitle = false;

	this.createBulletList(
				'Faster prototyping',
                'Faster development time',
				'Increased quality' );
}
goog.inherits( GoalPage, BaseLayer );

//------------------------------------------------------------------
//
// Proto Page
//
//------------------------------------------------------------------
var ProtoPage = function() {

	goog.base(this);

	this.title = 'Goal: Prototyping';
	this.subtitle = 'Faster and better';
	this.isMainTitle = false;

	this.createBulletList(
				'Faster: Scripting language',
                'Better: Prototyping editor' );
}
goog.inherits( ProtoPage, BaseLayer );

//------------------------------------------------------------------
//
// Devel Page
//
//------------------------------------------------------------------
var DevelPage = function() {

	goog.base(this);

	this.title = 'Goal: Development';
	this.subtitle = 'Better and Faster devel time';
	this.isMainTitle = false;

	this.createBulletList(
				'Faster: Less code + more data',
				'Faster: Scripting language',
                'Faster: Portable iOS, Android, Web',
                'Better: less code + more data' );
}
goog.inherits( DevelPage, BaseLayer );

//------------------------------------------------------------------
//
// Quality Page
//
//------------------------------------------------------------------
var QualityPage = function() {

	goog.base(this);

	this.title = 'Goal: Quality';
	this.subtitle = 'Increased quality';
	this.isMainTitle = false;

	this.createBulletList(
				'Authoring tools',
                'Portability: portable code + data' );
}
goog.inherits( QualityPage, BaseLayer );

//------------------------------------------------------------------
//
// HowPage
//
//------------------------------------------------------------------
var HowPage = function() {

	goog.base(this);

	this.title = 'How';
	this.subtitle = 'GDK components';
	this.isMainTitle = false;

	this.createBulletList( 'A Game Engine: cocos2d',
				'A Physics Engine: Chipmunk',
				'A World Editor: CocosBuilder',
                'A Language: Javascript' );
}
goog.inherits( HowPage, BaseLayer );

//------------------------------------------------------------------
//
// CocosStatusPage 
//
//------------------------------------------------------------------
var CocosStatusPage = function() {

	goog.base(this);

	this.title = 'cocos2d';
	this.subtitle = '';
	this.isMainTitle = false;

    this.createImage( 'Presentation/cocos2d_status.png' );
}
goog.inherits( CocosStatusPage, BaseLayer );

//------------------------------------------------------------------
//
// ChipmunkStatusPage 
//
//------------------------------------------------------------------
var ChipmunkStatusPage = function() {

	goog.base(this);

	this.title = 'Chipmunk';
	this.subtitle = '';
	this.isMainTitle = false;

    this.createImage( 'Presentation/chipmunk_status.png' );
}
goog.inherits( ChipmunkStatusPage, BaseLayer );

//------------------------------------------------------------------
//
// CCBStatusPage 
//
//------------------------------------------------------------------
var CCBStatusPage = function() {

	goog.base(this);

	this.title = 'CocosBuilder Reader';
	this.subtitle = '';
	this.isMainTitle = false;

    this.createImage( 'Presentation/cocosbuilder_status.png' );
}
goog.inherits( CCBStatusPage, BaseLayer );

//------------------------------------------------------------------
//
// FuturePage 
//
//------------------------------------------------------------------
var FuturePage = function() {

	goog.base(this);

	this.title = "What's next";
	this.subtitle = '';
	this.isMainTitle = false;

	this.createBulletList(
                'Integration with WFF',
				'JS Debugger and Profiler',
                'Sample Games',
				'CocosBuilder + JS Integration'
                );
}
goog.inherits( FuturePage, BaseLayer );


//------------------------------------------------------------------
//
// DemoPage
//
//------------------------------------------------------------------
var DemoPage = function() {

	goog.base(this);

	this.title = 'Demo';
	this.subtitle = '';
	this.isMainTitle = true;
}
goog.inherits( DemoPage, BaseLayer );

//------------------------------------------------------------------
//
// OneMoreThing
//
//------------------------------------------------------------------
var OneMoreThingPage = function() {

	goog.base(this);

	this.title = 'One More Thing';
	this.subtitle = '';
	this.isMainTitle = true;
}
goog.inherits( OneMoreThingPage, BaseLayer );

//------------------------------------------------------------------
//
// Thanks
//
//------------------------------------------------------------------
var ThanksPage = function() {

	goog.base(this);

	this.title = 'Thanks';
	this.subtitle = '';
	this.isMainTitle = true;
}
goog.inherits( ThanksPage, BaseLayer );


//
// Order of tests
//
scenes.push( IntroPage );
scenes.push( GoalPage );
scenes.push( ProtoPage );
scenes.push( DevelPage );
scenes.push( QualityPage );
scenes.push( HowPage );
scenes.push( CocosStatusPage );
scenes.push( ChipmunkStatusPage );
scenes.push( CCBStatusPage );
scenes.push( FuturePage );
scenes.push( DemoPage );
scenes.push( OneMoreThingPage );
scenes.push( ThanksPage );


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

	director.setDisplayStats( false );

    var runningScene = director.getRunningScene();
    if( runningScene == null )
        director.runWithScene( scene );
    else
        director.replaceScene( cc.TransitionFade.create(0.5, scene ) );
}

run();

