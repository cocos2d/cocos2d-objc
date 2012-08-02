var winSize = null;
var keys = [];
var global = {
    level:1,
    life:4,
    score:0,
    sound:true,
    DELTA_X:-100,
    OFFSET_X:-24,
    ROT:-5.625,
    bulletType:{
        Ship:1,
        Enemy:2
    },
    weaponType:{
        one:1
    },
    Tag:{
        EnemyBullet:900,
        Enemy:901,
        Ship:902,
        ShipBullet:903
    },
    moveType:{
        Attack:0,
        Vertical:1,
        Horizontal:2,
        Overlap:3
    },
    AttackMode:{
        Normal:1,
        Tsuihikidan:2
    },
    lifeUpScores:[50000, 100000, 150000, 200000, 250000, 300000],
    enemyContainer:[],
    ebulletContainer:[],
    sbulletContainer:[],

    STATE_PLAYING : 0,
    STATE_GAME_OVER : 1,
};
