
#import "GLProgram.h"
#import "../../Support/CCFileUtils.h"

// START:typedefs
#pragma mark Function Pointer Definitions
typedef void (*GLInfoFunction)(GLuint program, 
                               GLenum pname, 
                               GLint* params);
typedef void (*GLLogFunction) (GLuint program, 
                               GLsizei bufsize, 
                               GLsizei* length, 
                               GLchar* infolog);
// END:typedefs
#pragma mark -
#pragma mark Private Extension Method Declaration
// START:extension
@interface GLProgram()
{
}
- (BOOL)compileShader:(GLuint *)shader 
                 type:(GLenum)type 
                 file:(NSString *)file;
- (NSString *)logForOpenGLObject:(GLuint)object 
                    infoCallback:(GLInfoFunction)infoFunc 
                         logFunc:(GLLogFunction)logFunc;
@end
// END:extension
#pragma mark -

@implementation GLProgram
// START:init
- (id)initWithVertexShaderFilename:(NSString *)vShaderFilename 
            fragmentShaderFilename:(NSString *)fShaderFilename
{
    if (self = [super init])
    {
        attributes = [[NSMutableArray alloc] init];
        uniforms = [[NSMutableArray alloc] init];
        NSString *vertShaderPathname, *fragShaderPathname;
        program = glCreateProgram();
        
        vertShaderPathname = [CCFileUtils fullPathFromRelativePath:vShaderFilename]; 

        if (![self compileShader:&vertShader 
                            type:GL_VERTEX_SHADER 
                            file:vertShaderPathname])
            NSLog(@"Failed to compile vertex shader");
        
        // Create and compile fragment shader
        fragShaderPathname = [CCFileUtils fullPathFromRelativePath:fShaderFilename];

        if (![self compileShader:&fragShader 
                            type:GL_FRAGMENT_SHADER 
                            file:fragShaderPathname])
            NSLog(@"Failed to compile fragment shader");
        
        glAttachShader(program, vertShader);
        glAttachShader(program, fragShader);
    }
    
    return self;
}
// END:init
// START:compile
- (BOOL)compileShader:(GLuint *)shader 
                 type:(GLenum)type 
                 file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = 
      (GLchar *)[[NSString stringWithContentsOfFile:file 
                                           encoding:NSUTF8StringEncoding 
                                              error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    return status == GL_TRUE;
}
// END:compile
#pragma mark -
// START:addattribute
- (void)addAttribute:(NSString *)attributeName
{
    if (![attributes containsObject:attributeName])
    {
        [attributes addObject:attributeName];
        glBindAttribLocation(program, 
                             [attributes indexOfObject:attributeName], 
                             [attributeName UTF8String]);
    }
}
// END:addattribute
// START:indexmethods
- (GLuint)attributeIndex:(NSString *)attributeName
{
    return [attributes indexOfObject:attributeName];
}
- (GLuint)uniformIndex:(NSString *)uniformName
{
    return glGetUniformLocation(program, [uniformName UTF8String]);
}
// END:indexmethods
#pragma mark -
// START:link
- (BOOL)link
{
    GLint status;
    
    glLinkProgram(program);
    glValidateProgram(program);
    
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == GL_FALSE)
        return NO;
    
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    return YES;
}
// END:link
// START:use
- (void)use
{
    glUseProgram(program);
}
// END:use
#pragma mark -
// START:privatelog
- (NSString *)logForOpenGLObject:(GLuint)object 
                    infoCallback:(GLInfoFunction)infoFunc 
                         logFunc:(GLLogFunction)logFunc
{
    GLint logLength = 0, charsWritten = 0;
    
    infoFunc(object, GL_INFO_LOG_LENGTH, &logLength);    
    if (logLength < 1)
        return nil;
    
    char *logBytes = malloc(logLength);
    logFunc(object, logLength, &charsWritten, logBytes);
    NSString *log = [[[NSString alloc] initWithBytes:logBytes 
                                              length:logLength 
                                            encoding:NSUTF8StringEncoding] 
                      autorelease];
    free(logBytes);
    return log;
}
// END:privatelog
// START:log
- (NSString *)vertexShaderLog
{
    return [self logForOpenGLObject:vertShader 
                       infoCallback:(GLInfoFunction)&glGetProgramiv 
                            logFunc:(GLLogFunction)&glGetProgramInfoLog];
    
}
- (NSString *)fragmentShaderLog
{
    return [self logForOpenGLObject:fragShader 
                       infoCallback:(GLInfoFunction)&glGetProgramiv 
                            logFunc:(GLLogFunction)&glGetProgramInfoLog];
}
- (NSString *)programLog
{
    return [self logForOpenGLObject:program 
                       infoCallback:(GLInfoFunction)&glGetProgramiv 
                            logFunc:(GLLogFunction)&glGetProgramInfoLog];
}
// END:log
#pragma mark -
// START:dealloc
- (void)dealloc
{
    [attributes release];
    [uniforms release];
  
    if (vertShader)
        glDeleteShader(vertShader);
        
    if (fragShader)
        glDeleteShader(fragShader);
    
    if (program)
        glDeleteProgram(program);
       
    [super dealloc];
}
// END:dealloc
@end
