// http://www.cocos2d-iphone.org
//
// Test Objective-J API
// http://cappuccino.org/learn/
//


// Helper functions
function ccp( x, y ) {
	return CGPointMake( x, y );
}

//
// Objective-J Test
//
function test_objective_j() {
	this.title = "Objective-J Test";
	this.subtitle = "Testing the Objective-J + cocos2d";	
}

test_objective_j.prototype.test = function( layer ) {
	var director = [CCDirector sharedDirector];
	
	// create sprite
	var sprite = [CCSprite spriteWithFile:'grossini.png'];
	[layer addChild: sprite ];
	var s = [director winSize];
	[sprite setPosition: CGPointMake( s.width/2, s.height/2 ) ];
	
	
	// action
	var rotate = [CCRotateBy actionWithDuration:2 angle:360];
	var move = [CCMoveBy actionWithDuration:2 position:CGPointMake(200,0)];
	var jump = [CCJumpBy actionWithDuration:2 position:CGPointMake(-300,0) height:100 jumps:2];
	
	var seq = [CCSequence actionsWithArray: [rotate, move, jump] ];
	[sprite runAction:seq ];
};

//
// Javascript Test
//
function test_javascript() {
	this.title = "Javascript Test";
	this.subtitle = "Testing the Javascript + cocos2d";		
}

test_javascript.prototype.test = function( layer ) {
	var director = CCDirector.sharedDirector;
	
	// create sprite
	var sprite = CCSprite.spriteWithFile('grossini.png');
	layer.addChild( sprite );
	var s = director.winSize;
	sprite.setPosition( CGPointMake( s.width/2, s.height/2 ) );
	
	
	// action
	var rotate = CCRotateBy.actionWithDuration_angle(2, 360 );
	var move = CCMoveBy.actionWithDuration_position(2, CGPointMake(200,0) );
	var jump = CCJumpBy.actionWithDuration_position_height_jumps( 2, CGPointMake(-300,0), 100, 2 );
	
	var seq = CCSequence.actionsWithArray( [rotate, move, jump] );
	sprite.runAction( seq );
}


//
// Sprite Color
//
function SpriteColorOpacity() {
	this.title = "Sprite: Color & Opacity";
	this.subtitle = "Javascript testing";		
}

SpriteColorOpacity.prototype.test = function( self ) {
	
	var s = CCDirector.sharedDirector.winSize;

	var sprite1 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*0, 121*1, 85, 121) );
	var sprite2 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*1, 121*1, 85, 121) );
	var sprite3 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*2, 121*1, 85, 121) );
	var sprite4 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*3, 121*1, 85, 121) );
	
	var sprite5 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*0, 121*1, 85, 121) );
	var sprite6 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*1, 121*1, 85, 121) );
	var sprite7 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*2, 121*1, 85, 121) );
	var sprite8 = CCSprite.spriteWithFile_rect("grossini_dance_atlas.png", CGRectMake(85*3, 121*1, 85, 121) );
	
	sprite1.position = ccp( (s.width/5)*1, (s.height/3)*1);
	sprite2.position = ccp( (s.width/5)*2, (s.height/3)*1);
	sprite3.position = ccp( (s.width/5)*3, (s.height/3)*1);
	sprite4.position = ccp( (s.width/5)*4, (s.height/3)*1);
	sprite5.position = ccp( (s.width/5)*1, (s.height/3)*2);
	sprite6.position = ccp( (s.width/5)*2, (s.height/3)*2);
	sprite7.position = ccp( (s.width/5)*3, (s.height/3)*2);
	sprite8.position = ccp( (s.width/5)*4, (s.height/3)*2);
	
	var action = CCFadeIn.actionWithDuration( 2 );
	var action_back = action.reverse;
	var fade = CCRepeatForever.actionWithAction( CCSequence.actionsWithArray( [action, action_back] ) );
	
	var tintred = CCTintBy.actionWithDuration_red_green_blue(2,0,-255,-255);
	var tintred_back = tintred.reverse;
	var red = CCRepeatForever.actionWithAction( CCSequence.actionsWithArray( [tintred, tintred_back] ) );
	
	var tintgreen = CCTintBy.actionWithDuration_red_green_blue(2,-255,0,-255);
	var tintgreen_back = tintgreen.reverse;
	var green = CCRepeatForever.actionWithAction( CCSequence.actionsWithArray( [tintgreen, tintgreen_back] ) );
	
	var tintblue = CCTintBy.actionWithDuration_red_green_blue(2,-255,-255,0);
	var tintblue_back = tintblue.reverse;
	var blue = CCRepeatForever.actionWithAction( CCSequence.actionsWithArray( [tintblue, tintblue_back] ) );
	
	
	sprite5.runAction( red );
	sprite6.runAction( green );
	sprite7.runAction( blue );
	sprite8.runAction( fade );
	
	// late add: test dirtyColor and dirtyPosition
	self.addChild( sprite1 );
	self.addChild( sprite2 );
	self.addChild( sprite3 );
	self.addChild( sprite4 );
	self.addChild( sprite5 );
	self.addChild( sprite6 );
	self.addChild( sprite7 );
	self.addChild( sprite8 );
}

//
// Main
// 
// Returns the main scene
function get_scene() {
	var mainScene = CCDirector.sharedDirector.runningScene;
	return mainScene.children[0];	
}

//
// Test to execute
//
var array_of_tests = [ test_objective_j, test_javascript, SpriteColorOpacity ];

// Get running Layer
var layer = get_scene();

layer.numberOfTests = array_of_tests.length;
var index = layer.testIndex;

// Get Test
var test = new array_of_tests[index];

// Set Title
layer.setTitle( test.title );
layer.setSubtitle( test.subtitle );

// Run it
test.test( layer );
