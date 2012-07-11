//
// http://www.cocos2d-iphone.org
// http://www.cocos2d-html5.org
// http://www.cocos2d-x.org
//
// Javascript + cocos2d particles tests
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

        if (numberOfSprites == 0) {
            this._tamara.setVisible(false);
            this._kathia.setVisible(false);
            this._grossini.setVisible(false);
        }
        else if (numberOfSprites == 1) {
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
        var item4 = cc.MenuItemFont.create("back", this, function() { require("javascript-spidermonkey/main.js"); } );
        item4.setFontSize( 22 );

        var menu = cc.Menu.create(item1, item2, item3, item4 );

        menu.setPosition( cc.p(0,0) );
        item1.setPosition( cc.p(winSize.width / 2 - 100, 30));
        item2.setPosition( cc.p(winSize.width / 2, 30));
        item3.setPosition( cc.p(winSize.width / 2 + 100, 30));
        item4.setPosition( cc.p(winSize.width - 60, winSize.height - 30 ) );

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

var BaseLayer = cc.LayerGradient.extend({
    _emitter:null,
    _background:null,
    _shapeModeButton:null,
    _textureModeButton:null,

    ctor:function () {
        var parent = new cc.LayerGradient();
        __associateObjWithNative(this, parent);
        this.init(cc.c4(0, 0, 0, 255), cc.c4(0, 128, 255, 255));

        this._emitter = null;

        this.setTouchEnabled(true);

        var label = cc.LabelTTF.create(this.title(), "Arial", 28);
        this.addChild(label, 100, 1000);
        label.setPosition(cc.p(winSize.width / 2, winSize.height - 50));

        var tapScreen = cc.LabelTTF.create("(Tap the Screen)", "Arial", 20);
        tapScreen.setPosition(cc.p(s.width / 2, s.height - 80));
        this.addChild(tapScreen, 100);
        var selfPoint = this;
        var item1 = cc.MenuItemImage.create(s_pathB1, s_pathB2, this, this.backCallback);
        var item2 = cc.MenuItemImage.create(s_pathR1, s_pathR2, this, function () {
            selfPoint._emitter.resetSystem();
        });
        var item3 = cc.MenuItemImage.create(s_pathF1, s_pathF2, this, this.nextCallback);

        var freeBtnNormal = cc.Sprite.create(s_MovementMenuItem, cc.RectMake(0, 23 * 2, 123, 23));
        var freeBtnSelected = cc.Sprite.create(s_MovementMenuItem, cc.RectMake(0, 23, 123, 23));
        var freeBtnDisabled = cc.Sprite.create(s_MovementMenuItem, cc.RectMake(0, 0, 123, 23));

        var relativeBtnNormal = cc.Sprite.create(s_MovementMenuItem, cc.RectMake(123, 23 * 2, 138, 23));
        var relativeBtnSelected = cc.Sprite.create(s_MovementMenuItem, cc.RectMake(123, 23, 138, 23));
        var relativeBtnDisabled = cc.Sprite.create(s_MovementMenuItem, cc.RectMake(123, 0, 138, 23));

        var groupBtnNormal = cc.Sprite.create(s_MovementMenuItem, cc.RectMake(261, 23 * 2, 136, 23));
        var groupBtnSelected = cc.Sprite.create(s_MovementMenuItem, cc.RectMake(261, 23, 136, 23));
        var groupBtnDisabled = cc.Sprite.create(s_MovementMenuItem, cc.RectMake(261, 0, 136, 23));

        this._freeMovementButton = cc.MenuItemSprite.create(freeBtnNormal, freeBtnSelected, freeBtnDisabled, this,
            function () {
                selfPoint._emitter.setPositionType(cc.CCPARTICLE_TYPE_RELATIVE);
                selfPoint._relativeMovementButton.setVisible(true);
                selfPoint._freeMovementButton.setVisible(false);
                selfPoint._groupMovementButton.setVisible(false);
            });
        this._freeMovementButton.setPosition(new cc.Point(10, 150));
        this._freeMovementButton.setAnchorPoint(cc.p(0, 0));

        this._relativeMovementButton = cc.MenuItemSprite.create(relativeBtnNormal, relativeBtnSelected, relativeBtnDisabled, this,
            function () {
                selfPoint._emitter.setPositionType(cc.CCPARTICLE_TYPE_GROUPED);
                selfPoint._relativeMovementButton.setVisible(false);
                selfPoint._freeMovementButton.setVisible(false);
                selfPoint._groupMovementButton.setVisible(true);
            });
        this._relativeMovementButton.setVisible(false);
        this._relativeMovementButton.setPosition(new cc.Point(10, 150));
        this._relativeMovementButton.setAnchorPoint(cc.p(0, 0));

        this._groupMovementButton = cc.MenuItemSprite.create(groupBtnNormal, groupBtnSelected, groupBtnDisabled, this,
            function () {
                selfPoint._emitter.setPositionType(cc.CCPARTICLE_TYPE_FREE);
                selfPoint._relativeMovementButton.setVisible(false);
                selfPoint._freeMovementButton.setVisible(true);
                selfPoint._groupMovementButton.setVisible(false);
            });
        this._groupMovementButton.setVisible(false);
        this._groupMovementButton.setPosition(new cc.Point(10, 150));
        this._groupMovementButton.setAnchorPoint(cc.p(0, 0));

        var spriteNormal = cc.Sprite.create(s_shapeModeMenuItem, cc.RectMake(0, 23 * 2, 115, 23));
        var spriteSelected = cc.Sprite.create(s_shapeModeMenuItem, cc.RectMake(0, 23, 115, 23));
        var spriteDisabled = cc.Sprite.create(s_shapeModeMenuItem, cc.RectMake(0, 0, 115, 23));

        this._shapeModeButton = cc.MenuItemSprite.create(spriteNormal, spriteSelected, spriteDisabled, this,
            function () {
                selfPoint._emitter.setDrawMode(cc.PARTICLE_TEXTURE_MODE);
                selfPoint._textureModeButton.setVisible(true);
                selfPoint._shapeModeButton.setVisible(false);
            });
        this._shapeModeButton.setPosition(new cc.Point(10, 100));
        this._shapeModeButton.setAnchorPoint(cc.p(0, 0));

        var spriteNormal_t = cc.Sprite.create(s_textureModeMenuItem, cc.RectMake(0, 23 * 2, 115, 23));
        var spriteSelected_t = cc.Sprite.create(s_textureModeMenuItem, cc.RectMake(0, 23, 115, 23));
        var spriteDisabled_t = cc.Sprite.create(s_textureModeMenuItem, cc.RectMake(0, 0, 115, 23));

        this._textureModeButton = cc.MenuItemSprite.create(spriteNormal_t, spriteSelected_t, spriteDisabled_t, this,
            function () {
                selfPoint._emitter.setDrawMode(cc.PARTICLE_SHAPE_MODE);
                selfPoint._textureModeButton.setVisible(false);
                selfPoint._shapeModeButton.setVisible(true);
            });
        this._textureModeButton.setVisible(false);
        this._textureModeButton.setPosition(new cc.Point(10, 100));
        this._textureModeButton.setAnchorPoint(cc.p(0, 0));

        var menu = cc.Menu.create(item1, item2, item3, this._shapeModeButton, this._textureModeButton,
            this._freeMovementButton, this._relativeMovementButton, this._groupMovementButton);

        menu.setPosition(cc.PointZero());
        item1.setPosition(cc.p(s.width / 2 - 100, 30));
        item2.setPosition(cc.p(s.width / 2, 30));
        item3.setPosition(cc.p(s.width / 2 + 100, 30));

        this.addChild(menu, 100);
        //TODO
        var labelAtlas = cc.LabelTTF.create("0000", "Arial", 24);
        this.addChild(labelAtlas, 100, TAG_LABEL_ATLAS);
        labelAtlas.setPosition(cc.p(s.width - 66, 50));

        // moving background
        this._background = cc.Sprite.create(s_back3);
        this.addChild(this._background, 5);
        this._background.setPosition(cc.p(s.width / 2, s.height - 180));

        var move = cc.MoveBy.create(4, cc.p(300, 0));
        var move_back = move.reverse();
        var seq = cc.Sequence.create(move, move_back, null);
        this._background.runAction(cc.RepeatForever.create(seq));

        this.schedule(this.step);
    },

    onEnter:function () {
        this._super();

        var pLabel = this.getChildByTag(1000);
        pLabel.setString(this.title());
    },
    title:function () {
        return "No title";
    },

    restartCallback:function (sender) {
        this._emitter.resetSystem();
    },
    nextCallback:function (sender) {
        var s = new ParticleTestScene();
        s.addChild(nextParticleAction());
        cc.Director.sharedDirector().replaceScene(s);
    },
    backCallback:function (sender) {
        var s = new ParticleTestScene();
        s.addChild(backParticleAction());
        cc.Director.sharedDirector().replaceScene(s);
    },
    toggleCallback:function (sender) {
        if (this._emitter.getPositionType() == cc.CCPARTICLE_TYPE_GROUPED)
            this._emitter.setPositionType(cc.CCPARTICLE_TYPE_FREE);
        else if (this._emitter.getPositionType() == cc.CCPARTICLE_TYPE_FREE)
            this._emitter.setPositionType(cc.CCPARTICLE_TYPE_RELATIVE);
        else if (this._emitter.getPositionType() == cc.CCPARTICLE_TYPE_RELATIVE)
            this._emitter.setPositionType(cc.CCPARTICLE_TYPE_GROUPED);
    },

    registerWithTouchDispatcher:function () {
        cc.Director.sharedDirector().getTouchDispatcher().addTargetedDelegate(this, 0, false);
    },
    ccTouchBegan:function (touch, event) {
        return true;
    },
    ccTouchMoved:function (touch, event) {
        return this.ccTouchEnded(touch, event);
    },
    ccTouchEnded:function (touch, event) {
        var location = touch.locationInView();
        //CCPoint convertedLocation = CCDirector::sharedDirector().convertToGL(location);

        var pos = cc.PointZero();
        if (this._background) {
            pos = this._background.convertToWorldSpace(cc.PointZero());
        }
        this._emitter.setPosition(cc.ccpSub(location, pos));
    },

    step:function (dt) {
        if (this._emitter) {
            var atlas = this.getChildByTag(TAG_LABEL_ATLAS);
            atlas.setString(this._emitter.getParticleCount().toFixed(0));
        }
    },
    setEmitterPosition:function () {
        var s = cc.Director.sharedDirector().getWinSize();
        this._emitter.setPosition(cc.p(s.width / 2, s.height / 2));
    }
});

var DemoFirework = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this._emitter = cc.ParticleFireworks.create();
        this._background.addChild(this._emitter, 10);
        var myTexture = cc.TextureCache.sharedTextureCache().addImage(s_stars1);
        this._emitter.setTexture(myTexture);
        this._emitter.setShapeType(cc.PARTICLE_STAR_SHAPE);
        this.setEmitterPosition();
    },
    title:function () {
        return "ParticleFireworks";
    }
});

