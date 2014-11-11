//
//  AppDelegate+OALAction_Private.h
//  ObjectAL
//
//  Created by Karl Stenerud on 3/18/12.
//  Copyright (c) 2012 Stenerud. All rights reserved.
//

#import "OALAction.h"

/** \cond */
@interface OALAction ()

@property(nonatomic,readwrite,assign) id target;

@property(nonatomic,readwrite,assign) float duration;

@property(nonatomic,readwrite,assign) bool running;

@property(nonatomic,readwrite,assign) bool runningInManager;

@end
/** \endcond */
