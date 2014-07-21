/* Copyright (c) 2012 Scott Lembcke and Howling Moon Software
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
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

/*
 * Code copied & pasted from SpacePatrol game https://github.com/slembcke/SpacePatrol
 *
 * Renamed and added some changes for cocos2d
 *
 */

#import "CCDrawNode.h"
#import "CCShader.h"
#import "Support/CGPointExtension.h"
#import "CCNode_Private.h"
#import "CCColor.h"

#ifdef ANDROID // Many Android devices do NOT support GL_OES_standard_derivatives correctly
static NSString *CCDrawNodeShaderSource =
    @"void main(){\n"
    @"  gl_FragColor = cc_FragColor*step(0.0, 1.0 - length(cc_FragTexCoord1));\n"
    @"}\n";
#else
static NSString *CCDrawNodeShaderSource =
	@"#ifdef GL_ES\n"
	@"#extension GL_OES_standard_derivatives : enable\n"
	@"#endif\n"
	@"\n"
	@"void main(){\n"
	@"	gl_FragColor = cc_FragColor*smoothstep(0.0, length(fwidth(cc_FragTexCoord1)), 1.0 - length(cc_FragTexCoord1));\n"
	@"}\n";
#endif

@implementation CCDrawNode {
    GLsizei _vertexCount, _vertexCapacity;
    CCVertex *_vertexes;
    
    GLsizei _elementCount, _elementCapacity;
    GLushort *_elements;
}

+ (CCShader *)fragmentShader
{
    static CCShader *shader = nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        shader = [[CCShader alloc] initWithFragmentShaderSource:CCDrawNodeShaderSource];
    });
    return shader;
}

#pragma mark memory

-(CCRenderBuffer)bufferVertexes:(GLsizei)vertexCount andTriangleCount:(GLsizei)triangleCount
{
    GLsizei requiredVertexes = _vertexCount + vertexCount;
    if(requiredVertexes > _vertexCapacity){
        // Double the size of the buffer until it fits.
        while(requiredVertexes >= _vertexCapacity) _vertexCapacity *= 2;
        
        _vertexes = realloc(_vertexes, _vertexCapacity*sizeof(*_vertexes));
    }
    
    GLsizei elementCount = 3*triangleCount;
    GLsizei requiredElements = _elementCount + elementCount;
    if(requiredElements > _elementCapacity){
        // Double the size of the buffer until it fits.
        while(requiredElements >= _elementCapacity) _elementCapacity *= 2;
        
        _elements = realloc(_elements, _elementCapacity*sizeof(*_elements));
    }
    
    CCRenderBuffer buffer = {
        _vertexes + _vertexCount,
        _elements + _elementCount,
        _vertexCount
    };
    
    _vertexCount += vertexCount;
    _elementCount += elementCount;
    
    return buffer;
}

-(id)init
{
    if((self = [super init])){
        self.blendMode = [CCBlendMode premultipliedAlphaMode];
        self.shader = [CCDrawNode fragmentShader];
        
        _vertexCapacity = 128;
        _vertexes = calloc(_vertexCapacity, sizeof(*_vertexes));
        
        _elementCapacity = 128;
        _elements = calloc(_elementCapacity, sizeof(*_elements));
    }
    
    return self;
}

-(void)dealloc
{
    free(_vertexes); _vertexes = NULL;
    free(_elements); _elements = NULL;
}

#pragma mark Rendering

-(void)draw:(CCRenderer *)renderer transform:(const CCMatrix4 *)transform
{
    if(_elementCount == 0) return;
    
    CCRenderBuffer buffer = [renderer enqueueTriangles:_elementCount/3 andVertexes:_vertexCount withState:self.renderState globalSortOrder:0];
    
    // TODO Maybe it would be even better to skip the CPU transform and use a uniform matrix?
    for(int i=0; i<_vertexCount; i++){
        CCRenderBufferSetVertex(buffer, i, CCVertexApplyTransform(_vertexes[i], transform));
    }
    
    for(int i=0; i<_elementCount; i++){
        buffer.elements[i] = _elements[i] + buffer.startIndex;
    }
}

#pragma mark Immediate Mode

