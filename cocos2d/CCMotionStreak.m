/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 ForzeField Studios S.L. http://forzefield.com
 * Copyright (c) 2013-2014 Cocos2D Authors
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

#import "CCMotionStreak.h"
#import "CCTextureCache.h"
#import "CCShader.h"
#import "ccMacros.h"
#import "CCNode_Private.h"
#import "CCTexture_Private.h"
#import "CCRenderer_private.h"

#import "Support/CGPointExtension.h"


static BOOL CCVertexLineIntersect(float Ax, float Ay,
                               float Bx, float By,
                               float Cx, float Cy,
                               float Dx, float Dy, float *T)
{
    float  distAB, theCos, theSin, newX;

    // FAIL: Line undefined
    if ((Ax==Bx && Ay==By) || (Cx==Dx && Cy==Dy)) return NO;

    //  Translate system to make A the origin
    Bx-=Ax; By-=Ay;
    Cx-=Ax; Cy-=Ay;
    Dx-=Ax; Dy-=Ay;

    // Length of segment AB
    distAB = sqrtf(Bx*Bx+By*By);

    // Rotate the system so that point B is on the positive X axis.
    theCos = Bx/distAB;
    theSin = By/distAB;
    newX = Cx*theCos+Cy*theSin;
    Cy  = Cy*theCos-Cx*theSin; Cx = newX;
    newX = Dx*theCos+Dy*theSin;
    Dy  = Dy*theCos-Dx*theSin; Dx = newX;

    // FAIL: Lines are parallel.
    if (Cy == Dy) return NO;

    // Discover the relative position of the intersection in the line AB
    *T = (Dx+(Cx-Dx)*Dy/(Dy-Cy))/distAB;

    // Success.
    return YES;
}

static void CCVertexLineToPolygon(CGPoint *points, float stroke, ccVertex2F *vertices, NSUInteger offset, NSUInteger nuPoints)
{
    nuPoints += offset;
    if(nuPoints<=1) return;

    stroke *= 0.5f;

    NSUInteger idx;
    NSUInteger nuPointsMinus = nuPoints-1;

    for(NSUInteger i = offset; i<nuPoints; i++)
    {
        idx = i*2;
        CGPoint p1 = points[i];
        CGPoint perpVector;

        if(i == 0)
            perpVector = ccpPerp(ccpNormalize(ccpSub(p1, points[i+1])));
        else if(i == nuPointsMinus)
            perpVector = ccpPerp(ccpNormalize(ccpSub(points[i-1], p1)));
        else
        {
            CGPoint p2 = points[i+1];
            CGPoint p0 = points[i-1];

            CGPoint p2p1 = ccpNormalize(ccpSub(p2, p1));
            CGPoint p0p1 = ccpNormalize(ccpSub(p0, p1));

            // Calculate angle between vectors
            float angle = acosf(ccpDot(p2p1, p0p1));

            if(angle < CC_DEGREES_TO_RADIANS(70))
                perpVector = ccpPerp(ccpNormalize(ccpMidpoint(p2p1, p0p1)));
            else if(angle < CC_DEGREES_TO_RADIANS(170))
                perpVector = ccpNormalize(ccpMidpoint(p2p1, p0p1));
            else
                perpVector = ccpPerp(ccpNormalize(ccpSub(p2, p0)));
        }
        perpVector = ccpMult(perpVector, stroke);

        vertices[idx] = (ccVertex2F) {p1.x+perpVector.x, p1.y+perpVector.y};
        vertices[idx+1] = (ccVertex2F) {p1.x-perpVector.x, p1.y-perpVector.y};
    }

    // Validate vertexes
    offset = (offset==0) ? 0 : offset-1;
    for(NSUInteger i = offset; i<nuPointsMinus; i++)
    {
        idx = i*2;
        const NSUInteger idx1 = idx+2;

        ccVertex2F p1 = vertices[idx];
        ccVertex2F p2 = vertices[idx+1];
        ccVertex2F p3 = vertices[idx1];
        ccVertex2F p4 = vertices[idx1+1];

        float s;
        //BOOL fixVertex = !ccpLineIntersect(ccp(p1.x, p1.y), ccp(p4.x, p4.y), ccp(p2.x, p2.y), ccp(p3.x, p3.y), &s, &t);
        BOOL fixVertex = !CCVertexLineIntersect(p1.x, p1.y, p4.x, p4.y, p2.x, p2.y, p3.x, p3.y, &s);
        if(!fixVertex)
            if (s<0.0f || s>1.0f)
                fixVertex = YES;

        if(fixVertex)
        {
            vertices[idx1] = p4;
            vertices[idx1+1] = p3;
        }
    }
}


