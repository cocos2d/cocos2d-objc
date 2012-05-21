// http://www.cocos2d-iphone.org
//
// Javascript Action tests
// Test are coded using Javascript, with the exception of MenuCallback which uses Objective-J to handle the callbacks.
// 


cc.log('Hello World');

a = new cc.Node();
a.init();

a.onEnter = function() {
	cc.log("On Enter called");
}

cc.addToRunningScene( a );
