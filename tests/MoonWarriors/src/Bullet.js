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
        this.yVolocity = -bulletSpeed;
        this.attackMode = attackMode;
        cc.SpriteFrameCache.getInstance().addSpriteFrames(s_bullet_plist);
        this.initWithSpriteFrameName(weaponType);
        this.setBlendFunc(new cc.BlendFunc(cc.GL_SRC_ALPHA, cc.GL_ONE));
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
        var newX = this.getPositionX(), newY = this.getPositionY();
        newX -= this.xVolocity * dt;
        newY -= this.yVolocity * dt;
        this.setPosition(cc.p(newX, newY));
        if (this.HP <= 0) {
            this.active = false;
        }
    },
    destroy:function () {
        var explode = cc.Sprite.create(s_hit);
        explode.setBlendFunc(new cc.BlendFunc(cc.GL_SRC_ALPHA, cc.GL_ONE));
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
        var a = this.getContentSize();
        var r = new cc.RectMake(this.getPositionX() - 3,this.getPositionY() - 3,6,6);
        return r;
    }
});
