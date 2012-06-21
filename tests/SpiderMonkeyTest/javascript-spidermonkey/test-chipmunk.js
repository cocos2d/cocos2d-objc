// http://www.cocos2d-iphone.org
//
// Javascript Action tests
// Test are coded using Javascript, with the exception of MenuCallback which uses Objective-J to handle the callbacks.
//

//require("javascript-spidermonkey/helper.js");

var director = cc.Director.sharedDirector();
var _winSize = director.winSize();
var winSize = {width:_winSize[0], height:_winSize[1]};

// class
//copy_properties( base_menu, SpriteColorOpacity );

var layer1 = cc.Node.create();
//copy_properties( SpriteColorOpacity, layer1 );
layer1.onEnter = function () {
        cc.log("onEnter called");
        __jsc__.garbageCollect();
};

var scene = cc.Scene.create();
scene.addChild( layer1 );

//director.runWithScene( scene );
//cc.addToRunningScene( scene );
director.replaceScene( scene );
