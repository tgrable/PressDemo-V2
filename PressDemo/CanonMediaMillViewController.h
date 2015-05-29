//
//  CanonMediaMillViewController.h
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
#import <MediaPlayer/MediaPlayer.h>
#import "GAITrackedViewController.h"
#import "UMTableView.h"
#import "DownloadFile.h"
#import "CanonTableKeyViewController.h"
#import "UIBorderLabel.h"
#import "CanonViewController.h"
#import <MessageUI/MessageUI.h>

@interface CanonMediaMillViewController : GAITrackedViewController<NetworkDelegate, FileDelegate, UMTableViewDelegate, UIPopoverControllerDelegate, UIScrollViewDelegate, MPMediaPickerControllerDelegate, UIAlertViewDelegate, UIPrintInteractionControllerDelegate, MFMailComposeViewControllerDelegate>{
    //objects
    NetworkData *network;
    DownloadFile *downloadFile;
    
    //global views
    UIImageView *topBanner, *logo, *impressLogo;
    UIView *customNavBar, *mainView, *sideBar;
    UIButton *navBarHomeButton, *backButton, *videoButton, *shareButton;
    
    //sidebar views
    UIButton *overview, *videos, *mediaPapers, *allMills;
    UIImageView *sidebarIndicator, *overViewIcon, *mediaPapersIcon;
    UIImageView *allMillsIcon, *videoIcon;
    UILabel *overviewLabel, *mediaPapersLabel, *videoLabel, *allMillsLabel;
    
    //main area views
    UIImageView *mainShortBanner, *actualDocumentBanner, *millLogo;
    UIView *overviewContainer, *documentContainer, *tableBackground, *tableHeaderRow, *overlay, *globalModal;
    UIScrollView *overviewImages, *documentScroll, *overviewContent;
    UIPageControl *overviewImageDots;
    UITextView *millDescription;
    UILabel *documentLabel, *millNameHeader, *millNameOverview, *millPhone, *millAddress, *tableHeader;
    UIBorderLabel *cell0, *cell1, *cell2, *cell3, *cell4, *cell5, *cell6, *cell7;
    UIButton *documentHeaderButton, *urlMill, *tableKey;
    UMTableView *tableView;
    
    //global data
    NSMutableDictionary *currentDocumentData;
    NSMutableDictionary *offlineImages;
    NSMutableDictionary *offlineVideos;
    NSMutableArray *offlineVideoRows;
    NSMutableArray *rowHeadersPaper, *rowHeadersMill, *paperData, *allPaperData, *headerLabelsPaper, *headerLabelsMill, *iconArray;
    NSString *downloadingURL, *websiteKey;
    BOOL paperTable, tableEmpty, modalViewPresent;
    int tableRows, tableColumns, emailStep;
    float contentHeight;
    
    /* No Internet View/Label */
    UIView *noConnection;
    UILabel *noConnectionLabel;
    
}
@property(nonatomic)NetworkData *network;
@property(nonatomic)CanonTableKeyViewController *popView;
@property(nonatomic, readonly)CanonModel *model;
@property(nonatomic, strong)UIButton *navBarHomeButton, *videoButton;
@property(nonatomic, strong)UIView *customNavBar, *mainView, *sideBar;
@property(nonatomic, strong)NSMutableDictionary *offlineImages;
@property(nonatomic, strong)UIPopoverController *pop;
@property float contentHeight;


@end
