//
// cocosLiveDemo
//

#import "cocoslive.h"

enum {
	kCategoryEasy = 0,
	kCategoryMedium = 1,
	kCategoryHard = 2,
};

enum {
	kAll = 0,
	kCountry = 1,
	kDevice = 2,
};

//CLASS INTERFACE
@interface AppController : NSObject <UIApplicationDelegate>
{
	IBOutlet UIWindow				*window;
	IBOutlet UIView					*mainView;
	IBOutlet UITableView			*myTableView;
	IBOutlet UINavigationBar		*myNavigation;

	// scores category
	int			category;
	// scores world
	int			world;
	
	NSMutableArray *globalScores;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) NSMutableArray *globalScores;


// segment delegate
- (void)segmentAction:(id)sender;

// button delegate
- (void)buttonCallback:(id)sender;

@end
