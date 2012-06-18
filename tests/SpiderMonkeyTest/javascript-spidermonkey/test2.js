// http://www.cocos2d-iphone.org
//
// Javascript Action tests
// Test are coded using Javascript, with the exception of MenuCallback which uses Objective-J to handle the callbacks.
//

require("javascript-spidermonkey/helper.js");

var director = cc.Director.sharedDirector();


var scene = director.runningScene();

cc.log( scene.position() );

//scene.addChild( parent1 );
//scene.addChild( parent2 );

var size = director.winSize();
cc.log( 'WinSize: ' + size[0] + ' ' + size[1] )
