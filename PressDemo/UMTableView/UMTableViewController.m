//
//  Copyright 2012 Ultramarine UI - Christian Scheid IT Consulting. All rights reserved.
//


#import "UMTableViewController.h"

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)


@implementation UMTableViewController

@synthesize tableView;

- (void) loadView {	
    UMTableView* _tableView = [[UMTableView alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	self.tableView = _tableView;
	self.tableView.tableViewDelegate = self;		
	self.view = self.tableView;
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    ALog(@"HERE table %@", _tableView);
    
#if ! __has_feature(objc_arc)
	[_tableView release];
#endif
}

//- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    [table
//}

- (void) layoutView: (UMCellView*) cellView forRow: (int) row inColumn: (int) column {	
}

- (int) rowHeight {
	return 48;
}

- (int) numColumns {
    return 4;
}

- (int) numRows {
    return 16;
}

- (UIColor*) borderColor {
	return [UIColor grayColor];
}

@end
