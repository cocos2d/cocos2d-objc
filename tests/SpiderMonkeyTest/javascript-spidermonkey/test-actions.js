//
// http://www.cocos2d-iphone.org
//
// Javascript + cocos2d sprite tests
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

//------------------------------------------------------------------
//
// BaseLayer
//
//------------------------------------------------------------------
var BaseLayer = function() {

	//
	// VERY IMPORTANT
	//
	// Only subclasses of a native classes MUST call __associateObjectWithNative
	// Failure to do so, it will crash.
	//
	var parent = goog.base(this);
	__associateObjWithNative( this, parent );
	this.init( cc.c4(0,0,0,255), cc.c4(0,128,255,255));

	this.title =  "No title";
	this.subtitle = "";

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
goog.inherits(BaseLayer, cc.LayerGradient );

//
// Instance 'base' methods
// XXX: Should be defined after "goog.inherits"
//
BaseLayer.prototype.onEnter = function() {

	var label = cc.LabelTTF.create(this.title, "Arial", 28);
	this.addChild(label, 1);
	label.setPosition( cc.p(winSize.width / 2, winSize.height - 50));

	var strSubtitle = this.subtitle;
	if (strSubtitle != "") {
	    var l = cc.LabelTTF.create(strSubtitle, "Thonburi", 16);
	    this.addChild(l, 1);
	    l.setPosition( cc.p(winSize.width / 2, winSize.height - 80));
	}


	// WARNING: MenuItem API will change!
	var item1 = cc.MenuItemImage.itemWithNormalImageSelectedImageBlock("b1.png", "b2.png", this.backCallback);
	var item2 = cc.MenuItemImage.itemWithNormalImageSelectedImageBlock("r1.png", "r2.png", this.restartCallback);
	var item3 = cc.MenuItemImage.itemWithNormalImageSelectedImageBlock("f1.png", "f2.png", this.nextCallback);

	var menu = cc.Menu.create( item1, item2, item3 );

	menu.setPosition( cc.p(0,0) );
	item1.setPosition( cc.p(winSize.width / 2 - 100, 30));
	item2.setPosition( cc.p(winSize.width / 2, 30));
	item3.setPosition( cc.p(winSize.width / 2 + 100, 30));

	this.addChild(menu, 80);
}

BaseLayer.prototype.restartCallback = function (sender) {
	restartScene();
}

BaseLayer.prototype.nextCallback = function (sender) {
	nextScene();
}

BaseLayer.prototype.backCallback = function (sender) {
	previousScene();
}

BaseLayer.prototype.centerSprites = function (numberOfSprites) {

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
}

BaseLayer.prototype.alignSpritesLeft = function (numberOfSprites) {

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
}

//------------------------------------------------------------------
//
// ActionManual
//
//------------------------------------------------------------------
var ActionManual = function() {
	goog.base(this);

    this.onEnter = function () {
        goog.base(this, 'onEnter');


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
    }

    this.title = "Manual Transformation!";

}
goog.inherits( ActionManual, BaseLayer );



//------------------------------------------------------------------
//
//	ActionMove
//
//------------------------------------------------------------------
var ActionMove = function() {

	goog.base(this);

    this.onEnter = function () {
        goog.base(this, 'onEnter');

        this.centerSprites(3);

        var actionTo = cc.MoveTo.create(2, cc.p(winSize.width - 40, winSize.height - 40));

        var actionBy = cc.MoveBy.create(2, cc.p(80, 80));
        var actionByBack = actionBy.reverse();

        this._tamara.runAction(actionTo);
        this._grossini.runAction(cc.Sequence.create(actionBy, actionByBack));
        this._kathia.runAction(cc.MoveTo.create(1, cc.p(40, 40)));
    }

    this.title = "MoveTo / MoveBy";

}
goog.inherits( ActionMove, BaseLayer );

//------------------------------------------------------------------
//
// ActionScale
//
//------------------------------------------------------------------
var ActionScale = function() {

	goog.base(this);

    this.onEnter = function () {
        goog.base(this, 'onEnter');

        this.centerSprites(3);

        var actionTo = cc.ScaleTo.create(2, 0.5);
        var actionBy = cc.ScaleBy.create(2, 2);
        var actionBy2 = cc.ScaleBy.create(2, 0.25, 4.5);
        var actionByBack = actionBy.reverse();
        var actionBy2Back = actionBy2.reverse();

        this._tamara.runAction(actionTo);
        this._kathia.runAction(cc.Sequence.create(actionBy2, actionBy2Back));
        this._grossini.runAction(cc.Sequence.create(actionBy, actionByBack));

    }
    this.title = "ScaleTo / ScaleBy";

}
goog.inherits( ActionScale, BaseLayer );

//------------------------------------------------------------------
//
//	ActionSkew
//
//------------------------------------------------------------------
var ActionSkew = function() {

	goog.base(this);

    this.onEnter = function () {
        goog.base(this, 'onEnter');

        this.centerSprites(3);
        var actionTo = cc.SkewTo.create(2, 37.2, -37.2);
        var actionToBack = cc.SkewTo.create(2, 0, 0);
        var actionBy = cc.SkewBy.create(2, 0, -90);
        var actionBy2 = cc.SkewBy.create(2, 45.0, 45.0);
        var actionByBack = actionBy.reverse();
        var actionBy2Back = actionBy2.reverse();


        this._tamara.runAction(cc.Sequence.create(actionTo, actionToBack));
        this._grossini.runAction(cc.Sequence.create(actionBy, actionByBack));

        this._kathia.runAction(cc.Sequence.create(actionBy2, actionBy2Back));


    }

    this.title = "SkewTo / SkewBy";
}
goog.inherits( ActionSkew, BaseLayer );

var ActionSkewRotateScale = function() {

	goog.base(this);

    this.onEnter = function () {

        goog.base(this, 'onEnter');
        this._tamara.removeFromParentAndCleanup(true);
        this._grossini.removeFromParentAndCleanup(true);
        this._kathia.removeFromParentAndCleanup(true);

        var boxSize = cc.size(100.0, 100.0);
        var box = cc.LayerColor.create(cc.c4(255, 255, 0, 255));
        box.setAnchorPoint(cc.p(0, 0));
        box.setPosition( cc.p( (winSize.width - cc.size_get_width(boxSize) ) / 2,
				(winSize.height - cc.size_get_height(boxSize)) / 2
				) );
        box.setContentSize(boxSize);

        var markrside = 10.0;
        var uL = cc.LayerColor.create(cc.c4(255, 0, 0, 255));
        box.addChild(uL);
        uL.setContentSize(cc.size(markrside, markrside));
        uL.setPosition(cc.p(0, cc.size_get_height(boxSize) - markrside));
        uL.setAnchorPoint(cc.p(0, 0));

        var uR = cc.LayerColor.create(cc.c4(0, 0, 255, 255));
        box.addChild(uR);
        uR.setContentSize(cc.size(markrside, markrside));
        uR.setPosition(cc.p( cc.size_get_width(boxSize) - markrside, cc.size_get_height(boxSize) - markrside));
        uR.setAnchorPoint(cc.p(0, 0));

        this.addChild(box);
        var actionTo = cc.SkewTo.create(2, 0., 2.);
        var rotateTo = cc.RotateTo.create(2, 61.0);
        var actionScaleTo = cc.ScaleTo.create(2, -0.44, 0.47);

        var actionScaleToBack = cc.ScaleTo.create(2, 1.0, 1.0);
        var rotateToBack = cc.RotateTo.create(2, 0);
        var actionToBack = cc.SkewTo.create(2, 0, 0);

        box.runAction(cc.Sequence.create(actionTo, actionToBack) );
        box.runAction(cc.Sequence.create(rotateTo, rotateToBack) );
        box.runAction(cc.Sequence.create(actionScaleTo, actionScaleToBack) );
    }

    this.title = "Skew + Rotate + Scale";
}
goog.inherits( ActionSkewRotateScale, BaseLayer );

//------------------------------------------------------------------
//
//	ActionRotate
//
//------------------------------------------------------------------
var ActionRotate = function() {

	goog.base(this);

    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.centerSprites(3);
        var actionTo = cc.RotateTo.create(2, 45);
        var actionTo2 = cc.RotateTo.create(2, -45);
        var actionTo0 = cc.RotateTo.create(2, 0);
        this._tamara.runAction(cc.Sequence.create(actionTo, actionTo0 ) );

        var actionBy = cc.RotateBy.create(2, 360);
        var actionByBack = actionBy.reverse();
        this._grossini.runAction(cc.Sequence.create(actionBy, actionByBack ) );

        this._kathia.runAction(cc.Sequence.create(actionTo2, actionTo0.copy() ) );

    }
    this.title = "RotateTo / RotateBy";
}
goog.inherits( ActionRotate, BaseLayer );


