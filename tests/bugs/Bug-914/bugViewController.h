//
//  bugViewController.h
//  EAGLViewBug
//
//  Created by Wylan Werth on 7/5/10.
//  Copyright 2010 BanditBear Games. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "cocos2d.h"

@interface bugViewController : UIViewController {
	EAGLView *glView;
	UIWindow *window;
	
}

@property(nonatomic, retain) EAGLView *glView;


@end