static inline CCVector4
Premultiply(CCVector4 c)
{
    return CCVector4Make(c.r*c.a, c.g*c.a, c.b*c.a, c.a);
}

-(void)drawDot:(CGPoint)pos radius:(CGFloat)radius color:(CCColor *)color;
{
    CCVector4 color4 = Premultiply(color.CCVector4);
    
    CCVector2 zero2 = CCVector2Make(0, 0);
    
    CCRenderBuffer buffer = [self bufferVertexes:4 andTriangleCount:2];
    CCRenderBufferSetVertex(buffer, 0, (CCVertex){CCVector4Make(pos.x - radius, pos.y - radius, 0, 1), CCVector2Make(-1, -1), zero2, color4});
    CCRenderBufferSetVertex(buffer, 1, (CCVertex){CCVector4Make(pos.x - radius, pos.y + radius, 0, 1), CCVector2Make(-1,  1), zero2, color4});
    CCRenderBufferSetVertex(buffer, 2, (CCVertex){CCVector4Make(pos.x + radius, pos.y + radius, 0, 1), CCVector2Make( 1,  1), zero2, color4});
    CCRenderBufferSetVertex(buffer, 3, (CCVertex){CCVector4Make(pos.x + radius, pos.y - radius, 0, 1), CCVector2Make( 1, -1), zero2, color4});
    
    CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
    CCRenderBufferSetTriangle(buffer, 1, 0, 2, 3);
}

static inline CCVector2 CCVector2Perp(CCVector2 v){return CCVector2Make(-v.y, v.x);}

static inline void
SetVertex(CCRenderBuffer buffer, int index, CCVector2 v, CCVector2 texCoord, CCVector4 color)
{
    CCRenderBufferSetVertex(buffer, index, (CCVertex){CCVector4Make(v.x, v.y, 0.0f, 1.0f), texCoord, CCVector2Make(0.0f, 0.0f), color});
}

-(void)drawSegmentFrom:(CGPoint)_a to:(CGPoint)_b radius:(CGFloat)radius color:(CCColor*)color;
{
    CCVector4 color4 = Premultiply(color.CCVector4);
    CCVector2 a = CCVector2Make(_a.x, _a.y);
    CCVector2 b = CCVector2Make(_b.x, _b.y);
    
    CCVector2 n = CCVector2Normalize(CCVector2Perp(CCVector2Subtract(b, a)));
    CCVector2 t = CCVector2Perp(n);
    
    CCVector2 nw = CCVector2MultiplyScalar(n, radius);
    CCVector2 tw = CCVector2MultiplyScalar(t, radius);
    
    CCRenderBuffer buffer = [self bufferVertexes:8 andTriangleCount:6];
    SetVertex(buffer, 0, CCVector2Subtract(b, CCVector2Add(nw, tw)), CCVector2Negate(CCVector2Add(n, t)), color4);
    SetVertex(buffer, 1, CCVector2Add(b, CCVector2Subtract(nw, tw)), CCVector2Subtract(n, t), color4);
    SetVertex(buffer, 2, CCVector2Subtract(b, nw), CCVector2Negate(n), color4);
    SetVertex(buffer, 3, CCVector2Add(b, nw), n, color4);
    SetVertex(buffer, 4, CCVector2Subtract(a, nw), CCVector2Negate(n), color4);
    SetVertex(buffer, 5, CCVector2Add(a, nw), n, color4);
    SetVertex(buffer, 6, CCVector2Subtract(a, CCVector2Subtract(nw, tw)), CCVector2Subtract(t, n), color4);
    SetVertex(buffer, 7, CCVector2Add(a, CCVector2Add(nw, tw)), CCVector2Add(n, t), color4);
    
    CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
    CCRenderBufferSetTriangle(buffer, 1, 3, 1, 2);
    CCRenderBufferSetTriangle(buffer, 2, 3, 4, 2);
    CCRenderBufferSetTriangle(buffer, 3, 3, 4, 5);
    CCRenderBufferSetTriangle(buffer, 4, 6, 4, 5);
    CCRenderBufferSetTriangle(buffer, 5, 6, 7, 5);
}