//------------------------------------------------------------------
//
// ActionJump
//
//------------------------------------------------------------------
var ActionJump = function() {

	goog.base(this);

    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.centerSprites(3);

        var actionTo = cc.JumpTo.create(2, cc.p(300, 300), 50, 4);
        var actionBy = cc.JumpBy.create(2, cc.p(300, 0), 50, 4);
        var actionUp = cc.JumpBy.create(2, cc.p(0, 0), 80, 4);
        var actionByBack = actionBy.reverse();

        this._tamara.runAction(actionTo);
        this._grossini.runAction(cc.Sequence.create(actionBy, actionByBack) );
        this._kathia.runAction(cc.RepeatForever.create(actionUp));

    }

    this.title = "JumpTo / JumpBy";
}
goog.inherits( ActionJump, BaseLayer );

//------------------------------------------------------------------
//
// ActionBezier
//
//------------------------------------------------------------------
var ActionBezier = function() {
	goog.base(this);

    this.onEnter = function () {
        goog.base(this, 'onEnter');

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
        var rep = cc.RepeatForever.create(cc.Sequence.create(bezierForward, bezierBack) );


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

    }

    this.title = "BezierBy / BezierTo";
}
goog.inherits( ActionBezier, BaseLayer );

//------------------------------------------------------------------
//
// ActionBlink
//
//------------------------------------------------------------------
var ActionBlink = function() {

	goog.base(this);

    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.centerSprites(2);

        var action1 = cc.Blink.create(2, 10);
        var action2 = cc.Blink.create(2, 5);

        this._tamara.runAction(action1);
        this._kathia.runAction(action2);

    }

    this.title = "Blink";
}
goog.inherits( ActionBlink, BaseLayer );

