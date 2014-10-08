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
#import "CCConfiguration.h"
#import "CCMetalSupport_Private.h"

// Vertex shader that performs the modelview-projection multiplication on the GPU.
// Faster for draw nodes that draw many vertexes, but can't be batched.
static NSString *CCDrawNodeHWTransformVertexShaderSource =
	@"uniform highp mat4 u_MVP;\n"
	@"uniform highp vec4 u_TintColor;\n"
	@"void main(){\n"
	@"	gl_Position = u_MVP*cc_Position;\n"
	@"	cc_FragColor = clamp(u_TintColor*cc_Color, 0.0, 1.0);\n"
	@"	cc_FragTexCoord1 = cc_TexCoord1;\n"
	@"}\n";

#ifdef ANDROID // Many Android devices do NOT support GL_OES_standard_derivatives correctly
static NSString *CCDrawNodeFragmentShaderSource =
    @"void main(){\n"
    @"  gl_FragColor = cc_FragColor*step(0.0, 1.0 - length(cc_FragTexCoord1));\n"
    @"}\n";
#else
static NSString *CCDrawNodeFragmentShaderSource =
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
    
    GLsizei _indexCount, _indexCapacity;
    GLushort *_indexes;
		
		BOOL _useBatchMode;
}

CCShader *CCDRAWNODE_HWTRANSFORM_SHADER = nil;
CCShader *CCDRAWNODE_BATCH_SHADER = nil;

+(void)initialize
{
#if __CC_METAL_SUPPORTED_AND_ENABLED
	if([CCConfiguration sharedConfiguration].graphicsAPI == CCGraphicsAPIMetal){
		id<MTLLibrary> library = [CCMetalContext currentContext].library;
		NSAssert(library, @"Metal shader library not found.");
		
		id<MTLFunction> vertexFunc = [library newFunctionWithName:@"CCVertexFunctionDefault"];
		
		CCDRAWNODE_BATCH_SHADER = [[CCShader alloc] initWithMetalVertexFunction:vertexFunc fragmentFunction:[library newFunctionWithName:@"CCFragmentFunctionDefaultDrawNode"]];
		CCDRAWNODE_BATCH_SHADER.debugName = @"CCFragmentFunctionDefaultDrawNode";
	} else
#endif
	{
		CCDRAWNODE_HWTRANSFORM_SHADER = [[CCShader alloc] initWithVertexShaderSource:CCDrawNodeHWTransformVertexShaderSource fragmentShaderSource:CCDrawNodeFragmentShaderSource];
		CCDRAWNODE_HWTRANSFORM_SHADER.debugName = @"CCDRAWNODE_HWTRANSFORM_SHADER";
		
		CCDRAWNODE_BATCH_SHADER = [[CCShader alloc] initWithFragmentShaderSource:CCDrawNodeFragmentShaderSource];
		CCDRAWNODE_BATCH_SHADER.debugName = @"CCDRAWNODE_BATCH_SHADER";
	}
}

#pragma mark memory

-(CCRenderBuffer)bufferVertexes:(GLsizei)vertexCount andTriangleCount:(GLsizei)triangleCount
{
    GLsizei requiredVertexes = _vertexCount + vertexCount;
    if(requiredVertexes > _vertexCapacity){
		    _vertexCapacity = requiredVertexes*1.5;
        _vertexes = realloc(_vertexes, _vertexCapacity*sizeof(*_vertexes));
    }
    
    GLsizei indexCount = 3*triangleCount;
    GLsizei requiredIndexes = _indexCount + indexCount;
    if(requiredIndexes > _indexCapacity){
        _indexCapacity = requiredIndexes*1.5;
        _indexes = realloc(_indexes, _indexCapacity*sizeof(*_indexes));
    }
    
    CCRenderBuffer buffer = {
        _vertexes + _vertexCount,
        _indexes + _indexCount,
        _vertexCount
    };
    
    _vertexCount += vertexCount;
    _indexCount += indexCount;
    
    return buffer;
}

-(id)init
{
    if((self = [super init])){
        _blendMode = [CCBlendMode premultipliedAlphaMode];
				
        if(CCDRAWNODE_HWTRANSFORM_SHADER){
        	_shader = CCDRAWNODE_HWTRANSFORM_SHADER;
        } else {
        // HWTransform shader not currently supported for Metal rendering.
        	_shader = CCDRAWNODE_BATCH_SHADER;
        	_useBatchMode = YES;
        }
        
        _vertexCapacity = 128;
        _vertexes = calloc(_vertexCapacity, sizeof(*_vertexes));
        
        _indexCapacity = 128;
        _indexes = calloc(_indexCapacity, sizeof(*_indexes));
    }
    
    return self;
}

-(void)dealloc
{
    free(_vertexes); _vertexes = NULL;
    free(_indexes); _indexes = NULL;
}

#pragma mark Rendering