var DemoFire = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this._emitter = cc.ParticleFire.create();
        this._background.addChild(this._emitter, 10);

        this._emitter.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_fire));//.pvr"];
        this._emitter.setShapeType(cc.PARTICLE_BALL_SHAPE);
        var p = this._emitter.getPosition();
        this._emitter.setPosition(cc.p(p.x, 100));

        this.setEmitterPosition();
    },
    title:function () {
        return "ParticleFire";
    }
});

var DemoSun = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this._emitter = cc.ParticleSun.create();
        this._background.addChild(this._emitter, 10);
        var myTexture = cc.TextureCache.sharedTextureCache().addImage(s_fire);
        this._emitter.setTexture(myTexture);
        this._emitter.setShapeType(cc.PARTICLE_BALL_SHAPE);
        this.setEmitterPosition();
    },
    title:function () {
        return "ParticleSun";
    }
});

var DemoGalaxy = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this._emitter = cc.ParticleGalaxy.create();
        this._background.addChild(this._emitter, 10);
        var myTexture = cc.TextureCache.sharedTextureCache().addImage(s_fire);
        this._emitter.setTexture(myTexture);
        this._emitter.setShapeType(cc.PARTICLE_BALL_SHAPE);
        this.setEmitterPosition();
    },
    title:function () {
        return "ParticleGalaxy";
    }
});

