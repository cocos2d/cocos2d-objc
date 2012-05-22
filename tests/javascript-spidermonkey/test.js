// http://www.cocos2d-iphone.org
//
// Javascript Action tests
// Test are coded using Javascript, with the exception of MenuCallback which uses Objective-J to handle the callbacks.
// 


function ccp(x, y)
{
	var floats = new Float32Array(2);
	floats[0] = x;
	floats[1] = y;
	
	return floats;
}

cc.log('Hello World');

a = new cc.Node();
a.init();

a.setPosition( ccp(100,200) );

//p = a.getPosition();
//cc.log('position is' + p );

a.onEnter = function() {
	cc.log("On Enter called");
}


cc.addToRunningScene( a );
