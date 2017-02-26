//
//  CanonDownloadAll.h
//  PressDemo
//
//  Created by Trekk mini-1 on 1/12/15.
//  Copyright (c) 2015 Trekk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "NetworkData.h"
#import "CanonModel.h"
#import "AppDelegateProtocol.h"
#import "CanonViewController.h"
#import "DownloadFile.h"
#import "GAITrackedViewController.h"
#import "VerifyUserStatus.h"

@interface CanonDownloadAll : GAITrackedViewController<NetworkDelegate, FileDelegate, UITextFieldDelegate, UserStatusDelegate>{
    UIButton *downloadAll;
    UIActivityIndicatorView *activityIndicator;
    DownloadFile *download;
    UILabel *downloadStatus;
    UILabel *message;
    UIView *mainView;
    NSString *currentEmail;
}

@property(nonatomic)NetworkData *network;
@property(nonatomic, readonly)CanonModel *model;
@property(nonatomic, strong)UIAlertAction *okAction;
@property(strong, nonatomic)VerifyUserStatus *userStatus;

@end
