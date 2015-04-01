//
//  CCEffectVarying.m
//  cocos2d
//
//  Created by Thayer J Andrews on 3/5/15.
//
//

#import "CCEffectVarying.h"

#pragma mark CCEffectVarying

@implementation CCEffectVarying

-(id)initWithType:(NSString*)type name:(NSString*)name
{
    if((self = [self initWithType:type name:name count:0]))
    {
        return self;
    }
    
    return self;
}

+(instancetype)varying:(NSString*)type name:(NSString*)name
{
    return [[self alloc] initWithType:type name:name];
}

-(id)initWithType:(NSString*)type name:(NSString*)name count:(NSInteger)count
{
    if((self = [super init]))
    {
        _name = name;
        _type = type;
        _count = count;
        
        return self;
    }
    
    return self;
}

+(instancetype)varying:(NSString*)type name:(NSString*)name count:(NSInteger)count
{
    return [[self alloc] initWithType:type name:name count:count];
}


-(NSString*)declaration
{
    NSString* declaration;
    
    if(_count == 0)
        declaration = [NSString stringWithFormat:@"varying %@ %@;", _type, _name];
    else
        declaration = [NSString stringWithFormat:@"varying %@ %@[%lu];", _type, _name, (long)_count];
    
    return declaration;
}

@end
