//
// http://www.cocos2d-iphone.org
// http://www.cocos2d-html5.org
// http://www.cocos2d-x.org
//
// Javascript + cocos2d actions tests
//

require("javascript-spidermonkey/helper.js");

var director = cc.Director.getInstance();
var _winSize = director.winSize();
var winSize = {width:_winSize[0], height:_winSize[1]};
var centerPos = cc.p( winSize.width/2, winSize.height/2 );

var scenes = []
var currentScene = 0;

var nextScene = function () {
	currentScene = currentScene + 1;
	if( currentScene >= scenes.length )
		currentScene = 0;

	withTransition = true;
	loadScene(currentScene);
};

var previousScene = function () {
	currentScene = currentScene -1;
	if( currentScene < 0 )
		currentScene = scenes.length -1;

	withTransition = true;
	loadScene(currentScene);
};

var restartScene = function () {
	loadScene( currentScene );
};

var loadScene = function (sceneIdx)
{
	_winSize = director.winSize();
	winSize = {width:_winSize[0], height:_winSize[1]};
	centerPos = cc.p( winSize.width/2, winSize.height/2 );

	var scene = new cc.Scene();
	scene.init();
	var layer = new scenes[ sceneIdx ]();

	scene.addChild( layer );

//	scene.walkSceneGraph(0);

	director.replaceScene( scene );
//    __jsc__.garbageCollect();
}


cc.LayerGradient.extend = function (prop) {
    var _super = this.prototype;

    // Instantiate a base class (but only create the instance,
    // don't run the init constructor)
    initializing = true;
    var prototype = new this();
    initializing = false;
    fnTest = /xyz/.test(function(){xyz;}) ? /\b_super\b/ : /.*/;

    // Copy the properties over onto the new prototype
    for (var name in prop) {
        // Check if we're overwriting an existing function
        prototype[name] = typeof prop[name] == "function" &&
            typeof _super[name] == "function" && fnTest.test(prop[name]) ?
            (function (name, fn) {
                return function () {
                    var tmp = this._super;

                    // Add a new ._super() method that is the same method
                    // but on the super-class
                    this._super = _super[name];

                    // The method only need to be bound temporarily, so we
                    // remove it when we're done executing
                    var ret = fn.apply(this, arguments);
                    this._super = tmp;

                    return ret;
                };
            })(name, prop[name]) :
            prop[name];
    }

    // The dummy class constructor
    function Class() {
        // All construction is actually done in the init method
        if (!initializing && this.ctor)
            this.ctor.apply(this, arguments);
    }

    // Populate our constructed prototype object
    Class.prototype = prototype;

    // Enforce the constructor to be what we expect
    Class.prototype.constructor = Class;

    // And make this class extendable
    Class.extend = arguments.callee;

    return Class;
};

//
// Base Layer
//

