//
//  Copyright 2012 Ultramarine UI - Christian Scheid IT Consulting. All rights reserved.
//


#import "UMTableView.h"
#import <QuartzCore/QuartzCore.h>

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@interface UMTableView() 

@property(nonatomic,strong) NSMutableDictionary* rowMap;
@property(nonatomic,strong) NSMutableArray* reusableCellViews;

@property(nonatomic,strong) NSMutableArray* columnWidths;
@property(nonatomic,strong) UMTableBorderView* borderView;

- (void) recalculateColumnWidths;
- (void) markAllColumnsDirty;
- (void) maintainCellViews;
- (void) removeInvisibleCellViews;
- (void) removeRowAt: (NSUInteger) index;

@end


@implementation UMTableView

@synthesize tableViewDelegate, borderMode, outlineMode;
@synthesize columnWidths, borderView, reusableCellViews, rowMap, contentHeight;

- (id) initWithFrame: (CGRect) frame {
    
    self = [super initWithFrame:frame];

    if (self) {
        self.delaysContentTouches = NO;
        contentHeight = 0;
        
        borderMode = UMTableViewBordersRows | UMTableViewBordersColumns;
        outlineMode = UMTableViewOutlineTop | UMTableViewOutlineBottom | UMTableViewOutlineLeft | UMTableViewOutlineRight;
        self.backgroundColor = [UIColor clearColor];
        lastRows = 0;
        lastColumns = 0;
        self.alwaysBounceVertical = YES;
        self.rowMap = [NSMutableDictionary dictionaryWithCapacity:64];
        self.columnWidths = [NSMutableArray array];
        UMTableBorderView* tableBorderView = [[UMTableBorderView alloc] initWithTableView:self];
        self.borderView = tableBorderView;
        // self.borderView.alpha = 0;
        [self addSubview:borderView];
        self.reusableCellViews = [NSMutableArray array];
        
        
#if ! __has_feature(objc_arc)
        [tableBorderView release];
#endif
        lastOffset = CGPointZero;
        
    }
    return self;
}

- (void) setTableViewDelegate:(NSObject <UMTableViewDelegate>*) d {
    tableViewDelegate = d;		
	borderView.delegate = d;    
}

- (UMCellView*) reuseCellView {

    if (reusableCellViews.count < 1) {
        return [UMCellView new];        
    }
    else {
        UMCellView* cellView = [reusableCellViews lastObject];
#if ! __has_feature(objc_arc)
        [cellView retain];
#endif
        [reusableCellViews removeLastObject];
        cellView.isDirty = YES;
        return cellView;
    }
}

/*
 * Return the currently displayed view for the given indices.
 * Beware: if this row/column is currently not displayed this method will return nil
 */
- (UMCellView*) viewInRow: (NSUInteger) rowIndex column: (NSUInteger) columnIndex {
    UMCellView* cell = nil;
    
    int rowValue = (int)rowIndex;
    int colValue = (int)columnIndex;
    NSDictionary* row = [self.rowMap valueForKey:[[NSNumber numberWithInt:rowValue] stringValue]];
    if (row != nil) {
        cell = [row valueForKey:[[NSNumber numberWithInt:colValue] stringValue]];
    }
    return cell;
}


