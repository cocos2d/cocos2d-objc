//
// http://www.cocos2d-iphone.org
//
// Test cases for reported bugs
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
	this.init( cc.c4b(0,0,0,255), cc.c4b(0,128,255,255) );

	this.title =  "No title";
	this.subtitle = "No Subtitle";
};

cc.inherits(BaseLayer, cc.LayerGradient );

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


BaseLayer.prototype.onRestartCallback = function (sender) {
    restartSpriteTestAction();
};

BaseLayer.prototype.onNextCallback = function (sender) {
    nextSpriteTestAction();
};

BaseLayer.prototype.onBackCallback = function (sender) {
    backSpriteTestAction();
};

//------------------------------------------------------------------
//
// Longlong test
//
//------------------------------------------------------------------
var LongLongTest = function() {

	cc.base(this);

	this.title = 'LongLong test';
	this.subtitle = 'See output in console. This test only runs on OS X';

    var t = cc.config.deviceType;
    if( t == 'desktop' ) {
		var str = '3';
		var ret = '0';
		for( var i=0; i < 10; i++) {
			ret = cc.nextPOT(str);
			cc.log("POT number: " + str + " -> " + ret);

			// append a 0 and try again
			str += '0';
		}
    }
};
cc.inherits( LongLongTest, BaseLayer );


//
// Order of tests
//

// Bugs
scenes.push( LongLongTest );


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
