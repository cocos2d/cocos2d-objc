var flareEffect = function (parent, target, callback) {
    var flare = cc.Sprite.create(s_flare);
    // XXX riq XXX
    // It should be flare.setBlendFunc( cc.GL_SRC_ALPHA, cc.GL_ONE )
//    flare.setBlendFunc(new cc.BlendFunc(cc.GL_SRC_ALPHA, cc.GL_ONE));
    parent.addChild(flare, 10);
    flare.setOpacity(0);
    flare.setPosition(cc.p(-30, 297));
    flare.setRotation(-120);
    flare.setScale(0.2);

    var opacityAnim = cc.FadeTo.create(0.5, 255);
    var opacDim = cc.FadeTo.create(1, 0);
    var biggeAnim = cc.ScaleBy.create(0.7, 1.2, 1.2);
    var biggerEase = cc.EaseSineOut.create(biggeAnim);
    var moveAnim = cc.MoveBy.create(0.5, cc.p(328, 0));
    var easeMove = cc.EaseSineOut.create(moveAnim);
    var rotateAnim = cc.RotateBy.create(2.5, 90);
    var rotateEase = cc.EaseExponentialOut.create(rotateAnim)
    var bigger = cc.ScaleTo.create(0.5, 1);

    var onComplete = cc.CallFunc.create(target, callback);
    var killflare = cc.CallFunc.create(flare, function () {
        this.getParent().removeChild(this,true);
    });
    flare.runAction(cc.Sequence.create(opacityAnim, biggerEase, opacDim, killflare, onComplete));
    flare.runAction(easeMove);
    flare.runAction(rotateEase);
    flare.runAction(bigger);
}


var spark = function (ccpoint, parent, scale, duration) {
    scale = scale || 0.3;
    duration = duration || 0.5;
    var one = cc.Sprite.create(s_explode1);
    var two = cc.Sprite.create(s_explode2);
    var three = cc.Sprite.create(s_explode3);
    // XXX riq XXX
    // It should be flare.setBlendFunc( cc.GL_SRC_ALPHA, cc.GL_ONE )
//    one.setBlendFunc(new cc.BlendFunc(cc.GL_SRC_ALPHA, cc.GL_ONE));
//    two.setBlendFunc(new cc.BlendFunc(cc.GL_SRC_ALPHA, cc.GL_ONE));
//    three.setBlendFunc(new cc.BlendFunc(cc.GL_SRC_ALPHA, cc.GL_ONE));
    one.setPosition(ccpoint);
    two.setPosition(ccpoint);
    three.setPosition(ccpoint);
    //parent.addChild(one);
    parent.addChild(two);
    parent.addChild(three);
    one.setScale(scale);
    two.setScale(scale);
    three.setScale(scale);
    three.setRotation(Math.random() * 360);
    var left = cc.RotateBy.create(duration, -45);
    var right = cc.RotateBy.create(duration, 45);
    var scaleBy = cc.ScaleBy.create(duration, 3, 3);
    var fadeOut = cc.FadeOut.create(duration);
    one.runAction(left);
    two.runAction(right);
    one.runAction(scaleBy);
    two.runAction(scaleBy.copy());
    three.runAction(scaleBy.copy());
    one.runAction(fadeOut);
    two.runAction(fadeOut.copy());
    three.runAction(fadeOut.copy());
    setTimeout(function () {
        parent.removeChild(one,true);
        parent.removeChild(two,true);
        parent.removeChild(three,true);
    }, duration * 1000);
}
