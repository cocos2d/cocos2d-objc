var AboutLayer = cc.Layer.extend({
    ctor:function () {
        var parent = new cc.Layer();
        __associateObjWithNative(this, parent);
    },

    init:function () {
        var bRet = false;
        if( this._super() ) {
            var sp = cc.Sprite.create(s_loading);
            sp.setAnchorPoint(cc.POINT_ZERO);
            this.addChild(sp, 0, 1);

            var cacheImage = cc.TextureCache.getInstance().addImage(s_menuTitle)
            var title = cc.Sprite.createWithTexture(cacheImage, cc.rect(0, 34, 100, 34));
            title.setPosition(cc.p(winSize.width / 2, winSize.height - 120));
            this.addChild(title);

            // XXX riq XXX
            // LabelTTF API change.
            // OLD: cc.LabelTTF.create( label, FontName, FontSize );
            // OLD: cc.LabelTTF.create( label, dimension, hAlign, FontName, FontSize );
            //
            // NEW: cc.LabelTTF.create( label, FontName, FontSize );
            // NEW: cc.LabelTTF.create( label, FontName, FontSize, dimension, hAlign );
//            var about = cc.LabelTTF.create("   This showcase utilizes many features from Cocos2d-html5 engine, including: Parallax background, tilemap, actions, ease, frame animation, schedule, Labels, keyboard Dispatcher, Scene Transition. \n    Art and audio is copyrighted by Enigmata Genus Revenge, you may not use any copyrigted material without permission. This showcase is licensed under GPL. \n \n Programmer: \n Shengxiang Chen (陈升想) \n Dingping Lv (吕定平) \n Effects animation: Hao Wu(吴昊)\n Quality Assurance:  Sean Lin(林顺)", "Arial", 14, cc.size(winSize.width * 0.85, 100), cc.TEXT_ALIGNMENT_LEFT );
            var about = cc.LabelTTF.create("   This showcase utilizes many features from Cocos2d-html5 engine, including: Parallax background, tilemap, actions, ease, frame animation, schedule, Labels, keyboard Dispatcher, Scene Transition. \n    Art and audio is copyrighted by Enigmata Genus Revenge, you may not use any copyrigted material without permission. This showcase is licensed under GPL. \n \n Programmer: \n Shengxiang Chen\n Dingping Lv\n Effects animation: Hao Wu\n Quality Assurance:  Sean Lin", "Arial", 14, cc.size(winSize.width * 0.85, 100), cc.TEXT_ALIGNMENT_LEFT );
            about.setPosition(cc.p(winSize.width / 2, winSize.height / 2 + 40));
            this.addChild(about);

            var label = cc.LabelTTF.create("Go back", "Arial", 14);
            var back = cc.MenuItemLabel.create(label, this, this.backCallback);
            var menu = cc.Menu.create(back);
            menu.setPosition(cc.p(winSize.width / 2, 40));
            this.addChild(menu);

            bRet = true;
        }
        return bRet;
    },
    backCallback:function (pSender) {
        var scene = cc.Scene.create();
        scene.addChild(SysMenu.create());
        cc.Director.getInstance().replaceScene(cc.TransitionFade.create(1.2, scene));
    }
});

AboutLayer.create = function () {
    var sg = new AboutLayer();
    if (sg && sg.init()) {
        return sg;
    }
    return null;
};