var BaseLayer = cc.LayerGradient.extend({

    ctor:function () {
                                
        var parent = new cc.LayerGradient();
        __associateObjWithNative(this, parent);
        this.init(cc.c4(0, 0, 0, 255), cc.c4(0, 128, 255, 255));
    },

    centerSprites : function (numberOfSprites) {

        if (numberOfSprites == 1) {
            this._tamara.setVisible(false);
            this._kathia.setVisible(false);
            this._grossini.setPosition(cc.p(winSize.width / 2, winSize.height / 2));
        }
        else if (numberOfSprites == 2) {
            this._kathia.setPosition(cc.p(winSize.width / 3, winSize.height / 2));
            this._tamara.setPosition(cc.p(2 * winSize.width / 3, winSize.height / 2));
            this._grossini.setVisible(false);
        }
        else if (numberOfSprites == 3) {
            this._grossini.setPosition(cc.p(winSize.width / 2, winSize.height / 2));
            this._tamara.setPosition(cc.p(winSize.width / 4, winSize.height / 2));
            this._kathia.setPosition(cc.p(3 * winSize.width / 4, winSize.height / 2));
        }
    },

    alignSpritesLeft : function (numberOfSprites) {

        if (numberOfSprites == 1) {
            this._tamara.setVisible(false);
            this._kathia.setVisible(false);
            this._grossini.setPosition(cc.p(60, winSize.height / 2));
        }
        else if (numberOfSprites == 2) {
            this._kathia.setPosition(cc.p(60, winSize.height / 3));
            this._tamara.setPosition(cc.p(60, 2 * winSize.height / 3));
            this._grossini.setVisible(false);
        }
        else if (numberOfSprites == 3) {
            this._grossini.setPosition(cc.p(60, winSize.height / 2));
            this._tamara.setPosition(cc.p(60, 2 * winSize.height / 3));
            this._kathia.setPosition(cc.p(60, winSize.height / 3));
        }
    },

    title:function () {
        return "No Title";
    },

    subtitle:function () {
        return "";
    },

    code:function () {
        return "";
    },

    restartCallback:function (sender) {
        restartScene();
    },

    nextCallback:function (sender) {
        nextScene();
    },

    backCallback:function (sender) {
       previousScene();
    },

    onEnter:function () {
        // DO NOT CALL this._super()
//        this._super();

        // add title and subtitle
        var label = cc.LabelTTF.create(this.title(), "Arial", 28);
        this.addChild(label, 1);
        label.setPosition( cc.p(winSize.width / 2, winSize.height - 40));

        var strSubtitle = this.subtitle();
        if (strSubtitle != "") {
            var l = cc.LabelTTF.create(strSubtitle, "Thonburi", 16);
            this.addChild(l, 1);
            l.setPosition( cc.p(winSize.width / 2, winSize.height - 70));
        }

        var strCode = this.code();
        if( strCode !="" ) {
            var label = cc.LabelTTF.create(strCode, 'CourierNewPSMT', 16);
            label.setPosition( cc.p( winSize.width/2, winSize.height-120) );
            this.addChild( label,10 );

            var labelbg = cc.LabelTTF.create(strCode, 'CourierNewPSMT', 16);
            labelbg.setColor( cc.c3(10,10,255) );
            labelbg.setPosition( cc.p( winSize.width/2 +1, winSize.height-120 -1) );
            this.addChild( labelbg,9);
        }

        // Menu
        var item1 = cc.MenuItemImage.create("b1.png", "b2.png", this, this.backCallback);
        var item2 = cc.MenuItemImage.create("r1.png", "r2.png", this, this.restartCallback);
        var item3 = cc.MenuItemImage.create("f1.png", "f2.png", this, this.nextCallback);

        var menu = cc.Menu.create(item1, item2, item3 );

        menu.setPosition( cc.p(0,0) );
        item1.setPosition( cc.p(winSize.width / 2 - 100, 30));
        item2.setPosition( cc.p(winSize.width / 2, 30));
        item3.setPosition( cc.p(winSize.width / 2 + 100, 30));

        this.addChild(menu, 1);

        // Setup Sprites for this:w
        this._grossini = cc.Sprite.create("grossini.png");
        this._tamara = cc.Sprite.create("grossinis_sister1.png");
        this._kathia = cc.Sprite.create("grossinis_sister2.png");
        this.addChild(this._grossini, 1);
        this.addChild(this._tamara, 2);
        this.addChild(this._kathia, 3);
        this._grossini.setPosition(cc.p(winSize.width / 2, winSize.height / 3));
        this._tamara.setPosition(cc.p(winSize.width / 2, 2 * winSize.height / 3));
        this._kathia.setPosition(cc.p(winSize.width / 2, winSize.height / 2));
    }
});

//------------------------------------------------------------------
//
// ActionManual
//
//------------------------------------------------------------------
var ActionManual = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this._tamara.setScaleX(2.5);
        //window.tam = this._tamara;
        this._tamara.setScaleY(-1.0);
        this._tamara.setPosition(cc.p(100, 70));
        this._tamara.setOpacity(128);

        this._grossini.setRotation(120);
        this._grossini.setPosition(cc.p(winSize.width / 2, winSize.height / 2));
        this._grossini.setColor( cc.c3(255, 0, 0) );

        this._kathia.setPosition(cc.p(winSize.width - 100, winSize.height / 2));
        this._kathia.setColor(cc.c3(0,0,255) );

    },
    title:function () {
        return "Manual Transformation";
    },
    code:function () {
        return "sprite.setPosition( cc.p(10,20) );\n" +
                "sprite.setRotation( 90 );\n" +
                "sprite.setScale( 2 );";
    }

});


//------------------------------------------------------------------
//
//	ActionMove
//
//------------------------------------------------------------------
var ActionMove = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this.centerSprites(3);

        var actionTo = cc.MoveTo.create(2, cc.p(winSize.width - 40, winSize.height - 40));

        var actionBy = cc.MoveBy.create(2, cc.p(80, 80));
        var actionByBack = actionBy.reverse();

        this._tamara.runAction(actionTo);
        this._grossini.runAction(cc.Sequence.create(actionBy, actionByBack));
        this._kathia.runAction(cc.MoveTo.create(1, cc.p(40, 40)));
    },
    title:function () {
        return "MoveTo / MoveBy";
    },
    code:function () {
        return "a = cc.MoveBy.create( time, cc.p(x,y) );\n" +
               "a = cc.MoveTo.create( time, cc.p(x,y) );";
    },
});

