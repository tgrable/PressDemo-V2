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
#import "CanonTableKeyViewController.h"

@interface CanonMediaMillViewController : GAITrackedViewController<NetworkDelegate, UMTableViewDelegate, UIPopoverControllerDelegate, UIScrollViewDelegate, MPMediaPickerControllerDelegate, UIAlertViewDelegate>{
    //objects
    NetworkData *network;
    
    //global views
    UIImageView *topBanner, *logo;
    UIView *customNavBar, *mainView, *sideBar;
    UIButton *navBarHomeButton, *backButton, *videoButton;
    
    //sidebar views
    UIButton *overview, *videos, *mediaPapers, *allMills;
    UIImageView *sidebarIndicator, *overViewIcon, *mediaPapersIcon;
    UIImageView *allMillsIcon, *videoIcon;
    UILabel *overviewLabel, *mediaPapersLabel, *videoLabel, *allMillsLabel;
    
    //main area views
    UIImageView *mainShortBanner, *actualDocumentBanner, *millLogo;
    UIView *overviewContainer, *documentContainer, *tableBackground, *tableHeaderRow, *overlay, *globalModal;
    UIScrollView *overviewImages, *documentScroll;
    UIPageControl *overviewImageDots;
    UITextView *millDescription;
    UILabel *documentLabel, *millNameHeader, *millNameOverview, *millPhone, *millAddress, *tableHeader;
    UILabel *cell0, *cell1, *cell2, *cell3, *cell4, *cell5, *cell6, *cell7, *cell8;
    UIButton *documentHeaderButton, *urlMill, *tableKey;
    UMTableView *tableView;
    
    //global data
    NSMutableDictionary *currentDocumentData;
    NSMutableDictionary *offlineImages;
    NSMutableDictionary *offlineVideos;
    NSMutableArray *offlineVideoRows;
    NSMutableArray *rowHeadersPaper, *rowHeadersMill, *paperData, *allPaperData, *headerLabelsPaper, *headerLabelsMill;
    NSString *downloadingURL, *websiteKey;
    BOOL paperTable, tableEmpty;
    int tableRows, tableColumns;
    
    
}
@property(nonatomic)NetworkData *network;
@property(nonatomic)CanonTableKeyViewController *popView;
@property(nonatomic, readonly)CanonModel *model;
@property(nonatomic, strong)UIButton *navBarHomeButton, *videoButton;
@property(nonatomic, strong)UIView *customNavBar, *mainView, *sideBar;
@property(nonatomic, strong)NSMutableDictionary *offlineImages;
@property(nonatomic, strong)UIPopoverController *pop;

-(void)displayMessage:(NSString *)message withTitle:(NSString *)title;
-(void)setupLocalUserInterface:(completeBlock)completeFlag;
-(void)animateSidebarIndicator:(int)yValue;
-(void)tearDownAndLoadUpDocuments:(NSString *)flag withComplete:(completeBlock)completeFlag;
-(void)rearrangeDocumentStack;
-(void)buildPaperTableData;
-(void)setupTableHeaders;
-(void)hideOverlay;
-(UIView *)assembleModalView:(Paper *)obj;
- (CGFloat)widthOfString:(NSString *)string;
@end
