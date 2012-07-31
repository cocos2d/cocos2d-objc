var Enemy = cc.Sprite.extend({
    eID:0,
    active:true,
    speed:200,
    bulletSpeed:-200,
    HP:15,
    bulletPowerValue:1,
    moveType:null,
    scoreValue:200,
    zOrder:1000,
    delayTime:1 + 1.2 * Math.random(),
    attackMode:global.AttackMode.Normal,
    _hurtColorLife:0,
    ctor:function (arg) {
        var parent = new cc.Sprite();
        __associateObjWithNative(this, parent);

        this.HP = arg.HP;
        this.moveType = arg.moveType;
        this.scoreValue = arg.scoreValue;
        this.attackMode = arg.attackMode;

        this.initWithSpriteFrameName(arg.textureName);
        this.schedule(this.shoot, this.delayTime)
    },
    _timeTick:0,
    update:function (dt) {
        if (this.HP <= 0) {
            this.active = false;
        }
        this._timeTick += dt;
        if (this._timeTick > 0.1) {
            this._timeTick = 0;
            if (this._hurtColorLife > 0) {
                this._hurtColorLife--;
            }
            if (this._hurtColorLife == 1) {
                // XXX riq XXX
                // Uses new cc.c3 API
                this.setColor( cc.c3(255, 255, 255) );
            }
        }
    },
    destroy:function () {
        global.score += this.scoreValue;
        var a = new Explosion();
        a.setPosition(this.getPosition());
        this.getParent().addChild(a);
        spark(this.getPosition(),this.getParent(), 1.2, 0.7);
        cc.ArrayRemoveObject(global.enemyContainer,this);
        this.getParent().removeChild(this,true);
        if(global.sound){
            cc.AudioEngine.getInstance().playEffect(s_explodeEffect);
        }
    },
    shoot:function () {
        var b = new Bullet(this.bulletSpeed, "W2.png", this.attackMode);
        global.ebulletContainer.push(b);
        this.getParent().addChild(b, b.zOrder, global.Tag.EnemyBullet);
        var _pos = this.getPosition();
        var pos = {x:_pos[0], y:_pos[1]};
        var _cs = this.getContentSize();
        var cs = {width:_cs[0], height:_cs[1]};
        b.setPosition( cc.p(pos.x, pos.y - cs.height * 0.2) );
    },
    hurt:function () {
        this._hurtColorLife = 2;
        this.HP--;
        this.setColor( cc.RED );
    },
    collideRect:function(){
        var _a = this.getContentSize();
        var a = {width:_a[0], height:_a[1]};
        var _pos = this.getPosition();
        var pos = {x:_pos[0], y:_pos[1]};

        var r = cc.rect(pos.x - a.width/2, pos.y - a.height/4,a.width,a.height/2);
        return r;
    }
});

Enemy.sharedEnemy = function(){
    cc.SpriteFrameCache.getInstance().addSpriteFrames(s_Enemy_plist, s_Enemy);
};
