//
//  CCAppController.h
//  cocos2d
//
//  Created by Donald Hutchison on 13/01/15.
//
//

#import <Foundation/Foundation.h>

@class NSWindow;
@class CCGLView;
@interface CCAppController : NSObject

//for Mac we pass these properties from the AppDelegate to allow configuration
@property (weak) NSWindow *window;
@property (weak) CCGLView *glView;


@property(nonatomic, strong) NSDictionary *cocosConfig;

@property(nonatomic, copy) NSString *firstSceneName;

- (void)setupApplication;
@end
