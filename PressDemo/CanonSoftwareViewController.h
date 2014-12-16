//
//  CanonSoftwareViewController.h
//  PressDemo
//
//  Created by Trekk mini-1 on 12/16/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "NetworkData.h"
#import "CanonModel.h"
#import "AppDelegateProtocol.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GAITrackedViewController.h"

@interface CanonSoftwareViewController :GAITrackedViewController<NetworkDelegate, UIScrollViewDelegate, MPMediaPickerControllerDelegate, UIAlertViewDelegate>{
    //objects
    NetworkData *network;
    
    //global views
    UIImageView *topBanner, *logo;
    UIView *customNavBar, *mainView, *sideBar;
    UIButton *navBarHomeButton, *backButton, *videoButton;
    
    //sidebar views
    UIButton *overview, *videos, *brochure, *datasheet;
    UIImageView *sidebarIndicator, *overViewIcon, *brochureIcon;
    UIImageView *datasheetIcon, *videoIcon;
    UILabel *overviewLabel, *datasheetLabel, *videoLabel, *brochureLabel;
    
    //main area views
    UIImageView *mainShortBanner, *actualDocumentBanner;
    UIView *overviewContainer, *documentContainer, *actualDocumentView;
    UIScrollView *overviewImages;
    UIPageControl *overviewImageDots;
    UIScrollView *overviewContent, *documentScroll;
    UIWebView *webPage;
    UILabel *documentLabel, *bannerTitle, *softwareTitle;
    UIButton *documentHeaderButton;
    UITextView *softwareDescription;
    
    //global data
    NSMutableDictionary *currentDocumentData;
    NSMutableDictionary *offlineImages;
    NSMutableDictionary *offlineVideos;
    NSMutableArray *offlineVideoRows;
    NSString *downloadingURL;
    
}
@property(nonatomic)NetworkData *network;
@property(nonatomic, readonly)CanonModel *model;
@property(nonatomic, strong)UIButton *navBarHomeButton, *videoButton;
@property(nonatomic, strong)UIView *customNavBar, *mainView, *sideBar;
@property(nonatomic, strong)NSMutableDictionary *offlineImages;

-(void)displayMessage:(NSString *)message withTitle:(NSString *)title;
-(void)setupLocalUserInterface:(completeBlock)completeFlag;
-(void)animateSidebarIndicator:(int)yValue;
-(void)tearDownAndLoadUpDocuments:(NSString *)flag withComplete:(completeBlock)completeFlag;
-(void)loadUPWebpage:(NSData *)data complete:(completeBlock)completeFlag;
-(void)rearrangeDocumentStack;

@end
