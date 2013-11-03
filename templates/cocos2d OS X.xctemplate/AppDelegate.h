//
//  AppDelegate.h
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___.
//  Copyright ___ORGANIZATIONNAME___ ___YEAR___. All rights reserved.
//

#import "cocos2d.h"

@interface ___PROJECTNAMEASIDENTIFIER___AppDelegate : NSObject <NSApplicationDelegate>

@property (nonatomic, weak) IBOutlet NSWindow    *window;
@property (nonatomic, weak) IBOutlet CCGLView    *glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
