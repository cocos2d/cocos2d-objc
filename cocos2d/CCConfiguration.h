//
//  CCConfiguration.h
//  cocos2d-iphone
//
//  Created by Ricardo Quesada on 15/01/10.
//  Copyright 2010 Sapus Media. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>

/**
 CCConfiguration contains some openGL variables
 @since v0.99.0
 */

@interface CCConfiguration : NSObject {

	NSBundle	*loadingBundle_;
	
	GLint		maxTextureSize_;
	GLint		maxModelviewStackDepth_;
	BOOL		supportsPVRTC_;
}

/** the bundle we load everything from */
@property (nonatomic, readwrite, assign) NSBundle* loadingBundle;

/** OpenGL Max texture size. */
@property (nonatomic, readonly) GLint maxTextureSize;

/** OpenGL Max Modelview Stack Depth.
 */
@property (nonatomic, readonly) GLint maxModelviewStackDepth;

/** Whether or not PVR Texture Compressed is supported */
@property (nonatomic, readonly) BOOL supportsPVRTC;

/** returns a shared instance of the CCConfiguration */
+(CCConfiguration *) sharedConfiguration;

/** returns whether or not an OpenGL is supported */
- (BOOL) checkForGLExtension:(NSString *)searchName;

@end