- (void) layoutSubviews {
    [super layoutSubviews];
    // NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate];
    BOOL frameChanged = !CGRectEqualToRect(self.frame, lastFrame);
    BOOL numCellsChanged = lastColumns != [tableViewDelegate numColumns] || lastRows != [tableViewDelegate numRows];
    
    BOOL rowHeightChanged = lastRowHeight != [tableViewDelegate rowHeight];
    
    // remove all rows that are currently visible
    if (rowHeightChanged) {
        for (NSDictionary* row in [self.rowMap allValues]) {
            for (UMCellView* cellView in [row allValues]) {
                [cellView removeFromSuperview];
            }
        }
        [self.rowMap removeAllObjects];
    }
    
	if (frameChanged || numCellsChanged || rowHeightChanged) {        
      //NSTimeInterval t = [NSDate timeIntervalSinceReferenceDate];  
        [self markAllColumnsDirty]; 
        [self recalculateColumnWidths]; 
        //[borderView setNeedsDisplay];	
        lastFrame = self.frame;         

        // in case the delegate change its model from huge to small, release excess views
        if (self.reusableCellViews.count > [tableViewDelegate numColumns] * 8) {
            [self.reusableCellViews removeAllObjects];
        }
        
        if (numCellsChanged) {
            
            for (int i = [tableViewDelegate numRows]; i < lastRows;  i++) {
                [self removeRowAt:i];
            }
            for (int i = [tableViewDelegate numColumns]; i < lastColumns ; i++) {
                for (NSString* key in [self.rowMap allKeys]) {
                    NSString* columnKey = [[NSNumber numberWithInt:i] stringValue];
                    NSMutableDictionary* row = [self.rowMap objectForKey:key];
                    if (row != nil) {                                
                        UMCellView* cellView = [row valueForKey:columnKey];
                        if (cellView != nil) {
                            [reusableCellViews addObject:cellView];
                            [cellView removeFromSuperview];                    
                            [row removeObjectForKey:columnKey];
                            // NSLog(@"Removed column at: %@-%d", key, i);
                        }
                    }
                }
            }
        }
    }
            
    if (tableViewDelegate == nil) {
        NSLog(@"Warning: No UMTableViewDelegate found");
        return;
    }	        
    
    CGSize newContentSize = CGSizeMake([self totalContentWidth], [self totalContentHeight]);	
    if (!CGSizeEqualToSize(newContentSize, self.contentSize)) {        
        self.contentSize = newContentSize;
    }

    int frameHeight = self.frame.size.height;
    int contentYOffset = self.contentOffset.y;    
    int rowHeight = [tableViewDelegate rowHeight];
    
    // be sure to draw enough rows to compensate offset;
    frameHeight += 2 * rowHeight;
    
    int yOffsetRowNum = contentYOffset / rowHeight;
    int yOffset = yOffsetRowNum * rowHeight;
    int maxRowsLeft = [tableViewDelegate numRows] - yOffsetRowNum;
    int visibleRowHeight = (frameHeight / rowHeight) * rowHeight;
    int heightLeft = maxRowsLeft * rowHeight;
    int borderViewHeight = MIN(visibleRowHeight, heightLeft);            
    yOffset = MAX(0, yOffset);
    
    borderView.frame = CGRectMake(0, yOffset, self.bounds.size.width, borderViewHeight);
    [borderView setNeedsDisplay];
    
    lastRows = [tableViewDelegate numRows];
    lastColumns = [tableViewDelegate numColumns];
    lastRowHeight = [tableViewDelegate rowHeight];
	[self bringSubviewToFront:borderView];
    
    [self maintainCellViews];  
    
    lastOffset = self.contentOffset;    
}


- (void) maintainCellViews {
    int numRows = [tableViewDelegate numRows];
    int numColumns = [tableViewDelegate numColumns];
    
    float totalh = 0;
    
    CGRect contentRect = CGRectMake(self.contentOffset.x, self.contentOffset.y, self.frame.size.width, self.frame.size.height);    
    
    [self removeInvisibleCellViews];
    
    for (int y = 0; y < numRows; y++) {
		
        float h = [tableViewDelegate rowHeight];
		float totalw = 0;
        
        CGRect rowRect = CGRectMake(0, totalh, 1, h);        
        
        if (CGRectIntersectsRect(contentRect, rowRect)) {
            
            NSMutableDictionary* row = [self.rowMap valueForKey:[[NSNumber numberWithInt:y] stringValue]];                       
            
            for (int x = 0; x < numColumns; x++) {
                
                NSString* columnKey = [[NSNumber numberWithInt:x] stringValue];
                
                float w = [self widthForColumn:x];                                
                
                UMCellView* cellView = nil;
                if (row != nil) {
                    cellView = [row valueForKey:columnKey];
                }
                else {
                    row = [NSMutableDictionary dictionary];
                    [rowMap setValue:row forKey:[[NSNumber numberWithInt:y] stringValue]];   
                }
                
                if (cellView == nil) {
                    cellView = [self reuseCellView];                    
                    cellView.backgroundColor = [UIColor whiteColor];
                    
                    [self insertSubview:cellView atIndex:0]; 
#if ! __has_feature(objc_arc)
                    [cellView release];
#endif
                    [row setValue:cellView forKey:columnKey];
                }                    
                
                CGRect newCellRect = CGRectMake(totalw, totalh, w, h);			
                if (!CGRectEqualToRect(newCellRect, cellView.frame)) {
                    cellView.frame = newCellRect;
                }                    
                
                if (cellView.isDirty) {         
                    [cellView clearContent];
                    [tableViewDelegate layoutView:cellView forRow:y inColumn:x];
                    cellView.isDirty = NO;
                }
                totalw += w;
            }
        }
		totalh += h;	
    }
    
    
}

/*
 * Internally removes row from data structure and removes views
 */             
