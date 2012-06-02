// http://www.cocos2d-iphone.org
//
// Javascript Action tests
// Test are coded using Javascript, with the exception of MenuCallback which uses Objective-J to handle the callbacks.
// 


Float32Array.prototype.x = function () {
	return this[0];
};

Float32Array.prototype.y = function () {
	return this[1];
};

// cocos2d Helper
function ccp(x, y)
{
	var floats = new Float32Array(2);
	floats[0] = x;
	floats[1] = y;
	
	return floats;
}

function ccc3(r, g, b)
{
	var colors = new Uint8Array(3)
	colors[0] = r;
	colors[1] = g;
	colors[2] = b;
	
	return colors;
}

function ccc4f(r, g, b, a)
{
	var colors = new Float32Array(4)
	colors[0] = r;
	colors[1] = g;
	colors[2] = b;
	colors[3] = a;
	
	return colors;
}

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

var action2 = new cc.ScaleTo.actionWithDurationScale(4, 0.2 );

//
//var action2 = new cc.RotateBy();
//action2.initWithDurationangle(1, -360 );
//
//var action3 = new cc.RotateBy();
//action3.initWithDurationangle(2, 180 );
//
//var seq = new cc.Sequence();
//seq.initWithArray( [action, action2, action3] );

s.runAction( action )
s.runAction( action2 )

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

