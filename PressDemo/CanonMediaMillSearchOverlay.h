//
//  CanonMediaMillSearchOverlay.h
//  PressDemo
//
//  Created by Trekk mini-1 on 10/14/15.
//  Copyright © 2015 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "NetworkData.h"
#import "CanonModel.h"

@protocol SearchOverlayDelegate <NSObject>
@optional
//functions to be executed when the search routine is finished
-(void)searchResponse;
-(void)closeResponse;
@end

@interface CanonMediaMillSearchOverlay : NSObject <UIPickerViewDelegate, UIPickerViewDataSource> {
    UIView *background;
    UILabel *millLabel, *mediaNameLabel, *basisWeightLabel, *brightnessLabel, *coatingLabel, *colorLabel, *capabilityLabel, *inksetLabel, *searchBackgroundTitle;
    UIPickerView *millNamePicker, *mediaNamePicker, *basisWeightPicker, *brightnessPicker, *coatingPicker, *colorPicker, *capabilityPicker, *inksetPicker;
    UIButton *search, *close;
    NSMutableArray *searchArray, *iconArray;
}
@property (weak, nonatomic) id <SearchOverlayDelegate> delegate;
@property(nonatomic, readonly) CanonModel *model;
@property(nonatomic) UIView *background;
@property(nonatomic) UIPickerView *millNamePicker, *mediaNamePicker, *basisWeightPicker, *brightnessPicker, *coatingPicker, *colorPicker, *capabilityPicker, *inksetPicker;
@property(nonatomic) UITextField *basisWeightTextfield;
@property(nonatomic) NSMutableArray *searchArray, *iconArray;
@property(nonatomic) UILabel *searchBackgroundTitle;
- (void)buildViews;
@end