var DemoFlower = BaseLayer.extend({
    ctor:function () {
        this._super();
    },
    onEnter:function () {
        this._super();

        this._emitter = cc.ParticleFlower.create();
        this._background.addChild(this._emitter, 10);

        var myTexture = cc.TextureCache.sharedTextureCache().addImage(s_stars1);
        this._emitter.setTexture(myTexture);
        this._emitter.setShapeType(cc.PARTICLE_STAR_SHAPE);
        this.setEmitterPosition();
    },
    title:function () {
        return "ParticleFlower";
    }
});

var DemoBigFlower = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this._emitter = new cc.ParticleSystemQuad();
        this._emitter.initWithTotalParticles(50);
        //this._emitter.autorelease();

        this._background.addChild(this._emitter, 10);
        this._emitter.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_stars1));
        this._emitter.setShapeType(cc.PARTICLE_STAR_SHAPE);
        this._emitter.setDuration(-1);

        // gravity
        this._emitter.setGravity(cc.PointZero());

        // angle
        this._emitter.setAngle(90);
        this._emitter.setAngleVar(360);

        // speed of particles
        this._emitter.setSpeed(160);
        this._emitter.setSpeedVar(20);

        // radial
        this._emitter.setRadialAccel(-120);
        this._emitter.setRadialAccelVar(0);

        // tagential
        this._emitter.setTangentialAccel(30);
        this._emitter.setTangentialAccelVar(0);

        // emitter position
        this._emitter.setPosition(cc.p(160, 240));
        this._emitter.setPosVar(cc.PointZero());

        // life of particles
        this._emitter.setLife(4);
        this._emitter.setLifeVar(1);

        // spin of particles
        this._emitter.setStartSpin(0);
        this._emitter.setStartSizeVar(0);
        this._emitter.setEndSpin(0);
        this._emitter.setEndSpinVar(0);

        // color of particles
        var startColor = new cc.Color4F(0.5, 0.5, 0.5, 1.0);
        this._emitter.setStartColor(startColor);

        var startColorVar = new cc.Color4F(0.5, 0.5, 0.5, 1.0);
        this._emitter.setStartColorVar(startColorVar);

        var endColor = new cc.Color4F(0.1, 0.1, 0.1, 0.2);
        this._emitter.setEndColor(endColor);

        var endColorVar = new cc.Color4F(0.1, 0.1, 0.1, 0.2);
        this._emitter.setEndColorVar(endColorVar);

        // size, in pixels
        this._emitter.setStartSize(80.0);
        this._emitter.setStartSizeVar(40.0);
        this._emitter.setEndSize(cc.PARTICLE_START_SIZE_EQUAL_TO_END_SIZE);

        // emits per second
        this._emitter.setEmissionRate(this._emitter.getTotalParticles() / this._emitter.getLife());

        // additive
        this._emitter.setIsBlendAdditive(true);

        this.setEmitterPosition();
    },
    title:function () {
        return "ParticleBigFlower";
    }
});