-(void)drawPolyWithVerts:(const CGPoint *)_verts count:(NSUInteger)count fillColor:(CCColor*)fill  borderWidth:(CGFloat)width borderColor:(CCColor*)line;
{
    CCVector4 fill4 = Premultiply(fill.CCVector4);
    CCVector4 line4 = Premultiply(line.CCVector4);
    
    CCVector2 verts[count];
    for(int i=0; i<count; i++) verts[i] = CCVector2Make(_verts[i].x, _verts[i].y);
    
    struct ExtrudeVerts {CCVector2 offset, n;};
    struct ExtrudeVerts extrude[count];
    bzero(extrude, sizeof(extrude) );
    
    for(int i=0; i<count; i++){
        CCVector2 v0 = verts[(i-1+count)%count];
        CCVector2 v1 = verts[i];
        CCVector2 v2 = verts[(i+1)%count];
        
        CCVector2 n1 = CCVector2Normalize(CCVector2Perp(CCVector2Subtract(v1, v0)));
        CCVector2 n2 = CCVector2Normalize(CCVector2Perp(CCVector2Subtract(v2, v1)));
        
        CCVector2 offset = CCVector2MultiplyScalar(CCVector2Add(n1, n2), 1.0/(CCVector2DotProduct(n1, n2) + 1.0));
        extrude[i] = (struct ExtrudeVerts){offset, n2};
    }
    
    CCRenderBuffer buffer = [self bufferVertexes:(GLsizei)(count + 2*count*2) andTriangleCount:(GLsizei)(3*count - 2)];
    int vertexCursor = 0, triangleCursor = 0;
    
    BOOL outline = (line4.a > 0 && width > 0.0);
    const CCVector2 CCVector2Zero = {{0.0f, 0.0f}};
    
    CGFloat inset = (outline == 0.0 ? 0.5 : 0.0);
    for(int i=0; i<count; i++){
        SetVertex(buffer, vertexCursor++, CCVector2Subtract(verts[i], CCVector2MultiplyScalar(extrude[i].offset, inset)), CCVector2Zero, fill4);
    }
    
    for(int i=0; i<count-2; i++){
        CCRenderBufferSetTriangle(buffer, triangleCursor++, 0, i + 1, i + 2);
    }
    
    for(int i=0; i<count; i++){
        int j = (i+1)%count;
        CCVector2 v0 = ( verts[i] );
        CCVector2 v1 = ( verts[j] );
        
        CCVector2 n0 = extrude[i].n;
        
        float w = (outline ? width : 0.5);
        CCVector2 offset0 = extrude[i].offset;
        CCVector2 offset1 = extrude[j].offset;
        
        CCVector2 inner0 = CCVector2Subtract(v0, CCVector2MultiplyScalar(offset0, w));
        CCVector2 inner1 = CCVector2Subtract(v1, CCVector2MultiplyScalar(offset1, w));
        CCVector2 outer0 = CCVector2Add(v0, CCVector2MultiplyScalar(offset0, w));
        CCVector2 outer1 = CCVector2Add(v1, CCVector2MultiplyScalar(offset1, w));
        
        CCVector2 outerTexCoord = (outline ? CCVector2Negate(n0) : CCVector2Zero);
        
        CCRenderBufferSetTriangle(buffer, triangleCursor++, vertexCursor + 0, vertexCursor + 1, vertexCursor + 2);
        CCRenderBufferSetTriangle(buffer, triangleCursor++, vertexCursor + 0, vertexCursor + 2, vertexCursor + 3);
        
        CCVector4 outlineColor = (outline ? line4 : fill4);
        
        // TODO could reduce this to 2 vertexes per
        SetVertex(buffer, vertexCursor++, inner0, outerTexCoord, outlineColor);
        SetVertex(buffer, vertexCursor++, inner1, outerTexCoord, outlineColor);
        SetVertex(buffer, vertexCursor++, outer1, n0, outlineColor);
        SetVertex(buffer, vertexCursor++, outer0, n0, outlineColor);
    }
}

-(void)clear
{
    _vertexCount = 0;
    _elementCount = 0;
}

@end
