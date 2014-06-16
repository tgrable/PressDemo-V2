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

@interface CanonViewController : UIViewController<NetworkDelegate, UIAlertViewDelegate>{
    //objects
    NetworkData *network;
    NSMutableArray *layouViews;
    
    //local views
    UIImageView *homeHeader;
    
    
}
@property(nonatomic)NetworkData *network;
@property(nonatomic, readonly)CanonModel *model;



//regular views

-(void)displayMessage:(NSString *)message withTitle:(NSString *)title;
-(void)displayAllViews;
-(void)runLoadingSequence;
@end

