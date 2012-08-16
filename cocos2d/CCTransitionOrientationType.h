//
//  ccTransitionOrientationType.h
//  cocos2d-ios
//
//  Created by Goffredo Marocchi on 8/16/12.
//
//

#import <Foundation/Foundation.h>

/** Orientation Type used by some transitions
 */
typedef enum {
	/// An horizontal orientation where the Left is nearer
	kOrientationLeftOver = 0,
	/// An horizontal orientation where the Right is nearer
	kOrientationRightOver = 1,
	/// A vertical orientation where the Up is nearer
	kOrientationUpOver = 0,
	/// A vertical orientation where the Bottom is nearer
	kOrientationDownOver = 1,
} tOrientation;
