//
//  Copyright 2012 Ultramarine UI - Christian Scheid IT Consulting. All rights reserved.
//


@interface UMCellView : UIView {
	UILabel* label;
	UIEdgeInsets labelInsets;	
	int fixedWidth;

@private
	int lastLabelWidth;
}

/*
 * Removes all gesture recognizers and subviews except the label
 */ 
- (void) clearContent;

/*
 * Restores original font properties and labelInsets
 */
- (void) reset;

@property(nonatomic) BOOL isDirty;

@property(nonatomic) int fixedWidth;

@property(nonatomic, strong) UILabel* label;

@property(nonatomic, setter=setLabelInsets:) UIEdgeInsets labelInsets;
@end
