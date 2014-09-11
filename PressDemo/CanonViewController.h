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


@interface CanonViewController : UIViewController<NetworkDelegate, UIScrollViewDelegate, UIAlertViewDelegate>{
    //local views
    UIImageView *homeHeader, *whatPrint, *showProducts, *logo;
    
    //data
    BOOL downloadInProgress;
    
}
@property(nonatomic)NetworkData *network;
@property(nonatomic, readonly)CanonModel *model;

@property(nonatomic, strong)NSMutableArray *whatImageNames, *showAllImageNames;
@property(nonatomic, strong)UIScrollView *whatDoYouPrint, *showAllProducts;
@property(nonatomic, strong)UIView *customNavBar;

//regular views
-(void)displayMessage:(NSString *)message withTitle:(NSString *)title;
-(void)runLoadingSequence;
-(void)setupLocalUserInterface:(completeBlock)completeFlag;
@end

