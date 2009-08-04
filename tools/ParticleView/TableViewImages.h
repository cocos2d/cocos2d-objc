//
//  TableViewImages.h
//  ParticleView
//
//  Created by Type your name here on 7/27/09.
//  Copyright 2009 http://www.idevomsk.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ParticlesViewController.h"

@interface TableViewImages : UITableViewController<UITableViewDelegate, UITableViewDataSource> 
{
	NSMutableArray *images;
	int particleSystem;
}

@property int particleSystem;

@end
