//
//  Copyright 2012 Ultramarine UI - Christian Scheid IT Consulting. All rights reserved.
//


#import <Foundation/Foundation.h>

@class UMCellView;
@protocol UMTableViewDelegate <NSObject>

@required

- (int) numColumns;
- (int) numRows;
- (int) rowHeight;
- (void) layoutView: (UMCellView*) cellView forRow: (int) rowIndex inColumn: (int) columnIndex;

@optional

- (int) fixedWidthForColumn: (int) columnIndex;
- (Boolean) hasColumnFixedWidth: (int) columnIndex;
- (UIColor*) borderColor;
- (void) didDeleteRowAt: (int) rowIndex;
- (void)totalContentHeightOffScrollView:(float)height;
@end
