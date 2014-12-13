//
//  CanonTableKeyViewController.h
//  PressDemo
//
//  Created by Trekk mini-1 on 12/11/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanonModel.h"
#import "AppDelegateProtocol.h"

@interface CanonTableKeyViewController : UIViewController{
    UILabel *keyTitle;
    UILabel *textLabel, *textValue;
    UILabel *textPlusLabel, *textPlusValue;
    UILabel *productionLabel, *productionValue;
    UILabel *productionPlusLabel, *productionPlusValue;
    UILabel *premiumLabel, *premiumPlusValue;
}
@property(nonatomic, readonly)CanonModel *model;
@property(nonatomic, strong) UILabel *keyTitle;
@property(nonatomic, strong) UILabel *textLabel, *textValue;
@property(nonatomic, strong) UILabel *textPlusLabel, *textPlusValue;
@property(nonatomic, strong) UILabel *productionLabel, *productionValue;
@property(nonatomic, strong) UILabel *productionPlusLabel, *productionPlusValue;
@property(nonatomic, strong) UILabel *premiumLabel, *premiumPlusValue;
@end
