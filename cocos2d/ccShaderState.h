/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2011 Ricardo Quesada
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
 */

#ifndef __CC_SHADER_STATE_H
#define __CC_SHADER_STATE_H

#include <TargetConditionals.h>

#if (TARGET_OS_IPHONE == 1)
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#elif (TARGET_OS_MAC == 1)
#import <OpenGL/gl.h>
#endif // 

#include "Support/kazmath.h"

/** @file
*/

/** Uses the GL program in case program is different than the current one
 @since v2.0.0
 */
inline void ccShaderUseProgram( GLuint program );

/** sets the GL program in case program is different than the current one
 @since v2.0.0
 */
inline void ccShaderSetProjectionUniform( GLuint program );

/** sets the projection matrix
@since v2.0.0
*/
inline void ccShaderSetProjectionMatrix( kmMat4 *matrix );


#endif // __CC_SHADER_STATE_H