//------------------------------------------------------------------
//
// ActionFade
//
//------------------------------------------------------------------
var ActionFade = function() {

	goog.base(this);

    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.centerSprites(2);
        this._tamara.setOpacity(0);
        var action1 = cc.FadeIn.create(1.0);
        var action1Back = action1.reverse();

        var action2 = cc.FadeOut.create(1.0);
        var action2Back = action2.reverse();

        this._tamara.runAction(cc.Sequence.create(action1, action1Back) );
        this._kathia.runAction(cc.Sequence.create(action2, action2Back) );


    }

    this.title = "FadeIn / FadeOut";
}
goog.inherits( ActionFade, BaseLayer );

//------------------------------------------------------------------
//
// ActionTint
//
//------------------------------------------------------------------
var ActionTint = function() {

	goog.base(this);

    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.centerSprites(2);

        var action1 = cc.TintTo.create(2, 255, 0, 255);
        var action2 = cc.TintBy.create(2, -127, -255, -127);
        var action2Back = action2.reverse();

        this._tamara.runAction(action1);
        this._kathia.runAction(cc.Sequence.create(action2, action2Back));

    }

    this.title = "TintTo / TintBy";
}
goog.inherits( ActionTint, BaseLayer );

//------------------------------------------------------------------
//
// ActionAnimate
//
//------------------------------------------------------------------
var ActionAnimate = function() {

	goog.base(this);

    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.centerSprites(1);

        var animation = cc.Animation.create();
        for (var i = 1; i < 15; i++) {
            var frameName = "Resources/Images/grossini_dance_" + ((i < 10) ? ("0" + i) : i) + ".png";
            animation.addSpriteFrameWithFileName(frameName);
        }

        var action = cc.Animate.create(3, animation, false);
        var action_back = action.reverse();

        this._grossini.runAction(cc.Sequence.create(action, action_back) );
    }

    this.title = "Animation";
}
goog.inherits( ActionAnimate, BaseLayer );

