//------------------------------------------------------------------
//
// JavaScript sample
//
//------------------------------------------------------------------

//
// For a more complete sample, see "JS Watermelon With Me" bundled with cocos2d-iphone
//

// Loads cocos2d, chipmunk constants and helper functions
require("jsb.js");

director = cc.Director.getInstance();
winSize = director.getWinSize();
centerPos = cc.p( winSize.width/2, winSize.height/2 );

//------------------------------------------------------------------
//
// Main Layer
//
//------------------------------------------------------------------
var MainLayer = cc.LayerGradient.extend({

    // Constructor
    ctor:function () {
        // This is needed when subclassing a native class from JS
        cc.associateWithNative( this, cc.LayerGradient );

        // Initialize the Grandient Layer
        this.init(cc.c4b(0, 0, 0, 255), cc.c4b(0, 128, 255, 255));

        // After initializing, you can add nodes to the GradientLayer
        var hello = cc.LabelTTF.create("Hello World (JavaScript)", "Marker Felt", 36);
        this.addChild( hello );
        hello.setPosition( centerPos );

        // Simple Menu

        var item1 = cc.MenuItemFont.create("Play Game", this.onItem1, this);
        var item2 = cc.MenuItemFont.create("Options", this.onItem2, this);

        // Change size and color of items
        item1.setFontSize( 20 );
        item1.setColor( cc.c3b(192,192,192));
        item2.setFontSize( 20 );
        item2.setColor( cc.c3b(192,192,192));

        // create menu with items
        var menu = cc.Menu.create( item1, item2);
        menu.setPosition( cc.p( winSize.width/2, winSize.height/3) );
        menu.alignItemsHorizontally();
        this.addChild(menu);
    },

    //
    // callbacks
    //

    onEnter:function () {
        // Do something if needed
    },

    onExit:function () {
        // Do something if needed
    },

    onItem1:function(sender) {
        // Item 1 callback
        var scene = cc.Scene.create();
        var layer = new GameLayer();
        scene.addChild( layer );
        director.replaceScene( cc.TransitionFade.create(0.5, scene ) );
    },

    onItem2:function(sender) {
        // Item 2 callback
        sender.stopAllActions();
        var rot = cc.RotateBy.create( 2, 360 );
        sender.runAction( rot );
    }
});


//------------------------------------------------------------------
//
// Game Layer
//
//------------------------------------------------------------------
var GameLayer = cc.Layer.extend({

    // Constructor
    ctor:function () {
        // This is needed when subclassing a native class from JS
        cc.associateWithNative( this, cc.Layer );

        // Initialize the Layer
        this.init();

        // schedule update
        this.scheduleUpdate();

        // Misc label
        var label = cc.LabelTTF.create("GameLayer node", "Arial", 24);
        this.addChild( label );
        label.setPosition( centerPos );
    },

    //
    // callbacks
    //

    onEnter:function () {
        // Do something if needed
    },

    onExit:function () {
        // Do something if needed
    },

    update:function(dt) {
        // Add the game logic here
        // This function will be called each frame
        cc.log( 'Delta Time is: ' + dt );
    }
});


//------------------------------------------------------------------
//
// Main entry point
//
//------------------------------------------------------------------
function run()
{
    var scene = cc.Scene.create();
    var layer = new MainLayer();
    scene.addChild( layer );

    director.runWithScene( scene );
}

run();


