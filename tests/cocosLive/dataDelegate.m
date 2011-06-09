//
//  dataDelegate.m
//  cocos2d-iphone
//
//  Created by Ricardo Quesada on 30/01/09.
//  Copyright 2009 Sapus Media. All rights reserved.
//

// needed for AppController
#import "cocosLiveDemo.h"

#import "dataDelegate.h"

enum {
	kCellHeight = 24,
};


@implementation dataDelegate
#pragma mark UITableView Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return kCellHeight;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	AppController *appDelegate = [[UIApplication sharedApplication] delegate];
	NSInteger i = [[appDelegate globalScores] count];
	
	return i;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *MyIdentifier = @"HighScoreCell";
	
	UILabel *name, *score, *idx, *country;
	UILabel *speed, *angle;
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
		
		// Position
		idx = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 24, kCellHeight-2)];
		idx.tag = 3;
		//		name.font = [UIFont boldSystemFontOfSize:16.0];
		idx.font = [UIFont fontWithName:@"Marker Felt" size:16.0f];
		idx.adjustsFontSizeToFitWidth = YES;
		idx.textAlignment = UITextAlignmentRight;
		idx.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
		idx.autoresizingMask = UIViewAutoresizingFlexibleRightMargin; 
		[cell.contentView addSubview:idx];
		[idx release];
		
		// Name
		name = [[UILabel alloc] initWithFrame:CGRectMake(65.0f, 0.0f, 150, kCellHeight-2)];
		name.tag = 1;
		//		name.font = [UIFont boldSystemFontOfSize:16.0];
		name.font = [UIFont fontWithName:@"Marker Felt" size:16.0f];
		name.adjustsFontSizeToFitWidth = YES;
		name.textAlignment = UITextAlignmentLeft;
		name.textColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
		name.autoresizingMask = UIViewAutoresizingFlexibleRightMargin; 
		[cell.contentView addSubview:name];
		[name release];
		
		// Score
		score = [[UILabel alloc] initWithFrame:CGRectMake(200, 0.0f, 70.0f, kCellHeight-2)];
		score.tag = 2;
		score.font = [UIFont systemFontOfSize:16.0f];
		score.textColor = [UIColor darkGrayColor];
		score.adjustsFontSizeToFitWidth = YES;
		score.textAlignment = UITextAlignmentRight;
		score.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		[cell.contentView addSubview:score];
		[score release];
		
		// Speed
		speed = [[UILabel alloc] initWithFrame:CGRectMake(65, 20.0f, 40.0f, kCellHeight-2)];
		speed.tag = 5;
		speed.font = [UIFont systemFontOfSize:16.0f];
		speed.textColor = [UIColor darkGrayColor];
		speed.adjustsFontSizeToFitWidth = YES;
		speed.textAlignment = UITextAlignmentRight;
		speed.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		[cell.contentView addSubview:speed];
		[speed release];
		
		// Angle
		angle = [[UILabel alloc] initWithFrame:CGRectMake(160, 20.0f, 35.0f, kCellHeight-2)];
		angle.tag = 6;
		angle.font = [UIFont systemFontOfSize:16.0f];
		angle.textColor = [UIColor darkGrayColor];
		angle.adjustsFontSizeToFitWidth = YES;
		angle.textAlignment = UITextAlignmentRight;
		angle.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		[cell.contentView addSubview:angle];
		[angle release];
		
		// Flag
		country = [[UILabel alloc] initWithFrame:CGRectMake(280, 20.0f, 16, kCellHeight-2)];
		country.tag = 4;
		country.font = [UIFont systemFontOfSize:16.0f];
		country.textColor = [UIColor darkGrayColor];
		country.adjustsFontSizeToFitWidth = YES;
		country.textAlignment = UITextAlignmentRight;
		country.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
		[cell.contentView addSubview:country];
		[country release];
		
	} else {
		name = (UILabel *)[cell.contentView viewWithTag:1];
		score = (UILabel *)[cell.contentView viewWithTag:2];
		idx = (UILabel *)[cell.contentView viewWithTag:3];
		country = (UILabel*)[cell.contentView viewWithTag:4];
		speed = (UILabel *)[cell.contentView viewWithTag:5];
		angle = (UILabel *)[cell.contentView viewWithTag:6];
		
	}
	
	int i = indexPath.row;
	AppController *appDelegate = [[UIApplication sharedApplication] delegate];

	NSDictionary	*s = [[appDelegate globalScores] objectAtIndex:i];
//	NSLog(@"d: %@", s);

	idx.text = [[s objectForKey:@"position"] stringValue];
	name.text = [s objectForKey:@"cc_playername"];
	// this is an NSNumber... convert it to string
	score.text = [[s objectForKey:@"cc_score"] stringValue];
	
	// sanity check in case usr_speed doesn't is invalid
	id obSpeed = [s objectForKey:@"usr_speed"];
	if( [obSpeed respondsToSelector:@selector(stringValue)] )
		speed.text = [obSpeed stringValue];
	else
		speed.text = obSpeed;

	// sanity check in case usr_angle doesn't is invalid
	id obAngle = [s objectForKey:@"usr_angle"];
	if( [obAngle respondsToSelector:@selector(stringValue)] )
		angle.text = [obAngle stringValue];
	else
		angle.text = obAngle;
	
	country.text = [s objectForKey:@"cc_country"];
		

	return cell;
}

@end
