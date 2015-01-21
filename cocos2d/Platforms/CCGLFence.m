//
//  CCGLFence.m
//  cocos2d
//
//  Created by Oleg Osin on 1/12/15.
//
//

#import "CCGLFence.h"
#import "CCGL.h"

@implementation CCGLFence {
    GLsync _fence;
    BOOL _invalidated;
}

-(instancetype)init
{
    if((self = [super init])){
        _handlers = [NSMutableArray array];
    }
    
    return self;
}

-(void)insertFence
{
    _fence = glFenceSyncAPPLE(GL_SYNC_GPU_COMMANDS_COMPLETE_APPLE, 0);
    
    CC_CHECK_GL_ERROR_DEBUG();
}

-(BOOL)isReady
{
    // If there is a GL fence assigned, then the fence is waiting on it and not ready.
    return (_fence == NULL);
}

-(BOOL)isCompleted
{
    if(_fence){

    if(glClientWaitSyncAPPLE(_fence, GL_SYNC_FLUSH_COMMANDS_BIT_APPLE, 0) == GL_ALREADY_SIGNALED_APPLE){
            glDeleteSyncAPPLE(_fence);
            _fence = NULL;
            
            CC_CHECK_GL_ERROR_DEBUG();
            return YES;
        } else {
            // Fence is still waiting
            return NO;
        }
    } else {
        // Fence has completed previously.
        return YES;
    }
}

@end
