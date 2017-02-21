//
//  CanonAppDelegate.h
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegateProtocol.h"
#import "CanonDownloadAll.h"
#import "ReaderViewController.h"

@class CanonModel;

@interface CanonAppDelegate : UIResponder <UIApplicationDelegate, AppDelegateProtocol>{
    CanonModel * AppDataObj;
}
@property (nonatomic, retain)CanonModel * AppDataObj;
@property (strong, nonatomic)CanonDownloadAll *downloadViewController;
@property (strong, nonatomic) UIWindow *window;

@end
