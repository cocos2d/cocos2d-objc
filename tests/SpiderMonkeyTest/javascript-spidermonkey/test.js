// http://www.cocos2d-iphone.org
//
// Javascript Action tests
// Test are coded using Javascript, with the exception of MenuCallback which uses Objective-J to handle the callbacks.
// 

require("javascript-spidermonkey/helper.js");

cc.log('Hello World');

var parent1 = new cc.Node.node();
var parent2 = new cc.Node.node();


// Testing Rotation
var value = 90
parent1.setRotation( 90 )
var ret = parent1.rotation()
if (value != ret ) {
	cc.log('Error in setRotation / rotation');
}

// Testing ScaleX
value = 5;
parent1.setScaleX( 5 );
ret = parent1.scaleX();
if (value != ret) {
	cc.log('Error in setScaleX / scaleX ');
}

var s = new cc.Sprite.spriteWithFile("grossini.png");
s.setColor( ccc3(255,0,0) );

// Testing Position
parent1.setPosition( ccp(100,200) );
p = parent1.position();
cc.log('position is: ' + p[0] + ', ' + p[1] )

parent1.onEnter = function() {
	cc.log("On Enter called");
}

var action = new cc.RotateBy.actionWithDurationAngle(2, 360 );

var action2 = new cc.RotateBy();
action2.initWithDurationAngle(1, -360 );

var action3 = new cc.RotateBy();
action3.initWithDurationAngle(2, 180 );

var seq = new cc.Sequence.actionWithArray( [action, action2, action3] );

s.runAction( seq )

parent1.addChild( s );


// Labels
var l = new cc.LabelBMFont.labelWithStringFntfile("Testing Javascript", "konqa32.fnt");
l.setPosition( ccp(200,100 ) );
parent2.addChild( l )

//cc.addToRunningScene( a );

var director = cc.Director.sharedDirector();
var scene = director.runningScene();
cc.log( scene.position() );
scene.addChild( parent1 );
scene.addChild( parent2 );

var size = director.winSize();
cc.log( 'WinSize: ' + size[0] + ' ' + size[1] )

// Testing GC #1. Global properties
tmp = cc.Sprite.spriteWithFile("grossini.png");
delete tmp;
cc.forceGC();

// Testing GC #2. Variables
var tmp = cc.Sprite.spriteWithFile("grossini.png");
tmp = null;
cc.forceGC();

// Testing same object
var sprite3 = new cc.Sprite.spriteWithFile("grossinis_sister1.png");
sprite3.I_was_here = 'Oh Yeah';
parent2.addChildZTag( sprite3, 0, 100 );
sprite3.setPosition( ccp( 300,200) );

var sameSprite = parent2.getChildByTag( 100 );
cc.log( sameSprite.I_was_here );

sprite3.onEnter = function() {
	cc.log("Sprite3#onEnter was called");
}

// Testing Menu

var item1 = cc.MenuItemFont.itemWithStringBlock( "Click Me", function( sender )
												   {
												cc.log("Clicked me from" + sender );
												   } );

var item2 = cc.MenuItemFont.itemWithString( "Click Me 2" );

var menu = cc.Menu.menuWithArray( [item1, item2] );
menu.alignItemsHorizontally();
menu.setPosition( ccp(200,200) );
parent2.addChild( menu );



//
// Google "subclassing"
//
cc.log("hola");
var subclass = function() {
	cc.base(this);
	this.initWithFile("grossini.png");
	this.setPosition( ccp(100, 100) );
	this.setScale( 3 );
}
cc.inherits(subclass, cc.Sprite );

//for( var i in cc.Sprite ) { cc.log( "---->" + cc.Sprite[ i ] + "..." + i ); }
//var sprite = new subclass();

var sprite = new subclass();
sprite.setPosition( ccp(300,300) );
sprite.setRotation( 90 );
p = sprite.position();
cc.log( p );
parent2.addChild( sprite );
//cc.addToRunningScene( sprite );


//
// cocos2d-html5 subclassing
//
var subclass2 = cc.Sprite.extend({
	ctor:function() {
//		this.initWithFile("grossini.png");
		cc.log("OHHHHHHH YESSSSS");
		this.initWithFile("grossini.png");
    }
});
//cc.log( Object.keys( subclass2.prototype ).join(',') );
//var sprite3 = subclass2.spriteWithFile("grossini.png");
var sprite3 = new subclass2();
sprite3.setPosition( ccp(300,100) );
sprite3.setRotation( 180 );
parent2.addChild( sprite3 );

