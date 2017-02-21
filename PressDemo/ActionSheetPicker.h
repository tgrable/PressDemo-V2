//
//  ActionSheetPicker.h
//  PressDemo
//
//  Created by Trekk mini-1 on 10/26/15.
//  Copyright © 2015 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "NetworkData.h"
#import "CanonModel.h"

@protocol PopOverviewDelegate <NSObject>
@optional
//functions to be executed when the search routine is finished
-(void)closePopUpResponse;
@end

@interface ActionSheetPicker : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource> {
    UIView *background;
    UIPickerView *generalPickerview;
    UIActionSheet *actionSheet;
    UILabel *titleLabel;
    UIButton *doneButton;
    NSMutableArray *iconArray;
    BOOL colorFlag;
}
@property (weak, nonatomic) id <PopOverviewDelegate> delegate;
@property (nonatomic, readonly) CanonModel *model;
@property (nonatomic, retain)UIPickerView *generalPickerview;
@property (nonatomic, retain)UIActionSheet *actionSheet;
@property (nonatomic, retain)UIView *background;
@property (nonatomic, retain)UILabel *titleLabel;
@property (nonatomic, retain)UIButton *doneButton;
@property BOOL colorFlag;
-(UIView *)getColorIconSet:(int)value;
@end