//------------------------------------------------------------------
//
// ActionScale
//
//------------------------------------------------------------------
var ActionScale = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this.centerSprites(3);

        var actionTo = cc.ScaleTo.create(2, 0.5);
        var actionBy = cc.ScaleBy.create(2, 2);
        var actionBy2 = cc.ScaleBy.create(2, 0.25, 4.5);
        var actionByBack = actionBy.reverse();
        var actionBy2Back = actionBy2.reverse();

        this._tamara.runAction(actionTo);
        this._kathia.runAction(cc.Sequence.create(actionBy2, actionBy2Back) );
        this._grossini.runAction(cc.Sequence.create(actionBy, actionByBack) );

    },
    title:function () {
        return "ScaleTo / ScaleBy";
    },
    code:function () {
        return "a = cc.ScaleBy.create( time, scale );\n" +
               "a = cc.ScaleTo.create( time, scaleX, scaleY );";
    },
});

//------------------------------------------------------------------
//
//	ActionSkew
//
//------------------------------------------------------------------
var ActionSkew = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.centerSprites(3);
        var actionTo = cc.SkewTo.create(2, 37.2, -37.2);
        var actionToBack = cc.SkewTo.create(2, 0, 0);
        var actionBy = cc.SkewBy.create(2, 0, -90);
        var actionBy2 = cc.SkewBy.create(2, 45.0, 45.0);
        var actionByBack = actionBy.reverse();
        var actionBy2Back = actionBy2.reverse();


        this._tamara.runAction(cc.Sequence.create(actionTo, actionToBack ));
        this._grossini.runAction(cc.Sequence.create(actionBy, actionByBack ));

        this._kathia.runAction(cc.Sequence.create(actionBy2, actionBy2Back ));


    },
    title:function () {
        return "SkewTo / SkewBy";
    },
    code:function () {
        return "a = cc.SkewBy.create( time, skew );\n" +
               "a = cc.SkewTo.create( time, skewX, skewY );";
    },
});

//------------------------------------------------------------------
//
//	ActionSkewRotateScale
//
//------------------------------------------------------------------
var ActionSkewRotateScale = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this._tamara.removeFromParentAndCleanup(true);
        this._grossini.removeFromParentAndCleanup(true);
        this._kathia.removeFromParentAndCleanup(true);

        var boxSize = cc.size(100.0, 100.0);
        var box = cc.LayerColor.create(cc.c4(255, 255, 0, 255));
        box.setAnchorPoint(cc.p(0, 0));
        box.setPosition(cc.p((winSize.width - boxSize[0]) / 2, (winSize.height - boxSize[1]) / 2));
        box.setContentSize(boxSize);

        var markrside = 10.0;
        var uL = cc.LayerColor.create(cc.c4(255, 0, 0, 255));
        box.addChild(uL);
        uL.setContentSize(cc.size(markrside, markrside));
        uL.setPosition(cc.p(0, boxSize[1] - markrside));
        uL.setAnchorPoint(cc.p(0, 0));

        var uR = cc.LayerColor.create(cc.c4(0, 0, 255, 255));
        box.addChild(uR);
        uR.setContentSize(cc.size(markrside, markrside));
        uR.setPosition(cc.p(boxSize[0] - markrside, boxSize[1] - markrside));
        uR.setAnchorPoint(cc.p(0, 0));


        this.addChild(box);
        var actionTo = cc.SkewTo.create(2, 0., 2.);
        var rotateTo = cc.RotateTo.create(2, 61.0);
        var actionScaleTo = cc.ScaleTo.create(2, -0.44, 0.47);

        var actionScaleToBack = cc.ScaleTo.create(2, 1.0, 1.0);
        var rotateToBack = cc.RotateTo.create(2, 0);
        var actionToBack = cc.SkewTo.create(2, 0, 0);

        box.runAction(cc.Sequence.create(actionTo, actionToBack ));
        box.runAction(cc.Sequence.create(rotateTo, rotateToBack ));
        box.runAction(cc.Sequence.create(actionScaleTo, actionScaleToBack ));
    },
    title:function () {
        return "Skew + Rotate + Scale";
    },
});

//------------------------------------------------------------------
//
//	ActionRotate
//
//------------------------------------------------------------------
var ActionRotate = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.centerSprites(3);
        var actionTo = cc.RotateTo.create(2, 45);
        var actionTo2 = cc.RotateTo.create(2, -45);
        var actionTo0 = cc.RotateTo.create(2, 0);
        this._tamara.runAction(cc.Sequence.create(actionTo, actionTo0));

        var actionBy = cc.RotateBy.create(2, 360);
        var actionByBack = actionBy.reverse();
        this._grossini.runAction(cc.Sequence.create(actionBy, actionByBack ));

        this._kathia.runAction(cc.Sequence.create(actionTo2, actionTo0.copy() ));

    },
    title:function () {
        return "RotateTo / RotateBy";
    },
    code:function () {
        return "a = cc.RotateBy.create( time, degrees );\n" +
                "a = cc.RotateTo.create( time, degrees );";
    },
});