//------------------------------------------------------------------
//
//	ActionSequence
//
//------------------------------------------------------------------
var ActionSequence = function() {

	goog.base(this);

    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.alignSpritesLeft(1);

        var action = cc.Sequence.create(
            cc.MoveBy.create(2, cc.p(240, 0)),
            cc.RotateBy.create(2, 540) );

        this._grossini.runAction(action);

    }

    this.title = "Sequence: Move + Rotate";
}
goog.inherits( ActionSequence, BaseLayer );

//------------------------------------------------------------------
//
//	ActionSequence2
//
//------------------------------------------------------------------
var ActionSequence2 = function() {

	goog.base(this);

    this.onEnter = function () {
        goog.base(this, 'onEnter');
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

    }

    this.callback1 = function () {
        var label = cc.LabelTTF.create("callback 1 called", "Marker Felt", 16);
        label.setPosition(cc.p(winSize.width / 4 * 1, winSize.height / 2));

        this.addChild(label);
    }

    this.callback2 = function () {
        var label = cc.LabelTTF.create("callback 2 called", "Marker Felt", 16);
        label.setPosition(cc.p(winSize.width / 4 * 2, winSize.height / 2));

        this.addChild(label);
    }

    this.callback3 = function () {
        var label = cc.LabelTTF.create("callback 3 called", "Marker Felt", 16);
        label.setPosition(cc.p(winSize.width / 4 * 3, winSize.height / 2));

        this.addChild(label);
    }

    this.title = "Sequence of InstantActions";
}
goog.inherits( ActionSequence2, BaseLayer );

//------------------------------------------------------------------
//
//	ActionCallFunc
//
//------------------------------------------------------------------
var ActionCallFunc = function() {

	goog.base(this);

    this.onEnter = function () {
        goog.base(this, 'onEnter');
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

    }

    this.callback1 = function () {
        var label = cc.LabelTTF.create("callback 1 called", "Marker Felt", 16);
        label.setPosition(cc.p(winSize.width / 4 * 1, winSize.height / 2));
        this.addChild(label);
    }

    this.callback2 = function () {
        var label = cc.LabelTTF.create("callback 2 called", "Marker Felt", 16);
        label.setPosition(cc.p(winSize.width / 4 * 2, winSize.height / 2));

        this.addChild(label);
    }

    this.callback3 = function () {
        var label = cc.LabelTTF.create("callback 3 called", "Marker Felt", 16);
        label.setPosition(cc.p(winSize.width / 4 * 3, winSize.height / 2));
        this.addChild(label);
    }

    this.title = "Callbacks: CallFunc and friends";
}
goog.inherits( ActionCallFunc, BaseLayer );

//------------------------------------------------------------------
//
// ActionCallFuncND
//
//------------------------------------------------------------------
var ActionCallFuncND = function(){
    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.centerSprites(1);

        var action = cc.Sequence.create(cc.MoveBy.create(2.0, cc.p(200, 0)),
            cc.CallFunc.create(this._grossini, this.removeFromParentAndCleanup, true) );

        this._grossini.runAction(action);

    }

    this.subtitle = "CallFuncND + auto remove";
    this.title = "CallFuncND + removeFromParentAndCleanup. Grossini dissapears in 2s";
}
goog.inherits( ActionCallFuncND, BaseLayer );

