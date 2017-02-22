//
//  Copyright 2012 Ultramarine UI - Christian Scheid IT Consulting. All rights reserved.
//


#define ccp(x,y) CGPointMake(x,y)
#import "UMTableViewDelegate.h"
@class UMTableView;

@interface UMTableBorderView : UIView {	
	UMTableView* tableView;
}

@property(nonatomic, assign) NSObject<UMTableViewDelegate>* delegate;

- (void) drawLineWithColor: (UIColor*) color lineWidth:(float) lineWidth start:(CGPoint) start end:(CGPoint) end;
- (id) initWithTableView: (UMTableView*) _tableView;
@end

