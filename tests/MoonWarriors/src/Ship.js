var Ship = cc.Sprite.extend({
    speed:220,
    bulletSpeed:900,
    HP:10,
    bulletTypeValue:1,
    bulletPowerValue:1,
    throwBombing:false,
    canBeAttack:true,
    isThrowingBomb:false,
    zOrder:3000,
    maxBulletPowerValue:4,
    appearPosition:cc.p(160, 60),
    _hurtColorLife:0,
    active:true,
    ctor:function () {
        var parent = new cc.Sprite();
        __associateObjWithNative(this, parent);

        //init life
        var shipTexture = cc.TextureCache.getInstance().addImage(s_ship01);
        this.initWithTexture(shipTexture, cc.rect(0, 0, 60, 38));
        this.setTag(this.zOrder);
        this.setPosition(this.appearPosition);

        // set frame

        // XXX API INCONSISTENCY XXX riq XXX
        // renamed: create() -> crateWithTexture() like in cc.Sprite
        // cc.SpriteFrame.create( filename, rect );
        // cc.SpriteFrame.createWithTexture( texture, rect );
        var frame0 = cc.SpriteFrame.createWithTexture(shipTexture, cc.rect(0, 0, 60, 38));
        var frame1 = cc.SpriteFrame.createWithTexture(shipTexture, cc.rect(60, 0, 60, 38));

        var animFrames = [];
        animFrames.push(frame0);
        animFrames.push(frame1);

        // ship animate
        
        // XXX riq XXX
        // renamed createWithSpriteFrames() -> create()
        var animation = cc.Animation.create(animFrames, 0.1);
        var animate = cc.Animate.create(animation);
        this.runAction(cc.RepeatForever.create(animate));
        this.schedule(this.shoot, 1 / 6);

        //revive effect
        this.canBeAttack = false;
        var ghostSprite = cc.Sprite.createWithTexture(shipTexture, cc.rect(0, 45, 60, 38))
        // XXX riq XXX
        // New Blending function API. Similar to OpenGL / WebGL
        ghostSprite.setBlendFunc( gl.SRC_ALPHA, gl.ONE )
        ghostSprite.setScale(8);
        ghostSprite.setPosition(cc.p(this.getContentSize().width / 2, 12));
        this.addChild(ghostSprite, 3000, 99999);
        ghostSprite.runAction(cc.ScaleTo.create(0.5, 1, 1));
        var blinks = cc.Blink.create(3, 9);
        var makeBeAttack = cc.CallFunc.create(this, function (t) {
            t.canBeAttack = true;
            t.setVisible(true);
            t.removeChild(ghostSprite,true);
        });
        this.runAction(cc.Sequence.create(cc.DelayTime.create(0.5), blinks, makeBeAttack));
    },
    update:function (dt) {
        var newPos = this.getPosition();
        // XXX riq XXX
        // Keyboard not supported yet
//        if ((keys[cc.KEY.w] || keys[cc.KEY.up]) && this.getPosition().y <= winSize.height) {
//            newY += dt * this.speed;
//        }
//        if ((keys[cc.KEY.s] || keys[cc.KEY.down]) && this.getPosition().y >= 0) {
//            newY -= dt * this.speed;
//        }
//        if ((keys[cc.KEY.a] || keys[cc.KEY.left]) && this.getPosition().x >= 0) {
//            newX -= dt * this.speed;
//        }
//        if ((keys[cc.KEY.d] || keys[cc.KEY.right]) && this.getPosition().x <= winSize.width) {
//            newX += dt * this.speed;
//        }
        this.setPosition( newPos );

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
                this.setColor( cc.c3(255, 255, 255));
            }
        }
    },
    shoot:function (dt) {
        //this.shootEffect();
        var offset = 13;
        var _pos = this.getPosition();
        var pos = cc._from_p(_pos);
        var _cs = this.getContentSize();
        var cs = cc._from_size(_cs);
        var a = new Bullet(this.bulletSpeed, "W1.png", global.AttackMode.Normal);
        global.sbulletContainer.push(a);
        this.getParent().addChild(a, a.zOrder, global.Tag.ShipBullet);
        a.setPosition(cc.p(pos.x + offset, pos.y + 3 + cs.height * 0.3));

        var b = new Bullet(this.bulletSpeed, "W1.png", global.AttackMode.Normal);
        global.sbulletContainer.push(b);
        this.getParent().addChild(b, b.zOrder, global.Tag.ShipBullet);
        b.setPosition(cc.p(pos.x - offset, pos.y + 3 + cs.height * 0.3));
    },
    destroy:function () {
        var _pos = this.getPosition();
        var pos = cc._from_p(_pos);
        global.life--;
        this.getParent().addChild(new Explosion(pos.x, pos.y));
        this.getParent().removeChild(this,true);
        if (global.sound) {
            cc.AudioEngine.getInstance().playEffect(s_shipDestroyEffect,false);
        }
    },
    hurt:function () {
        if (this.canBeAttack) {
            this._hurtColorLife = 2;
            this.HP--;
            this.setColor(cc.RED);
        }
    },
    collideRect:function(){
        var _a = this.getContentSize();
        var a = cc._from_size(_a);
        var _p = this.getPosition();
        var p = cc._from_p(_p);
        var r = cc.rect(p.x - a.width/2, p.y - a.height/2,a.width,a.height/2);
        return r;
    }
});
