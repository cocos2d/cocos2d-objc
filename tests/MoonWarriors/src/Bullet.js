//bullet
var Bullet = cc.Sprite.extend({
    active:true,
    xVolocity:0,
    yVolocity:200,
    power:1,
    HP:1,
    moveType:null,
    zOrder:3000,
    attackMode:global.AttackMode.Normal,
    parentType:global.bulletType.Ship,
    ctor:function (bulletSpeed, weaponType, attackMode) {
        var parent = new cc.Sprite();
        __associateObjWithNative(this, parent);

        this.yVolocity = -bulletSpeed;
        this.attackMode = attackMode;
        cc.SpriteFrameCache.getInstance().addSpriteFrames(s_bullet_plist);
        this.initWithSpriteFrameName(weaponType);
        // XXX riq XXX
        // New Blending function API. Similar to OpenGL / WebGL
        this.setBlendFunc( gl.SRC_ALPHA, gl.ONE );
        /*var tmpAction;
         switch (this.attackMode) {
         case global.AttackMode.Normal:
         tmpAction = cc.MoveBy.create(2, cc.p(this.getPosition().x, 400));
         break;
         case global.AttackMode.Tsuihikidan:
         tmpAction = cc.MoveTo.create(2, GameLayer.create()._ship.getPosition());
         break;
         }
         this.runAction(tmpAction);*/
    },
    update:function (dt) {
        var pos = this.getPosition();
        var newX = pos[0];
        var newY = pos[1]
        newX -= this.xVolocity * dt;
        newY -= this.yVolocity * dt;
        this.setPosition(cc.p(newX, newY));
        if (this.HP <= 0) {
            this.active = false;
        }
    },
    destroy:function () {
        var explode = cc.Sprite.create(s_hit);
        // XXX riq XXX
        // New Blending function API. Similar to OpenGL / WebGL
        explode.setBlendFunc( gl.SRC_ALPHA, gl.ONE );
        explode.setPosition(this.getPosition());
        explode.setRotation(Math.random()*360);
        explode.setScale(0.75);
        this.getParent().addChild(explode,9999);
        cc.ArrayRemoveObject(global.ebulletContainer,this);
        cc.ArrayRemoveObject(global.sbulletContainer,this);
        this.getParent().removeChild(this,true);
        var removeExplode = cc.CallFunc.create(explode,explode.removeFromParentAndCleanup);
        explode.runAction(cc.ScaleBy.create(0.3, 2,2));
        explode.runAction(cc.Sequence.create(cc.FadeOut.create(0.3), removeExplode))
    },
    hurt:function () {
        this.HP--;
    },
    collideRect:function(){
        var pos = this.getPosition();
        var r = new cc.rect( pos[0] - 3, pos[1] - 3,6,6);
        return r;
    }
});
