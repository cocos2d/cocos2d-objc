// sprite
var director = [CCDirector sharedDirector];
var mainScene = director.runningScene;
var layer = mainScene.children[0];
var sprite = [CCSprite spriteWithFile:'grossini.png'];
[layer addChild: sprite ];
var s = [director winSize];
sprite.setPosition( CGPointMake( s.width/2, s.height/2 ) );


// action
var rotate = [CCRotateBy actionWithDuration:2 angle:360];
var move = [CCMoveBy actionWithDuration:2 position:CGPointMake(200,0)];
var jump = [CCJumpBy actionWithDuration:2 position:CGPointMake(-300,0) height:100 jumps:2];

var seq = [CCSequence actionsWithArray: [rotate, move, jump] ];
[sprite runAction:seq ];



