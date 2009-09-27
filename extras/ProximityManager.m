//
//  ProximityManager.m
//  Warfare
//
//  Created by Jason Booth on 1/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ProximityManager.h"

@implementation ProximityManager

+(id)create:(uint)gs
{
  self = [[[ProximityManager alloc] initWithSize:gs] autorelease];
  return self;
}

-(id)initWithSize:(uint)gs
{
  self = [super init];
  if (self)
  {
    gridSize = gs;
    objects = [[NSMutableArray alloc] init];
    positions = [[NSMutableDictionary alloc] initWithCapacity:100];
    cachedPositions = [[NSMutableDictionary alloc] initWithCapacity:100];
  }
  return self;
}

-(void)dealloc
{
  [objects removeAllObjects];
  [positions removeAllObjects];
  [cachedPositions removeAllObjects];
  [objects release];
  [positions release];
  [cachedPositions release];
  [super dealloc];
}

-(void)addObject:(CocosNode*)object
{
  [objects addObject:object];
}

-(void)removeObject:(CocosNode*)object
{
  [objects removeObject:object];
}

-(void)update
{
  [positions removeAllObjects];
  [cachedPositions removeAllObjects];
  uint off = gridSize*1024;
  for (CocosNode* o in objects)
  {
    uint index = (int)((o.position.x + off) / gridSize) << 11 | (int)((o.position.y + off) / gridSize); // max of +/- 2^10 rows and columns
    NSNumber* num = [NSNumber numberWithInt:index];
    NSMutableArray* ar = [positions objectForKey:num];
    if (ar == nil)
    {
      ar = [[[NSMutableArray alloc] init] autorelease];
      [positions setObject:ar forKey:num];
    }
    [ar addObject:o];
  }
}

-(NSMutableArray*)getExactRange:(float)x y:(float)y range:(int)range
{
  NSMutableArray* g = [self getRoughRange:x y:y range:range];
  NSMutableArray* r = [[[NSMutableArray alloc] init] autorelease];
  for (CocosNode* u in g)
  {
    if (sqrt(pow([u position].x - x, 2) + pow([u position].y - y, 2)) < range)
    {
      [r addObject:u];
    }
  }
  return r;
}

-(NSMutableArray*)getRoughRange:(float)x y:(float)y range:(int)range
{
  uint off = gridSize * 1024;
  uint index = (int)((x + off) / gridSize) << 11 | (int)((y + off) / gridSize); // max of +/- 2^10 rows and columns
  uint cells = 1 + (range / gridSize);
  
  // check cache
  NSString* tmp = [NSString stringWithFormat:@"%i_%i", index, cells];
  NSMutableArray* r = [cachedPositions objectForKey:tmp];
  if (r)
    return r;
  
  // ok, no luck with the cache, do a search
  r = [[[NSMutableArray alloc] init] autorelease];
  for (int xi = (index-cells); xi <= (index+cells); ++xi)
  {
    for (int yi = 0; yi <= (2 * cells); ++yi)
    {
      NSNumber* num = [NSNumber numberWithInt:((yi - cells)*2048)+xi];
      if ([positions objectForKey:num]) 
      {
        [r addObjectsFromArray:[positions objectForKey:num]];
      }
    }
  }
  [cachedPositions setObject:r forKey:tmp];
  return r;
}


@end