var DemoRotFlower = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this._emitter = new cc.ParticleSystemQuad();
        //this._emitter.initWithTotalParticles(300);
        this._emitter.initWithTotalParticles(150);

        this._background.addChild(this._emitter, 10);
        this._emitter.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_stars2));
        this._emitter.setShapeType(cc.PARTICLE_STAR_SHAPE);
        // duration
        this._emitter.setDuration(-1);

        // gravity
        this._emitter.setGravity(cc.PointZero());

        // angle
        this._emitter.setAngle(90);
        this._emitter.setAngleVar(360);

        // speed of particles
        this._emitter.setSpeed(160);
        this._emitter.setSpeedVar(20);

        // radial
        this._emitter.setRadialAccel(-120);
        this._emitter.setRadialAccelVar(0);

        // tagential
        this._emitter.setTangentialAccel(30);
        this._emitter.setTangentialAccelVar(0);

        // emitter position
        this._emitter.setPosition(cc.p(160, 240));
        this._emitter.setPosVar(cc.PointZero());

        // life of particles
        this._emitter.setLife(3);
        this._emitter.setLifeVar(1);

        // spin of particles
        this._emitter.setStartSpin(0);
        this._emitter.setStartSpinVar(0);
        this._emitter.setEndSpin(0);
        this._emitter.setEndSpinVar(2000);

        var startColor = new cc.Color4F(0.5, 0.5, 0.5, 1.0);
        this._emitter.setStartColor(startColor);

        var startColorVar = new cc.Color4F(0.5, 0.5, 0.5, 1.0);
        this._emitter.setStartColorVar(startColorVar);

        var endColor = new cc.Color4F(0.1, 0.1, 0.1, 0.2);
        this._emitter.setEndColor(endColor);

        var endColorVar = new cc.Color4F(0.1, 0.1, 0.1, 0.2);
        this._emitter.setEndColorVar(endColorVar);

        // size, in pixels
        this._emitter.setStartSize(30.0);
        this._emitter.setStartSizeVar(0);
        this._emitter.setEndSize(cc.PARTICLE_START_SIZE_EQUAL_TO_END_SIZE);

        // emits per second
        this._emitter.setEmissionRate(this._emitter.getTotalParticles() / this._emitter.getLife());

        // additive
        this._emitter.setIsBlendAdditive(false);

        this.setEmitterPosition();
    },
    title:function () {
        return "ParticleRotFlower";
    }
});

