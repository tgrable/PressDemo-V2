//
//  CanonViewController.h
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "NetworkData.h"
#import "CanonModel.h"
#import "AppDelegateProtocol.h"
#import "GAITrackedViewController.h"
#import "ShowAll.h"
#import "WhatDoYouPrint.h"

@interface CanonViewController : GAITrackedViewController<NetworkDelegate, UIScrollViewDelegate, UIAlertViewDelegate>{
    //local views
    UIImageView *homeHeader, *whatPrint, *showProducts, *logo, *impressLogo;
    
    //data
    BOOL downloadInProgress;
    
}
@property(nonatomic)NetworkData *network;
@property(nonatomic, readonly)CanonModel *model;

@property(nonatomic, strong)NSMutableArray *whatImageNames, *showAllImageNames;
@property(nonatomic, strong)WhatDoYouPrint *whatDoYouPrint;
@property(nonatomic, strong)ShowAll *showAllProducts;
@property(nonatomic, strong)UIView *customNavBar;


@end

