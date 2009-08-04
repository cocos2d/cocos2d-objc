//
//  TableViewImages.m
//  ParticleView
//
//  Created by Type your name here on 7/27/09.
//  Copyright 2009 http://www.idevomsk.com. All rights reserved.
//

#import "TableViewImages.h"
#import "ParticleViewAppDelegate.h"
#import "Constants.h"

@implementation TableViewImages

@synthesize particleSystem;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) 
	{
		// Initialization code
	}
	return self;
}

/*
 Implement loadView if you want to create a view hierarchy programmatically
 - (void)loadView 
 {
 }
 */

- (void)viewDidLoad 
{
	self.title = @"Images list";
	
	images = [[NSMutableArray alloc] init];
	
	for (int i = 1; i <= kImagesCount; ++i)
	{
		[images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"%d.png", i]]];
	}
	
	[super viewDidLoad];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc 
{
	[images release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark Table Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [images count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{	
	static NSString *TopLevelCellIdentifier = @"TopLevelCellIdentifier";
	
	for (UIView *view in [tableView subviews])
	{
		if ([[[view class] description] isEqualToString:@"UITableViewIndex"])
		{
			[view setBackgroundColor:[UIColor clearColor]];
		}
	}
	
	[tableView setBackgroundColor:[UIColor blackColor]];
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TopLevelCellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:TopLevelCellIdentifier] autorelease];
	}
	// Configure the cell
	NSUInteger row = [indexPath row];
#ifndef __IPHONE_3_0
	cell.image = [images objectAtIndex:row];
#else
	cell.imageView.image = [images objectAtIndex:row];

#endif // __IPHONE_3_0
	
	return cell;
}

#pragma mark -
#pragma mark Table View Delegate Methods

- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	NSUInteger row = [indexPath row] + 1;
	ParticleViewAppDelegate *delegate = [[UIApplication sharedApplication] delegate];

	if (self.particleSystem == kParticleSystem1)
	{
		[delegate.settings1 replaceObjectAtIndex:___textureNumber withObject:[NSString stringWithFormat:@"%d", row]];
	}
	else if (self.particleSystem == kParticleSystem2)
	{
		[delegate.settings2 replaceObjectAtIndex:___textureNumber withObject:[NSString stringWithFormat:@"%d", row]];
	}
	else if (self.particleSystem == kParticleSystem3)
	{
		[delegate.settings3 replaceObjectAtIndex:___textureNumber withObject:[NSString stringWithFormat:@"%d", row]];
	}
	else if (self.particleSystem == kParticleSystem4)
	{
		[delegate.settings4 replaceObjectAtIndex:___textureNumber withObject:[NSString stringWithFormat:@"%d", row]];
	}
	else if (self.particleSystem == kParticleSystem5)
	{
		[delegate.settings5 replaceObjectAtIndex:___textureNumber withObject:[NSString stringWithFormat:@"%d", row]];
	}

	[self.view removeFromSuperview];
}

@end