var DemoMeteor = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this._emitter = cc.ParticleMeteor.create();
        this._background.addChild(this._emitter, 10);

        this._emitter.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_fire));
        this._emitter.setShapeType(cc.PARTICLE_BALL_SHAPE);
        this.setEmitterPosition();
    },
    title:function () {
        return "ParticleMeteor";
    }
});

var DemoSpiral = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this._emitter = cc.ParticleSpiral.create();
        this._background.addChild(this._emitter, 10);

        this._emitter.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_fire));
        this._emitter.setShapeType(cc.PARTICLE_BALL_SHAPE);
        this.setEmitterPosition();
    },
    title:function () {
        return "ParticleSpiral";
    }
});

var DemoExplosion = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this._emitter = cc.ParticleExplosion.create();
        this._background.addChild(this._emitter, 10);

        this._emitter.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_stars1));
        this._emitter.setShapeType(cc.PARTICLE_STAR_SHAPE);
        this._emitter.setIsAutoRemoveOnFinish(true);

        this.setEmitterPosition();
    },
    title:function () {
        return "ParticleExplosion";
    }
});

var DemoSmoke = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this._emitter = cc.ParticleSmoke.create();
        this._background.addChild(this._emitter, 10);
        this._emitter.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_fire));

        var p = this._emitter.getPosition();
        this._emitter.setPosition(cc.p(p.x, 100));

        this.setEmitterPosition();
    },
    title:function () {
        return "ParticleSmoke";
    }
});

var DemoSnow = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this._emitter = cc.ParticleSnow.create();
        this._background.addChild(this._emitter, 10);

        var p = this._emitter.getPosition();
        this._emitter.setPosition(cc.p(p.x, p.y - 110));
        this._emitter.setLife(3);
        this._emitter.setLifeVar(1);

        // gravity
        this._emitter.setGravity(cc.p(0, -10));

        // speed of particles
        this._emitter.setSpeed(130);
        this._emitter.setSpeedVar(30);


        var startColor = this._emitter.getStartColor();
        startColor.r = 0.9;
        startColor.g = 0.9;
        startColor.b = 0.9;
        this._emitter.setStartColor(startColor);

        var startColorVar = this._emitter.getStartColorVar();
        startColorVar.b = 0.1;
        this._emitter.setStartColorVar(startColorVar);

        this._emitter.setEmissionRate(this._emitter.getTotalParticles() / this._emitter.getLife());

        this._emitter.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_snow));
        this._emitter.setShapeType(cc.PARTICLE_STAR_SHAPE);

        this.setEmitterPosition();
    },
    title:function () {
        return "ParticleSnow";
    }
});

var DemoRain = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this._emitter = cc.ParticleRain.create();
        this._background.addChild(this._emitter, 10);

        var p = this._emitter.getPosition();
        this._emitter.setPosition(cc.p(p.x, p.y - 100));
        this._emitter.setLife(4);

        this._emitter.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_fire));
        this._emitter.setShapeType(cc.PARTICLE_BALL_SHAPE);
        this.setEmitterPosition();
    },
    title:function () {
        return "ParticleRain";
    }
});

