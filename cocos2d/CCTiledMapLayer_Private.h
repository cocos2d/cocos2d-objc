//
//  CCTiledMapLayer_Private.h
//  cocos2d-ios
//
//  Created by Viktor on 10/29/13.
//
//

#import "CCTiledMapLayer.h"

@interface CCTiledMapLayer ()

/** dealloc the map that contains the tile position from memory.
 Unless you want to know at runtime the tiles positions, you can safely call this method.
 If you are going to call [layer tileGIDAt:] then, don't release the map
 */
-(void) releaseMap;

/** Creates the tiles */
-(void) setupTiles;

@end