//------------------------------------------------------------------
//
// ActionSpawn
//
//------------------------------------------------------------------
var ActionSpawn = function(){
    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.alignSpritesLeft(1);

        var action = cc.Spawn.create(
            cc.JumpBy.create(2, cc.p(300, 0), 50, 4),
            cc.RotateBy.create(2, 720) );

        this._grossini.runAction(action);

    }
    this.title = "Spawn: Jump + Rotate";
}
goog.inherits( ActionSpawn, BaseLayer );

//------------------------------------------------------------------
//
// ActionRepeatForever
//
//------------------------------------------------------------------
var ActionRepeatForever = function(){
    goog.base(this);
    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.centerSprites(1);
        var action = cc.Sequence.create(
            cc.DelayTime.create(1),
            cc.CallFunc.create(this, this.repeatForever) );

        this._grossini.runAction(action);


    }
    this.repeatForever = function (sender) {
        var repeat = cc.RepeatForever.create(cc.RotateBy.create(1.0, 360));
        sender.runAction(repeat)
    }

    this.title = "CallFuncN + RepeatForever";
}
goog.inherits( ActionRepeatForever, BaseLayer );

//------------------------------------------------------------------
//
// ActionRotateToRepeat
//
//------------------------------------------------------------------
var ActionRotateToRepeat = function(){
    goog.base(this);
    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.centerSprites(2);

        var act1 = cc.RotateTo.create(1, 90);
        var act2 = cc.RotateTo.create(1, 0);
        var seq = cc.Sequence.create(act1, act2);
        var rep1 = cc.RepeatForever.create(seq);
        var rep2 = cc.Repeat.create((seq.copy()), 10);

        this._tamara.runAction(rep1);
        this._kathia.runAction(rep2);

    }

    this.title = "Repeat/RepeatForever + RotateTo";
}
goog.inherits( ActionRotateToRepeat, BaseLayer );

//------------------------------------------------------------------
//
// ActionRotateJerk
//
//------------------------------------------------------------------
var ActionRotateJerk = function(){
    goog.base(this);
    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.centerSprites(2);
        var seq = cc.Sequence.create(
            cc.RotateTo.create(0.5, -20),
            cc.RotateTo.create(0.5, 20) );

        var rep1 = cc.Repeat.create(seq, 10);
        var rep2 = cc.RepeatForever.create((seq.copy()));

        this._tamara.runAction(rep1);
        this._kathia.runAction(rep2);
    }

    this.title = "RepeatForever / Repeat + Rotate";
}
goog.inherits( ActionRotateJerk, BaseLayer );

//------------------------------------------------------------------
//
// ActionReverse
//
//------------------------------------------------------------------
var ActionReverse = function(){
    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.alignSpritesLeft(1);

        var jump = cc.JumpBy.create(2, cc.p(300, 0), 50, 4);
        var action = cc.Sequence.create(jump, jump.reverse());

        this._grossini.runAction(action);
    }

    this.title = "Reverse an action";
}
goog.inherits( ActionReverse, BaseLayer );

//------------------------------------------------------------------
//
// ActionDelayTime
//
//------------------------------------------------------------------
var ActionDelayTime = function(){
    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.alignSpritesLeft(1);

        var move = cc.MoveBy.create(1, cc.p(150, 0));
        var action = cc.Sequence.create(move, cc.DelayTime.create(2), move);

        this._grossini.runAction(action);
    }

    this.title = "DelayTime: m + delay + m";
}
goog.inherits( ActionDelayTime, BaseLayer );

