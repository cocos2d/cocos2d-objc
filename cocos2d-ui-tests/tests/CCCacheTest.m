#import "TestBase.h"
#import "CCCache.h"

// -----------------------------------------------------------------
// Simple demo cache, holding an allocated array
// -----------------------------------------------------------------

@interface DemoCache : CCCache @end

@implementation DemoCache

- (id)createSharedDataForKey:(id<NSCopying>)key
{
    unsigned char* rawData = malloc(255);
    CCLOG(@"Data created for key: %@", key);
    return([NSValue valueWithPointer:rawData]);
}

- (id)createPublicObjectForSharedData:(id)data
{
    return([NSValue valueWithNonretainedObject:data]);
}

- (void)disposeOfSharedData:(id)data
{
    free([((NSValue *)data) pointerValue]);
}

- (void)logCache
{
    for (unsigned char letter = 'A'; letter < 'X'; letter ++)
    {
        NSString *key = [NSString stringWithFormat:@"object%c", letter];
        if ([self keyExists:key])
        {
            NSValue *value = [self rawObjectForKey:key];
            if (value) CCLOG(@"%@", key); else CCLOG(@"%@ (unused)", key);
        }
    }
}

@end

// -----------------------------------------------------------------
// Cache test
// -----------------------------------------------------------------

@interface CCCacheTest : TestBase @end

// -----------------------------------------------------------------

@implementation CCCacheTest
{
    DemoCache *_cache;
    int _testStep;
    NSValue *_A;
    NSValue *_B;
}

- (NSArray*) testConstructors
{
    return [NSArray arrayWithObjects:
            @"cacheTest",
            nil];
}

- (void)cacheTest
{
    self.subTitle = @"Cache Test";
    
    CCButton *button = [CCButton buttonWithTitle:@"[ Step test]" fontName:@"Arial" fontSize:18];
    button.positionType = CCPositionTypeNormalized;
    button.position = ccp(0.5, 0.5);
    [button setTarget:self selector:@selector(stepClicked:)];
    [self.contentNode addChild:button];
    
    _testStep = 0;
    
    _cache = [DemoCache cache];
    
    [_cache preload:@"objectA"];
    [_cache preload:@"objectA"]; // same object as above
    [_cache preload:@"objectB"];
    [_cache preload:@"objectC"];
}

- (void)stepClicked:(id)sender
{
    CCLOG(@"---------------------------------------------------");
    switch (_testStep) {
        case 0:
            CCLOG(@"-- All cached objects should be unused");
            break;
            
        case 1:
            CCLOG(@"-- objectA in use");
            _A = [_cache objectForKey:@"objectA"];
            break;
            
        case 2:
            CCLOG(@"-- objectB in use");
            _B = [_cache objectForKey:@"objectB"];
            break;
            
        case 3:
            CCLOG(@"-- Flush, and thus remove objectC");
            [_cache flush];
            break;
            
        case 4:
            CCLOG(@"-- objectA not in use anymore");
            _A = nil;
            break;
            
        case 5:
            CCLOG(@"-- Flush, and thus only leaving objectB");
            [_cache flush];
            break;
            
        case 6:
            CCLOG(@"-- New objectA should be created");
            _A = [_cache objectForKey:@"objectA"];
            break;
            
        case 7:
            CCLOG(@"-- No new objectB should be created");
            [_cache flush];
            _B = [_cache objectForKey:@"objectB"];
            break;
            
        default:
            CCLOG(@"End of test!");
            _testStep = -1;
            break;
    }
    [_cache logCache];
    _testStep ++;
}


// -----------------------------------------------------------------

@end