//------------------------------------------------------------------
//
// ActionJump
//
//------------------------------------------------------------------
var ActionJump = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.centerSprites(3);

        var actionTo = cc.JumpTo.create(2, cc.p(300, 300), 50, 4);
        var actionBy = cc.JumpBy.create(2, cc.p(300, 0), 50, 4);
        var actionUp = cc.JumpBy.create(2, cc.p(0, 0), 80, 4);
        var actionByBack = actionBy.reverse();

        this._tamara.runAction(actionTo);
        this._grossini.runAction(cc.Sequence.create(actionBy, actionByBack ));
        this._kathia.runAction(cc.RepeatForever.create(actionUp));

    },
    title:function () {
        return "JumpTo / JumpBy";
    },
    code:function () {
        return "a = cc.JumpBy.create( time, point, height, #_of_jumps );\n" +
               "a = cc.JumpTo.create( time, point, height, #_of_jumps );";
    },
});

//------------------------------------------------------------------
//
// ActionBezier
//
//------------------------------------------------------------------
var ActionBezier = BaseLayer.extend({
    onEnter:function () {
        this._super();

        //
        // startPosition can be any coordinate, but since the movement
        // is relative to the Bezier curve, make it (0,0)
        //

        this.centerSprites(3);

        // sprite 1
        var bezier = new cc.BezierConfig();
        bezier.controlPoint_1 = cc.p(0, winSize.height / 2);
        bezier.controlPoint_2 = cc.p(300, -winSize.height / 2);
        bezier.endPosition = cc.p(300, 100);

        var bezierForward = cc.BezierBy.create(3, bezier);
        var bezierBack = bezierForward.reverse();
        var rep = cc.RepeatForever.create(cc.Sequence.create(bezierForward, bezierBack ));


        // sprite 2
        this._tamara.setPosition(cc.p(80, 160));
        var bezier2 = new cc.BezierConfig();
        bezier2.controlPoint_1 = cc.p(100, winSize.height / 2);
        bezier2.controlPoint_2 = cc.p(200, -winSize.height / 2);
        bezier2.endPosition = cc.p(240, 160);

        var bezierTo1 = cc.BezierTo.create(2, bezier2);

        // sprite 3
        this._kathia.setPosition(cc.p(400, 160));
        var bezierTo2 = cc.BezierTo.create(2, bezier2);

        this._grossini.id = "gro";
        this._tamara.id = "tam";
        this._kathia.id = "kat";

        this._grossini.runAction(rep);
        this._tamara.runAction(bezierTo1);
        this._kathia.runAction(bezierTo2);

    },
    title:function () {
        return "BezierBy / BezierTo";
    }
});
//------------------------------------------------------------------
//
// ActionBlink
//
//------------------------------------------------------------------
var ActionBlink = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.centerSprites(2);

        var action1 = cc.Blink.create(2, 10);
        var action2 = cc.Blink.create(2, 5);

        this._tamara.runAction(action1);
        this._kathia.runAction(action2);

    },
    title:function () {
        return "Blink";
    },
    code:function () {
        return "a = cc.Blink.create( time, #_of_blinks );\n";
    },
});
//------------------------------------------------------------------
//
// ActionFade
//
//------------------------------------------------------------------
var ActionFade = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.centerSprites(2);
        this._tamara.setOpacity(0);
        var action1 = cc.FadeIn.create(1.0);
        var action1Back = action1.reverse();

        var action2 = cc.FadeOut.create(1.0);
        var action2Back = action2.reverse();

        this._tamara.runAction(cc.Sequence.create(action1, action1Back ));
        this._kathia.runAction(cc.Sequence.create(action2, action2Back ));


    },
    title:function () {
        return "FadeIn / FadeOut";
    },
    code:function () {
        return "" +
            "a = cc.FadeIn.create( time );\n" +
            "a = cc.FadeOut.create( time );\n"
    },
});
//------------------------------------------------------------------
//
// ActionTint
//
//------------------------------------------------------------------
var ActionTint = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.centerSprites(2);

        var action1 = cc.TintTo.create(2, 255, 0, 255);
        var action2 = cc.TintBy.create(2, -127, -255, -127);
        var action2Back = action2.reverse();

        this._tamara.runAction(action1);
        this._kathia.runAction(cc.Sequence.create(action2, action2Back));

    },
    title:function () {
        return "TintTo / TintBy";
    },
    code:function () {
        return "" +
            "a = cc.TintBy.create( time, red, green, blue );\n" +
            "a = cc.TintTo.create( time, red, green, blue );\n"
    },
});

