var Explosion = cc.Sprite.extend({
    tmpWidth:0,
    tmpHeight:0,
    ctor:function () {
        var parent = new cc.Sprite();
        __associateObjWithNative(this, parent);

        this._super();
        this.tmpWidth = this.getContentSize().width;
        this.tmpHeight = this.getContentSize().height;

        // XXX riq XXX
        // spriteFrameByName() -> getSpriteFrame()
        var pFrame = cc.SpriteFrameCache.getInstance().getSpriteFrame("explosion_01.png");
        this.initWithSpriteFrame(pFrame);

        var animation = cc.AnimationCache.getInstance().animationByName("Explosion");
        this.runAction(cc.Sequence.create(
            cc.Animate.create(animation, false),
            cc.CallFunc.create(this, this.destroy)
        ));
        this.setBlendFunc(gl.SRC_ALPHA, gl.GL_ONE );
    },
    destroy:function () {
        this.getParent().removeChild(this,true);
    }
});

Explosion.sharedExplosion = function () {
    cc.SpriteFrameCache.getInstance().addSpriteFrames(s_explosion_plist);
    var animFrames = [];
    var str = "";
    for (var i = 1; i < 35; i++) {
        str = "explosion_" + (i < 10 ? ("0" + i) : i) + ".png";
        // XXX riq XXX
        // spriteFrameByName() -> getSpriteFrame()
        var frame = cc.SpriteFrameCache.getInstance().getSpriteFrame(str);
        animFrames.push(frame);
    }
    var animation = cc.Animation.create(animFrames, 0.04);
    cc.AnimationCache.getInstance().addAnimation(animation, "Explosion");
};
