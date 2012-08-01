//
// http://www.cocos2d-iphone.org
// http://www.cocos2d-html5.org
// http://www.cocos2d-x.org
//
// Javascript + cocos2d actions tests
//

require("js/helper.js");

director = cc.Director.getInstance();
_winSize = director.getWinSize();
winSize = {width:_winSize[0], height:_winSize[1]};
centerPos = cc.p( winSize.width/2, winSize.height/2 );


var BaseLayer = cc.LayerGradient.extend({

    ctor:function () {
                                
        var parent = new cc.LayerGradient();
        __associateObjWithNative(this, parent);
        this.init(cc.c4(0, 0, 0, 255), cc.c4(0, 128, 255, 255));

        var item = cc.MenuItemFont.create("Hello", this, this.onButton );
        var menu = cc.Menu.create( item );
        menu.setPosition( centerPos );
        this.addChild( menu );
    },

    onButton:function() {
        cc.log("Button pressed");
    },
});


//------------------------------------------------------------------
//
// Main entry point
//
//------------------------------------------------------------------
function run()
{
    var scene = cc.Scene.create();
    var layer = new BaseLayer();
    scene.addChild( layer );

    director.runWithScene( scene );
}

run();


