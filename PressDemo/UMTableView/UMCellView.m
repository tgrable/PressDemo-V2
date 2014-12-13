//
//  Copyright 2012 Ultramarine UI - Christian Scheid IT Consulting. All rights reserved.
//


#import "UMCellView.h"


@implementation UMCellView

@synthesize label, labelInsets, fixedWidth, isDirty; 

- (id) init {
	self = [super init];
	if (self != nil) {
		lastLabelWidth = -1;
        self.isDirty = YES;
        [self reset];        
	}
	return self;
}

- (void) updateLabelFrame {
	float insetsHeight = labelInsets.top + labelInsets.bottom;
	float insetsWidth = labelInsets.left + labelInsets.right;
	self.label.frame = CGRectMake(labelInsets.left, labelInsets.top, self.frame.size.width-insetsWidth, self.frame.size.height-insetsHeight);
	lastLabelWidth = self.frame.size.width;
}

- (void) setLabelInsets:(UIEdgeInsets) insets {
	labelInsets = insets;
	[self updateLabelFrame];	
}

- (void) setFrame:(CGRect) rect {
	[super setFrame:rect];
	if (rect.size.width != lastLabelWidth) {
		[self updateLabelFrame];
	}
}

- (void) reset{
    if (self.label != nil) [self.label removeFromSuperview];
    UILabel* _label = [UILabel new];		
    self.label = _label;
#if ! __has_feature(objc_arc)
    [_label release];
#endif
    [self addSubview:self.label];
    self.label.font = [UIFont boldSystemFontOfSize:11];
    self.label.backgroundColor = [UIColor clearColor];	
    self.label.textColor = [UIColor blackColor];
    self.labelInsets = UIEdgeInsetsMake(8, 8, 8, 8);    
    [self updateLabelFrame];
}

- (void) clearContent {
 
    [self reset];
    for (UIGestureRecognizer* recognizer in self.gestureRecognizers) {
        [self removeGestureRecognizer:recognizer];
    }
    for (UIView* sub in self.subviews) {
        if (sub != self.label) {
            [sub removeFromSuperview];
        }
    }
}


- (void) dealloc {
#if ! __has_feature(objc_arc)
    self.label = nil;
	[super dealloc];
#endif
}

@end
