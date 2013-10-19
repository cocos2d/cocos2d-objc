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


#import "CCActionInterval.h"
#import "CCActionInstant.h"
#import "CCGrid.h"

@class CCGridBase;

/** Base class for Grid actions */
@interface CCGridAction : CCActionInterval
{
	CGSize _gridSize;
}

/** size of the grid */
@property (nonatomic,readwrite) CGSize gridSize;

/** creates the action with size and duration */
+(id) actionWithDuration:(ccTime)duration size:(CGSize)gridSize;
/** initializes the action with size and duration */
-(id) initWithDuration:(ccTime)duration size:(CGSize)gridSize;
/** returns the grid */
-(CCGridBase *)grid;

@end

////////////////////////////////////////////////////////////

/** Base class for CCGrid3D actions.
 Grid3D actions can modify a non-tiled grid.
 */
@interface CCGrid3DAction : CCGridAction
{
}

/** returns the vertex than belongs to certain position in the grid */
-(ccVertex3F)vertex:(CGPoint)position;
/** returns the non-transformed vertex than belongs to certain position in the grid */
-(ccVertex3F)originalVertex:(CGPoint)position;
/** sets a new vertex to a certain position of the grid */
-(void)setVertex:(CGPoint)position vertex:(ccVertex3F)vertex;

@end

////////////////////////////////////////////////////////////

/** Base class for CCTiledGrid3D actions */
@interface CCTiledGrid3DAction : CCGridAction
{
}

/** returns the tile that belongs to a certain position of the grid */
-(ccQuad3)tile:(CGPoint)position;
/** returns the non-transformed tile that belongs to a certain position of the grid */
-(ccQuad3)originalTile:(CGPoint)position;
/** sets a new tile to a certain position of the grid */
-(void)setTile:(CGPoint)position coords:(ccQuad3)coords;

@end

////////////////////////////////////////////////////////////

/** CCAccelDeccelAmplitude action */
@interface CCAccelDeccelAmplitude : CCActionInterval
{
	float			_rate;
	CCActionInterval *_other;
}

/** amplitude rate */
@property (nonatomic,readwrite) float rate;

/** creates the action with an inner action that has the amplitude property, and a duration time */
+(id)actionWithAction:(CCAction*)action duration:(ccTime)d;
/** initializes the action with an inner action that has the amplitude property, and a duration time */
-(id)initWithAction:(CCAction*)action duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** CCAccelAmplitude action */
@interface CCAccelAmplitude : CCActionInterval
{
	float			_rate;
	CCActionInterval *_other;
}

/** amplitude rate */
@property (nonatomic,readwrite) float rate;

/** creates the action with an inner action that has the amplitude property, and a duration time */
+(id)actionWithAction:(CCAction*)action duration:(ccTime)d;
/** initializes the action with an inner action that has the amplitude property, and a duration time */
-(id)initWithAction:(CCAction*)action duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** CCDeccelAmplitude action */
@interface CCDeccelAmplitude : CCActionInterval
{
	float			_rate;
	CCActionInterval *_other;
}

/** amplitude rate */
@property (nonatomic,readwrite) float rate;

/** creates the action with an inner action that has the amplitude property, and a duration time */
+(id)actionWithAction:(CCAction*)action duration:(ccTime)d;
/** initializes the action with an inner action that has the amplitude property, and a duration time */
-(id)initWithAction:(CCAction*)action duration:(ccTime)d;

@end

////////////////////////////////////////////////////////////

/** CCStopGrid action.
 Don't call this action if another grid action is active.
 Call if you want to remove the the grid effect. Example:
 [Sequence actions:[Lens ...], [StopGrid action], nil];
 */
@interface CCStopGrid : CCActionInstant
{
}
// to make BridgeSupport happy
-(void)startWithTarget:(id)aTarget;
@end

////////////////////////////////////////////////////////////

/** CCReuseGrid action */
@interface CCReuseGrid : CCActionInstant
{
	int _times;
}
/** creates an action with the number of times that the current grid will be reused */
+(id) actionWithTimes: (int) times;
/** initializes an action with the number of times that the current grid will be reused */
-(id) initWithTimes: (int) times;
@end