//------------------------------------------------------------------
//
// ActionReverseSequence
//
//------------------------------------------------------------------
var ActionReverseSequence = function(){
    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.alignSpritesLeft(1);

        var move1 = cc.MoveBy.create(1, cc.p(250, 0));
        var move2 = cc.MoveBy.create(1, cc.p(0, 50));
        var seq = cc.Sequence.create(move1, move2, move1.reverse() );
        var action = cc.Sequence.create(seq, seq.reverse() );

        this._grossini.runAction(action);

    }

    this.title = "Reverse a sequence";
}
goog.inherits( ActionReverseSequence, BaseLayer );

//------------------------------------------------------------------
//
// ActionReverseSequence2
//
//------------------------------------------------------------------
var ActionReverseSequence2 = function(){
    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.alignSpritesLeft(2);


        // Test:
        //   Sequence should work both with IntervalAction and InstantActions
        var move1 = cc.MoveBy.create(3, cc.p(250, 0));
        var move2 = cc.MoveBy.create(3, cc.p(0, 50));
        var tog1 = new cc.ToggleVisibility();
        var tog2 = new cc.ToggleVisibility();
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
        var hide = new cc.Hide();
        var seq_tamara = cc.Sequence.create(move_tamara, hide, move_tamara2 );
        var seq_back = seq_tamara.reverse();
        this._tamara.runAction(cc.Sequence.create(seq_tamara, seq_back ));
    }

    this.title = "Reverse sequence 2";
}
goog.inherits( ActionReverseSequence2, BaseLayer );

//------------------------------------------------------------------
//
// ActionRepeat
//
//------------------------------------------------------------------
var ActionRepeat = function(){
    this.onEnter = function () {
        goog.base(this, 'onEnter');
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
    }

    this.title = "Repeat / RepeatForever actions";
}
goog.inherits( ActionRepeat, BaseLayer );

//------------------------------------------------------------------
//
// ActionOrbit
//
//------------------------------------------------------------------
var ActionOrbit = function(){
    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.centerSprites(3);

        var orbit1 = cc.OrbitCamera.create(2, 1, 0, 0, 180, 0, 0);
        var action1 = cc.Sequence.create(
            orbit1,
            orbit1.reverse() );

        var orbit2 = cc.OrbitCamera.create(2, 1, 0, 0, 180, -45, 0);
        var action2 = cc.Sequence.create(
            orbit2,
            orbit2.reverse() );

        var orbit3 = cc.OrbitCamera.create(2, 1, 0, 0, 180, 90, 0);
        var action3 = cc.Sequence.create(
            orbit3,
            orbit3.reverse() );

        this._kathia.runAction(cc.RepeatForever.create(action1));
        this._tamara.runAction(cc.RepeatForever.create(action2));
        this._grossini.runAction(cc.RepeatForever.create(action3));

        var move = cc.MoveBy.create(3, cc.p(100, -100));
        var move_back = move.reverse();
        var seq = cc.Sequence.create(move, move_back);
        var rfe = cc.RepeatForever.create(seq);
        this._kathia.runAction(rfe);
        this._tamara.runAction((rfe.copy()));
        this._grossini.runAction((rfe.copy()));

    }

    this.title = "OrbitCamera action";
}
goog.inherits( ActionOrbit, BaseLayer );

//------------------------------------------------------------------
//
// ActionFollow
//
//------------------------------------------------------------------
var ActionFollow = function(){
    this.onEnter = function () {
        goog.base(this, 'onEnter');
        this.centerSprites(1);

        this._grossini.setPosition(cc.p(-200, winSize.height / 2));
        var move = cc.MoveBy.create(2, cc.p(winSize.width * 3, 0));
        var move_back = move.reverse();
        var seq = cc.Sequence.create(move, move_back);
        var rep = cc.RepeatForever.create(seq);

        this._grossini.runAction(rep);

        this.runAction(cc.Follow.create(this._grossini, cc.RectMake(0, 0, winSize.width * 2 - 100, winSize.height)));
    }

    this.title = "Follow action";
}
goog.inherits( ActionFollow, BaseLayer );

