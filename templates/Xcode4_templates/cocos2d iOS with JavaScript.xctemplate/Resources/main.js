//
// JavaScript example
//

require("jsb_constants.js");

director = cc.Director.getInstance();
winSize = director.getWinSize();
centerPos = cc.p( winSize.width/2, winSize.height/2 );

var MainLayer = cc.LayerGradient.extend({

    ctor:function () {
        cc.associateWithNative( this, cc.LayerGradient );
        this.init(cc.c4b(0, 0, 0, 255), cc.c4b(0, 128, 255, 255));

        var hello = cc.LabelTTF.create("Hello", "Marker Felt", 36);
        this.addChild( hello );
        hello.setPosition( centerPos );
    },

    onEnter:function () {
        // Do something if needed
    },

    onExit:function () {
        // Do something if needed
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

    var runningScene = director.getRunningScene();
    if( runningScene == null )
        director.runWithScene( scene );
    else
        director.replaceScene( cc.TransitionFade.create(0.5, scene ) );
}

run();