//------------------------------------------------------------------
//
// ActionAnimate
//
//------------------------------------------------------------------
var ActionAnimate = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.centerSprites(1);

        var animation = cc.Animation.create();
        animation.setDelayPerUnit( 0.3 );
        for (var i = 1; i < 15; i++) {
            var frameName = "grossini_dance_" + ((i < 10) ? ("0" + i) : i) + ".png";
            animation.addSpriteFrameWithFilename(frameName);
        }

        var action = cc.Animate.create( animation );
        var action_back = action.reverse();

        this._grossini.runAction(cc.Sequence.create(action, action_back ));

    },
    title:function () {
        return "Animation";
    },
    code:function () {
        return "" +
            "a = cc.Animate.create( animation );\n";
    },
});

//------------------------------------------------------------------
//
//	ActionSequence
//
//------------------------------------------------------------------
var ActionSequence = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.alignSpritesLeft(1);

        var action = cc.Sequence.create(
            cc.MoveBy.create(2, cc.p(240, 0)),
            cc.RotateBy.create(2, 540) );

        this._grossini.runAction(action);

    },
    title:function () {
        return "Sequence: Move + Rotate";
    },
    code:function () {
        return "" +
            "a = cc.Sequence.create( a1, a2, a3,..., aN);\n";
    },
});
//------------------------------------------------------------------
//
//	ActionSequence2
//
//------------------------------------------------------------------
var ActionSequence2 = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.centerSprites(1);
        this._grossini.setVisible(false);
        var action = cc.Sequence.create(
            cc.Place.create(cc.p(200, 200)),
            cc.Show.create(),
            cc.MoveBy.create(1, cc.p(100, 0)),
            cc.CallFunc.create(this, this.callback1),
            cc.CallFunc.create(this, this.callback2),
            cc.CallFunc.create(this, this.callback3) );
        this._grossini.runAction(action);

    },
    callback1:function () {
        var label = cc.LabelTTF.create("callback 1 called", "Marker Felt", 16);
        label.setPosition(cc.p(winSize.width / 4 * 1, winSize.height / 2));

        this.addChild(label);
    },
    callback2:function () {
        var label = cc.LabelTTF.create("callback 2 called", "Marker Felt", 16);
        label.setPosition(cc.p(winSize.width / 4 * 2, winSize.height / 2));

        this.addChild(label);
    },
    callback3:function () {
        var label = cc.LabelTTF.create("callback 3 called", "Marker Felt", 16);
        label.setPosition(cc.p(winSize.width / 4 * 3, winSize.height / 2));

        this.addChild(label);
    },
    title:function () {
        return "Sequence of InstantActions";
    }
});
//------------------------------------------------------------------
//
//	ActionCallFunc
//
//------------------------------------------------------------------
var ActionCallFunc = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.centerSprites(3);

        var action = cc.Sequence.create(
            cc.MoveBy.create(2, cc.p(200, 0)),
            cc.CallFunc.create(this, this.callback1)
        );

        var action2 = cc.Sequence.create(
            cc.ScaleBy.create(2, 2),
            cc.FadeOut.create(2),
            cc.CallFunc.create(this, this.callback2)
        );

        var action3 = cc.Sequence.create(
            cc.RotateBy.create(3, 360),
            cc.FadeOut.create(2),
            cc.CallFunc.create(this, this.callback3, 0xbebabeba)
        );

        this._grossini.runAction(action);
        this._tamara.runAction(action2);
        this._kathia.runAction(action3);

    },
    callback1:function () {
        var label = cc.LabelTTF.create("callback 1 called", "Marker Felt", 16);
        label.setPosition(cc.p(winSize.width / 4 * 1, winSize.height / 2));
        this.addChild(label);
    },
    callback2:function () {
        var label = cc.LabelTTF.create("callback 2 called", "Marker Felt", 16);
        label.setPosition(cc.p(winSize.width / 4 * 2, winSize.height / 2));

        this.addChild(label);
    },
    callback3:function () {
        var label = cc.LabelTTF.create("callback 3 called", "Marker Felt", 16);
        label.setPosition(cc.p(winSize.width / 4 * 3, winSize.height / 2));
        this.addChild(label);
    },
    title:function () {
        return "Callbacks: CallFunc and friends";
    },
    code:function () {
        return "" +
            "a = cc.CallFunc.create( this, this.callback );\n" +
            "a = cc.CallFunc.create( this, this.callback, optional_arg );";
    },
});
//------------------------------------------------------------------
//
// ActionCallFuncND
//
//------------------------------------------------------------------
var ActionCallFuncND = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.centerSprites(1);

        var action = cc.Sequence.create(cc.MoveBy.create(2.0, cc.p(200, 0)),
            cc.CallFunc.create(this, this.removeGrossini, this._grossini) );

        this._grossini.runAction(action);

    },

    removeGrossini : function( spriteToRemove ) {
        spriteToRemove.removeFromParentAndCleanup( true );
    },

    title:function () {
        return "CallFunc + auto remove";
    },
    subtitle:function () {
        return "CallFunc + removeFromParentAndCleanup. Grossini dissapears in 2s";
    },
    code:function () {
        return "" +
            "a = cc.CallFunc.create( this, this.callback );\n" +
            "a = cc.CallFunc.create( this, this.callback, optional_arg );";
    },
});
//------------------------------------------------------------------
//
// ActionSpawn
//
//------------------------------------------------------------------
var ActionSpawn = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.alignSpritesLeft(1);

        var action = cc.Spawn.create(
            cc.JumpBy.create(2, cc.p(300, 0), 50, 4),
            cc.RotateBy.create(2, 720) );

        this._grossini.runAction(action);

    },
    title:function () {
        return "Spawn: Jump + Rotate";
    },
    code:function () {
        return "" +
            "a = cc.Spawn.create( a1, a2, ..., aN );";
    },
});
//------------------------------------------------------------------
//
// ActionRepeatForever
//
//------------------------------------------------------------------
var ActionRepeatForever = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.centerSprites(1);
        var action = cc.Sequence.create(
            cc.DelayTime.create(1),
            cc.CallFunc.create(this, this.repeatForever) );

        this._grossini.runAction(action);


    },
    repeatForever:function (sender) {
        var repeat = cc.RepeatForever.create(cc.RotateBy.create(1.0, 360));
        sender.runAction(repeat)
    },
    title:function () {
        return "CallFunc + RepeatForever";
    },
    code:function () {
        return "" +
            "a = cc.RepeatForever.create( action_to_repeat );";
    },
});
//------------------------------------------------------------------
//
// ActionRotateToRepeat
//
//------------------------------------------------------------------
var ActionRotateToRepeat = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.centerSprites(2);

        var act1 = cc.RotateTo.create(1, 90);
        var act2 = cc.RotateTo.create(1, 0);
        var seq = cc.Sequence.create(act1, act2);
        var rep1 = cc.RepeatForever.create(seq);
        var rep2 = cc.Repeat.create((seq.copy()), 10);

        this._tamara.runAction(rep1);
        this._kathia.runAction(rep2);

    },
    title:function () {
        return "Repeat/RepeatForever + RotateTo";
    },
    code:function () {
        return "" +
            "a = cc.Repeat.create( action_to_repeat, #_of_times );";
    },
});
//------------------------------------------------------------------
//
// ActionRotateJerk
//
//------------------------------------------------------------------
var ActionRotateJerk = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.centerSprites(2);
        var seq = cc.Sequence.create(
            cc.RotateTo.create(0.5, -20),
            cc.RotateTo.create(0.5, 20) );

        var rep1 = cc.Repeat.create(seq, 10);
        var rep2 = cc.RepeatForever.create((seq.copy()));

        this._tamara.runAction(rep1);
        this._kathia.runAction(rep2);
    },
    title:function () {
        return "RepeatForever / Repeat + Rotate";
    }
});
//------------------------------------------------------------------
//
// ActionReverse
//
//------------------------------------------------------------------
var ActionReverse = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.alignSpritesLeft(1);

        var jump = cc.JumpBy.create(2, cc.p(300, 0), 50, 4);
        var action = cc.Sequence.create(jump, jump.reverse() );

        this._grossini.runAction(action);
    },
    title:function () {
        return "Reverse an action";
    },
    code:function () {
        return "" +
            "a = action.reverse();";
    },
});
//------------------------------------------------------------------
//
// ActionDelayTime
//
//------------------------------------------------------------------
var ActionDelayTime = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.alignSpritesLeft(1);

        var move = cc.MoveBy.create(1, cc.p(150, 0));
        var action = cc.Sequence.create(move, cc.DelayTime.create(2), move );

        this._grossini.runAction(action);
    },
    title:function () {
        return "DelayTime: m + delay + m";
    },
    code:function () {
        return "" +
            "a = cc.DelayTime.create( time );";
    },
});
//------------------------------------------------------------------
//
// ActionReverseSequence
//
//------------------------------------------------------------------
var ActionReverseSequence = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.alignSpritesLeft(1);

        var move1 = cc.MoveBy.create(1, cc.p(250, 0));
        var move2 = cc.MoveBy.create(1, cc.p(0, 50));
        var seq = cc.Sequence.create(move1, move2, move1.reverse() );
        var action = cc.Sequence.create(seq, seq.reverse() );

        this._grossini.runAction(action);

    },
    title:function () {
        return "Reverse a sequence";
    }
});
//------------------------------------------------------------------
//
// ActionReverseSequence2
//
//------------------------------------------------------------------
var ActionReverseSequence2 = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.alignSpritesLeft(2);


        // Test:
        //   Sequence should work both with IntervalAction and InstantActions
        var move1 = cc.MoveBy.create(3, cc.p(250, 0));
        var move2 = cc.MoveBy.create(3, cc.p(0, 50));
        var tog1 = cc.ToggleVisibility.create();
        var tog2 = cc.ToggleVisibility.create();
        var seq = cc.Sequence.create(move1, tog1, move2, tog2, move1.reverse() );
        var action = cc.Repeat.create(
            cc.Sequence.create(
                seq,
                seq.reverse()
            ),
            3
        );


        // Test:
        //   Also test that the reverse of Hide is Show, and vice-versa
        this._kathia.runAction(action);

        var move_tamara = cc.MoveBy.create(1, cc.p(100, 0));
        var move_tamara2 = cc.MoveBy.create(1, cc.p(50, 0));
        var hide = cc.Hide.create()
        var seq_tamara = cc.Sequence.create(move_tamara, hide, move_tamara2 );
        var seq_back = seq_tamara.reverse();
        this._tamara.runAction(cc.Sequence.create(seq_tamara, seq_back ));
    },
    title:function () {
        return "Reverse sequence 2";
    }
});
//------------------------------------------------------------------
//
// ActionRepeat
//
//------------------------------------------------------------------
var ActionRepeat = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.alignSpritesLeft(2);


        var a1 = cc.MoveBy.create(1, cc.p(150, 0));
        var action1 = cc.Repeat.create(
            cc.Sequence.create(cc.Place.create(cc.p(60, 60)), a1 ),
            3);
        var action2 = cc.RepeatForever.create(
            (cc.Sequence.create((a1.copy()), a1.reverse() ))
        );

        this._kathia.runAction(action1);
        this._tamara.runAction(action2);
    },
    title:function () {
        return "Repeat / RepeatForever actions";
    }
});
//------------------------------------------------------------------
//
// ActionOrbit
//
//------------------------------------------------------------------
var ActionOrbit = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.centerSprites(3);

        var orbit1 = cc.OrbitCamera.create(2, 1, 0, 0, 180, 0, 0);
        var action1 = cc.Sequence.create(
            orbit1,
            orbit1.reverse());

        var orbit2 = cc.OrbitCamera.create(2, 1, 0, 0, 180, -45, 0);
        var action2 = cc.Sequence.create(
            orbit2,
            orbit2.reverse());

        var orbit3 = cc.OrbitCamera.create(2, 1, 0, 0, 180, 90, 0);
        var action3 = cc.Sequence.create(
            orbit3,
            orbit3.reverse() );

        this._kathia.runAction(cc.RepeatForever.create(action1));
        this._tamara.runAction(cc.RepeatForever.create(action2));
        this._grossini.runAction(cc.RepeatForever.create(action3));

        var move = cc.MoveBy.create(3, cc.p(100, -100));
        var move_back = move.reverse();
        var seq = cc.Sequence.create(move, move_back );
        var rfe = cc.RepeatForever.create(seq);
        this._kathia.runAction(rfe);
        this._tamara.runAction((rfe.copy()));
        this._grossini.runAction((rfe.copy()));

    },
    title:function () {
        return "OrbitCamera action";
    }
});
//------------------------------------------------------------------
//
// ActionFollow
//
//------------------------------------------------------------------
var ActionFollow = BaseLayer.extend({
    onEnter:function () {
        this._super();
        this.centerSprites(1);

        this._grossini.setPosition(cc.p(-200, winSize.height / 2));
        var move = cc.MoveBy.create(2, cc.p(winSize.width * 3, 0));
        var move_back = move.reverse();
        var seq = cc.Sequence.create(move, move_back );
        var rep = cc.RepeatForever.create(seq);

        this._grossini.runAction(rep);

        this.runAction(cc.Follow.create(this._grossini, cc.rect(0, 0, winSize.width * 2 - 100, winSize.height)));
    },
    title:function () {
        return "Follow action";
    }
});

