//
//  Copyright 2012 Ultramarine UI - Christian Scheid IT Consulting. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "UMTableViewDelegate.h"
#import "UMTableBorderView.h"
#import "UMCellView.h"

/*
 * use these flags to define if borders between rows and columns should be drawn
 */
typedef enum {
    UMTableViewBordersNone                   = 1 << 0,
    UMTableViewBordersRows                   = 1 << 1,
    UMTableViewBordersColumns                = 1 << 2,
} UMTableViewBorderMode;


/*
 * use these flags to define if outlines of the table should be drawn
 */
typedef enum {
    UMTableViewOutlineNone                   = 1 << 0,
    UMTableViewOutlineTop                    = 1 << 1,
    UMTableViewOutlineBottom                 = 1 << 2,
    UMTableViewOutlineLeft                   = 1 << 3,
    UMTableViewOutlineRight                  = 1 << 4,
} UMTableViewOutlineMode;


@interface UMTableView : UIScrollView {

@protected
    UMTableViewBorderMode borderMode;
    UMTableViewOutlineMode outlineMode;    
    
@private 
    
    UMTableBorderView* borderView;
    NSMutableDictionary* rowMap;
    NSMutableArray* reusableCellViews;    
    NSMutableArray* columnWidths;
    
	int lastRows;
	int lastColumns;	
    int lastRowHeight;
	
    CGRect lastFrame;    
    CGPoint lastOffset;
}

@property(nonatomic,assign) NSObject<UMTableViewDelegate>* tableViewDelegate;


@property(nonatomic) UMTableViewBorderMode borderMode;
@property(nonatomic) UMTableViewOutlineMode outlineMode;
@property float contentHeight;
/*
 * This will mark all rows as "dirty" and will kick-off `layoutSubviews` which will then redraw all visible rows
 */ 
- (void) refresh;

- (int) widthForColumn: (int) columnIndex;

- (int) totalContentWidth;

- (float) totalContentHeight;

/*
 * Returns the currently displayed view for the given indices.
 * Beware: if this row/column is currently not displayed this method will return nil
 */
- (UMCellView*) viewInRow: (NSUInteger) rowIndex column: (NSUInteger) columnIndex;

@end