//------------------------------------------------------------------
//
// ActionCardinalSpline
//
//------------------------------------------------------------------
var ActionCardinalSpline = function(){
    goog.base(this);

    this._array = new cc.PointArray();

    this.onEnter = function () {
        goog.base(this, 'onEnter');

        this.centerSprites(2);

        var array = cc.PointArray.create();

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

        this._array = array;
    }

    this.draw = function (ctx) {
        goog.base(this, 'draw', ctx);

        var context = ctx || cc.renderContext;
        // move to 50,50 since the "by" path will start at 50,50
        context.save();
        context.translate(50, -50);
        cc.drawingUtil.drawCardinalSpline(this._array, 0, 100);
        context.restore();

        context.save();
        context.translate(winSize.width / 2, -50);
        cc.drawingUtil.drawCardinalSpline(this._array, 1, 100);
        context.restore();
    }

    this.subtitle = "Cardinal Spline paths. Testing different tensions for one array";
    this.title = "CardinalSplineBy / CardinalSplineAt";
}
goog.inherits( ActionCardinalSpline, BaseLayer );

//------------------------------------------------------------------
//
// ActionCatmullRom
//
//------------------------------------------------------------------
var ActionCatmullRom = function() {
    goog.base(this);

    this._array1 = new cc.PointArray();
    this._array2 = new cc.PointArray();

    this.onEnter = function () {
        goog.base(this, 'onEnter');

        this.centerSprites(2);

        //
        // sprite 1 (By)
        //
        // startPosition can be any coordinate, but since the movement
        // is relative to the Catmull Rom curve, it is better to start with (0,0).
        //
        this._tamara.setPosition(cc.p(50, 50));

        var array = cc.PointArray.create();
        array.addControlPoint(cc.p(0, 0));
        array.addControlPoint(cc.p(80, 80));
        array.addControlPoint(cc.p(winSize.width - 80, 80));
        array.addControlPoint(cc.p(winSize.width - 80, winSize.height - 80));
        array.addControlPoint(cc.p(80, winSize.height - 80));
        array.addControlPoint(cc.p(80, 80));
        array.addControlPoint(cc.p(winSize.width / 2, winSize.height / 2));

        var action1 = cc.CatmullRomBy.create(3, array);
        var reverse1 = action1.reverse();
        var seq1 = cc.Sequence.create(action1, reverse1);

        this._tamara.runAction(seq1);

        //
        // sprite 2 (To)
        //
        // The startPosition is not important here, because it uses a "To" action.
        // The initial position will be the 1st point of the Catmull Rom path
        //
        var array2 = cc.PointArray.create();

        array2.addControlPoint(cc.p(winSize.width / 2, 30));
        array2.addControlPoint(cc.p(winSize.width - 80, 30));
        array2.addControlPoint(cc.p(winSize.width - 80, winSize.height - 80));
        array2.addControlPoint(cc.p(winSize.width / 2, winSize.height - 80));
        array2.addControlPoint(cc.p(winSize.width / 2, 30));

        var action2 = cc.CatmullRomTo.create(3, array2);
        var reverse2 = action2.reverse();

        var seq2 = cc.Sequence.create(action2, reverse2);

        this._kathia.runAction(seq2);

        this._array1 = array;
        this._array2 = array2;
    }

    this.draw = function (ctx) {
        goog.base(this, 'draw', ctx);
        var context = ctx || cc.renderContext;

        // move to 50,50 since the "by" path will start at 50,50
        context.save();
        context.translate(50, -50);
        cc.drawingUtil.drawCatmullRom(this._array1, 50);
        context.restore();

        cc.drawingUtil.drawCatmullRom(this._array2, 50);
    }

    this.subtitle = "Catmull Rom spline paths. Testing reverse too";
    this.title = "CatmullRomBy / CatmullRomTo tito";
}
goog.inherits( ActionCatmullRom, BaseLayer );


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
scenes.push( ActionBezier );
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
    var scene = new cc.Scene();
    scene.init();
    var layer = new scenes[currentScene]();
    scene.addChild( layer );

    director.runWithScene( scene );
}

run();
