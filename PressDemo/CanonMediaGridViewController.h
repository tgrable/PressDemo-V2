//
//  CanonMediaGridViewController.h
//  PressDemo
//
//  Created by Trekk mini-1 on 12/10/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "NetworkData.h"
#import "CanonModel.h"
#import "AppDelegateProtocol.h"
#import "GAITrackedViewController.h"
#import "ProductScroll.h"

@interface CanonMediaGridViewController : GAITrackedViewController<NetworkDelegate, UIScrollViewDelegate, UIAlertViewDelegate>{
    
    //local views
    UIImageView *logo;
    
}
@property(nonatomic)NetworkData *network;
@property(nonatomic, readonly)CanonModel *model;
@property(nonatomic, strong)UIImageView *topBanner;
@property(nonatomic, strong)ProductScroll *productScroll;
@property(nonatomic, strong)UIButton *navBarHomeButton;
@property(nonatomic, strong)UIView *customNavBar;
@property(nonatomic, strong)NSMutableDictionary *offlineImages;


@end