-(void)enableBatchMode
{
	_useBatchMode = YES;
	
	if(_shader == CCDRAWNODE_HWTRANSFORM_SHADER){
		CCLOGINFO(@"Changing the blend mode or shader of a CCBatchNode disables GPU accelerated transform and tinting.");
		_shader = CCDRAWNODE_BATCH_SHADER;
	}
	
	// Reset the render state.
	_renderState = nil;
}

// Force batch mode on if the user changes the blendmode or shader.
-(void)setBlendMode:(CCBlendMode *)blendMode
{
	[super setBlendMode:blendMode];
	[self enableBatchMode];
}

-(void)setShader:(CCShader *)shader
{
	[super setShader:shader];
	[self enableBatchMode];
}

-(void)draw:(CCRenderer *)renderer transform:(const GLKMatrix4 *)transform
{
    if(_indexCount == 0) return;
		
		// If batch mode is disabled (default), update the MVP matrix in the uniforms.
		if(!_useBatchMode){
			self.shaderUniforms[@"u_MVP"] = [NSValue valueWithGLKMatrix4:*transform];
			
			GLKVector4 color = Premultiply(GLKVector4Make(_displayColor.r, _displayColor.g, _displayColor.b, _displayColor.a));
			self.shaderUniforms[@"u_TintColor"] = [NSValue valueWithGLKVector4:color];
		}
		
    CCRenderBuffer buffer = [renderer enqueueTriangles:_indexCount/3 andVertexes:_vertexCount withState:self.renderState globalSortOrder:0];
    
		if(_useBatchMode){
			// Transform the vertexes on the CPU.
			for(int i=0; i<_vertexCount; i++){
				CCRenderBufferSetVertex(buffer, i, CCVertexApplyTransform(_vertexes[i], transform));
			}
		} else {
			// memcpy() the buffer and let the GPU handle the transform.
			memcpy(buffer.vertexes, _vertexes, _vertexCount*sizeof(*_vertexes));
		}
    
		// Offset the indices.
    for(int i=0; i<_indexCount; i++){
			buffer.elements[i] = _indexes[i] + buffer.startIndex;
		}
}

#pragma mark Immediate Mode

static inline GLKVector4
Premultiply(GLKVector4 c)
{
    return GLKVector4Make(c.r*c.a, c.g*c.a, c.b*c.a, c.a);
}

-(void)drawDot:(CGPoint)pos radius:(CGFloat)radius color:(CCColor *)color;
{
    GLKVector4 color4 = Premultiply(color.glkVector4);
    
    GLKVector2 zero2 = GLKVector2Make(0, 0);
    
    CCRenderBuffer buffer = [self bufferVertexes:4 andTriangleCount:2];
    CCRenderBufferSetVertex(buffer, 0, (CCVertex){GLKVector4Make(pos.x - radius, pos.y - radius, 0, 1), GLKVector2Make(-1, -1), zero2, color4});
    CCRenderBufferSetVertex(buffer, 1, (CCVertex){GLKVector4Make(pos.x - radius, pos.y + radius, 0, 1), GLKVector2Make(-1,  1), zero2, color4});
    CCRenderBufferSetVertex(buffer, 2, (CCVertex){GLKVector4Make(pos.x + radius, pos.y + radius, 0, 1), GLKVector2Make( 1,  1), zero2, color4});
    CCRenderBufferSetVertex(buffer, 3, (CCVertex){GLKVector4Make(pos.x + radius, pos.y - radius, 0, 1), GLKVector2Make( 1, -1), zero2, color4});
    
    CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
    CCRenderBufferSetTriangle(buffer, 1, 0, 2, 3);
}

static inline GLKVector2 GLKVector2Perp(GLKVector2 v){return GLKVector2Make(-v.y, v.x);}

static inline void
SetVertex(CCRenderBuffer buffer, int index, GLKVector2 v, GLKVector2 texCoord, GLKVector4 color)
{
    CCRenderBufferSetVertex(buffer, index, (CCVertex){GLKVector4Make(v.x, v.y, 0.0f, 1.0f), texCoord, GLKVector2Make(0.0f, 0.0f), color});
}

