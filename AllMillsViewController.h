//
//  AllMillsViewController.h
//  PressDemo
//
//  Created by Justin Davis on 3/7/16.
//  Copyright © 2016 Trekk. All rights reserved.
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
#import "CanonMediaMillSearchOverlay.h"
#import "ActionSheetPicker.h"
#import "ProductScroll.h"

@interface AllMillsViewController : GAITrackedViewController<NetworkDelegate, FileDelegate, UMTableViewDelegate, SearchOverlayDelegate, UIPopoverControllerDelegate, UIScrollViewDelegate, MPMediaPickerControllerDelegate, UIAlertViewDelegate, UIPrintInteractionControllerDelegate, MFMailComposeViewControllerDelegate, PopOverviewDelegate>{
    
    //local views
    UIImageView *logo, *impressLogo;
    /* No Internet View/Label */
    UIView *noConnection;
    UILabel *noConnectionLabel;
    
    NetworkData *network;
    ActionSheetPicker *action;
    
    UIButton *navBarHomeButton, *backButton, *videoButton, *shareButton;
    
    int tableRows, tableColumns, emailStep, searchRowIndex;
    
    
    UMTableView *tableView;
    
    UIView *overviewContainer, *documentContainer, *tableBackground, *tableHeaderRow, *overlay, *globalModal, *emailTableContainer, *loadingView;
    
    UILabel *documentLabel, *millNameHeader, *millNameOverview, *millPhone, *millAddress, *tableHeader, *noTableInfo;
    
    UIButton *documentHeaderButton, *urlMill, *tableKey, *searchButton, *resetTable;
    
    CanonMediaMillSearchOverlay *searchView;
    
    NSMutableArray *rowHeadersPaper, *rowHeadersMill, *paperData, *headerLabelsPaper, *headerLabelsMill, *iconArray;
    
    float contentHeight;
    
    
    BOOL paperTable, tableEmpty, modalViewPresent;
    
    UIBorderLabel *cell0, *cell1, *cell2, *cell3, *cell4, *cell5, *cell6, *cell7;
    
    NSString *downloadingURL, *websiteKey;
    
}

@property(nonatomic)NetworkData *network;
@property(nonatomic, readonly)CanonModel *model;
@property(nonatomic, strong)UIImageView *topBanner;
@property(nonatomic, strong)UIView *customNavBar, *mainView;
@property(nonatomic, strong)ProductScroll *productScroll;
@property float contentHeight;
@property(nonatomic)CanonTableKeyViewController *popView;
@property(nonatomic, strong)UIPopoverController *pop, *searchField;
@property(nonatomic)ActionSheetPicker *action;

@end