var DemoModernArt = BaseLayer.extend({
    onEnter:function () {
        this._super();

        //FIXME: If use CCParticleSystemPoint, bada 1.0 device will crash.
        //  Crash place: CCParticleSystemPoint.cpp Line 149, function: glDrawArrays(GL_POINTS, 0, this._particleIdx);
        //  this._emitter = new CCParticleSystemPoint();
        this._emitter = new cc.ParticleSystemQuad();
        //this._emitter.initWithTotalParticles(1000);
        this._emitter.initWithTotalParticles(200);
        //this._emitter.autorelease();

        this._background.addChild(this._emitter, 10);
        ////this._emitter.release();

        var s = cc.Director.sharedDirector().getWinSize();

        // duration
        this._emitter.setDuration(-1);

        // gravity
        this._emitter.setGravity(cc.p(0, 0));

        // angle
        this._emitter.setAngle(0);
        this._emitter.setAngleVar(360);

        // radial
        this._emitter.setRadialAccel(70);
        this._emitter.setRadialAccelVar(10);

        // tagential
        this._emitter.setTangentialAccel(80);
        this._emitter.setTangentialAccelVar(0);

        // speed of particles
        this._emitter.setSpeed(50);
        this._emitter.setSpeedVar(10);

        // emitter position
        this._emitter.setPosition(cc.p(s.width / 2, s.height / 2));
        this._emitter.setPosVar(cc.PointZero());

        // life of particles
        this._emitter.setLife(2.0);
        this._emitter.setLifeVar(0.3);

        // emits per frame
        this._emitter.setEmissionRate(this._emitter.getTotalParticles() / this._emitter.getLife());

        // color of particles
        var startColor = new cc.Color4F(0.5, 0.5, 0.5, 1.0);
        this._emitter.setStartColor(startColor);

        var startColorVar = new cc.Color4F(0.5, 0.5, 0.5, 1.0);
        this._emitter.setStartColorVar(startColorVar);

        var endColor = new cc.Color4F(0.1, 0.1, 0.1, 0.2);
        this._emitter.setEndColor(endColor);

        var endColorVar = new cc.Color4F(0.1, 0.1, 0.1, 0.2);
        this._emitter.setEndColorVar(endColorVar);

        // size, in pixels
        this._emitter.setStartSize(1.0);
        this._emitter.setStartSizeVar(1.0);
        this._emitter.setEndSize(32.0);
        this._emitter.setEndSizeVar(8.0);

        // texture
        this._emitter.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_fire));
        this._emitter.setShapeType(cc.PARTICLE_BALL_SHAPE);
        // additive
        this._emitter.setIsBlendAdditive(false);

        this.setEmitterPosition();
    },
    title:function () {
        return "Varying size";
    }
});

var DemoRing = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this._emitter = cc.ParticleFlower.create();

        this._background.addChild(this._emitter, 10);

        this._emitter.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_stars1));
        this._emitter.setShapeType(cc.PARTICLE_STAR_SHAPE);

        this._emitter.setLifeVar(0);
        this._emitter.setLife(10);
        this._emitter.setSpeed(100);
        this._emitter.setSpeedVar(0);
        this._emitter.setEmissionRate(10000);

        this.setEmitterPosition();
    },
    title:function () {
        return "Ring Demo";
    }
});

var ParallaxParticle = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this._background.getParent().removeChild(this._background, true);
        this._background = null;

        //TODO
        var p = cc.ParallaxNode.create();
        this.addChild(p, 5);

        var p1 = cc.Sprite.create(s_back3);
        var p2 = cc.Sprite.create(s_back3);

        p.addChild(p1, 1, cc.p(0.5, 1), cc.p(0, 250));
        p.addChild(p2, 2, cc.p(1.5, 1), cc.p(0, 50));

        this._emitter = cc.ParticleFlower.create();
        this._emitter.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_fire));

        p1.addChild(this._emitter, 10);
        this._emitter.setPosition(cc.p(250, 200));

        var par = cc.ParticleSun.create();
        p2.addChild(par, 10);
        par.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_fire));

        var move = cc.MoveBy.create(4, cc.p(300, 0));
        var move_back = move.reverse();
        var seq = cc.Sequence.create(move, move_back, null);
        p.runAction(cc.RepeatForever.create(seq));
    },
    title:function () {
        return "Parallax + Particles";
    }
});

var DemoParticleFromFile = BaseLayer.extend({
    title:"",
    ctor:function (filename) {
        this._super();
        this.title = filename;
    },
    onEnter:function () {
        this._super();

        this.setColor(cc.BLACK());
        this.removeChild(this._background, true);
        this._background = null;

        this._emitter = new cc.ParticleSystemQuad();
        var filename = "Resources/Images/" + this.title + ".plist";
        this._emitter.initWithFile(filename);
        this.addChild(this._emitter, 10);

        this.setEmitterPosition();
    },
    title:function () {
        return this.title;
    }
});

