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
#import "DownloadFile.h"
#import "AppDelegateProtocol.h"
#import "CanonViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "GAITrackedViewController.h"
#import "ReaderViewController.h"

@interface SeriesViewController : GAITrackedViewController<NetworkDelegate, FileDelegate, ReaderViewControllerDelegate, UIScrollViewDelegate, MPMediaPickerControllerDelegate, UIAlertViewDelegate>{
    //objects
    NetworkData *network;
    DownloadFile *downloadFile;
    
    //global views
    UIImageView *topBanner, *logo;
    UIView *customNavBar, *mainView, *sideBar;
    UIButton *navBarHomeButton, *backButton, *videoButton;

    //sidebar views
    UIButton *overview, *videos, *productSpec, *whitePaper, *caseStudy, *prePostSolutionButton;
    UIImageView *sidebarIndicator, *overViewIcon, *whitePaperIcon;
    UIImageView *caseStudyIcon, *videoIcon, *productSpecIcon, *prePostSolutionImage;
    UILabel *overviewLabel, *caseStudyLabel, *videoLabel, *productSpecLabel, *whitePaperLabel, *prePostSolutionLabel;
    
    //main area views
    UIImageView *mainShortBanner, *actualDocumentBanner;
    UIView *overviewContainer, *documentContainer, *actualDocumentView;
    UIScrollView *overviewImages;
    UIPageControl *overviewImageDots;
    UIScrollView *overviewContent, *documentScroll;
    UIWebView *webPage;
    UILabel *documentLabel, *bannerTitle;
    UIButton *documentHeaderButton;
    
    
    //global data
    NSMutableDictionary *currentDocumentData;
    NSMutableDictionary *offlineImages;
    NSMutableDictionary *offlineVideos;
    NSMutableArray *offlineVideoRows, *potentailPartners;
    NSString *downloadingURL;
    BOOL decodedSolutions;

}
@property(nonatomic)NetworkData *network;
@property(nonatomic, readonly)CanonModel *model;
@property(nonatomic, strong)UIButton *navBarHomeButton, *videoButton;
@property(nonatomic, strong)UIView *customNavBar, *mainView, *sideBar;
@property(nonatomic, strong)NSMutableDictionary *offlineImages;


@end
