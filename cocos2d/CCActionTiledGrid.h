/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2009 On-Core
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

#import "CCActionGrid.h"

/** CCShakyTiles3D action */
@interface CCShakyTiles3D : CCTiledGrid3DAction
{
	int		_randrange;
	BOOL	_shakeZ;
}

/** creates the action with a range, whether or not to shake Z vertices, a grid size, and duration */
+(id)actionWithDuration:(ccTime)duration size:(CGSize)gridSize range:(int)range shakeZ:(BOOL)shakeZ;
/** initializes the action with a range, whether or not to shake Z vertices, a grid size, and duration */
-(id)initWithDuration:(ccTime)duration size:(CGSize)gridSize range:(int)range shakeZ:(BOOL)shakeZ;

@end

////////////////////////////////////////////////////////////

/** CCShatteredTiles3D action */
@interface CCShatteredTiles3D : CCTiledGrid3DAction
{
	int		_randrange;
	BOOL	_once;
	BOOL	_shatterZ;
}

/** creates the action with a range, whether of not to shatter Z vertices, a grid size and duration */
+(id)actionWithDuration:(ccTime)duration size:(CGSize)gridSize range:(int)range shatterZ:(BOOL)shatterZ;
/** initializes the action with a range, whether or not to shatter Z vertices, a grid size and duration */
-(id)initWithDuration:(ccTime)duration size:(CGSize)gridSize range:(int)range shatterZ:(BOOL)shatterZ;

@end

////////////////////////////////////////////////////////////

/** CCShuffleTiles action
 Shuffle the tiles in random order
 */
@interface CCShuffleTiles : CCTiledGrid3DAction
{
	unsigned	_seed;
	NSUInteger _tilesCount;
	NSUInteger *_tilesOrder;
	void *_tiles;
}

/** creates the action with a random seed, the grid size and the duration */
+(id)actionWithDuration:(ccTime)duration size:(CGSize)gridSize seed:(unsigned)seed;
/** initializes the action with a random seed, the grid size and the duration */
-(id)initWithDuration:(ccTime)duration size:(CGSize)gridSize seed:(unsigned)seed;

@end

////////////////////////////////////////////////////////////

/** CCFadeOutTRTiles action
 Fades out the tiles in a Top-Right direction
 */
@interface CCFadeOutTRTiles : CCTiledGrid3DAction
{
}
// XXX: private, but added to make BridgeSupport happy
-(float)testFunc:(CGSize)pos time:(ccTime)time;
@end

////////////////////////////////////////////////////////////

/** CCFadeOutBLTiles action.
 Fades out the tiles in a Bottom-Left direction
 */
@interface CCFadeOutBLTiles : CCFadeOutTRTiles
{
}
// XXX: private, but added to make BridgeSupport happy
-(float)testFunc:(CGSize)pos time:(ccTime)time;
@end

////////////////////////////////////////////////////////////

/** CCFadeOutUpTiles action.
 Fades out the tiles in upwards direction
 */
@interface CCFadeOutUpTiles : CCFadeOutTRTiles
{
}
// XXX: private, but added to make BridgeSupport happy
-(float)testFunc:(CGSize)pos time:(ccTime)time;
@end

////////////////////////////////////////////////////////////

/** CCFadeOutDownTiles action.
 Fades out the tiles in downwards direction
 */
@interface CCFadeOutDownTiles : CCFadeOutUpTiles
{
}
// XXX: private, but added to make BridgeSupport happy
-(float)testFunc:(CGSize)pos time:(ccTime)time;
@end

////////////////////////////////////////////////////////////

/** CCTurnOffTiles action.
 Turn off the files in random order
 */
@interface CCTurnOffTiles : CCTiledGrid3DAction
{
	unsigned	_seed;
	NSUInteger _tilesCount;
	NSUInteger *_tilesOrder;
}

/** creates the action with a random seed, the grid size and the duration */
+(id)actionWithDuration:(ccTime)duration size:(CGSize)gridSize seed:(unsigned)seed;
/** initializes the action with a random seed, the grid size and the duration */
-(id)initWithDuration:(ccTime)duration size:(CGSize)gridSize seed:(unsigned)seed;
@end

////////////////////////////////////////////////////////////

/** CCWavesTiles3D action. */
@interface CCWavesTiles3D : CCTiledGrid3DAction
{
	NSUInteger _waves;
	float _amplitude;
	float _amplitudeRate;
}

/** waves amplitude */
@property (nonatomic,readwrite) float amplitude;
/** waves amplitude rate */
@property (nonatomic,readwrite) float amplitudeRate;

/** creates the action with a number of waves, the waves amplitude, the grid size and the duration */
+(id)actionWithDuration:(ccTime)duration size:(CGSize)gridSize waves:(NSUInteger)wav amplitude:(float)amp;
/** initializes the action with a number of waves, the waves amplitude, the grid size and the duration */
-(id)initWithDuration:(ccTime)duration size:(CGSize)gridSize waves:(NSUInteger)wav amplitude:(float)amp;

@end

////////////////////////////////////////////////////////////

/** CCJumpTiles3D action.
 A sin function is executed to move the tiles across the Z axis
 */
@interface CCJumpTiles3D : CCTiledGrid3DAction
{
	NSUInteger _jumps;
	float _amplitude;
	float _amplitudeRate;
}

/** amplitude of the sin*/
@property (nonatomic,readwrite) float amplitude;
/** amplitude rate */
@property (nonatomic,readwrite) float amplitudeRate;

/** creates the action with the number of jumps, the sin amplitude, the grid size and the duration */
+(id)actionWithDuration:(ccTime)duration size:(CGSize)gridSize jumps:(NSUInteger)numberOfJumps amplitude:(float)amplitude;
/** initializes the action with the number of jumps, the sin amplitude, the grid size and the duration */
-(id)initWithDuration:(ccTime)duration size:(CGSize)gridSize jumps:(NSUInteger)numberOfJumps amplitude:(float)amplitude;

@end

////////////////////////////////////////////////////////////

/** CCSplitRows action */
@interface CCSplitRows : CCTiledGrid3DAction
{
	NSUInteger	_rows;
	CGSize	_winSize;
}
/** creates the action with the number of rows to split and the duration */
+(id)actionWithDuration:(ccTime)duration rows:(NSUInteger)rows;
/** initializes the action with the number of rows to split and the duration */
-(id)initWithDuration:(ccTime)duration rows:(NSUInteger)rows;

@end

////////////////////////////////////////////////////////////

/** CCSplitCols action */
@interface CCSplitCols : CCTiledGrid3DAction
{
	NSUInteger	_cols;
	CGSize	_winSize;
}
/** creates the action with the number of columns to split and the duration */
+(id)actionWithDuration:(ccTime)duration cols:(NSUInteger)cols;
/** initializes the action with the number of columns to split and the duration */
-(id)initWithDuration:(ccTime)duration cols:(NSUInteger)cols;

@end