var RadiusMode1 = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this.setColor(cc.BLACK());
        this.removeChild(this._background, true);
        this._background = null;

        this._emitter = new cc.ParticleSystemQuad();
        //this._emitter.initWithTotalParticles(200);
        this._emitter.initWithTotalParticles(150);
        this.addChild(this._emitter, 10);
        this._emitter.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_starsGrayscale));

        // duration
        this._emitter.setDuration(cc.CCPARTICLE_DURATION_INFINITY);

        // radius mode
        this._emitter.setEmitterMode(cc.CCPARTICLE_MODE_RADIUS);

        // radius mode: start and end radius in pixels
        this._emitter.setStartRadius(0);
        this._emitter.setStartRadiusVar(0);
        this._emitter.setEndRadius(160);
        this._emitter.setEndRadiusVar(0);

        // radius mode: degrees per second
        this._emitter.setRotatePerSecond(180);
        this._emitter.setRotatePerSecondVar(0);


        // angle
        this._emitter.setAngle(90);
        this._emitter.setAngleVar(0);

        // emitter position
        var size = cc.Director.sharedDirector().getWinSize();
        this._emitter.setPosition(cc.ccp(size.width / 2, size.height / 2));
        this._emitter.setPosVar(cc.PointZero());

        // life of particles
        this._emitter.setLife(5);
        this._emitter.setLifeVar(0);

        // spin of particles
        this._emitter.setStartSpin(0);
        this._emitter.setStartSpinVar(0);
        this._emitter.setEndSpin(0);
        this._emitter.setEndSpinVar(0);

        // color of particles
        var startColor = new cc.Color4F(0.5, 0.5, 0.5, 1.0);
        this._emitter.setStartColor(startColor);

        var startColorVar = new cc.Color4F(0.5, 0.5, 0.5, 1.0);
        this._emitter.setStartColorVar(startColorVar);

        var endColor = new cc.Color4F(0.1, 0.1, 0.1, 0.2);
        this._emitter.setEndColor(endColor);

        var endColorVar = new cc.Color4F(0.1, 0.1, 0.1, 0.2);
        this._emitter.setEndColorVar(endColorVar);

        // size, in pixels
        this._emitter.setStartSize(32);
        this._emitter.setStartSizeVar(0);
        this._emitter.setEndSize(cc.CCPARTICLE_START_SIZE_EQUAL_TO_END_SIZE);

        // emits per second
        this._emitter.setEmissionRate(this._emitter.getTotalParticles() / this._emitter.getLife());

        // additive
        this._emitter.setIsBlendAdditive(false);
    },
    title:function () {
        return "Radius Mode: Spiral";
    }
});

var RadiusMode2 = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this.setColor(cc.BLACK());
        this.removeChild(this._background, true);
        this._background = null;

        this._emitter = new cc.ParticleSystemQuad();
        this._emitter.initWithTotalParticles(200);
        this.addChild(this._emitter, 10);
        this._emitter.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_starsGrayscale));

        // duration
        this._emitter.setDuration(cc.CCPARTICLE_DURATION_INFINITY);

        // radius mode
        this._emitter.setEmitterMode(cc.CCPARTICLE_MODE_RADIUS);

        // radius mode: start and end radius in pixels
        this._emitter.setStartRadius(100);
        this._emitter.setStartRadiusVar(0);
        this._emitter.setEndRadius(cc.CCPARTICLE_START_RADIUS_EQUAL_TO_END_RADIUS);
        this._emitter.setEndRadiusVar(0);

        // radius mode: degrees per second
        this._emitter.setRotatePerSecond(45);
        this._emitter.setRotatePerSecondVar(0);


        // angle
        this._emitter.setAngle(90);
        this._emitter.setAngleVar(0);

        // emitter position
        var size = cc.Director.sharedDirector().getWinSize();
        this._emitter.setPosition(cc.ccp(size.width / 2, size.height / 2));
        this._emitter.setPosVar(cc.PointZero());

        // life of particles
        this._emitter.setLife(4);
        this._emitter.setLifeVar(0);

        // spin of particles
        this._emitter.setStartSpin(0);
        this._emitter.setStartSpinVar(0);
        this._emitter.setEndSpin(0);
        this._emitter.setEndSpinVar(0);

        // color of particles
        var startColor = new cc.Color4F(0.5, 0.5, 0.5, 1.0);
        this._emitter.setStartColor(startColor);

        var startColorVar = new cc.Color4F(0.5, 0.5, 0.5, 1.0);
        this._emitter.setStartColorVar(startColorVar);

        var endColor = new cc.Color4F(0.1, 0.1, 0.1, 0.2);
        this._emitter.setEndColor(endColor);

        var endColorVar = new cc.Color4F(0.1, 0.1, 0.1, 0.2);
        this._emitter.setEndColorVar(endColorVar);

        // size, in pixels
        this._emitter.setStartSize(32);
        this._emitter.setStartSizeVar(0);
        this._emitter.setEndSize(cc.CCPARTICLE_START_SIZE_EQUAL_TO_END_SIZE);

        // emits per second
        this._emitter.setEmissionRate(this._emitter.getTotalParticles() / this._emitter.getLife());

        // additive
        this._emitter.setIsBlendAdditive(false);
    },
    title:function () {
        return "Radius Mode: Semi Circle";
    }
});