- (void) removeRowAt: (NSUInteger) index {
    
    int ind = (int)index;
    
    NSString* key = [[NSNumber numberWithInt:ind] stringValue];
    NSMutableDictionary* row = [self.rowMap objectForKey:key];
    if (row != nil) {                                
        for (UMCellView* cellView in [row allValues]) {
            [reusableCellViews addObject:cellView];
            [cellView removeFromSuperview];                    
        }
        [row removeAllObjects];
        [self.rowMap removeObjectForKey:key];
        // NSLog(@"Removed row at: %d", index);
    }        
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view {
    ALog(@"View %@", view);
    if ([view isKindOfClass:UIButton.class]) {
        ALog(@"Cancel");
        return YES;
    }
    
    return [super touchesShouldCancelInContentView:view];
}


/*
 * Internally removes rows that are no longer visible due to scrolling
 */             
- (void) removeInvisibleCellViews {
     
    CGPoint offsetDiff = CGPointMake(self.contentOffset.x - lastOffset.x, self.contentOffset.y - lastOffset.y);
    
    // table scrolls down
    if (offsetDiff.y > 0) {
        int numRowsHiddenSinceLastTime = offsetDiff.y / [tableViewDelegate rowHeight] + 1;
        int indexToDelete = self.contentOffset.y / [tableViewDelegate rowHeight] - 2;
        for (int i = 0; i < numRowsHiddenSinceLastTime; i++) {
            [self removeRowAt:indexToDelete];
            indexToDelete--;
        }
    }
    
    else {
        int numRowsHiddenSinceLastTime = offsetDiff.y * -1 / [tableViewDelegate rowHeight] + 1;
        int indexToDelete = (self.contentOffset.y + self.frame.size.height) / [tableViewDelegate rowHeight] + 2;
        for (int i = 0; i < numRowsHiddenSinceLastTime; i++) {
            [self removeRowAt:indexToDelete];
            indexToDelete++;
        }        
    }
}

- (float) totalContentHeight {
    float h = ([tableViewDelegate rowHeight] * [tableViewDelegate numRows]) + 160;
    contentHeight = ([tableViewDelegate rowHeight] * [tableViewDelegate numRows]);
    [tableViewDelegate totalContentHeightOffScrollView:contentHeight];
    return h;
}

- (int) totalContentWidth {
	int totalWidth = 0;
	int numColumns = [tableViewDelegate numColumns];
	if (columnWidths.count != numColumns) {	
		[self recalculateColumnWidths];		
	}
	for (NSNumber* n in columnWidths) {
		totalWidth += [n intValue];
	}
	return totalWidth;
}

- (int) widthForColumn: (int) columnIndex {
	if (columnWidths.count > columnIndex) {
		return [[columnWidths objectAtIndex:columnIndex] intValue];	
	}
	return 0;
}

- (void) recalculateColumnWidths {
	int numColumns = [tableViewDelegate numColumns];
	[columnWidths removeAllObjects];
	for (int i = 0; i < numColumns; i++) {
		[columnWidths addObject:[NSNumber numberWithInt:0]];
	}
	Boolean delegateRespondsToFixedWidths = [tableViewDelegate respondsToSelector:@selector(hasColumnFixedWidth:)] 
											&& [tableViewDelegate respondsToSelector:@selector(fixedWidthForColumn:)];	
	int numColumnsFixed = 0;
	int totalFixedWidth = 0;
	for (int i = 0; i < numColumns; i++) {
		if (delegateRespondsToFixedWidths) {
			if ([tableViewDelegate hasColumnFixedWidth:i]) {
				int fixedWidth = [tableViewDelegate fixedWidthForColumn:i];
				numColumnsFixed++;
				totalFixedWidth += fixedWidth;			
				[columnWidths replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:fixedWidth]];					
			}
		}
	}		
	
	int restWidth = (self.bounds.size.width - totalFixedWidth);
	int remainingFlexibleColumns = numColumns - numColumnsFixed;
	
	if (remainingFlexibleColumns > 0) {
		int widthPerNonFixedColumn = restWidth / remainingFlexibleColumns;
		int* newColumnWidths = (int*)malloc(sizeof(int) * numColumns);
		
		for (int i = 0; i < numColumns; i++) {
			if (!delegateRespondsToFixedWidths || ![tableViewDelegate hasColumnFixedWidth:i]) {
				newColumnWidths[i] = widthPerNonFixedColumn;
			}
		}
		// redistribute remaining space which coulnd't be shared across all columns by former division
		int remainder = restWidth - ((numColumns - numColumnsFixed) * widthPerNonFixedColumn);
		while (remainder > 0) {
			for (int i = 0; i < numColumns; i++) {
				if (remainder == 0) break;
				if (newColumnWidths[i] > 0) {
					newColumnWidths[i]++;
					remainder--;
				}	
			}	
		}
		
		// save new column widhts
		for (int i = 0; i < [tableViewDelegate numColumns]; i++) {
			if (!delegateRespondsToFixedWidths || ![tableViewDelegate hasColumnFixedWidth:i]) {
				[columnWidths replaceObjectAtIndex:i withObject:[NSNumber numberWithInt:newColumnWidths[i]]];					
			}	
		}	
		free(newColumnWidths);	
	}
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void) markAllColumnsDirty {
    for (NSMutableDictionary* row in [self.rowMap allValues]) {
        for (UMCellView* view in [row allValues]) {
            view.isDirty = YES;
        }
    }
}

/*
 * Will mark all rows as "dirty" but only redraw visible rows
 */
- (void) refresh {
	[self markAllColumnsDirty];
    [self setNeedsLayout];
	// [borderView setNeedsDisplay];
}

- (void)dealloc {
#if ! __has_feature(objc_arc)
    self.columnWidths = nil;
    self.rowMap = nil;
    self.borderView = nil;
    [super dealloc];
#endif
}

@end
