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
#import "DownloadFile.h"
#import "CanonViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GAITrackedViewController.h"
#import "ReaderViewController.h"

@interface CanonSoftwareViewController :GAITrackedViewController<NetworkDelegate, FileDelegate, ReaderViewControllerDelegate, UIScrollViewDelegate, MPMediaPickerControllerDelegate, UIAlertViewDelegate>{
    
    //objects
    NetworkData *network;
    DownloadFile *downloadFile;
    //global views
    UIImageView *topBanner, *logo, *impressLogo;
    UIView *customNavBar, *mainView, *sideBar;
    UIButton *navBarHomeButton, *backButton, *videoButton;
    
    //sidebar views
    UIButton *overview;
    UIImageView *sidebarIndicator, *overViewIcon;
    UILabel *overviewLabel;
    
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
    NSMutableArray *offlineVideoRows, *sidebarIcons, *sidebarNames, *sidebarObjects, *sidebarTextNames, *sidebarLabelWidths;
    NSString *downloadingURL;
    
    /* No Internet View/Label */
    UIView *noConnection;
    UILabel *noConnectionLabel;
    
}
@property(nonatomic)NetworkData *network;
@property(nonatomic, readonly)CanonModel *model;
@property(nonatomic, strong)UIButton *navBarHomeButton, *videoButton;
@property(nonatomic, strong)UIView *customNavBar, *mainView, *sideBar;
@property(nonatomic, strong)NSMutableDictionary *offlineImages;



@end