var Issue704 = BaseLayer.extend({
    onEnter:function () {
        this._super();

        this.setColor(cc.BLACK());
        this.removeChild(this._background, true);
        this._background = null;

        this._emitter = new cc.ParticleSystemQuad();
        this._emitter.initWithTotalParticles(100);
        this.addChild(this._emitter, 10);
        this._emitter.setTexture(cc.TextureCache.sharedTextureCache().addImage(s_fire));
        this._emitter.setShapeType(cc.PARTICLE_BALL_SHAPE);
        // duration
        this._emitter.setDuration(cc.CCPARTICLE_DURATION_INFINITY);

        // radius mode
        //this._emitter.setEmitterMode(cc.CCPARTICLE_MODE_RADIUS);

        // radius mode: start and end radius in pixels
        this._emitter.setStartRadius(50);
        this._emitter.setStartRadiusVar(0);
        this._emitter.setEndRadius(cc.CCPARTICLE_START_RADIUS_EQUAL_TO_END_RADIUS);
        this._emitter.setEndRadiusVar(0);

        // radius mode: degrees per second
        this._emitter.setRotatePerSecond(0);
        this._emitter.setRotatePerSecondVar(0);


        // angle
        this._emitter.setAngle(90);
        this._emitter.setAngleVar(0);

        // emitter position
        var size = cc.Director.sharedDirector().getWinSize();
        this._emitter.setPosition(cc.ccp(size.width / 2, size.height / 2));
        this._emitter.setPosVar(cc.PointZero());

        // life of particles
        this._emitter.setLife(5);
        this._emitter.setLifeVar(0);

        // spin of particles
        this._emitter.setStartSpin(0);
        this._emitter.setStartSpinVar(0);
        this._emitter.setEndSpin(0);
        this._emitter.setEndSpinVar(0);

        // color of particles
        var startColor = new cc.Color4F(0.5, 0.5, 0.5, 1.0);
        this._emitter.setStartColor(startColor);

        var startColorVar = new cc.Color4F(0.5, 0.5, 0.5, 1.0);
        this._emitter.setStartColorVar(startColorVar);

        var endColor = new cc.Color4F(0.1, 0.1, 0.1, 0.2);
        this._emitter.setEndColor(endColor);

        var endColorVar = new cc.Color4F(0.1, 0.1, 0.1, 0.2);
        this._emitter.setEndColorVar(endColorVar);

        // size, in pixels
        this._emitter.setStartSize(16);
        this._emitter.setStartSizeVar(0);
        this._emitter.setEndSize(cc.CCPARTICLE_START_SIZE_EQUAL_TO_END_SIZE);

        // emits per second
        this._emitter.setEmissionRate(this._emitter.getTotalParticles() / this._emitter.getLife());

        // additive
        this._emitter.setIsBlendAdditive(false);

        var rot = cc.RotateBy.create(16, 360);
        this._emitter.runAction(cc.RepeatForever.create(rot));
    },
    title:function () {
        return "Issue 704. Free + Rot";
    },
    subtitle:function () {
        return "Emitted particles should not rotate";
    }
});

var Issue870 = BaseLayer.extend({
    _index:0,
    onEnter:function () {
        this._super();

        this.setColor(cc.BLACK());
        this.removeChild(this._background, true);
        this._background = null;

        var system = new cc.ParticleSystemQuad();
        system.initWithFile("Images/SpinningPeas.plist");
        system.setTextureWithRect(cc.TextureCache.sharedTextureCache().addImage("Images/particles.png"), cc.RectMake(0, 0, 32, 32));
        this.addChild(system, 10);
        this._emitter = system;

        this._index = 0;
        this.schedule(this.updateQuads, 2.0);
    },
    title:function () {
        return "Issue 870. SubRect";
    },
    subtitle:function () {
        return "Every 2 seconds the particle should change";
    },
    updateQuads:function (dt) {
        this._index = (this._index + 1) % 4;
        var rect = cc.RectMake(this._index * 32, 0, 32, 32);
        this._emitter.setTextureWithRect(this._emitter.getTexture(), rect);
    }
});

//
// Order of tests
//

scenes.push( ActionManual );

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

    var runningScene = director.getRunningScene();
    if( runningScene == null )
        director.runWithScene( scene );
    else
        director.replaceScene( cc.TransitionFade.create(0.5, scene ) );
}

run();