@implementation CCMotionStreak {
    
    // Position.
    CGPoint _positionR;
    
    // Stroke width.
    float _stroke;
    
    // Fade time.
    float _fadeDelta;
    
    // Minimum segments.
    float _minSeg;
    
    // Point counters.
    NSUInteger _maxPoints;
    NSUInteger _nuPoints;
    NSUInteger _previousNuPoints;

    // Trail vertexes.
    CGPoint *_pointVertexes;
    
    // Trail vertex states.
    float *_pointState;

    // OpenGL.
    ccVertex2F *_vertices;
    ccTex2F *_texCoords;
    unsigned char *_colorPointer;

    // Toggle fast mode.
    BOOL	_fastMode;
	
    // Starting point.
	BOOL	_startingPositionInitialized;
}

@synthesize fastMode = _fastMode;

+ (id) streakWithFade:(float)fade minSeg:(float)minSeg width:(float)stroke color:(CCColor*)color textureFilename:(NSString*)path
{
    return [[self alloc] initWithFade:fade minSeg:minSeg width:stroke color:color textureFilename:path];
}

+ (id) streakWithFade:(float)fade minSeg:(float)minSeg width:(float)stroke color:(CCColor*)color texture:(CCTexture*)texture
{
    return [[self alloc] initWithFade:fade minSeg:minSeg width:stroke color:color texture:texture];
}

- (id) initWithFade:(float)fade minSeg:(float)minSeg width:(float)stroke color:(CCColor*)color textureFilename:(NSString*)path
{
    NSAssert(path != nil, @"Invalid filename");

    CCTexture *texture = [[CCTextureCache sharedTextureCache] addImage:path];
    return [self initWithFade:fade minSeg:minSeg width:stroke color:color texture:texture];
}

- (id) initWithFade:(float)fade minSeg:(float)minSeg width:(float)stroke color:(CCColor*)color texture:(CCTexture*)texture
{
    self = [super init];
    if (self)
    {
        [super setPosition:CGPointZero];
        [self setAnchorPoint:CGPointZero];

        _startingPositionInitialized = NO;
        _positionR = CGPointZero;
        _fastMode = YES;
        _minSeg = (minSeg == -1.0f) ? stroke/5.0f : minSeg;
        _minSeg *= _minSeg;

        _stroke = stroke;
        _fadeDelta = 1.0f/fade;

        _maxPoints = (int)(fade*60.0f)+2;
        _nuPoints = _previousNuPoints = 0;
        _pointState = malloc(sizeof(float) * _maxPoints);
        _pointVertexes = malloc(sizeof(CGPoint) * _maxPoints);

        _vertices = malloc(sizeof(ccVertex2F) * _maxPoints * 2);
        _texCoords = malloc(sizeof(ccTex2F) * _maxPoints * 2);
        _colorPointer =  malloc(sizeof(GLubyte) * _maxPoints * 2 * 4);

        // Set blend mode
				self.blendMode = [CCBlendMode alphaMode];

        // shader program
        self.shader = [CCShader positionTextureColorShader];

        [self setTexture:texture];
        [super setColor:color];
    }
    return self;
}

#pragma mark -

- (void) setPosition:(CGPoint)position
{
	_startingPositionInitialized = YES;
    _positionR = position;
}

- (void) setColor:(CCColor*)color
{
    ccColor3B color3 = color.ccColor3b;
    
    [super setColor:color];

    // Fast assignation
    for(int i = 0; i<_nuPoints*2; i++)
        *((ccColor3B*) (_colorPointer+i*4)) = color3;
}

- (void) setOpacity:(CGFloat)opacity
{
    NSAssert(NO, @"Set opacity not supported");
}

- (CGFloat) opacity
{
    NSAssert(NO, @"Opacity not supported");
    return 0;
}

#pragma mark -

