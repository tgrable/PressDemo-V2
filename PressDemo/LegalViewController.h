//
//  LegalViewController.h
//  PressDemo
//
//  Created by Trekk mini-1 on 1/26/15.
//  Copyright (c) 2015 Trekk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CanonModel.h"
#import "AppDelegateProtocol.h"

@interface LegalViewController : UIViewController{
    UIImageView *logo, *impressLogo;
    
}
@property(nonatomic, readonly)CanonModel *model;
@property(nonatomic, strong)UIView *customNavBar;
@end
