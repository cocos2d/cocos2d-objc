// sprite
var director = [CCDirector sharedDirector];
var mainScene = director.runningScene;
var layer = mainScene.children[0];
var sprite = CCSprite.alloc.initWithFile('grossini.png');
layer.addChild( sprite );
var s = [director winSize];
sprite.setPosition( CGPointMake( s.width/2, s.height/2 ) );
sprite.release;


// action
var rotate = [CCRotateBy actionWithDuration:2 angle:360];
var move = [CCMoveBy actionWithDuration:2 position:CGPointMake(200,0)];
var seq = [CCSequence actionsWithArray: [rotate, move] ];
sprite.runAction( seq );