-(void)drawSegmentFrom:(CGPoint)_a to:(CGPoint)_b radius:(CGFloat)radius color:(CCColor*)color;
{
    GLKVector4 color4 = Premultiply(color.glkVector4);
    GLKVector2 a = GLKVector2Make(_a.x, _a.y);
    GLKVector2 b = GLKVector2Make(_b.x, _b.y);
    
    GLKVector2 n = GLKVector2Normalize(GLKVector2Perp(GLKVector2Subtract(b, a)));
    GLKVector2 t = GLKVector2Perp(n);
    
    GLKVector2 nw = GLKVector2MultiplyScalar(n, radius);
    GLKVector2 tw = GLKVector2MultiplyScalar(t, radius);
    
    CCRenderBuffer buffer = [self bufferVertexes:8 andTriangleCount:6];
    SetVertex(buffer, 0, GLKVector2Subtract(b, GLKVector2Add(nw, tw)), GLKVector2Negate(GLKVector2Add(n, t)), color4);
    SetVertex(buffer, 1, GLKVector2Add(b, GLKVector2Subtract(nw, tw)), GLKVector2Subtract(n, t), color4);
    SetVertex(buffer, 2, GLKVector2Subtract(b, nw), GLKVector2Negate(n), color4);
    SetVertex(buffer, 3, GLKVector2Add(b, nw), n, color4);
    SetVertex(buffer, 4, GLKVector2Subtract(a, nw), GLKVector2Negate(n), color4);
    SetVertex(buffer, 5, GLKVector2Add(a, nw), n, color4);
    SetVertex(buffer, 6, GLKVector2Subtract(a, GLKVector2Subtract(nw, tw)), GLKVector2Subtract(t, n), color4);
    SetVertex(buffer, 7, GLKVector2Add(a, GLKVector2Add(nw, tw)), GLKVector2Add(n, t), color4);
    
    CCRenderBufferSetTriangle(buffer, 0, 0, 1, 2);
    CCRenderBufferSetTriangle(buffer, 1, 3, 1, 2);
    CCRenderBufferSetTriangle(buffer, 2, 3, 4, 2);
    CCRenderBufferSetTriangle(buffer, 3, 3, 4, 5);
    CCRenderBufferSetTriangle(buffer, 4, 6, 4, 5);
    CCRenderBufferSetTriangle(buffer, 5, 6, 7, 5);
}

-(void)drawPolyWithVerts:(const CGPoint *)_verts count:(NSUInteger)count fillColor:(CCColor*)fill  borderWidth:(CGFloat)width borderColor:(CCColor*)line;
{
    GLKVector4 fill4 = Premultiply(fill.glkVector4);
    GLKVector4 line4 = Premultiply(line.glkVector4);
    
    GLKVector2 verts[count];
    for(int i=0; i<count; i++) verts[i] = GLKVector2Make(_verts[i].x, _verts[i].y);
    
    struct ExtrudeVerts {GLKVector2 offset, n;};
    struct ExtrudeVerts extrude[count];
    bzero(extrude, sizeof(extrude) );
    
    for(int i=0; i<count; i++){
        GLKVector2 v0 = verts[(i-1+count)%count];
        GLKVector2 v1 = verts[i];
        GLKVector2 v2 = verts[(i+1)%count];
        
        GLKVector2 n1 = GLKVector2Normalize(GLKVector2Perp(GLKVector2Subtract(v1, v0)));
        GLKVector2 n2 = GLKVector2Normalize(GLKVector2Perp(GLKVector2Subtract(v2, v1)));
        
        GLKVector2 offset = GLKVector2MultiplyScalar(GLKVector2Add(n1, n2), 1.0/(GLKVector2DotProduct(n1, n2) + 1.0));
        extrude[i] = (struct ExtrudeVerts){offset, n2};
    }
    
    CCRenderBuffer buffer = [self bufferVertexes:(GLsizei)(count + 2*count*2) andTriangleCount:(GLsizei)(3*count - 2)];
    int vertexCursor = 0, triangleCursor = 0;
    
    BOOL outline = (line4.a > 0 && width > 0.0);
    const GLKVector2 GLKVector2Zero = {{0.0f, 0.0f}};
    
    CGFloat inset = (outline == 0.0 ? 0.5 : 0.0);
    for(int i=0; i<count; i++){
        SetVertex(buffer, vertexCursor++, GLKVector2Subtract(verts[i], GLKVector2MultiplyScalar(extrude[i].offset, inset)), GLKVector2Zero, fill4);
    }
    
    for(int i=0; i<count-2; i++){
        CCRenderBufferSetTriangle(buffer, triangleCursor++, 0, i + 1, i + 2);
    }
    
    for(int i=0; i<count; i++){
        int j = (i+1)%count;
        GLKVector2 v0 = ( verts[i] );
        GLKVector2 v1 = ( verts[j] );
        
        GLKVector2 n0 = extrude[i].n;
        
        float w = (outline ? width : 0.5);
        GLKVector2 offset0 = extrude[i].offset;
        GLKVector2 offset1 = extrude[j].offset;
        
        GLKVector2 inner0 = GLKVector2Subtract(v0, GLKVector2MultiplyScalar(offset0, w));
        GLKVector2 inner1 = GLKVector2Subtract(v1, GLKVector2MultiplyScalar(offset1, w));
        GLKVector2 outer0 = GLKVector2Add(v0, GLKVector2MultiplyScalar(offset0, w));
        GLKVector2 outer1 = GLKVector2Add(v1, GLKVector2MultiplyScalar(offset1, w));
        
        GLKVector2 outerTexCoord = (outline ? GLKVector2Negate(n0) : GLKVector2Zero);
        
        CCRenderBufferSetTriangle(buffer, triangleCursor++, vertexCursor + 0, vertexCursor + 1, vertexCursor + 2);
        CCRenderBufferSetTriangle(buffer, triangleCursor++, vertexCursor + 0, vertexCursor + 2, vertexCursor + 3);
        
        GLKVector4 outlineColor = (outline ? line4 : fill4);
        
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
    _indexCount = 0;
}

@end