- (void) update:(CCTime)delta
{
	if( !_startingPositionInitialized )
		return;

    delta *= _fadeDelta;
	
    NSUInteger newIdx, newIdx2, i, i2;
    NSUInteger mov = 0;

    // Update current points
    for(i = 0; i<_nuPoints; i++)
    {
        _pointState[i]-=delta;

        if(_pointState[i] <= 0) {
            mov++;
        } else {
            newIdx = i-mov;

            if(mov>0)
            {
                // Move data
                _pointState[newIdx] = _pointState[i];

                // Move point
                _pointVertexes[newIdx] = _pointVertexes[i];

                // Move vertices
                i2 = i*2;
                newIdx2 = newIdx*2;
                _vertices[newIdx2] = _vertices[i2];
                _vertices[newIdx2+1] = _vertices[i2+1];

                // Move color
                i2 *= 4;
                newIdx2 *= 4;
                _colorPointer[newIdx2+0] = _colorPointer[i2+0];
                _colorPointer[newIdx2+1] = _colorPointer[i2+1];
                _colorPointer[newIdx2+2] = _colorPointer[i2+2];
                _colorPointer[newIdx2+4] = _colorPointer[i2+4];
                _colorPointer[newIdx2+5] = _colorPointer[i2+5];
                _colorPointer[newIdx2+6] = _colorPointer[i2+6];
            } else {
                newIdx2 = newIdx*8;
						}

            const GLubyte op = _pointState[newIdx] * 255.0f;
            _colorPointer[newIdx2+3] = op;
            _colorPointer[newIdx2+7] = op;
        }
    }
    _nuPoints-=mov;

    // Append new point
    BOOL appendNewPoint = YES;
    if(_nuPoints >= _maxPoints) {
        appendNewPoint = NO;
		} else if(_nuPoints>0) {
        BOOL a1 = ccpDistanceSQ(_pointVertexes[_nuPoints-1], _positionR) < _minSeg;
        BOOL a2 = (_nuPoints == 1) ? NO : (ccpDistanceSQ(_pointVertexes[_nuPoints-2], _positionR) < (_minSeg * 2.0f));
        if(a1 || a2)
            appendNewPoint = NO;
    }

    if(appendNewPoint)
    {
        _pointVertexes[_nuPoints] = _positionR;
        _pointState[_nuPoints] = 1.0f;

        // Color and opacity assignment
        const NSUInteger offset = _nuPoints*8;
        *((ccColor4B*)(_colorPointer + offset)) = ccc4BFromccc4F(_displayColor);
        *((ccColor4B*)(_colorPointer + offset+4)) = ccc4BFromccc4F(_displayColor);

        // Generate polygon
        if(_nuPoints > 0 && _fastMode )
        {
            if(_nuPoints > 1){
                CCVertexLineToPolygon(_pointVertexes, _stroke, _vertices, _nuPoints, 1);
            } else {
                CCVertexLineToPolygon(_pointVertexes, _stroke, _vertices, 0, 2);
						}
        }

        _nuPoints ++;
    }

    if( ! _fastMode ) {
        CCVertexLineToPolygon(_pointVertexes, _stroke, _vertices, 0, _nuPoints);
		}
	
	
	// Updated Tex Coords only if they are different than previous step
	if( _nuPoints  && _previousNuPoints != _nuPoints ) {
		float texDelta = 1.0f / _nuPoints;
		for( i=0; i < _nuPoints; i++ ) {
			_texCoords[i*2] = (ccTex2F) {0, texDelta*i};
			_texCoords[i*2+1] = (ccTex2F) {1, texDelta*i};
		}
		
		_previousNuPoints = _nuPoints;
	}
}

- (void) reset
{
    _nuPoints = 0;
}

// TODO should update the class to store the rendering values in actual output types.
static inline CCVertex
MakeVertex(ccVertex2F v, ccTex2F texCoord, unsigned char *color, GLKMatrix4 transform)
{
	return (CCVertex){
		GLKMatrix4MultiplyVector4(transform, GLKVector4Make(v.x, v.y, 0.0f, 1.0f)),
		GLKVector2Make(texCoord.u, texCoord.v), GLKVector2Make(0.0f, 0.0f),
		GLKVector4Make(color[0]/255.0, color[1]/255.0, color[2]/255.0, color[3]/255.0)
	};
}

- (void) draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
	if(_nuPoints <= 1) return;
	
	CCRenderBuffer buffer = [renderer enqueueTriangles:2*(_nuPoints - 1) andVertexes:2*_nuPoints withState:self.renderState globalSortOrder:0];
	
	// Output vertexes.
	for(int i=0; i<_nuPoints; i++){
		CCRenderBufferSetVertex(buffer, 2*i + 0, MakeVertex(_vertices[2*i + 0], _texCoords[2*i + 0], _colorPointer + (2*i + 0)*4, *transform));
		CCRenderBufferSetVertex(buffer, 2*i + 1, MakeVertex(_vertices[2*i + 1], _texCoords[2*i + 1], _colorPointer + (2*i + 1)*4, *transform));
	}
	
	// Output triangles.
	for(int i=0; i<_nuPoints - 1; i++){
		CCRenderBufferSetTriangle(buffer, 2*i + 0,  2*i + 0,  2*i + 1,  2*i + 2);
		CCRenderBufferSetTriangle(buffer, 2*i + 1,  2*i + 1,  2*i + 2,  2*i + 3);
	}
}

- (void)dealloc
{
    free(_pointState);
    free(_pointVertexes);
    free(_vertices);
    free(_colorPointer);
    free(_texCoords);

}

@end
