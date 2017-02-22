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
-(void)bringUpSearchDialog:(int)rowValue withTitle:(NSString *)title;
-(void)closeResponse;
@end

@interface CanonMediaMillSearchOverlay : NSObject {
    UIView *background;
    UILabel *millLabel, *mediaNameLabel, *basisWeightLabel, *brightnessLabel, *coatingLabel, *colorLabel, *capabilityLabel, *inksetLabel, *searchBackgroundTitle;
    UIButton *search, *close;
    NSMutableArray *searchArray, *searchTitles;
    UIButton *millButton, *mediaButton, *basisWeightButton, *brightnessButton, *coatingButton, *colorButton, *capabilityButton, *inksetButton;
    int savedColorValue;
}
@property (weak, nonatomic) id <SearchOverlayDelegate> delegate;
@property(nonatomic, readonly) CanonModel *model;
@property(nonatomic) UIView *background;
@property(nonatomic) UIButton *colorButton;
@property(nonatomic) UITextField *basisWeightTextfield;
@property(nonatomic) NSMutableArray *searchArray, *searchTitles;
@property(nonatomic) UILabel *searchBackgroundTitle;
@property int savedColorValue;
- (void)buildViews;
@end
