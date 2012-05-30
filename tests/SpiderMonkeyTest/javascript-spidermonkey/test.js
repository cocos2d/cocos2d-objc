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

a = new cc.Node();
a.init();

var value = 90
a.setRotation( 90 )
var ret = a.rotation()
if (value != ret ) {
	cc.log('Error in setRotation / rotation');
}

value = 5;
a.setScaleX( 5 );
ret = a.scaleX();
if (value != ret) {
	cc.log('Error in setScaleX / scaleX ');
}


var s = new cc.Sprite();
s.initWithFile("grossini.png");

s.setColor( ccc3(255,0,0) );

a.setPosition( ccp(100,200) );

p = a.position();
cc.log('position is: ' + p[0] + ', ' + p[1] )

a.onEnter = function() {
	cc.log("On Enter called");
}

var action = new cc.RotateBy()
action.initWithDurationangle(2, 360 )

s.runAction( action )

a.addChild( s );
cc.addToRunningScene( a );