//------------------------------------------------------------------
//
// ActionCardinalSpline
//
//------------------------------------------------------------------
var ActionCardinalSpline = BaseLayer.extend({

    onEnter:function () {
        this._super();

        this.centerSprites(2);

        var array = cc.PointArray.create(10);

        array.addControlPoint(cc.p(0, 0));
        array.addControlPoint(cc.p(winSize.width / 2 - 30, 0));
        array.addControlPoint(cc.p(winSize.width / 2 - 30, winSize.height - 80));
        array.addControlPoint(cc.p(0, winSize.height - 80));
        array.addControlPoint(cc.p(0, 0));

        //
        // sprite 1 (By)
        //
        // Spline with no tension (tension==0)
        //
        var action1 = cc.CardinalSplineBy.create(3, array, 0);
        var reverse1 = action1.reverse();
        var seq = cc.Sequence.create(action1, reverse1);

        this._tamara.setPosition(cc.p(50, 50));
        this._tamara.runAction(seq);

        //
        // sprite 2 (By)
        //
        // Spline with high tension (tension==1)
        //
        var action2 = cc.CardinalSplineBy.create(3, array, 1);
        var reverse2 = action2.reverse();
        var seq2 = cc.Sequence.create(action2, reverse2);

        this._kathia.setPosition(cc.p(winSize.width / 2, 50));
        this._kathia.runAction(seq2);
    },

    subtitle:function () {
        return "Cardinal Spline paths. Testing different tensions for one array";
    },
    title:function () {
        return "CardinalSplineBy / CardinalSplineAt";
    },
    code:function() {
        return "" +
            " a = cc.CadinalSplineBy.create( time, array_of_points, tension );\n" +
            " a = cc.CadinalSplineTo.create( time, array_of_points, tension );\n";
    
    },
});

