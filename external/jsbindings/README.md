# Javascript Bindings for C and Objective-C


## What's this ?
Javascript Bindings (JSB) is a script that generates "glue" code between native (C or Objective-C) code and Javascript code.
It automatically generates the code needed to call native code from Javascript and to call Javascript code from native.

## How to update the current bindings

    $ cd cocos2d-iphone/JSBindings
    $ ../tools/js/generate_spidermonkey_bindings.py -c ../tools/js/cocos2d_spidermonkey.ini 
    $ ../tools/js/generate_spidermonkey_bindings.py -c ../tools/js/chipmunk_spidermonkey.ini 
    $ ../tools/js/generate_spidermonkey_bindings.py -c ../tools/js/CocosBuilderReader_spidermonkey.ini 
    $ ../tools/js/generate_spidermonkey_bindings.py -c ../tools/js/CocosDenshion_spidermonkey.ini 



## Understanding the bindings

The Javascript Bidnings (JSB) generates the code needed to execute "native code" from Javascript. And by "native code" it could be any Objective-C (or C) library.

### Functions

As an example, the following code will execute 10 times the the native function "ccpAdd()":

	var p = cc.p(0,0);
	var q = cc.p(1,1);
	for( var i=0; i < 10; i++)
		p = cc.pAdd(p, q);   // cc.pAdd is a "wrapped" function, and it will call the cocos2d cc.pAdd() function


JSB will convert the Javascript object "p" into a valid CGPoint struct.


### Classes

JSB also works with Objective-C objects. Example:

	var sprite = cc.Sprite.create("grossini.png"); // Creates a native cocos2d CCSprite (a native object);
	sprite.setPosition( cc.p(10,10) );  // sends the message "setPosition" to the newly created instance


### Arguments

JSB converts any Javascript arguments into valid native objects. In this case, the "sprite" argument is converted from a Javascript object into a CCSprite object.

	var scene = cc.Scene.create();  // creates a cocos2d CCScene object.
	scene.addChild( sprite );   // sends the "addChild" message to the scene.


### Messages

JSB can also merge multiple messages into one. Objective-C doesn't support optional arguments, but Javascript does. So it is possible to merge multiple messages into one. Example:

	-(void) addChild:(CCNode*)node;
	-(void) addChild:(CCNode*)node z:(NSInteger)z;
	-(void) addChild:(CCNode*)node z:(NSInteger)z tag:(NSInteger)tag;

can be merged into just one Javascript call. Example:

	scene.addChild( sprite );        // calls  addChild:
	scene.addChild( sprite, 10);     // calls  addChild:z:
	scene.addChild( sprite, 10, -1); // calls  addChild:z:tag: 

