//
//  VirtualAccelerometer.h
//  cocos2d-port
//
//  Created by alecu on 22/06/08.
//  Copyright 2008 alecu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VirtualAccelerometerDelegate;

@interface VirtualAcceleration : NSObject {
    NSTimeInterval timestamp;
    UIAccelerationValue x, y, z;
}

@property(nonatomic) NSTimeInterval timestamp;
@property(nonatomic) UIAccelerationValue x;
@property(nonatomic) UIAccelerationValue y;
@property(nonatomic) UIAccelerationValue z;

@end

@interface VirtualAccelerometer : NSObject {
	id <VirtualAccelerometerDelegate> delegate;
	NSTimeInterval updateInterval;
	NSOutputStream *oStream;
    NSInputStream *iStream;
}

@property(nonatomic,assign) id<VirtualAccelerometerDelegate> delegate;
@property(nonatomic,assign) NSTimeInterval updateInterval;

+ (VirtualAccelerometer *)sharedAccelerometer;
- (void) connect;
- (void) stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode;

@end


@protocol VirtualAccelerometerDelegate <NSObject>

@optional

- (void)accelerometer:(VirtualAccelerometer *)accelerometer didAccelerate:(VirtualAcceleration *)acceleration;

@end

/*
#if TARGET_IPHONE_SIMULATOR // running inside the simulator
#define UIAccelerometer VirtualAccelerometer
#define UIAcceleration VirtualAcceleration
#define UIAccelerometerDelegate VirtualAccelerometerDelegate
#endif // simulator
*/