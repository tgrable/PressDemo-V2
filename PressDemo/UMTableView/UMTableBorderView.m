//
//  Copyright 2012 Ultramarine UI - Christian Scheid IT Consulting. All rights reserved.
//


#import "UMTableBorderView.h"
#import "UMTableView.h"

@implementation UMTableBorderView
@synthesize delegate;

- (id) initWithTableView: (UMTableView*) _tableView {
	self = [super init];
	if (self != nil) {
		tableView = _tableView;
		self.backgroundColor = [UIColor clearColor];
        //[[UIColor redColor] colorWithAlphaComponent:0.2];//
		self.userInteractionEnabled = NO;	
	}
	return self;
}

- (BOOL) isFirstResponder {
	return NO;
}

- (BOOL) canBecomeFirstResponder {
	return NO;
}

- (void) drawRect:(CGRect) rect {	
	UIColor* borderColor = [UIColor blackColor];
	if ([delegate respondsToSelector:@selector(borderColor)]) {
		borderColor = [delegate borderColor];
	}
	float borderSize = 1.0;	
	float totalh = [delegate rowHeight];
	
    // NSLog(@"self.frame: %@", NSStringFromCGRect(self.frame));
    
	if (tableView.outlineMode & UMTableViewOutlineTop) {
		CGPoint start = ccp(0, 1);
		CGPoint end = ccp([tableView totalContentWidth],1);
		[self drawLineWithColor:borderColor lineWidth:borderSize start:start end:end];	
	}
	
	// draw rows
    int numRowsInViewHeight = (self.frame.size.height / [delegate rowHeight]);
    for (int y = 1; y < numRowsInViewHeight; y++) {
		float h = [delegate rowHeight];
		
		CGPoint start = ccp(0, totalh);
		CGPoint end = ccp([tableView totalContentWidth], totalh);
		if (tableView.borderMode & UMTableViewBordersRows) {
			[self drawLineWithColor:borderColor lineWidth:borderSize start:start end:end];	
		}
//        NSLog(@"drawing row from: %@ to: %@", NSStringFromCGPoint(start), NSStringFromCGPoint(end));
		totalh += h;
    }
	int xoffset = 0;
	
	if (tableView.borderMode & UMTableViewBordersColumns) {
		for (int x = 1; x < [delegate numColumns]; x++) {
			float w = [tableView widthForColumn:x-1];
			CGPoint start = ccp(xoffset + w, 0);		
			CGPoint end = ccp(xoffset + w, [tableView totalContentHeight]);			
			[self drawLineWithColor:borderColor lineWidth:borderSize start:start end:end];			
			xoffset += w;
		}
	}
	if (tableView.outlineMode & UMTableViewOutlineBottom) {
		CGPoint start = ccp(0, totalh);
		CGPoint end = ccp([tableView totalContentWidth], totalh);
		[self drawLineWithColor:borderColor lineWidth:borderSize start:start end:end];	
	}
	if (tableView.outlineMode & UMTableViewOutlineLeft) {
		CGPoint start = ccp(0, 0);
		CGPoint end = ccp(0, totalh);
		[self drawLineWithColor:borderColor lineWidth:borderSize start:start end:end];	
	}
	if (tableView.outlineMode & UMTableViewOutlineRight) {
		CGPoint start = ccp([tableView totalContentWidth]-1, 0);
		CGPoint end = ccp([tableView totalContentWidth]-1, totalh);
		[self drawLineWithColor:borderColor lineWidth:borderSize start:start end:end];	
	}
}

- (void) drawLineWithColor: (UIColor*) color lineWidth:(float) lineWidth start:(CGPoint) start end:(CGPoint) end {
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGContextSetAllowsAntialiasing(currentContext, NO); 
    CGContextSetShouldAntialias(currentContext, NO);
    CGContextBeginPath(currentContext);
    CGContextSetLineWidth(currentContext, lineWidth);
    CGContextSetStrokeColorWithColor(currentContext, color.CGColor);
    CGContextMoveToPoint(currentContext, start.x, start.y);
    CGContextAddLineToPoint(currentContext, end.x, end.y);
    CGContextStrokePath(currentContext);   
}

@end
