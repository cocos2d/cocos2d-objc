//
//  ObjectiveC++Test.m
//  cocos2d-tests
//
//  Created by Logan on 6/25/16.
//  Copyright © 2016 Cocos2d. All rights reserved.
//

#import "cocos2d.h"
#import "TestBase.h"
#include <vector>
#import "CCRenderer_Private.h"

@interface ObjectiveCppTest : TestBase @end
@implementation ObjectiveCppTest {
    BOOL _transformTest;
    CCSprite *_transformTestDeepestDescendedSprite;
    CCNode *_transformContainer;
}

- (void)setUp {
    _transformTest = NO;
    [[CCFileUtils sharedFileUtils] setSearchPath: @[ @"Images", kCCFileUtilsDefaultSearchPath] ];
}

- (NSArray*)testConstructors
{
    return [NSArray arrayWithObjects:
            @"objCppBasicTest",
            @"objCppTransformTest",
            nil];
}

static CCNode* spriteContainer( std::vector<CCSprite *>& v ) {
    CCNode *container = [CCNode node];
    float lastScale = container.scale;
    CCNode *lastNode = container;
    for ( std::vector<CCSprite *>::iterator it = v.begin(); it != v.end(); ++it ) {
        CCSprite *s = *it;
        [lastNode addChild:s];
        s.position = ccp( s.parent.contentSize.width/2., s.parent.contentSize.height/2. );
        s.scale = lastScale * 0.75;
        lastScale = s.scale;

        s.anchorPoint = ccp( CCRANDOM_0_1(), CCRANDOM_0_1() );

        CCActionInterval *rotate = [CCActionRotateBy actionWithDuration:CCRANDOM_0_1()*6. + 4. angle:360];
        rotate = CCRANDOM_0_1() < 0.5 ? rotate : [rotate reverse];
        [s runAction:[CCActionRepeatForever actionWithAction:rotate]];

        lastNode = s;
    }
    return container;
}

static CCNode* getSprites() {
    std::vector<CCSprite *> sprites;
    for ( int i = 0; i < 3; ++i ) {
        CCSprite *sprite = [CCSprite spriteWithImageNamed:@"powered.png"];
        sprites.push_back( sprite );
    }
    CCNode *container = spriteContainer( sprites );
    CGSize s = [[CCDirector sharedDirector] viewSize];
    container.position = ccp( s.width/2.0f, s.height/2.0f);
    return container;
}

- (void)objCppBasicTest {
    _transformTest = NO;
    [self.contentNode addChild:getSprites()];
    self.subTitle = @"Node hierarchy in Obj-C++ with some CCActions, after using some basic C++ objects and logic";
}

- (void)objCppTransformTest {
    _transformTest = YES;
    _transformContainer = getSprites();
    CCSprite *grandestChildSprite = (CCSprite *)_transformContainer.children[0];
    // find the deepest-descended sprite
    while ( grandestChildSprite.children[0] ) {
        grandestChildSprite = grandestChildSprite.children[0];
        [grandestChildSprite onEnter];
    }
    _transformTestDeepestDescendedSprite = grandestChildSprite;
//    [_transformTestDeepestDescendedSprite onEnter];

    self.subTitle = @"Same as before, but only drawing the deepest-descended sprite using only transform matrices";
}

- (void)visit:(CCRenderer *)renderer parentTransform:(const GLKMatrix4 *)parentTransform {
    if ( _transformTest ) {
        CCRenderer *renderer = [CCRenderer currentRenderer];
        GLKMatrix4 transformMatrix;
        [renderer.globalShaderUniforms[CCShaderUniformProjection] getValue:&transformMatrix];

        NSMutableArray *transformNodes = [[NSMutableArray alloc] init];
        CCNode *currentNode = _transformTestDeepestDescendedSprite;
        for ( int i = 0; i < 2; ++i ) {
        while ( currentNode.parent ) {
            currentNode = currentNode.parent;
            [transformNodes addObject:currentNode];
        }
            if ( i == 0 ) {
            currentNode = self.contentNode;
            [transformNodes addObject:self.contentNode];
            }
        }
        for ( CCNode *n in [transformNodes reverseObjectEnumerator] ) {
            transformMatrix = [n transform:&transformMatrix];
        }
        [_transformTestDeepestDescendedSprite visit:renderer parentTransform:&transformMatrix];
    }
    [super visit:renderer parentTransform:parentTransform];
}

@end