//------------------------------------------------------------------
//
// ActionCatmullRom
//
//------------------------------------------------------------------
var ActionCatmullRom = BaseLayer.extend({

    onEnter:function () {
        this._super();

        this.centerSprites(2);

        var array1 = cc.PointArray.create( 10 );
        var array2 = cc.PointArray.create( 10 );

        //
        // sprite 1 (By)
        //
        // startPosition can be any coordinate, but since the movement
        // is relative to the Catmull Rom curve, it is better to start with (0,0).
        //
        this._tamara.setPosition(cc.p(50, 50));

        array1.addControlPoint(cc.p(0, 0));
        array1.addControlPoint(cc.p(80, 80));
        array1.addControlPoint(cc.p(winSize.width - 80, 80));
        array1.addControlPoint(cc.p(winSize.width - 80, winSize.height - 80));
        array1.addControlPoint(cc.p(80, winSize.height - 80));
        array1.addControlPoint(cc.p(80, 80));
        array1.addControlPoint(cc.p(winSize.width / 2, winSize.height / 2));

        var action1 = cc.CatmullRomBy.create(3, array1);
        var reverse1 = action1.reverse();
        var seq1 = cc.Sequence.create(action1, reverse1);

        this._tamara.runAction(seq1);

        //
        // sprite 2 (To)
        //
        // The startPosition is not important here, because it uses a "To" action.
        // The initial position will be the 1st point of the Catmull Rom path
        //
        array2.addControlPoint(cc.p(winSize.width / 2, 30));
        array2.addControlPoint(cc.p(winSize.width - 80, 30));
        array2.addControlPoint(cc.p(winSize.width - 80, winSize.height - 80));
        array2.addControlPoint(cc.p(winSize.width / 2, winSize.height - 80));
        array2.addControlPoint(cc.p(winSize.width / 2, 30));

        var action2 = cc.CatmullRomTo.create(3, array2);
        var reverse2 = action2.reverse();

        var seq2 = cc.Sequence.create(action2, reverse2);

        this._kathia.runAction(seq2);
    },
    subtitle:function () {
        return "Catmull Rom spline paths. Testing reverse too";
    },
    title:function () {
        return "CatmullRomBy / CatmullRomTo";
    },
    code:function() {
        return "" +
            " a = cc.CatmullRomBy.create( time, array_of_points );\n" +
            " a = cc.CatmullRomTo.create( time, array_of_points );\n";
    },
});

