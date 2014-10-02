//
//  SeriesViewController.h
//  PressDemo
//
//  Created by Trekk mini-1 on 8/12/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "NetworkData.h"
#import "CanonModel.h"
#import "AppDelegateProtocol.h"
#import <MediaPlayer/MediaPlayer.h>

@interface SeriesViewController : UIViewController<NetworkDelegate, UIScrollViewDelegate, MPMediaPickerControllerDelegate, UIAlertViewDelegate>{
    //objects
    NetworkData *network;
    
    //global views
    UIImageView *topBanner, *logo;
    UIView *customNavBar, *mainView, *sideBar;
    UIButton *navBarHomeButton, *backButton, *videoButton;

    //sidebar views
    UIButton *overview, *videos, *productSpec, *whitePaper, *caseStudy;
    UIImageView *sidebarIndicator, *overViewIcon, *whitePaperIcon;
    UIImageView *caseStudyIcon, *videoIcon, *productSpecIcon;
    UILabel *overviewLabel, *caseStudyLabel, *videoLabel, *productSpecLabel, *whitePaperLabel;
    
    //main area views
    UIImageView *mainShortBanner, *actualDocumentBanner;
    UIView *overviewContainer, *documentContainer, *actualDocumentView;
    UIScrollView *overviewImages;
    UIPageControl *overviewImageDots;
    UIScrollView *overviewContent, *documentScroll;
    UIWebView *webPage;
    UILabel *documentLabel;
    UIButton *documentHeaderButton;
    
    
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
-(NSMutableArray *)generateSeriesProductImages:(NSMutableArray *)products;
-(void)tearDownAndLoadUpDocuments:(NSString *)flag withComplete:(completeBlock)completeFlag;
-(void)loadUPWebpage:(NSData *)data complete:(completeBlock)completeFlag;
-(void)rearrangeDocumentStack;
@end