//
// Order of tests
//

scenes.push( ActionManual );
scenes.push( ActionMove );
scenes.push( ActionScale );
scenes.push( ActionRotate );
scenes.push( ActionSkew );
scenes.push( ActionSkewRotateScale );
scenes.push( ActionJump );
//scenes.push( ActionBezier );
scenes.push( ActionCardinalSpline );
scenes.push( ActionCatmullRom );
scenes.push( ActionBlink );
scenes.push( ActionFade );
scenes.push( ActionTint );
scenes.push( ActionSequence );
scenes.push( ActionSequence2 );
scenes.push( ActionSpawn );
scenes.push( ActionReverse );
scenes.push( ActionDelayTime );
scenes.push( ActionRepeat );
scenes.push( ActionRepeatForever );
scenes.push( ActionRotateToRepeat );
scenes.push( ActionRotateJerk );
scenes.push( ActionCallFunc );
scenes.push( ActionCallFuncND );
scenes.push( ActionReverseSequence );
scenes.push( ActionReverseSequence2 );
scenes.push( ActionAnimate );


//------------------------------------------------------------------
//
// Main entry point
//
//------------------------------------------------------------------
function run()
{
    var scene = cc.Scene.create();
    var layer = new scenes[currentScene]();
    scene.addChild( layer );

    director.runWithScene( scene );
}

run();

