//
//  CanonMediaMillViewController.m
//  PressDemo
//
//  Created by Trekk mini-1 on 12/10/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "CanonMediaMillViewController.h"
#import "UIImageView+WebCache.h"
#import "UIButton+Extensions.h"
#import "LegalViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SearchablePaper.h"

#define ResourcePath(path)[[NSBundle mainBundle] pathForResource:path ofType:nil]

#define ImageWithPath(path)[UIImage imageWithContentsOfFile:path]
#define kMaxHeight 1000.0f

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)


@implementation CanonMediaMillViewController
@synthesize customNavBar, sideBar, mainView, videoButton, searchView;
@synthesize model, network, navBarHomeButton, offlineImages, pop, popView, contentHeight, action, searchField;

//Here we are setting up the delegate method
- (CanonModel *) AppDataObj;
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    CanonModel * modelObject;
    modelObject = (CanonModel*) theDelegate.AppDataObj;
    
    return modelObject;
}

/*-----------------------------------------------------
 
 Function to register all the global notifications
 -(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 
 -------------------------------------------------------*/
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
    }
    return self;
}

/*-----------------------------------------------------
 
 Function to dispense the reachability notifications
 -(void)reachabilityDidChange:(NSNotification *)notification
 
 -------------------------------------------------------*/
- (void)reachabilityDidChange:(NSNotification *)notification {
    //reachability object
    Reachability *reachability = (Reachability *)[notification object];
    //if we can reach the internet
    if ([reachability isReachable]) {
        ALog(@"REACHABLE");
        
    } else {
        //set UI error
        ALog(@"NOT REACHABLE");
    }
}

/*-----------------------------------------------------
 
 Functions to control when the app comes in and out of focus
 -(void)appWentIntoBackground
 -(void)appCameBackIntoFocus
 
 -------------------------------------------------------*/

/* suppress anything that should be killed when app moves to the background */
-(void)appWentIntoBackground
{
    ALog(@"App went into the background");
    //kill anything that is running here
}

/* decided if the app needs to be loaded up again when it comes back to focus */
-(void)appCameBackIntoFocus
{
    //start the update check here
    ALog(@"App came back into focus");
    
    //if we can reach the internet
    ALog(@"Reachable %@", model.hostReachability);
    if ([model.hostReachability isReachable]) {
        ALog(@"APP came back into focus and it is reachable");
        noConnection.alpha = 0.0;
        //check for the app on a background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [network checkForUpdate];
        });
        
        //resync the UI
        if(!model.layoutSync){
            //sync all images while the user was offline
            if([offlineImages count] > 0){
                for (id key in offlineImages) {
                    //grab the image view
                    UIImageView *i = [offlineImages objectForKey:key];
                    //check to see what type of image we are replacing
                    if(i.frame.size.width < 776)
                        [i sd_setImageWithURL:key placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
                    else
                        [i sd_setImageWithURL:key placeholderImage:[UIImage imageNamed:@"overviewPlaceholder.png"]];
                }
                [offlineImages removeAllObjects];
                
            }
            model.layoutSync = YES;
        }
        
        //make sure we display all the videos when we are back online
        //make sure we remove all of the offline videos
        //TODO, think about removing this variable
        if([offlineVideos count] > 0){
            [offlineVideos removeAllObjects];
        }
        for(UIView *v in [documentScroll subviews]){
            v.alpha = 1.0;
        }
        
    }else{
        //we are on videos
        if(sidebarIndicator.frame.origin.y == 96){
            //disable videos while offline
            for(UIView *v in offlineVideoRows){
                UIButton *b = (UIButton *)[v viewWithTag:777];
                //if there is a subview with the 777 tag, then we know that this row is saved to the device
                if(b == nil){
                    v.alpha = 0.6;
                }
                
            }
        }
        noConnection.alpha = 1.0;
        [model logData:@"CanonMediaMillViewController" withAction:@"No Internet Connection" withLabel:@"Came back into focus with no connection"];
    }
    
}

/*-----------------------------------------------------
 
 Functions that control the view load and unloading lifecycle
 - (void)viewWillAppear:(BOOL)animated
 - (void)viewDidAppear:(BOOL)animated
 - (void)viewWillDisappear:(BOOL)animated
 - (void)viewDidDisappear:(BOOL)animated
 - (void)viewDidLoad
 -------------------------------------------------------*/

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([model.hostReachability isReachableViaWiFi]) {
        noConnection.alpha = 0.0;
    }else{
        noConnection.alpha = 1.0;
        [model logData:@"CanonMediaMillViewController" withAction:@"No Internet Connection" withLabel:@"Running the app with no internet"];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //app going into background notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWentIntoBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    //set observation notification on completion
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appCameBackIntoFocus) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Mill View";
    
    network = [[NetworkData alloc] init];
    network.delegate = self;
    
    model = [self AppDataObj];
    
    downloadFile = [[DownloadFile alloc] init];
    downloadFile.delegate = self;
    
    searchView = [[CanonMediaMillSearchOverlay alloc] init];
    searchView.delegate = self;

    
    //***** Load up views to the local view controller ************//
    //the nav bar
    customNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 1024, 64)];
    [customNavBar setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:customNavBar];
    
    noConnection = [[UIView alloc] initWithFrame:CGRectMake(36, -17, 134, 15)];
    noConnection.alpha = 0.0;
    noConnection.backgroundColor = model.blue;
    [customNavBar addSubview:noConnection];
    
    noConnectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 3, 132, 11)];
    noConnectionLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:10.0];
    noConnectionLabel.text = @"NO INTERNET CONNECTION";
    noConnectionLabel.textColor = [UIColor whiteColor];
    noConnectionLabel.backgroundColor = [UIColor clearColor];
    [noConnection addSubview:noConnectionLabel];
    
    logo = [[UIImageView alloc] initWithFrame:CGRectMake(891, 1, 97, 62)];
    [logo setUserInteractionEnabled:YES];
    [logo setImage:[UIImage imageNamed:@"csa-logo.png"]];
    [customNavBar addSubview:logo];
    
    backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(36, 9, 105, 44)];
    [backButton addTarget:self action:@selector(triggerBack:)forControlEvents:UIControlEventTouchDown];
    backButton.showsTouchWhenHighlighted = YES;
    backButton.tag = 20;
    [customNavBar addSubview:backButton];
    
    navBarHomeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navBarHomeButton setFrame:CGRectMake(177, 14, 35, 35)];
    [navBarHomeButton addTarget:self action:@selector(triggerHome:)forControlEvents:UIControlEventTouchDown];
    navBarHomeButton.showsTouchWhenHighlighted = YES;
    navBarHomeButton.tag = 20;
    [customNavBar addSubview:navBarHomeButton];
     
    
    mainView = [[UIView alloc] initWithFrame:CGRectMake(248, 84, 776, 684)];
    mainView.backgroundColor = model.dullBlack;
    mainView.userInteractionEnabled = YES;
    [self.view addSubview:mainView];
    
    //########### Table Setup ####################################
    
    tableBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 884, 776, 684)];
    tableBackground.backgroundColor = [UIColor whiteColor];
    tableBackground.userInteractionEnabled = YES;
    [mainView addSubview:tableBackground];
    
    tableHeader = [[UILabel alloc] initWithFrame:CGRectMake(44, 56, 400, 40)];
    [tableHeader setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:18.0]];
    tableHeader.textColor = model.dullBlack;
    tableHeader.text = @"SELECT A PAPER FOR DETAILED SPECIFICATIONS";
    tableHeader.numberOfLines = 1;
    tableHeader.backgroundColor = [UIColor clearColor];
    [tableBackground addSubview:tableHeader];
    
    tableKey = [UIButton buttonWithType:UIButtonTypeCustom];
    [tableKey setFrame:CGRectMake(690, 56, 33, 33)];
    [tableKey addTarget:self action:@selector(tableKeySelected:)forControlEvents:UIControlEventTouchDown];
    tableKey.showsTouchWhenHighlighted = YES;
    [tableKey setBackgroundImage:[model getImageWithName:@"/icn-key@2x.png"] forState:UIControlStateNormal];
    tableKey.backgroundColor = [UIColor clearColor];
    [tableBackground addSubview:tableKey];
    
    searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchButton setFrame:CGRectMake(580, 56, 80, 33)];
    [searchButton addTarget:self action:@selector(searchTable:)forControlEvents:UIControlEventTouchDown];
    searchButton.showsTouchWhenHighlighted = YES;
    [searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [searchButton setBackgroundColor:model.blue];
    searchButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [searchButton setTitle:@"Filter" forState:UIControlStateNormal];
    [searchButton.titleLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
    [tableBackground addSubview:searchButton];
    
    resetTable = [UIButton buttonWithType:UIButtonTypeCustom];
    [resetTable setFrame:CGRectMake(490, 56, 80, 33)];
    [resetTable addTarget:self action:@selector(resetTable:)forControlEvents:UIControlEventTouchDown];
    resetTable.showsTouchWhenHighlighted = YES;
    resetTable.titleLabel.textAlignment = NSTextAlignmentCenter;
    [resetTable setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [resetTable setBackgroundColor:[UIColor blackColor]];
    [resetTable setTitle:@"Reset" forState:UIControlStateNormal];
    [resetTable.titleLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
    [resetTable setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [tableBackground addSubview:resetTable];
    
    //cell0, *cell1, *cell2, *cell3, *cell4, *cell5, *cell6, *cell7
    tableHeaderRow = [[UIView alloc] initWithFrame:CGRectMake(20, 110, 736, 50)];
    tableHeaderRow.userInteractionEnabled = YES;
    tableHeaderRow.backgroundColor = [UIColor blackColor];
    [tableBackground addSubview:tableHeaderRow];
    
    //create an array to add the header lables to for future editing
    headerLabelsPaper = [NSMutableArray array];
    headerLabelsMill = [NSMutableArray array];
    
    
    cell0 =  [[UIBorderLabel alloc] initWithFrame:CGRectMake(8, 0, 104, 50)];
    cell0.font = [UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:12.0];
    cell0.textColor = [UIColor whiteColor];
    cell0.numberOfLines = 2;
    cell0.textAlignment = NSTextAlignmentLeft;
    cell0.backgroundColor = model.pink;
    cell0.leftInset = 8;
    [tableHeaderRow addSubview:cell0];
    [headerLabelsPaper addObject:cell0];
    [headerLabelsMill addObject:cell0];
    
    cell1 =  [[UIBorderLabel alloc] initWithFrame:CGRectMake(120, 0, 88, 50)];
    cell1.font = [UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:12.0];
    cell1.textColor = [UIColor whiteColor];
    cell1.numberOfLines = 2;
    cell1.textAlignment = NSTextAlignmentLeft;
    cell1.leftInset = 8;
    cell1.backgroundColor = [UIColor blackColor];
    [tableHeaderRow addSubview:cell1];
    [headerLabelsPaper addObject:cell1];
    [headerLabelsMill addObject:cell1];
    
    cell2 =  [[UIBorderLabel alloc] initWithFrame:CGRectMake(208, 0, 88, 50)];
    cell2.font = [UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:12.0];
    cell2.textColor = [UIColor whiteColor];
    cell2.numberOfLines = 2;
    cell2.textAlignment = NSTextAlignmentLeft;
    cell2.backgroundColor = [UIColor blackColor];
    cell2.leftInset = 8;
    [tableHeaderRow addSubview:cell2];
    [headerLabelsPaper addObject:cell2];
    [headerLabelsMill addObject:cell2];
    
    cell3 =  [[UIBorderLabel alloc] initWithFrame:CGRectMake(296, 0, 88, 50)];
    cell3.font = [UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:12.0];
    cell3.textColor = [UIColor whiteColor];
    cell3.numberOfLines = 2;
    cell3.textAlignment = NSTextAlignmentLeft;
    cell3.leftInset = 8;
    cell3.backgroundColor = [UIColor blackColor];
    [tableHeaderRow addSubview:cell3];
    [headerLabelsPaper addObject:cell3];
    [headerLabelsMill addObject:cell3];
    
    cell4 =  [[UIBorderLabel alloc] initWithFrame:CGRectMake(384, 0, 88, 50)];
    cell4.font = [UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:12.0];
    cell4.textColor = [UIColor whiteColor];
    cell4.numberOfLines = 2;
    cell4.textAlignment = NSTextAlignmentLeft;
    cell4.leftInset = 8;
    cell4.backgroundColor = [UIColor blackColor];
    [tableHeaderRow addSubview:cell4];
    [headerLabelsPaper addObject:cell4];
    [headerLabelsMill addObject:cell4];
    
    cell5 =  [[UIBorderLabel alloc] initWithFrame:CGRectMake(472, 0, 88, 50)];
    cell5.font = [UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:12.0];
    cell5.textColor = [UIColor whiteColor];
    cell5.numberOfLines = 2;
    cell5.textAlignment = NSTextAlignmentLeft;
    cell5.backgroundColor = [UIColor blackColor];
    cell5.leftInset = 8;
    [tableHeaderRow addSubview:cell5];
    [headerLabelsPaper addObject:cell5];
    [headerLabelsMill addObject:cell5];
    
    cell6 =  [[UIBorderLabel alloc] initWithFrame:CGRectMake(560, 0, 88, 50)];
    cell6.font = [UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:12.0];
    cell6.textColor = [UIColor whiteColor];
    cell6.numberOfLines = 2;
    cell6.textAlignment = NSTextAlignmentLeft;
    cell6.backgroundColor = [UIColor blackColor];
    cell6.leftInset = 8;
    [tableHeaderRow addSubview:cell6];
    [headerLabelsPaper addObject:cell6];
    [headerLabelsMill addObject:cell6];
    
    cell7 =  [[UIBorderLabel alloc] initWithFrame:CGRectMake(648, 0, 88, 50)];
    cell7.font = [UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:12.0];
    cell7.textColor = [UIColor whiteColor];
    cell7.numberOfLines = 2;
    cell7.textAlignment = NSTextAlignmentLeft;
    cell7.backgroundColor = [UIColor blackColor];
    cell7.leftInset = 8;
    [tableHeaderRow addSubview:cell7];
    [headerLabelsPaper addObject:cell7];
    [headerLabelsMill addObject:cell7];
    
    
    
    UILabel *notice = [[UILabel alloc] initWithFrame:CGRectMake(20, 530, 736, 50)];
    [notice setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:12.0]];
    notice.textColor = model.dullBlack;
    notice.text = @"NOTE: All papers on this list are available in the use either from the mill directly or through distribution. Some papers may require a minimum order from the mill. Availability can and will change based on supply and demand for papers, contact your mill or distributor for the most up to date availablility. Many mills will have stocking levels incicated on their web sites with the most up to date information. Follow the links provided to access mill web sites.";
    notice.numberOfLines = 4;
    notice.backgroundColor = [UIColor clearColor];
    
    UILabel *noticeTwo = [[UILabel alloc] initWithFrame:CGRectMake(20, 600, 736, 50)];
    [noticeTwo setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:12.0]];
    noticeTwo.textColor = model.blue;
    noticeTwo.text = @"The papers listed in this document have been evaluated on Canon Solutions America and Oce production printing equipment. Canon Solutions America does not guarantee the performance or availability of any papers listed. Results may vary.This list is only to be used as a guide for selecting papers for further testing in specific applications. For more information consult your local sales represenitive It is recommended that a paper trial including linerization of the trial.";
    noticeTwo.numberOfLines = 4;
    noticeTwo.backgroundColor = [UIColor clearColor];
    
    noTableInfo = [[UILabel alloc] initWithFrame:CGRectMake(20, 220, 736, 50)];
    [noTableInfo setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:18.0]];
    noTableInfo.textColor = model.dullBlack;
    noTableInfo.text = @"- NO RESULTS FOUND -";
    noTableInfo.textAlignment = NSTextAlignmentCenter;
    noTableInfo.backgroundColor = [UIColor clearColor];
    noTableInfo.alpha = 0.0;
    [tableBackground addSubview:noTableInfo];
    
    
    //########### Video Setup ####################################
    documentContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 776, 684)];
    [mainView addSubview:documentContainer];
    
    documentScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(14, 44, 748, 628)];
    documentScroll.showsHorizontalScrollIndicator = NO;
    documentScroll.showsVerticalScrollIndicator = YES;
    documentScroll.scrollEnabled = YES;
    documentScroll.delegate = self;
    documentScroll.backgroundColor = model.dullBlack;
    [documentContainer addSubview:documentScroll];
    
    
    //########### Overview Setup ####################################
    overviewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 776, 684)];
    overviewContainer.backgroundColor = [UIColor whiteColor];
    [mainView addSubview:overviewContainer];
    
    overviewImages = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 44, 776, 264)];
    overviewImages.showsHorizontalScrollIndicator = NO;
    overviewImages.showsVerticalScrollIndicator = NO;
    overviewImages.pagingEnabled = YES;
    overviewImages.scrollEnabled = YES;
    overviewImages.delegate = self;
    overviewImages.backgroundColor = model.dullBlack;
    [overviewContainer addSubview:overviewImages];
    
    overviewImageDots = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 285, 776, 15)];
    overviewImageDots.currentPage = 0;
    overviewImageDots.backgroundColor = [UIColor clearColor];
    overviewImageDots.pageIndicatorTintColor = model.dullBlack;
    overviewImageDots.currentPageIndicatorTintColor = model.blue;
    [mainView addSubview:overviewImageDots];
    
    UIView *borderBelowImageSlider = [[UIView alloc] initWithFrame:CGRectMake(0, 306, 776, 1)];
    borderBelowImageSlider.backgroundColor = [UIColor colorWithRed:251.0f/255.0f green:251.0f/255.0f blue:251.0f/255.0f alpha:1.0];
    [overviewContainer addSubview:borderBelowImageSlider];
    
    
    //banner that sits on top of the overview slide.  this is th pink bar
    mainShortBanner = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 776, 64)];
    [mainShortBanner setUserInteractionEnabled:YES];
    [mainView addSubview:mainShortBanner];
    
    //name of the mill
    millNameHeader = [[UILabel alloc] initWithFrame:CGRectMake(44, 9, 601, 32)];
    [millNameHeader setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:26.0]];
    millNameHeader.textColor = [UIColor whiteColor];
    millNameHeader.numberOfLines = 1;
    millNameHeader.adjustsFontSizeToFitWidth = YES;
    millNameHeader.backgroundColor = [UIColor clearColor];
    [mainShortBanner addSubview:millNameHeader];
    
    shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setFrame:CGRectMake(662, 5, 32, 32)];
    [shareButton addTarget:self action:@selector(shareView:)forControlEvents:UIControlEventTouchDown];
    [shareButton setBackgroundImage:[UIImage imageNamed:@"ico-share.png"] forState:UIControlStateNormal];
    shareButton.showsTouchWhenHighlighted = YES;
    shareButton.tag = 20;
    [mainShortBanner addSubview:shareButton];
    
    
    overviewContent = [[UIScrollView alloc] initWithFrame:CGRectMake(36, 342, 712, 342)];
    overviewContent.showsHorizontalScrollIndicator = NO;
    overviewContent.showsVerticalScrollIndicator = YES;
    overviewContent.scrollEnabled = YES;
    overviewContent.delegate = self;
    overviewContent.backgroundColor = [UIColor clearColor];
    [overviewContainer addSubview:overviewContent];
    
    //logo of the mill in the overview container
    millLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    millLogo.contentMode = UIViewContentModeScaleAspectFit;
    millLogo.userInteractionEnabled = YES;
    [overviewContent addSubview:millLogo];
    
    //name of the mill next to the logo in the overview container
    millNameOverview = [[UILabel alloc] initWithFrame:CGRectMake(140, 16, 564, 32)];
    [millNameOverview setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:22.0]];
    millNameOverview.textColor = model.dullBlack;
    millNameOverview.numberOfLines = 1;
    millNameOverview.backgroundColor = [UIColor clearColor];
    [overviewContent addSubview:millNameOverview];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(140, 52, 557, 1)];
    line.backgroundColor = model.dullBlack;
    [overviewContent addSubview:line];
    
    millPhone = [[UILabel alloc] initWithFrame:CGRectMake(140, 66, 400, 20)];
    [millPhone setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
    millPhone.textColor = model.dullBlack;
    millPhone.numberOfLines = 1;
    millPhone.backgroundColor = [UIColor clearColor];
    [overviewContent addSubview:millPhone];
    
    millAddress = [[UILabel alloc] initWithFrame:CGRectMake(140, 90, 564, 50)];
    [millAddress setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
    millAddress.textColor = model.dullBlack;
    millAddress.numberOfLines = 3;
    millAddress.backgroundColor = [UIColor clearColor];
    [overviewContent addSubview:millAddress];
    
    millDescription = [[UITextView alloc] initWithFrame:CGRectMake(0, 150, 697, 182)];
    millDescription.editable = NO;
    millDescription.clipsToBounds = YES;
    millDescription.font = [UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0];
    millDescription.backgroundColor = [UIColor clearColor];
    millDescription.scrollEnabled = NO;
    millDescription.textColor = model.dullBlack;
    [overviewContent addSubview:millDescription];
    
    urlMill = [UIButton buttonWithType:UIButtonTypeCustom];
    [urlMill setFrame:CGRectMake(379, 66, 305, 20)];
    [urlMill addTarget:self action:@selector(urlSelected:)forControlEvents:UIControlEventTouchDown];
    urlMill.showsTouchWhenHighlighted = YES;
    urlMill.titleLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0];
    [urlMill setTitleColor:model.dullBlack forState:UIControlStateNormal];
    urlMill.backgroundColor = [UIColor clearColor];
    urlMill.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [overviewContent addSubview:urlMill];
    
    
    //########### ALL Sidebar Views ##############################
    //sidebar setup
    sideBar = [[UIView alloc] initWithFrame:CGRectMake(0, 84, 248, 684)];
    sideBar.backgroundColor = [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0];
    sideBar.layer.shadowColor = [UIColor blackColor].CGColor;
    sideBar.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
    sideBar.layer.shadowOpacity = 0.7f;
    sideBar.layer.shadowRadius = 2.0f;
    sideBar.layer.shadowPath = [UIBezierPath bezierPathWithRect:sideBar.bounds].CGPath;
    [self.view addSubview:sideBar];
    
    UIView *hideShadow = [[UIView alloc] initWithFrame:CGRectMake(0, -4, 248, 4)];
    hideShadow.backgroundColor = [UIColor whiteColor];
    [sideBar addSubview:hideShadow];
    
    sidebarIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 35, 35)];
    [sidebarIndicator setUserInteractionEnabled:YES];
    [sidebarIndicator setImage:[UIImage imageNamed:@"icn-selected.png"]];
    [sideBar addSubview:sidebarIndicator];
    
    //overview button
    overview = [UIButton buttonWithType:UIButtonTypeCustom];
    [overview setFrame:CGRectMake(36, 30, 178, 36)];
    [overview addTarget:self action:@selector(loadUpMainTray:)forControlEvents:UIControlEventTouchDown];
    overview.showsTouchWhenHighlighted = YES;
    overview.titleLabel.text = @"overview";
    overview.tag = 30;
    overview.backgroundColor = [UIColor clearColor];
    [sideBar addSubview:overview];
    
    overViewIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [overViewIcon setImage:[UIImage imageNamed:@"icn-overview.png"]];
    [overview addSubview:overViewIcon];
    
    overviewLabel = [[UILabel alloc] initWithFrame:CGRectMake(53, 0, 125, 36)];
    [overviewLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
    overviewLabel.textColor = model.dullBlack;
    overviewLabel.numberOfLines = 2;
    overviewLabel.backgroundColor = [UIColor clearColor];
    overviewLabel.text = @"OVERVIEW";
    [overview addSubview:overviewLabel];
    
    //video button
    videos = [UIButton buttonWithType:UIButtonTypeCustom];
    [videos setFrame:CGRectMake(36, 96, 178, 36)];
    [videos addTarget:self action:@selector(loadUpMainTray:)forControlEvents:UIControlEventTouchDown];
    videos.showsTouchWhenHighlighted = YES;
    videos.titleLabel.text = @"videos";
    videos.tag = 96;
    videos.backgroundColor = [UIColor clearColor];
    [sideBar addSubview:videos];
    
    videoIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [videoIcon setImage:[UIImage imageNamed:@"icn-video.png"]];
    [videos addSubview:videoIcon];
    
    videoLabel = [[UILabel alloc] initWithFrame:CGRectMake(53, 0, 125, 36)];
    [videoLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
    videoLabel.textColor = model.dullBlack;
    videoLabel.numberOfLines = 2;
    videoLabel.backgroundColor = [UIColor clearColor];
    videoLabel.text = @"VIDEO";
    [videos addSubview:videoLabel];
    
    //papers button
    mediaPapers = [UIButton buttonWithType:UIButtonTypeCustom];
    [mediaPapers setFrame:CGRectMake(36, 162, 178, 36)];
    [mediaPapers addTarget:self action:@selector(loadUpMainTray:)forControlEvents:UIControlEventTouchDown];
    mediaPapers.showsTouchWhenHighlighted = YES;
    mediaPapers.tag = 162;
    mediaPapers.titleLabel.text = @"papers";
    mediaPapers.backgroundColor = [UIColor clearColor];
    [sideBar addSubview:mediaPapers];
    
    mediaPapersIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [mediaPapersIcon setImage:[model getImageWithName:@"/icn-mill@2x-2.png"]];
    [mediaPapers addSubview:mediaPapersIcon];
    
    mediaPapersLabel = [[UILabel alloc] initWithFrame:CGRectMake(53, 0, 125, 36)];
    [mediaPapersLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
    mediaPapersLabel.textColor = model.dullBlack;
    mediaPapersLabel.numberOfLines = 2;
    mediaPapersLabel.backgroundColor = [UIColor clearColor];
    mediaPapersLabel.text = @"MEDIA/PAPERS";
    [mediaPapers addSubview:mediaPapersLabel];
    
    //all mills button
    allMills = [UIButton buttonWithType:UIButtonTypeCustom];
    [allMills setFrame:CGRectMake(36, 228, 178, 36)];
    [allMills addTarget:self action:@selector(loadUpMainTray:)forControlEvents:UIControlEventTouchDown];
    allMills.showsTouchWhenHighlighted = YES;
    allMills.tag = 228;
    allMills.titleLabel.text = @"key";
    allMills.backgroundColor = [UIColor clearColor];
    [sideBar addSubview:allMills];
    
    allMillsIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [allMillsIcon setImage:[UIImage imageNamed:@"icn-mill-all@2x-2.png"]];
    [allMills addSubview:allMillsIcon];
    
    allMillsLabel = [[UILabel alloc] initWithFrame:CGRectMake(53, 0, 105, 36)];
    [allMillsLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
    allMillsLabel.textColor = model.dullBlack;
    allMillsLabel.numberOfLines = 2;
    allMillsLabel.backgroundColor = [UIColor clearColor];
    allMillsLabel.text = @"ALL MILLS MEDIA LIST";
    [allMills addSubview:allMillsLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(overlayTapped:)];
    
    overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    overlay.backgroundColor = [UIColor blackColor];
    overlay.alpha = 0.0;
    [overlay addGestureRecognizer:tapGesture];
    overlay.userInteractionEnabled = YES;
    [self.view addSubview:overlay];
    
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(462, 334, 100, 100)];
    [loadingView setBackgroundColor:[UIColor blackColor]];
    loadingView.layer.cornerRadius = 5;
    loadingView.layer.masksToBounds = YES;
    loadingView.alpha = 0.0;
    [self.view addSubview:loadingView];
    
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 767, 1024, 1)];
    [bottomView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:bottomView];
    
    activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake(32.0, 32.0, 35.0, 35.0);
    [activityIndicator setColor:[UIColor whiteColor]];
    [activityIndicator startAnimating];
    [loadingView addSubview:activityIndicator];
    
    popView = [[CanonTableKeyViewController alloc] initWithNibName:@"CanonTableKeyViewController" bundle:nil];
    currentDocumentData = [[NSMutableDictionary alloc] init];
    offlineImages = [[NSMutableDictionary alloc] init];
    offlineVideos = [[NSMutableDictionary alloc] init];
    offlineVideoRows = [NSMutableArray array];
    paperData = [NSMutableArray array];
    rowHeadersPaper = [NSMutableArray arrayWithObjects:[model.selectedMill.title uppercaseString], @"BASIS WEIGHT", @"BRIGHTNESS", @"COATING", @"COLOR", @"CAPABILITY", @"INKSET", nil];
    rowHeadersMill = [NSMutableArray arrayWithObjects:@"MILL NAME", @"MEDIA NAME", @"BASIS WEIGHT", @"BRIGHTNESS", @"COATING", @"COLOR", @"CAPABILITY", @"INKSET", nil];
    
    iconArray = [NSMutableArray array];
    [iconArray addObject:[UIImage imageNamed:@"ico-blackwhite.png"]];
    [iconArray addObject:[UIImage imageNamed:@"ico-color.png"]];
    [iconArray addObject:[UIImage imageNamed:@"ico-color.png"]];
    [iconArray addObject:[UIImage imageNamed:@"ico-color.png"]];
    [iconArray addObject:[UIImage imageNamed:@"ico-color.png"]];
    
    paperTable = YES;
    tableEmpty = NO;
    modalViewPresent = NO;
    tableRows = 0;
    tableColumns = 0;
    websiteKey = @"";
    contentHeight = 0;
    emailStep = 1;
    searchRowIndex = 0;
    
    [self setupLocalUserInterface:^(BOOL completeFlag){
        //GA
        [model logData:@"Mill View" withAction:@"View Tracker" withLabel:[NSString stringWithFormat:@"Landed on mill view: %@", model.selectedMill.title]];
    }];
    
    downloadingURL = @"";
    
}


-(void)shareView:(id)sender
{
    
    NSDateFormatter *setDateFormat = [[NSDateFormatter alloc]init];
    [setDateFormat setDateFormat:@"yyyy-MM-dd-hh-mm-ss"];
    NSString *date = [setDateFormat stringFromDate:[NSDate date]];
    NSString *filename = [NSString stringWithFormat:@"media%@.pdf", date];
   
    [self drawPDF:filename complete:^(BOOL completeFlag){
      
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* PDFPath = [documentsDirectory stringByAppendingPathComponent:filename];
        
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:PDFPath error:NULL];
        NSNumber *fileSize = [fileAttributes objectForKey:NSFileSize]; // File size (bytes)
        
        
        unsigned long long fileSizeLong = [fileSize unsignedLongLongValue];
        ALog(@"file size %llu",fileSizeLong);
        if (fileSizeLong < 15728640ull) // Check attachment size limit (15MB)
        {
            NSData *attachment = [NSData dataWithContentsOfFile:PDFPath];
            ALog(@"length %lu", (unsigned long)[attachment length]);
            
            if (attachment != nil) // Ensure that we have valid document file attachment data available
            {
                MFMailComposeViewController *mailComposer = [MFMailComposeViewController new];
                
                [mailComposer addAttachmentData:attachment mimeType:@"application/pdf" fileName:filename];
                
                [mailComposer setSubject:millNameHeader.text]; // Use the document file name for the subject
                
                mailComposer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
                mailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
                
                mailComposer.mailComposeDelegate = self; // MFMailComposeViewControllerDelegate
                
                [self presentViewController:mailComposer animated:YES completion:NULL];
            }
        }
    }];
}


- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {

    [self dismissViewControllerAnimated:YES completion:NULL];
    [emailTableContainer removeFromSuperview];
}

- (void)drawPDF:(NSString *)filename complete:(completeBlock)completeFlag {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:filename];
    
    // @TODO GET EMAIL FRAME CONTEXT
    __block CGRect rect = CGRectMake(0, 0, 1024, 768);
    __block CALayer *pdfLayer = self.view.layer;
  
    if (!modalViewPresent) {
        if (emailStep == 1) {
            rect = CGRectMake(250, 0, 774, 768);
            pdfLayer = self.view.layer;
            UIGraphicsBeginPDFContextToFile(path, CGRectZero, nil);
            UIGraphicsBeginPDFPageWithInfo(rect, nil);
            CGContextRef currentContext = UIGraphicsGetCurrentContext();
            CGContextTranslateCTM(currentContext, 0, 0);
            
            [pdfLayer renderInContext:currentContext];
            
            UIGraphicsEndPDFContext();
            completeFlag(YES);
            
        } else {
            loadingView.alpha = 1.0;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                // Creates a mutable data object for updating with binary data, like a byte array
                NSMutableData *pdfData = [NSMutableData data];
                
                // Points the pdf converter to the mutable data object and to the UIView to be converted
                UIGraphicsBeginPDFContextToData(pdfData, (CGRect){0,0, tableView.contentSize}, nil);
                UIGraphicsBeginPDFPage();
                CGContextRef pdfContext = UIGraphicsGetCurrentContext();
                
                CGRect origSize = tableView.frame;
                CGRect newSize = origSize;
                newSize.size = tableView.contentSize;
                [tableView setFrame:newSize];
                
                [tableView.layer renderInContext:pdfContext];
                
                [tableView setFrame:origSize];
                
                // remove PDF rendering context
                UIGraphicsEndPDFContext();
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                NSString* newPath = [documentsDirectory stringByAppendingPathComponent:filename];
                
                // instructs the mutable data object to write its context to a file on disk
                [pdfData writeToFile:newPath atomically:YES];
                loadingView.alpha = 0.0;
                completeFlag(YES);
                
            });
            //get the table
        }
    } else {
        UIGraphicsBeginPDFContextToFile(path, CGRectZero, nil);
        UIGraphicsBeginPDFPageWithInfo(rect, nil);
        CGContextRef currentContext = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(currentContext, 0, 0);
        
        [pdfLayer renderInContext:currentContext];
        
        UIGraphicsEndPDFContext();
        completeFlag(YES);
    }


}

#pragma mark -
#pragma mark table filtering functions
// Resets all table data back to normal
-(void)resetTable:(id)sender
{
    [paperData removeAllObjects];
    [self buildAllPaperData];
    noTableInfo.alpha = 0.0;
    [tableView refresh];
}

// Brings up the search overlay
-(void)searchTable:(id)sender
{
    [self resetTable:resetTable];
    
    searchView.searchBackgroundTitle.text = @"Search ALL Mill Table";
    [self.view addSubview:searchView.background];
    
    [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        searchView.background.alpha = 0.98;
    }completion:^(BOOL finished) {
        
    }];
    
}


-(void)bringUpSearchDialog:(int)rowValue withTitle:(NSString *)title
{
    searchRowIndex = rowValue;
    model.searchDataArray = [[model.searchableMillData objectAtIndex:searchRowIndex] mutableCopy];

    action = [[ActionSheetPicker alloc] initWithNibName:@"ActionSheetPicker" bundle:nil];
    if (searchRowIndex == 5) {
        action.colorFlag = YES;
    } else {
        action.colorFlag = NO;
    }
    action.delegate = self;
    [action.view addSubview:action.background];
    
    action.titleLabel.text = title;
    
    //set the UIPopoverController with the PopUpMenuViewController object and set the frame
    searchField = [[UIPopoverController alloc] initWithContentViewController:action];
    searchField.popoverContentSize = CGSizeMake(600, 220);
    searchField.delegate = self;
    [searchField presentPopoverFromRect:bottomView.bounds inView:bottomView permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

-(void)closePopUpResponse
{
    NSMutableArray *dataRow = [model.searchableMillData objectAtIndex:searchRowIndex];
    NSString *value = [dataRow objectAtIndex:[action.generalPickerview selectedRowInComponent:0]];
    
    int alteredSearchRowIndex = searchRowIndex + 1;

    for (UIView *v in [searchView.background subviews]) {
        if (v.tag == alteredSearchRowIndex) {
            UIButton *b = (UIButton *)v;
            
            // color icon
            if (alteredSearchRowIndex == 6) {
                // Remove icon subview (if any)
                for (UIView *nestedViews in [b subviews]) {
                    if (nestedViews.tag == 222) {
                        [nestedViews removeFromSuperview];
                    }
                }
                // load new view or set none as the label
                int i = (int)[value integerValue];
                if (i == 0) {
                  [b setTitle:@"- NONE -" forState:UIControlStateNormal];
                  searchView.savedColorValue = -1;
                } else {
                  UIView *iv = [action getColorIconSet:i];
                  iv.frame = CGRectMake(241, 0, 88, 15);
                  [b addSubview:iv];
                  [b setTitle:@"" forState:UIControlStateNormal];
                  searchView.savedColorValue = i;
                }
            } else {
              [b setTitle:value forState:UIControlStateNormal];
            }
            break;
        }
    }
    
    [searchField dismissPopoverAnimated:NO];
}

#pragma mark -
#pragma mark SearchOverlayDelegate functions
// Search response delegate function being called from CanonMediaMillSearchOverlay filter button
-(void)searchResponse
{
    
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    [searchDictionary setObject:[searchView.searchArray objectAtIndex:0] forKey:@"mill_name"];
    [searchDictionary setObject:[searchView.searchArray objectAtIndex:1] forKey:@"title"];
    [searchDictionary setObject:[searchView.searchArray objectAtIndex:2] forKey:@"basis_weight"];
    [searchDictionary setObject:[searchView.searchArray objectAtIndex:3] forKey:@"brightness"];
    [searchDictionary setObject:[searchView.searchArray objectAtIndex:4] forKey:@"coating"];
    [searchDictionary setObject:[searchView.searchArray objectAtIndex:5] forKey:@"color_capability"];
    [searchDictionary setObject:[searchView.searchArray objectAtIndex:6] forKey:@"category"];
    [searchDictionary setObject:[searchView.searchArray objectAtIndex:7] forKey:@"dye_pigment"];
    
    [paperData removeAllObjects];
    [model searchInitialPaperData:searchDictionary complete:^(BOOL completeFlag){
        tableRows = 0;
        tableColumns = 8;
        int count = (int)[model.searchablePaperDataObjects count];
        if (count > 0) {
            noTableInfo.alpha = 0.0;
            for (SearchablePaper *p in model.searchablePaperDataObjects) {
                NSMutableArray *rowArray = [[NSMutableArray alloc] init];
        
                [rowArray addObject:p.mill_name];
                
                [rowArray addObject:p.title];
                
                [rowArray addObject:p.basis_weight];

                [rowArray addObject:p.brightness];
                
                [rowArray addObject:p.coating];
                
                [rowArray addObject:p.color_capability];
                
                [rowArray addObject:p.category];
                
                [rowArray addObject:p.dye_pigment];
                
                tableRows++;
                [paperData addObject:rowArray];
                
                if (tableRows == count) {
                    [tableView refresh];
                    [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                        searchView.background.alpha = 0.0;
                    }completion:^(BOOL finished) {
                        [searchView.background removeFromSuperview];
                    }];
                }
            }
        } else {
            noTableInfo.alpha = 1.0;
            [tableView refresh];
            [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                searchView.background.alpha = 0.0;
            }completion:^(BOOL finished) {
                [searchView.background removeFromSuperview];
            }];
        }
    }];
}

// Search response delegate function being called from CanonMediaMillSearchOverlay close button
-(void)closeResponse
{
    [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        searchView.background.alpha = 0.0;
    }completion:^(BOOL finished) {
        [searchView.background removeFromSuperview];
    }];
}

//this function moves around the content in the main view of the app
-(void)loadUpMainTray:(id)sender
{
    UIButton *b = (UIButton *)sender;
    
    //start to build the table dataset if either the paper table or mill table were selected
    if([b.titleLabel.text isEqualToString:@"key"]){
        //setup the initial paper data
        //reset the paper data
        [paperData removeAllObjects];
        
        @try {
            [model sortInitialPaperDataAlpha:@"mill_name" complete:^(BOOL completeFlag){
                [self buildAllPaperData];
                
                [model buildSearchableDataSource:model.initialSetOfPaper sourceFlag:YES complete:^(BOOL completeFlag) {
                    [searchView buildViews];
                }];
                
            }];
        }
        @catch (NSException *exception) {
            ALog(@"%@", exception.reason);
            ALog(@"%@", exception);
        }
        @finally {
            
        }
        
        NSString *bannerTitle = [NSString stringWithFormat:@"All Mills Media List"];
        //the name of the mill
        millNameHeader.text = bannerTitle;
        emailStep = 2;
        shareButton.frame = CGRectMake(676, 5, 32, 32);
        searchButton.alpha = 1.0;
        resetTable.alpha = 1.0;
        
    }else if([b.titleLabel.text isEqualToString:@"papers"]){
        //setup the initial paper data
        //reset the paper data
        [paperData removeAllObjects];
        [model sortInitialPaperDataAlpha:@"title" complete:^(BOOL completeFlag){
            [self buildPaperTableData];
            // build search overlay views
            [searchView buildViews];
        }];
        
        NSString *bannerTitle = [NSString stringWithFormat:@"%@ : Media/Papers", model.selectedMill.title];
        //the name of the mill
        millNameHeader.text = bannerTitle;
        emailStep = 2;
        shareButton.frame = CGRectMake(662, 5, 32, 32);
        searchButton.alpha = 0.0;
        resetTable.alpha = 0.0;
        
    }else if([b.titleLabel.text isEqualToString:@"videos"]){
        NSString *bannerTitle = [NSString stringWithFormat:@"%@ : Videos", model.selectedMill.title];
        //the name of the mill
        millNameHeader.text = bannerTitle;
    }else if([b.titleLabel.text isEqualToString:@"overview"]){
        millNameHeader.text = model.selectedMill.title;
        emailStep = 1;
        shareButton.frame = CGRectMake(662, 5, 32, 32);
        searchButton.alpha = 0.0;
        resetTable.alpha = 0.0;
    }
    
    
    
    
    
    //switch to overview from anything
    if([b.titleLabel.text isEqualToString:@"overview"]){
        [self rearrangeDocumentStack];

        //perform the animation
        [UIView animateWithDuration:1.2f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            overviewContainer.alpha = 1.0;
            overviewImageDots.alpha = 1.0;
            documentContainer.alpha = 0.0;
            tableBackground.alpha = 0.0;
        }completion:^(BOOL finished) {
            
        }];
    
    //switch from overview to videos
    }else if([b.titleLabel.text isEqualToString:@"videos"] && sidebarIndicator.frame.origin.y == 30){
        
        documentContainer.frame = CGRectMake(0, 884, 776, 684);
   
        //perform the animation to move the documet
        [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            overviewContainer.alpha = 0.0;
            overviewImageDots.alpha = 0.0;
        }completion:^(BOOL finished) {
            [mainView sendSubviewToBack:documentContainer];
            [mainView bringSubviewToFront:mainShortBanner];
            [self tearDownAndLoadUpDocuments:b.titleLabel.text withComplete:^(BOOL completeFlag){
                [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                    documentScroll.alpha = 1.0;
                    documentContainer.alpha = 1.0;
                    documentContainer.frame = CGRectMake(0, 0, 748, 628);
                }completion:^(BOOL finished) {
                    
                }];
            }];
        }];
    
    //switch from overview to table
    }else if(([b.titleLabel.text isEqualToString:@"papers"] || [b.titleLabel.text isEqualToString:@"key"]) && sidebarIndicator.frame.origin.y == 30){
        
        [mainView sendSubviewToBack:documentContainer];
        [mainView bringSubviewToFront:mainShortBanner];
        
        //perform the animation
        tableBackground.alpha = 1.0;
        tableBackground.frame = CGRectMake(0, 884, 776, 684);
        
        [UIView animateWithDuration:1.2f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            overviewContainer.alpha = 0.0;
            overviewImageDots.alpha = 0.0;
            documentContainer.alpha = 0.0;
        }completion:^(BOOL finished) {
            [self tearDownAndLoadUpDocuments:b.titleLabel.text withComplete:^(BOOL completeFlag){
                [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                    tableBackground.frame = CGRectMake(0, 0, 776, 684);
                }completion:^(BOOL finished) {
                    
                }];
            }];
        }];
     //switch from papers to videos
    }else if([b.titleLabel.text isEqualToString:@"videos"] && (sidebarIndicator.frame.origin.y == 162 || sidebarIndicator.frame.origin.y == 228)){
        overviewContainer.alpha = 0.0;
        overviewImageDots.alpha = 0.0;
        documentContainer.frame = CGRectMake(0, 884, 776, 684);

        //perform the animation to move the documet
        [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            tableBackground.frame = CGRectMake(1040, 0, 776, 684);
            tableBackground.alpha = 0.0;
        }completion:^(BOOL finished) {
            [mainView sendSubviewToBack:tableBackground];
            [mainView bringSubviewToFront:mainShortBanner];
            [self tearDownAndLoadUpDocuments:b.titleLabel.text withComplete:^(BOOL completeFlag){
                [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                    documentScroll.alpha = 1.0;
                    documentContainer.alpha = 1.0;
                    documentContainer.frame = CGRectMake(0, 0, 748, 628);
                }completion:^(BOOL finished) {
              
                }];
            }];
        }];
        
    //switch from videos to papers
    }else if(([b.titleLabel.text isEqualToString:@"papers"] || [b.titleLabel.text isEqualToString:@"key"]) && sidebarIndicator.frame.origin.y == 96){
        overviewContainer.alpha = 0.0;
        overviewImageDots.alpha = 0.0;
        tableBackground.frame = CGRectMake(0, 884, 776, 684);

        //perform the animation to move the documet
        [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            documentContainer.frame = CGRectMake(1040, 0, 776, 684);
            documentContainer.alpha = 0.0;
        }completion:^(BOOL finished) {
            [mainView sendSubviewToBack:documentContainer];
            [mainView bringSubviewToFront:mainShortBanner];
            [self tearDownAndLoadUpDocuments:b.titleLabel.text withComplete:^(BOOL completeFlag){
                [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                    tableBackground.alpha = 1.0;
                    tableBackground.frame = CGRectMake(0, 0, 776, 684);
                }completion:^(BOOL finished) {
                    
                }];
            }];
        }];
   
     //switch from table to table
    }else if(([b.titleLabel.text isEqualToString:@"papers"] || [b.titleLabel.text isEqualToString:@"key"])
             && (sidebarIndicator.frame.origin.y == 228 || sidebarIndicator.frame.origin.y == 162)){
        overviewContainer.alpha = 0.0;
        overviewImageDots.alpha = 0.0;

        //perform the animation to move the documet
        [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            tableBackground.frame = CGRectMake(1040, 0, 776, 684);
            tableBackground.alpha = 0.0;
        }completion:^(BOOL finished) {
            tableBackground.frame = CGRectMake(0, 884, 776, 684);
            [mainView sendSubviewToBack:tableBackground];
            [mainView bringSubviewToFront:mainShortBanner];
            [self tearDownAndLoadUpDocuments:b.titleLabel.text withComplete:^(BOOL completeFlag){
                [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                    tableBackground.alpha = 1.0;
                    tableBackground.alpha = 1.0;
                    tableBackground.frame = CGRectMake(0, 0, 776, 684);
                }completion:^(BOOL finished) {
                    
                }];
            }];
        }];
        
    }
    
    noTableInfo.alpha = 0.0;
    //animate the indicator
    [self animateSidebarIndicator:(int)b.tag];
    
}

//this function switches around the view index in the stack
-(void)rearrangeDocumentStack
{
    [mainView sendSubviewToBack:tableBackground];
    [mainView bringSubviewToFront:mainShortBanner];
}

//this function switches the main view from document to document
-(void)tearDownAndLoadUpDocuments:(NSString *)flag withComplete:(completeBlock)completeFlag
{
    //remove all subviews
    for(UIView *v in [documentScroll subviews]){
        [v removeFromSuperview];
    }
    
 
    //dynamic property reference!!! woooohooo!
    NSMutableArray *data = [model.selectedMill valueForKey:flag];
    
    //remove video rows
    [offlineVideoRows removeAllObjects];

    
    //make sure we are dealing with an array, otherwise we can assume that their is no content assigned to this
    if(([data isKindOfClass:[NSArray class]] && [data count] > 0) || [flag isEqualToString:@"key"]){
        //make sure we are dealing with videos
        if([flag isEqualToString:@"videos"]){
            //Below we loop through eith the document or video data to load up a dynamic set of buttons
            int count = (int)[data count], i = 0, y = 0;
            for(NSString *documentKey in data){
                NSData *doc = [model getFileData:documentKey complete:^(BOOL completeFlag){}];
                
                y = i * 193 + 16;
                if(y == 0) y = 16;
                
                UIView *rowContainer = [[UIView alloc] initWithFrame:CGRectMake(0, y, 748, 179)];
                rowContainer.backgroundColor = [UIColor whiteColor];
                
                UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
                [back setFrame:CGRectMake(0, 0, 748, 179)];
                [back addTarget:self action:@selector(rowTapped:)forControlEvents:UIControlEventTouchUpInside];
                back.showsTouchWhenHighlighted = YES;
                [back setUserInteractionEnabled:YES];
                [back setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                back.tag = i;
                [back setBackgroundColor:[UIColor whiteColor]];
                [rowContainer addSubview:back];
                
                UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 308, 173)];
                iv.backgroundColor = model.blue;
                [back addSubview:iv];
                
                UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(328, 16, 360, 24)];
                [title setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:16.0]];
                title.textColor = [UIColor blackColor];
                title.numberOfLines = 2;
                title.adjustsFontSizeToFitWidth = YES;
                title.backgroundColor = [UIColor clearColor];
                [back addSubview:title];
                
                UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(328, 40, 360, 1)];
                horizontalLine.backgroundColor = [UIColor blackColor];
                [back addSubview:horizontalLine];
                
                UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(328, 47, 360, 121)];
                [desc setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
                desc.textColor = model.dullBlack;
                desc.numberOfLines = 15;
                desc.backgroundColor = [UIColor clearColor];
                [back addSubview:desc];
                
                /**** if the array data is a video ****/
                //consider removing this check because they will all be videos
                if ([flag isEqualToString:@"videos"]){
                    /*************** Videos ************************/
                    
                    //set a video object from the selected object
                    Video *v = [NSKeyedUnarchiver unarchiveObjectWithData:doc];
                    //set the key for the object
                    [back setTitle:v.key forState:UIControlStateNormal];
                    
                    if([v.image isEqualToString:@""]){
                        [iv setImage:[UIImage imageNamed:@"tmb-FPO-video.png"]];
                    }else{
                        //try and load the image via the internet, otherwise use placeholder as a fallback
                        NSString *u = [v.image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                        [iv sd_setImageWithURL:[NSURL URLWithString:u] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
                        
                    }
                    
                    NSString *rawVideo = [v.rawVideo stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                    NSString *name = [model getVideoFileName:rawVideo];
                    
                    
                    //set the data for the rest of the row
                    title.text = v.title;
                    desc.text = v.description;
                    
                    //make sure the video row is faded out if the user is not online
                    if(![model.hostReachability isReachableViaWiFi]){
                        //user is not connected to the internet
                        NSString *lookupName = [name stringByReplacingOccurrencesOfString:@"%20" withString:@"_"];
                        
                        //check if the user has the video saved locally
                        if([model fileExists:lookupName]){
                            rowContainer.alpha = 1.0;
                            back.enabled = YES;
                        }else{
                            rowContainer.alpha = 0.6;
                            model.layoutSync = NO;
                            [offlineVideos setObject:rowContainer forKey:v.key];
                        }
                    }else{
                        rowContainer.alpha = 1.0;
                        back.enabled = YES;
                    }
                    
                    [offlineVideoRows addObject:rowContainer];
                    //add the data set of data being held for easy reference
                    [currentDocumentData setObject:v forKey:v.key];
                }
                
                //add sub view to the scroll container
                [documentScroll addSubview:rowContainer];
                i++;
                
                //check to see if we are done building the view yet and send the thread back to the calling function
                if(i == count){
                    [documentScroll setContentSize:CGSizeMake(748, (y + 193))];
                    completeFlag(YES);
                }
            }
        /********** Paper Table ************************/
        //this block of code sets up the table for paper
        }else if([flag isEqualToString:@"papers"]){
            
            //set the paper only flag
            paperTable = YES;
            
            //load up table for papers
            if(tableEmpty == NO){
                
               //if there is an old table present, remove it and rebuild another one
               if([tableBackground viewWithTag:130] != nil){
                    [[tableBackground viewWithTag:130] removeFromSuperview];
               }
                
               //remove an existing tableview from the supervier
               [tableView removeFromSuperview];
                
               //setup the table headers based upon the current table we are using
               [self setupTableHeaders];
                
               //build a new tableview and add it to the super view
               CGRect frm = CGRectMake(20, 160, 736, 500);
               tableView = [[UMTableView alloc] initWithFrame: frm];
               tableView.tableViewDelegate = self;
               tableView.tag = 130;
               tableView.delaysContentTouches = NO;
               tableView.borderMode = UMTableViewBordersRows;
               tableView.outlineMode = UMTableViewOutlineNone;
               [tableBackground addSubview:tableView];
               
               //GA
               [model logData:@"Mill View" withAction:@"View Tracker" withLabel:[NSString stringWithFormat:@"Loading up paper table for mill: %@", model.selectedMill.title]];
               
            }else{
                
                UILabel *noTabledata = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 748, 80)];
                [noTabledata setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:16.0]];
                noTabledata.textColor = [UIColor whiteColor];
                noTabledata.textAlignment = NSTextAlignmentCenter;
                noTabledata.text = @"- NO PAPERS ASSOCIATED WITH THIS MILL -";
                noTabledata.numberOfLines = 1;
                noTabledata.tag = 120;
                noTabledata.backgroundColor = [UIColor clearColor];
                [tableBackground addSubview:noTabledata];
                
                //remove the table view from the table background
                if([tableBackground viewWithTag:120] != nil){
                    [[tableBackground viewWithTag:130] removeFromSuperview];
                }
            }
            completeFlag(YES);
            
        }else if([flag isEqualToString:@"key"]){
            //load up table for mills and tables
            paperTable = NO;
            
            //start assembling the all paper table
            if(tableEmpty == NO){

                //remove the no table data from the table view
                if([tableBackground viewWithTag:130] != nil){
                    [[tableBackground viewWithTag:130] removeFromSuperview];
                }
                //remove an existing tableview from the supervier
                [tableView removeFromSuperview];
                
                //setup the table headers based upon the current table we are using
                [self setupTableHeaders];
                
                CGRect frm = CGRectMake(20, 160, 736, 500);
                tableView = [[UMTableView alloc] initWithFrame: frm];
                tableView.tableViewDelegate = self;
                tableView.tag = 130;
                tableView.delaysContentTouches = NO;
                tableView.borderMode = UMTableViewBordersRows;
                tableView.outlineMode = UMTableViewOutlineNone;
                
                [tableBackground addSubview:tableView];
                
                //GA
                [model logData:@"Mill View" withAction:@"View Tracker" withLabel:[NSString stringWithFormat:@"Loading up full mill table for mill: %@", model.selectedMill.title]];
                
               
            }
            
            completeFlag(YES);
        }
    }else{
        //this mean there is not results
        UIView *rowContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 748, 179)];
        rowContainer.backgroundColor = [UIColor whiteColor];
        
        UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 748, 80)];
        [desc setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:16.0]];
        desc.textColor = [UIColor whiteColor];
        desc.textAlignment = NSTextAlignmentCenter;
        desc.text = @"- NO CONTENT ASSOCIATED WITH THIS ITEM -";
        desc.numberOfLines = 2;
        desc.backgroundColor = [UIColor clearColor];
        [rowContainer addSubview:desc];
        
        [documentScroll addSubview:desc];
        
        [documentScroll setContentSize:CGSizeMake(748, 300)];
        completeFlag(YES);
    }
    
    
}


//This function executes the functionality when a row is tapped on either a document of a video
-(void)rowTapped:(id)sender
{
    UIButton *b = (UIButton *)sender;
    
    //since we are only dealing with videos that can be tapped in the row
    Video *v = [currentDocumentData objectForKey: b.titleLabel.text];
    NSString *filename = [model getVideoFileName:v.rawVideo];
    NSString *lookupName = [filename stringByReplacingOccurrencesOfString:@"%20" withString:@"_"];
    
    //try and play the moview from the device first
    if([model fileExists:[lookupName lastPathComponent]]){
        
        NSString *fullPath = [model returnFilePath:lookupName];
        NSString *urlPath = [NSString stringWithFormat:@"file://%@", fullPath];
        NSURL *videoURL = [NSURL URLWithString:urlPath];
        MPMoviePlayerViewController *moviePlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [self presentMoviePlayerViewControllerAnimated:moviePlayerView];
        ALog(@"LOAD VIDEO FROM DEVICE %@", videoURL);
        
        //GA
        [model logData:@"Mill View" withAction:@"View Tracker" withLabel:[NSString stringWithFormat:@"Loading video from the device: %@", v.title]];
        //if not on the device, try  and stream it
    }else{
        
        if([model.hostReachability isReachableViaWiFi]){
            NSString *videoURLString = [v.streamingURL stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            NSURL *videoURL = [NSURL URLWithString:videoURLString];
            MPMoviePlayerViewController *moviePlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
            [self presentMoviePlayerViewControllerAnimated:moviePlayerView];
            ALog(@"Streaming");
            
            //GA
            [model logData:@"Mill View" withAction:@"View Tracker" withLabel:[NSString stringWithFormat:@"Streaming video: %@", v.title]];
        }
    }
}


//button where url is selected
-(void)urlSelected:(id)sender
{
    //this is triggered by the single paper table
    if([websiteKey isEqualToString:@""]){
        //go out to the website of the selectd mill
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.selectedMill.website]];
        
    //this is triggered by the overlay where there could be any number of mills urls
    }else{
        for(Mill *m in model.initialSetOfMills){
            if([websiteKey isEqualToString:m.key]){
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:m.website]];
                return;
            }
        }
    }
}

//this function performs the animation to run the sidebar indicator up and down
-(void)animateSidebarIndicator:(int)yValue
{
    int offset = 5;
    if(sidebarIndicator.frame.origin.y > yValue){
        offset = -5;
    }
    
    [UIView animateWithDuration:0.8f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        sidebarIndicator.frame = CGRectMake(0, (yValue + offset), 35, 35);
    }completion:^(BOOL finished) {
        //completion
        [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            sidebarIndicator.frame = CGRectMake(0, yValue, 35, 35);
        
        }completion:^(BOOL finished) {
            //completion
        }];
    }];
    
}
//this function sends the user back one view
-(void)triggerBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

//this function sends the user back home
-(void)triggerHome:(id)sender
{
    for (UIViewController *vc in [self.navigationController viewControllers]) {
        if ([vc isMemberOfClass:[CanonViewController class]]) {
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
        
    }
}

//this function sets up the disposable views and also sets up the overview view in the main portion of the app
-(void)setupLocalUserInterface:(completeBlock)completeFlag
{
    //back button
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn-backgrid.png"] forState:UIControlStateNormal];
    
    //home icon
    [navBarHomeButton setBackgroundImage:[UIImage imageNamed:@"icn-home.png"] forState:UIControlStateNormal];
    
    //add the small main header
    mainShortBanner.image = [model getImageWithName:@"/hdr-short-pink@X2.png"];
    
    millNameHeader.text = model.selectedMill.title;
    
    //set the logo, or try and set the logo
    [millLogo sd_setImageWithURL:[NSURL URLWithString:model.selectedMill.logo] placeholderImage:[UIImage imageNamed:@"overviewPlaceholder.png"]];
    
    //set the mill name in the overview container
    millNameOverview.text = model.selectedMill.title;
    
    //set the phone number
    millPhone.text = model.selectedMill.phone;
    
    //set the mill address
    millAddress.text = model.selectedMill.address;
    
    //set the mill description
    millDescription.text = model.selectedMill.description;
    [millDescription sizeToFit];
    
    float h = millDescription.frame.size.height, offset = 0;
    if(h > 182){
        offset = millDescription.frame.size.height - 182;
        
    }
    
    [overviewContent setContentSize:CGSizeMake(712, (342 + offset))];
    
    //the mill's website name
    NSString *websiteName = [NSString stringWithFormat:@"%@'s Website", model.selectedMill.title];
    [urlMill setTitle:websiteName forState:UIControlStateNormal];
    
    
    //#### setup image slider in overview view ####
    NSMutableArray *images = model.selectedMill.banners;
    int i = 0, width = 0;
    overviewImageDots.numberOfPages = [images count];
    for(NSString *url in images){
        width = i * 776;
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(width, 0, 776, 264)];
        
        NSString *u = [url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        //check to make sure the value exists on disk
        [img sd_setImageWithURL:[NSURL URLWithString:u] placeholderImage:[UIImage imageNamed:@"overviewPlaceholder.png"]];
        img.backgroundColor = [UIColor whiteColor];
        img.contentMode = UIViewContentModeScaleAspectFit;
        [img setUserInteractionEnabled:YES];
        [overviewImages addSubview:img];
        i++;
    }
    //set the content size for the scroll view
    [overviewImages setContentSize:CGSizeMake((width + 776), 264)];
    
    //setup the display of the page control dots
    if([images count] == 1){
        overviewImageDots.alpha = 0.0;
    }else{
        [mainView bringSubviewToFront:overviewImageDots];
    }
    
 
    completeFlag(YES);
}

//this function updates the dots for the current image the the user is on
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = scrollView.bounds.size.width;
    //display the appropriate dot when scrolled
    NSInteger pageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    overviewImageDots.currentPage = pageNumber;
    
}

/*********************************************************************************************************************
 *
 *  Table Delegate Functions and Table Building/Interaction Functions
 *
 *********************************************************************************************************************/

- (int) rowHeight {
    return 50;
}

- (int) numColumns {
    return tableColumns;
}

- (int) numRows {
    return tableRows;
}

-(void)totalContentHeightOffScrollView:(float)height
{
    self.contentHeight = height;
   
    [self addNoticeToTable:self.contentHeight andView:tableView];
}

-(void)addNoticeToTable:(float)offset andView:(UMTableView *)view
{
    
    if([view viewWithTag:3] == nil){
    
        UIView *tableNotice = [[UIView alloc] initWithFrame:CGRectMake(0, (offset + 20), 736, 120)];
        tableNotice.tag = 3;
        [view addSubview:tableNotice];
        
        UILabel *notice = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 736, 50)];
        [notice setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:12.0]];
        notice.textColor = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0];
        notice.text = @"NOTE: All papers on this list are available in the use either from the mill directly or through distribution. Some papers may require a minimum order from the mill. Availability can and will change based on supply and demand for papers, contact your mill or distributor for the most up to date availablility. Many mills will have stocking levels incicated on their web sites with the most up to date information. Follow the links provided to access mill web sites.";
        notice.numberOfLines = 4;
        notice.backgroundColor = [UIColor clearColor];
        [tableNotice addSubview:notice];
        
        UILabel *noticeTwo = [[UILabel alloc] initWithFrame:CGRectMake(0, 70, 736, 50)];
        [noticeTwo setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:12.0]];
        noticeTwo.textColor = [UIColor colorWithRed:1.0f/255.0f green:120.0f/255.0f blue:180.0f/255.0f alpha:1.0];
        noticeTwo.text = @"The papers listed in this document have been evaluated on Canon Solutions America and Oce production printing equipment. Canon Solutions America does not guarantee the performance or availability of any papers listed. Results may vary.This list is only to be used as a guide for selecting papers for further testing in specific applications. For more information consult your local sales represenitive It is recommended that a paper trial including linerization of the trial.";
        noticeTwo.numberOfLines = 4;
        noticeTwo.backgroundColor = [UIColor clearColor];
        [tableNotice addSubview:noticeTwo];
    }
}

// Only certain columns have a fixed size, the other columns share the remainder
- (int) fixedWidthForColumn: (int) columnIndex {
    
    //if we are dealing with column 0 or 1 make sure the width is set to 120
    if (columnIndex == 0) {
          return 120;
    }else if(columnIndex == 1){
          return 120;
    }else {
        return 0;
    }
   
}

// variable columns with a fixed size
- (Boolean) hasColumnFixedWidth: (int) columnIndex {
    //based upon which table we are dealing with, return the column that has a set width
    if(paperTable)
      return columnIndex == 0;
    else
      return columnIndex == 1;
}

- (UIColor*) borderColor {
    return [UIColor blackColor];
}

// Customize cells and provide data content
// Note: the cellView will always be empty (except its label)
- (void) layoutView: (UMCellView*) cellView forRow:(int)row inColumn:(int) column {
    
    if(tableEmpty == false){
       
        //get the data for this row
        NSMutableArray *rowArray = [paperData objectAtIndex:row];
        
        cellView.backgroundColor = [UIColor clearColor];
        cellView.label.font = [UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:12.0];
        cellView.label.textColor = [UIColor blackColor];
        
        
        //if we are not dealing with the last column, load text
        if(paperTable){
            //just mill specific paper
            if(column == 4){
                //color capability
                int x = 8;
                int dyeValue = [[rowArray objectAtIndex:column] intValue];
                if(dyeValue == 5) x = -4;
                UIView *iconView = [self getColorIconSet:YES withXValue:x andYValue:16 withColorValue:dyeValue];
                [cellView addSubview:iconView];
            }else if(column == 5){
                cellView.label.font = [UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:11.0];
                cellView.label.text = [rowArray objectAtIndex:column];
            }else{
                //all other text
                cellView.label.text = [rowArray objectAtIndex:column];
            }
        }else{
            //all paper table
            if(column == 5){
                //color capability
                int x = 8;
                int dyeValue = [[rowArray objectAtIndex:column] intValue];
                if(dyeValue == 5) x = -4;
                UIView *iconView = [self getColorIconSet:YES withXValue:x andYValue:16 withColorValue:dyeValue];
                [cellView addSubview:iconView];
            
            }else if(column == 6){
                cellView.label.font = [UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:11.0];
                cellView.label.text = [rowArray objectAtIndex:column];
            }else{
                //all other text
                cellView.label.text = [rowArray objectAtIndex:column];
            }
        }
        
        
        // This will center the label horizontally
        cellView.label.textAlignment = NSTextAlignmentLeft;
        cellView.label.numberOfLines = 3;
        cellView.label.adjustsFontSizeToFitWidth = YES;
        
        float widthCell = cellView.frame.size.width;
        float heightCell = cellView.frame.size.height;
        int intCount = (int)([rowArray count] - 1);
        
        UIButton *maskButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [maskButton setFrame:CGRectMake(0, 0, widthCell, heightCell)];
        [maskButton addTarget:self action:@selector(infoButtonForPaper:)forControlEvents:UIControlEventTouchUpInside];
        maskButton.showsTouchWhenHighlighted = YES;
        maskButton.titleLabel.text = [rowArray objectAtIndex:intCount];
        maskButton.backgroundColor = [UIColor clearColor];
        [cellView addSubview:maskButton];
        
    }

}

-(UIView *)getColorIconSet:(BOOL)flag withXValue:(int)x andYValue:(int)y withColorValue:(int)value
{
    UIView *iconSet = [[UIView alloc] initWithFrame:CGRectMake(x, y, 120, 21)];
    iconSet.backgroundColor = [UIColor clearColor];
    int i = 0;
    if(flag){
        //small view
        iconSet.frame = CGRectMake(x, y, 88, 15);
        while(i < value){
            int xOffset = i * 18;
            UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, 0, 15, 15)];
            [icon setImage:[iconArray objectAtIndex:i]];
            [iconSet addSubview:icon];
            i++;
        }
    }else{
        //large view
        while(i < value){
            int xOffset = i * 25;
            UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, 0, 18, 18)];
            [icon setImage:[iconArray objectAtIndex:i]];
            [iconSet addSubview:icon];
            i++;
        }
        
    }
    return iconSet;
}

//this function rearranges the table headers based upon which table we are displaying
-(void)setupTableHeaders
{
    int i = 0;
    if(paperTable){
        //setup headers for the paper table
        tableKey.frame = CGRectMake(662, 56, 33, 33);
        [cell7 removeFromSuperview];
        while(i < 7){
            UILabel *l = [headerLabelsPaper objectAtIndex:i];
            l.text = [rowHeadersPaper objectAtIndex:i];
            //setup the first column based upon the first column's dynamic width
            //the rest of the columns are setup based upon the width of 88
            if(i == 0){
                l.frame = CGRectMake(0, 0, 120, 50);
            }else{
                int offset = 120 + ((i -1) * 103);
                l.frame = CGRectMake(offset, 0, 103, 50);
            }
            i++;
        }
        
    }else{
        //setup heders for the mill table
        tableKey.frame = CGRectMake(676, 56, 33, 33);
        [tableHeaderRow addSubview:cell7];
        while(i < 8){
            UILabel *l = [headerLabelsMill objectAtIndex:i];
            l.text = [rowHeadersMill objectAtIndex:i];
            
            //setup the first two columns based upon the second columns dynamic width
            //the rest of the columns are setup based upon the width of 77
            if(i == 0){
                l.frame = CGRectMake(0, 0, 90, 50);
            }else if(i == 1){
                l.frame = CGRectMake(90, 0, 120, 50);
            }else if(i == 2){
                l.frame = CGRectMake(205, 0, 87.6, 50);
            }else{
                int offset = 210 + ((i -2) * 87.6);
                l.frame = CGRectMake(offset, 0, 87.6, 50);
            }
            i++;
        }
    }
}

//this function is used assemble and pop open the overlay for table
-(void)infoButtonForPaper:(id)sender
{
    UIButton *b = (UIButton *)sender;

    
    Paper *selectedPaper;
    for(Paper *p in model.initialSetOfPaper){
        if([p.key isEqualToString:b.titleLabel.text]){
            selectedPaper = p;
        }
    }
    
   
    //bring the overlay to the front
    [self.view bringSubviewToFront:overlay];
    
    //get the new modal window
    globalModal = [self assembleModalView:selectedPaper];
    [self.view addSubview:globalModal];
    
    //display the views
    [UIView animateWithDuration:0.8f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        overlay.alpha = 0.7;
        globalModal.alpha = 1.0;
    }completion:^(BOOL finished) {
        modalViewPresent = YES;
    }];
    
}

//this function is used to pop open the table key for either table
-(void)tableKeySelected:(id)sender
{
    //load up all attributes of the PopUpMenuViewController view controller
    popView.view.frame = CGRectMake(0, 0, 650, 220);
    
    //set the UIPopoverController with the PopUpMenuViewController object and set the frame
    pop = [[UIPopoverController alloc] initWithContentViewController:popView];
    pop.popoverContentSize = CGSizeMake(650, 220);
    pop.delegate = self;
    [pop presentPopoverFromRect:((UIButton *)sender).bounds inView:sender permittedArrowDirections:UIPopoverArrowDirectionRight animated:YES];
}

/*********************************************************************************************************************
 *
 *  Overlay Functions
 *
 *********************************************************************************************************************/

-(UIView *)assembleModalView:(Paper *)obj
{
    UIView *modalView = [[UIView alloc] initWithFrame:CGRectMake(40, 60, 944, 648)];
    modalView.tag = 2020;
    modalView.alpha = 0.0;
    modalView.layer.shadowColor = [UIColor blackColor].CGColor;
    modalView.layer.shadowOffset = CGSizeMake(1.0f, 1.0f);
    modalView.layer.shadowOpacity = 0.7f;
    modalView.layer.shadowRadius = 2.0f;
    modalView.layer.shadowPath = [UIBezierPath bezierPathWithRect:modalView.bounds].CGPath;
    modalView.backgroundColor = [UIColor whiteColor];
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 944, 40)];
    header.backgroundColor = model.dullBlack;
    header.userInteractionEnabled = YES;
    [modalView addSubview:header];
    
    
    float millWidth = [model widthOfString:[obj.mill_name uppercaseString] withStringSize:16.0 andFontKey:@"ITCAvantGardeStd-Md"];
    float paperWidth = [model widthOfString:[obj.title uppercaseString] withStringSize:16.0 andFontKey:@"ITCAvantGardeStd-Md"];
    
    UILabel *paperMill = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, millWidth, 20)];
    [paperMill setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0]];
    paperMill.textColor = [UIColor whiteColor];
    paperMill.numberOfLines = 1;
    paperMill.backgroundColor = [UIColor clearColor];
    paperMill.text = [obj.mill_name uppercaseString];
    [modalView addSubview:paperMill];
    
    UILabel *paperName = [[UILabel alloc] initWithFrame:CGRectMake((millWidth + 50), 10, paperWidth, 20)];
    [paperName setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0]];
    paperName.textColor = [UIColor whiteColor];
    paperName.numberOfLines = 1;
    paperName.backgroundColor = [UIColor clearColor];
    paperName.text = [obj.title uppercaseString];
    [modalView addSubview:paperName];
    
    NSString *basisWeightString = @"";
    for(NSString *s in obj.basis_weight){
        basisWeightString = [NSString stringWithFormat:@"%@ ", s];
    }
    
    UILabel *basisWeight = [[UILabel alloc] initWithFrame:CGRectMake((paperWidth + millWidth + 80), 10, 160, 20)];
    [basisWeight setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0]];
    basisWeight.textColor = [UIColor whiteColor];
    basisWeight.numberOfLines = 1;
    basisWeight.backgroundColor = [UIColor clearColor];
    basisWeight.text = [basisWeightString uppercaseString];
    [modalView addSubview:basisWeight];
    
    UIButton *overlayShareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [overlayShareButton setFrame:CGRectMake(850, 4, 32, 32)];
    [overlayShareButton addTarget:self action:@selector(shareView:)forControlEvents:UIControlEventTouchDown];
    [overlayShareButton setBackgroundImage:[UIImage imageNamed:@"ico-print.png"] forState:UIControlStateNormal];
    overlayShareButton.showsTouchWhenHighlighted = YES;
    [header addSubview:overlayShareButton];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton setFrame:CGRectMake(904, 0, 40, 40)];
    [closeButton addTarget:self action:@selector(closeOverlay:)forControlEvents:UIControlEventTouchDown];
    closeButton.showsTouchWhenHighlighted = YES;
    [closeButton setBackgroundImage:[UIImage imageNamed:@"btn-close.png"] forState:UIControlStateNormal];
    closeButton.backgroundColor = [UIColor clearColor];
    [header addSubview:closeButton];
    
    /************************** start of table rows ************************************/
    
    /*************************** table row one ********************************/
    /***** Labels *******/
    UILabel *regionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 132, 20)];
    [regionLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    regionLabel.textColor = [UIColor blackColor];
    regionLabel.numberOfLines = 1;
    regionLabel.backgroundColor = [UIColor clearColor];
    regionLabel.text = @"REGION";
    [modalView addSubview:regionLabel];
    
    UILabel *micrLabel = [[UILabel alloc] initWithFrame:CGRectMake(126, 80, 132, 20)];
    [micrLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    micrLabel.textColor = [UIColor blackColor];
    micrLabel.numberOfLines = 1;
    micrLabel.backgroundColor = [UIColor clearColor];
    micrLabel.text = @"MICR CAPABLE";
    [modalView addSubview:micrLabel];
    
    UILabel *priceRangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(268, 80, 132, 20)];
    [priceRangeLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    priceRangeLabel.textColor = [UIColor blackColor];
    priceRangeLabel.numberOfLines = 1;
    priceRangeLabel.backgroundColor = [UIColor clearColor];
    priceRangeLabel.text = @"PRICE RANGE";
    [modalView addSubview:priceRangeLabel];
    
    UILabel *brightRangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(406, 63, 122, 40)];
    [brightRangeLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    brightRangeLabel.textColor = [UIColor blackColor];
    brightRangeLabel.numberOfLines = 2;
    brightRangeLabel.backgroundColor = [UIColor clearColor];
    brightRangeLabel.text = @"WHITE / BRIGHT RANGE";
    [modalView addSubview:brightRangeLabel];
    
    UILabel *opacityRangeLabel = [[UILabel alloc] initWithFrame:CGRectMake(550, 63, 112, 40)];
    [opacityRangeLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    opacityRangeLabel.textColor = [UIColor blackColor];
    opacityRangeLabel.numberOfLines = 2;
    opacityRangeLabel.backgroundColor = [UIColor clearColor];
    opacityRangeLabel.text = @"OPACITY RANGE";
    [modalView addSubview:opacityRangeLabel];
    
    UILabel *caliperLabel = [[UILabel alloc] initWithFrame:CGRectMake(685, 80, 132, 20)];
    [caliperLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    caliperLabel.textColor = [UIColor blackColor];
    caliperLabel.numberOfLines = 1;
    caliperLabel.backgroundColor = [UIColor clearColor];
    caliperLabel.text = @"CALIPER";
    [modalView addSubview:caliperLabel];
    
    UILabel *recycledLabel = [[UILabel alloc] initWithFrame:CGRectMake(812, 80, 132, 20)];
    [recycledLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    recycledLabel.textColor = [UIColor blackColor];
    recycledLabel.numberOfLines = 1;
    recycledLabel.backgroundColor = [UIColor clearColor];
    recycledLabel.text = @"RECYCLED %";
    [modalView addSubview:recycledLabel];
    
    UIView *rowLine = [[UIView alloc] initWithFrame:CGRectMake(0, 110, 944, 1)];
    rowLine.backgroundColor = [UIColor blackColor];
    [modalView addSubview:rowLine];
    
    UIView *rowOne = [[UIView alloc] initWithFrame:CGRectMake(0, 111, 944, 40)];
    rowOne.backgroundColor = [UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:1.0];
    [modalView addSubview:rowOne];
    
    /***** Values *******/
    
    UILabel *regionValue = [[UILabel alloc] initWithFrame:CGRectMake(20, 8, 132, 20)];
    [regionValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:13.0]];
    regionValue.textColor = [UIColor blackColor];
    regionValue.numberOfLines = 1;
    regionValue.backgroundColor = [UIColor clearColor];
    regionValue.text = obj.region;
    [rowOne addSubview:regionValue];
    
    UILabel *micrValue = [[UILabel alloc] initWithFrame:CGRectMake(126, 10, 132, 20)];
    [micrValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:13.0]];
    micrValue.textColor = [UIColor blackColor];
    micrValue.numberOfLines = 1;
    micrValue.backgroundColor = [UIColor clearColor];
    micrValue.text = obj.micr_capable;
    [rowOne addSubview:micrValue];
    
    UILabel *priceRangeValue = [[UILabel alloc] initWithFrame:CGRectMake(268, 10, 132, 20)];
    [priceRangeValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:13.0]];
    priceRangeValue.textColor = model.green;
    priceRangeValue.numberOfLines = 1;
    priceRangeValue.backgroundColor = [UIColor clearColor];
    priceRangeValue.text = obj.price_range;
    [rowOne addSubview:priceRangeValue];
    
    UILabel *brightRangeValue = [[UILabel alloc] initWithFrame:CGRectMake(406, 10, 122, 20)];
    [brightRangeValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:13.0]];
    brightRangeValue.textColor = [UIColor blackColor];
    brightRangeValue.numberOfLines = 1;
    brightRangeValue.backgroundColor = [UIColor clearColor];
    brightRangeValue.text = obj.brightness;
    [rowOne addSubview:brightRangeValue];
    
    UILabel *opacityRangeValue = [[UILabel alloc] initWithFrame:CGRectMake(550, 10, 122, 20)];
    [opacityRangeValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:13.0]];
    opacityRangeValue.textColor = [UIColor blackColor];
    opacityRangeValue.numberOfLines = 1;
    opacityRangeValue.adjustsFontSizeToFitWidth = YES;
    opacityRangeValue.backgroundColor = [UIColor clearColor];
    opacityRangeValue.text = obj.opacity_range;
    [rowOne addSubview:opacityRangeValue];
    
    UILabel *caliperValue = [[UILabel alloc] initWithFrame:CGRectMake(685, 8, 132, 20)];
    [caliperValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:13.0]];
    caliperValue.textColor = [UIColor blackColor];
    caliperValue.numberOfLines = 1;
    caliperValue.backgroundColor = [UIColor clearColor];
    caliperValue.text = obj.caliper;
    [rowOne addSubview:caliperValue];
    
    UILabel *recycledValue = [[UILabel alloc] initWithFrame:CGRectMake(812, 8, 132, 20)];
    [recycledValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:13.0]];
    recycledValue.textColor = [UIColor blackColor];
    recycledValue.numberOfLines = 1;
    recycledValue.backgroundColor = [UIColor clearColor];
    recycledValue.text = obj.recycled_percentage;
    [rowOne addSubview:recycledValue];
    
    /************************************ table row two *********************************************/
    
    /***** Labels *******/
    UILabel *typeOneLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 200, 132, 20)];
    [typeOneLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    typeOneLabel.textColor = [UIColor blackColor];
    typeOneLabel.numberOfLines = 1;
    typeOneLabel.backgroundColor = [UIColor clearColor];
    typeOneLabel.text = @"TYPE";
    [modalView addSubview:typeOneLabel];
    
    UILabel *typeTwoLabel = [[UILabel alloc] initWithFrame:CGRectMake(126, 200, 132, 20)];
    [typeTwoLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    typeTwoLabel.textColor = [UIColor blackColor];
    typeTwoLabel.numberOfLines = 1;
    typeTwoLabel.backgroundColor = [UIColor clearColor];
    typeTwoLabel.text = @"TYPE";
    [modalView addSubview:typeTwoLabel];
    
    UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(268, 200, 132, 20)];
    [categoryLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    categoryLabel.textColor = [UIColor blackColor];
    categoryLabel.numberOfLines = 1;
    categoryLabel.backgroundColor = [UIColor clearColor];
    categoryLabel.text = @"CATEGORY";
    [modalView addSubview:categoryLabel];
    
    UILabel *colorCapabilityLabel = [[UILabel alloc] initWithFrame:CGRectMake(406, 183, 122, 40)];
    [colorCapabilityLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    colorCapabilityLabel.textColor = [UIColor blackColor];
    colorCapabilityLabel.numberOfLines = 2;
    colorCapabilityLabel.backgroundColor = [UIColor clearColor];
    colorCapabilityLabel.text = @"COLOR CAPABILITY";
    [modalView addSubview:colorCapabilityLabel];
    
    UILabel *weightsLabel = [[UILabel alloc] initWithFrame:CGRectMake(550, 183, 112, 40)];
    [weightsLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    weightsLabel.textColor = [UIColor blackColor];
    weightsLabel.numberOfLines = 2;
    weightsLabel.backgroundColor = [UIColor clearColor];
    weightsLabel.text = @"WEIGHTS AVAILABLE";
    [modalView addSubview:weightsLabel];
    
    UILabel *boostSampleAvailableLabel = [[UILabel alloc] initWithFrame:CGRectMake(685, 183, 132, 40)];
    [boostSampleAvailableLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    boostSampleAvailableLabel.textColor = [UIColor blackColor];
    boostSampleAvailableLabel.numberOfLines = 2;
    boostSampleAvailableLabel.backgroundColor = [UIColor clearColor];
    boostSampleAvailableLabel.text = @"BOOST SAMPLE AVAILABLE";
    [modalView addSubview:boostSampleAvailableLabel];
    
    UILabel *houseLabel = [[UILabel alloc] initWithFrame:CGRectMake(812, 200, 132, 20)];
    [houseLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    houseLabel.textColor = [UIColor blackColor];
    houseLabel.numberOfLines = 1;
    houseLabel.backgroundColor = [UIColor clearColor];
    houseLabel.text = @"HOUSE PAPER";
    [modalView addSubview:houseLabel];
    
    UIView *rowLineTwo = [[UIView alloc] initWithFrame:CGRectMake(0, 225, 944, 1)];
    rowLineTwo.backgroundColor = [UIColor blackColor];
    [modalView addSubview:rowLineTwo];
    
    UIView *rowTwo = [[UIView alloc] initWithFrame:CGRectMake(0, 226, 944, 40)];
    rowTwo.backgroundColor = [UIColor colorWithRed:221.0f/255.0f green:221.0f/255.0f blue:221.0f/255.0f alpha:1.0];
    [modalView addSubview:rowTwo];
    
    /***** Values *******/
    
    UILabel *typeOneValue = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 132, 20)];
    [typeOneValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:13.0]];
    typeOneValue.textColor = [UIColor blackColor];
    typeOneValue.numberOfLines = 1;
    typeOneValue.backgroundColor = [UIColor clearColor];
    typeOneValue.text = obj.type_one;
    [rowTwo addSubview:typeOneValue];
    
    UILabel *typeTwoValue = [[UILabel alloc] initWithFrame:CGRectMake(126, 10, 132, 20)];
    [typeTwoValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:13.0]];
    typeTwoValue.textColor = [UIColor blackColor];
    typeTwoValue.numberOfLines = 1;
    typeTwoValue.backgroundColor = [UIColor clearColor];
    typeTwoValue.text = obj.type_two;
    [rowTwo addSubview:typeTwoValue];
    
    UILabel *categoryValue = [[UILabel alloc] initWithFrame:CGRectMake(268, 10, 132, 20)];
    [categoryValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:13.0]];
    categoryValue.textColor = [UIColor blackColor];
    categoryValue.numberOfLines = 1;
    categoryValue.backgroundColor = [UIColor clearColor];
    categoryValue.text = obj.category;
    [rowTwo addSubview:categoryValue];
    
    //color capability
    int colorValue = [obj.color_capability intValue], xValue = 406;
    if(colorValue > 3) xValue = 390;
    
    UIView *colorIconSet = [self getColorIconSet:NO withXValue:xValue andYValue:10 withColorValue:[obj.color_capability intValue]];
    [rowTwo addSubview:colorIconSet];
    
    UILabel *weightsAvailableValue = [[UILabel alloc] initWithFrame:CGRectMake(550, 10, 122, 20)];
    [weightsAvailableValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:13.0]];
    weightsAvailableValue.textColor = [UIColor blackColor];
    weightsAvailableValue.numberOfLines = 1;
    weightsAvailableValue.adjustsFontSizeToFitWidth = YES;
    weightsAvailableValue.backgroundColor = [UIColor clearColor];
    weightsAvailableValue.text = obj.weights_available;
    [rowTwo addSubview:weightsAvailableValue];
    
    UILabel *boostSampleAvailableValue = [[UILabel alloc] initWithFrame:CGRectMake(685, 10, 132, 20)];
    [boostSampleAvailableValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:13.0]];
    boostSampleAvailableValue.textColor = [UIColor blackColor];
    boostSampleAvailableValue.numberOfLines = 1;
    boostSampleAvailableValue.backgroundColor = [UIColor clearColor];
    boostSampleAvailableValue.text = obj.boost_sample;
    [rowTwo addSubview:boostSampleAvailableValue];
    
    UILabel *housePaperValue = [[UILabel alloc] initWithFrame:CGRectMake(812, 10, 132, 20)];
    [housePaperValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:13.0]];
    housePaperValue.textColor = model.pink;
    housePaperValue.numberOfLines = 1;
    housePaperValue.backgroundColor = [UIColor clearColor];
    housePaperValue.text = [obj.house_paper uppercaseString];
    [rowTwo addSubview:housePaperValue];
    
    /************************************ website button *********************************************/
    
    float w = (millWidth + 180);
    NSString *millWebsiteName = [NSString stringWithFormat:@"%@'s Website", obj.mill_name];
    
    //set the mill key so I can look up the URL later
    websiteKey = obj.mill;
    
    UIButton *websiteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [websiteButton setFrame:CGRectMake(20, 286, w, 40)];
    [websiteButton addTarget:self action:@selector(urlSelected:)forControlEvents:UIControlEventTouchDown];
    websiteButton.showsTouchWhenHighlighted = YES;
    websiteButton.backgroundColor = model.blue;
    [websiteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [websiteButton setTitle:[millWebsiteName uppercaseString] forState:UIControlStateNormal];
    [modalView addSubview:websiteButton];
    
    /************************************ keys ****************************************************/
    
    UIImageView *keyImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, 346, 33, 33)];
    [keyImage setImage:[UIImage imageNamed:@"icn-key.png"]];
    [modalView addSubview:keyImage];
    
    UILabel *keyTitle = [[UILabel alloc] initWithFrame:CGRectMake(73, 346, 500, 30)];
    [keyTitle setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:18.0]];
    keyTitle.textColor = [UIColor blackColor];
    keyTitle.numberOfLines = 1;
    keyTitle.backgroundColor = [UIColor clearColor];
    keyTitle.text = @"CATEGORY KEY";
    [modalView addSubview:keyTitle];
    
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 374, 190, 20)];
    [textLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    textLabel.textColor = [UIColor blackColor];
    textLabel.numberOfLines = 1;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.text = @"TEXT";
    [modalView addSubview:textLabel];
    
    UILabel *textValue = [[UILabel alloc] initWithFrame:CGRectMake(253, 374, 270, 20)];
    [textValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:15.0]];
    textValue.textColor = model.dullBlack;
    textValue.numberOfLines = 1;
    textValue.backgroundColor = [UIColor clearColor];
    textValue.text = @"UNTREATED B&W TEXT";
    [modalView addSubview:textValue];
    
    UIImageView *bwText = [[UIImageView alloc] initWithFrame:CGRectMake(513, 374, 15, 15)];
    [bwText setImage:[UIImage imageNamed:@"ico-blackwhite.png"]];
    [modalView addSubview:bwText];
    
    UILabel *textPlusLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 394, 190, 20)];
    [textPlusLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    textPlusLabel.textColor = [UIColor blackColor];
    textPlusLabel.numberOfLines = 1;
    textPlusLabel.backgroundColor = [UIColor clearColor];
    textPlusLabel.text = @"TEXT PLUS";
    [modalView addSubview:textPlusLabel];
    
    UILabel *textPlusValue = [[UILabel alloc] initWithFrame:CGRectMake(253, 394, 270, 20)];
    [textPlusValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:15.0]];
    textPlusValue.textColor = model.dullBlack;
    textPlusValue.numberOfLines = 1;
    textPlusValue.backgroundColor = [UIColor clearColor];
    textPlusValue.text = @"UNTREATED B & W 2/c, LIGHT 4/c";
    [modalView addSubview:textPlusValue];
    
    UIImageView *bwPlus = [[UIImageView alloc] initWithFrame:CGRectMake(513, 394, 15, 15)];
    [bwPlus setImage:[UIImage imageNamed:@"ico-blackwhite.png"]];
    [modalView addSubview:bwPlus];
    
    UIImageView *colorOnePlus = [[UIImageView alloc] initWithFrame:CGRectMake(533, 394, 15, 15)];
    [colorOnePlus setImage:[UIImage imageNamed:@"ico-color.png"]];
    [modalView addSubview:colorOnePlus];
    
    UILabel *productionLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 414, 190, 20)];
    [productionLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    productionLabel.textColor = [UIColor blackColor];
    productionLabel.numberOfLines = 1;
    productionLabel.backgroundColor = [UIColor clearColor];
    productionLabel.text = @"PRODUCTION";
    [modalView addSubview:productionLabel];
    
    UILabel *productionValue = [[UILabel alloc] initWithFrame:CGRectMake(253, 414, 270, 20)];
    [productionValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:15.0]];
    productionValue.textColor = model.dullBlack;
    productionValue.numberOfLines = 1;
    productionValue.backgroundColor = [UIColor clearColor];
    productionValue.text = @"TREATED 2/C, 4/C";
    [modalView addSubview:productionValue];
    
    UIImageView *bwProduction = [[UIImageView alloc] initWithFrame:CGRectMake(513, 414, 15, 15)];
    [bwProduction setImage:[UIImage imageNamed:@"ico-blackwhite.png"]];
    [modalView addSubview:bwProduction];
    
    UIImageView *colorOneProduction = [[UIImageView alloc] initWithFrame:CGRectMake(533, 414, 15, 15)];
    [colorOneProduction setImage:[UIImage imageNamed:@"ico-color.png"]];
    [modalView addSubview:colorOneProduction];
    
    UIImageView *colorTwoProduction = [[UIImageView alloc] initWithFrame:CGRectMake(553, 414, 15, 15)];
    [colorTwoProduction setImage:[UIImage imageNamed:@"ico-color.png"]];
    [modalView addSubview:colorTwoProduction];
    
    UILabel *productionPlusLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 434, 190, 20)];
    [productionPlusLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    productionPlusLabel.textColor = [UIColor blackColor];
    productionPlusLabel.numberOfLines = 1;
    productionPlusLabel.backgroundColor = [UIColor clearColor];
    productionPlusLabel.text = @"PRODUCTION PLUS";
    [modalView addSubview:productionPlusLabel];
    
    UILabel *productionPlusValue = [[UILabel alloc] initWithFrame:CGRectMake(253, 434, 270, 20)];
    [productionPlusValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:15.0]];
    productionPlusValue.textColor = model.dullBlack;
    productionPlusValue.numberOfLines = 1;
    productionPlusValue.backgroundColor = [UIColor clearColor];
    productionPlusValue.text = @"TREATED HIGH QUALITY 4/C";
    [modalView addSubview:productionPlusValue];
    
    UIImageView *bwProductionPlus = [[UIImageView alloc] initWithFrame:CGRectMake(513, 434, 15, 15)];
    [bwProductionPlus setImage:[UIImage imageNamed:@"ico-blackwhite.png"]];
    [modalView addSubview:bwProductionPlus];
    
    UIImageView *colorOneProductionPlus = [[UIImageView alloc] initWithFrame:CGRectMake(533, 434, 15, 15)];
    [colorOneProductionPlus setImage:[UIImage imageNamed:@"ico-color.png"]];
    [modalView addSubview:colorOneProductionPlus];
    
    UIImageView *colorTwoProductionPlus = [[UIImageView alloc] initWithFrame:CGRectMake(553, 434, 15, 15)];
    [colorTwoProductionPlus setImage:[UIImage imageNamed:@"ico-color.png"]];
    [modalView addSubview:colorTwoProductionPlus];
    
    UIImageView *colorThreeProductionPlus = [[UIImageView alloc] initWithFrame:CGRectMake(573, 434, 15, 15)];
    [colorThreeProductionPlus setImage:[UIImage imageNamed:@"ico-color.png"]];
    [modalView addSubview:colorThreeProductionPlus];
    
    UILabel *premiumLabel = [[UILabel alloc] initWithFrame:CGRectMake(73, 454, 190, 20)];
    [premiumLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    premiumLabel.textColor = [UIColor blackColor];
    premiumLabel.numberOfLines = 1;
    premiumLabel.backgroundColor = [UIColor clearColor];
    premiumLabel.text = @"PREMIUM";
    [modalView addSubview:premiumLabel];
    
    UILabel *premiumPlusValue = [[UILabel alloc] initWithFrame:CGRectMake(253, 454, 270, 20)];
    [premiumPlusValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:15.0]];
    premiumPlusValue.textColor = model.dullBlack;
    premiumPlusValue.numberOfLines = 1;
    premiumPlusValue.backgroundColor = [UIColor clearColor];
    premiumPlusValue.text = @"COATED PREMIUM QUALITY 4/C";
    [modalView addSubview:premiumPlusValue];
    
    UIImageView *bwPremium = [[UIImageView alloc] initWithFrame:CGRectMake(513, 454, 15, 15)];
    [bwPremium setImage:[UIImage imageNamed:@"ico-blackwhite.png"]];
    [modalView addSubview:bwPremium];
    
    UIImageView *colorOnePremium = [[UIImageView alloc] initWithFrame:CGRectMake(533, 454, 15, 15)];
    [colorOnePremium setImage:[UIImage imageNamed:@"ico-color.png"]];
    [modalView addSubview:colorOnePremium];
    
    UIImageView *colorTwoPremium = [[UIImageView alloc] initWithFrame:CGRectMake(553, 454, 15, 15)];
    [colorTwoPremium setImage:[UIImage imageNamed:@"ico-color.png"]];
    [modalView addSubview:colorTwoPremium];
    
    UIImageView *colorThreePremium = [[UIImageView alloc] initWithFrame:CGRectMake(573, 454, 15, 15)];
    [colorThreePremium setImage:[UIImage imageNamed:@"ico-color.png"]];
    [modalView addSubview:colorThreePremium];
    
    UIImageView *colorFourPremium = [[UIImageView alloc] initWithFrame:CGRectMake(593, 454, 15, 15)];
    [colorFourPremium setImage:[UIImage imageNamed:@"ico-color.png"]];
    [modalView addSubview:colorFourPremium];
    
    /************************************ price range info *******************************************/
    
    UILabel *priceTitle = [[UILabel alloc] initWithFrame:CGRectMake(660, 346, 300, 30)];
    [priceTitle setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:18.0]];
    priceTitle.textColor = [UIColor blackColor];
    priceTitle.numberOfLines = 1;
    priceTitle.backgroundColor = [UIColor clearColor];
    priceTitle.text = @"PRICE RANGE INFORMATION";
    [modalView addSubview:priceTitle];
    
    UILabel *oneLabel = [[UILabel alloc] initWithFrame:CGRectMake(660, 374, 80, 20)];
    [oneLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    oneLabel.textColor = model.green;
    oneLabel.numberOfLines = 1;
    oneLabel.backgroundColor = [UIColor clearColor];
    oneLabel.text = @"$";
    [modalView addSubview:oneLabel];
    
    UILabel *oneValue = [[UILabel alloc] initWithFrame:CGRectMake(760, 374, 200, 20)];
    [oneValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:15.0]];
    oneValue.textColor = model.dullBlack;
    oneValue.numberOfLines = 1;
    oneValue.backgroundColor = [UIColor clearColor];
    oneValue.text = @"O TO 53 PER CWT.";
    [modalView addSubview:oneValue];
    
    UILabel *twoLabel = [[UILabel alloc] initWithFrame:CGRectMake(660, 394, 80, 20)];
    [twoLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    twoLabel.textColor = model.green;
    twoLabel.numberOfLines = 1;
    twoLabel.backgroundColor = [UIColor clearColor];
    twoLabel.text = @"$$";
    [modalView addSubview:twoLabel];
    
    UILabel *twoValue = [[UILabel alloc] initWithFrame:CGRectMake(760, 394, 200, 20)];
    [twoValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:15.0]];
    twoValue.textColor = model.dullBlack;
    twoValue.numberOfLines = 1;
    twoValue.backgroundColor = [UIColor clearColor];
    twoValue.text = @"54 TO 69 PER CWT.";
    [modalView addSubview:twoValue];
    
    UILabel *threeLabel = [[UILabel alloc] initWithFrame:CGRectMake(660, 414, 80, 20)];
    [threeLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    threeLabel.textColor = model.green;
    threeLabel.numberOfLines = 1;
    threeLabel.backgroundColor = [UIColor clearColor];
    threeLabel.text = @"$$$";
    [modalView addSubview:threeLabel];
    
    UILabel *threeValue = [[UILabel alloc] initWithFrame:CGRectMake(760, 414, 200, 20)];
    [threeValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:15.0]];
    threeValue.textColor = model.dullBlack;
    threeValue.numberOfLines = 1;
    threeValue.backgroundColor = [UIColor clearColor];
    threeValue.text = @"70 TO 90 CWT.";
    [modalView addSubview:threeValue];
    
    UILabel *fourLabel = [[UILabel alloc] initWithFrame:CGRectMake(660, 434, 80, 20)];
    [fourLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:15.0]];
    fourLabel.textColor = model.green;
    fourLabel.numberOfLines = 1;
    fourLabel.backgroundColor = [UIColor clearColor];
    fourLabel.text = @"$$$$";
    [modalView addSubview:fourLabel];
    
    UILabel *fourValue = [[UILabel alloc] initWithFrame:CGRectMake(760, 434, 200, 20)];
    [fourValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:15.0]];
    fourValue.textColor = model.dullBlack;
    fourValue.numberOfLines = 1;
    fourValue.backgroundColor = [UIColor clearColor];
    fourValue.text = @"90+ CWT.";
    [modalView addSubview:fourValue];
    
    /************************************ notices ****************************************************/

    
    UILabel *notice = [[UILabel alloc] initWithFrame:CGRectMake(20, 500, 904, 50)];
    [notice setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:12.0]];
    notice.textColor = model.dullBlack;
    notice.text = @"NOTE: All papers on this list are available in the use either from the mill directly or through distribution. Some papers may require a minimum order from the mill. Availability can and will change based on supply and demand for papers, contact your mill or distributor for the most up to date availablility. Many mills will have stocking levels incicated on their web sites with the most up to date information. Follow the links provided to access mill web sites.";
    notice.numberOfLines = 4;
    notice.backgroundColor = [UIColor clearColor];
    [modalView addSubview:notice];
    
    UILabel *noticeTwo = [[UILabel alloc] initWithFrame:CGRectMake(20, 570, 904, 50)];
    [noticeTwo setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:12.0]];
    noticeTwo.textColor = model.blue;
    noticeTwo.text = @"The papers listed in this document have been evaluated on Canon Solutions America and Oce production printing equipment. Canon Solutions America does not guarantee the performance or availability of any papers listed. Results may vary.This list is only to be used as a guide for selecting papers for further testing in specific applications. For more information consult your local sales represenitive It is recommended that a paper trial including linerization of the trial.";
    noticeTwo.numberOfLines = 4;
    noticeTwo.backgroundColor = [UIColor clearColor];
    [modalView addSubview:noticeTwo];
    
    
    return modalView;
}



- (void)overlayTapped:(UITapGestureRecognizer *)sender
{
    UIView *theSuperview = self.view; // whatever view contains your image views
    CGPoint touchPointInSuperview = [sender locationInView:theSuperview];
    UIView *touchedView = [theSuperview hitTest:touchPointInSuperview withEvent:nil];
    if([touchedView isKindOfClass:[UIView class]])
    {
        [self hideOverlay];
        websiteKey = @"";
    }
}

-(void)closeOverlay:(id)sender
{
    [self hideOverlay];
}

-(void)hideOverlay
{
    [UIView animateWithDuration:0.8f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
        overlay.alpha = 0.0;
        globalModal. alpha = 0.0;
    }completion:^(BOOL finished) {
        //remove the present modal box
        modalViewPresent = NO;
        if([self.view viewWithTag:2020] != nil){
            [[self.view viewWithTag:2020] removeFromSuperview];
        }
    }];
}

/*********************************************************************************************************************
 *
 *  Network Delegate Functions
 *
 *********************************************************************************************************************/

//function to delegate interaction with the user about whether or not they want to update
//the application data
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //dismiss
    if(buttonIndex == 0){
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
    //download
    if (buttonIndex == 1){
        
        if([model.hostReachability isReachableViaWiFi]){
            //we have now loaded
            model.needsUpdate = YES;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [self displayMessage:@"Please connect to the internet to update the application" withTitle:@"Alert"];
        }
    }
}


//function that is called when the video is done downloading
//this function adds the video URL to the button as the title for download
/*
-(void)videoDownloadResponse:(BOOL)flag
{
   
    UIView *v = [videoButton viewWithTag:110];
    [v removeFromSuperview];
    
    if(flag){
        [videoButton setImage:[UIImage imageNamed:@"icn-load.png"] forState:UIControlStateNormal];
        videoButton.tag = 777;

        [videoButton setTitle:[self.model returnFilePath:downloadingURL] forState:UIControlStateNormal];
    }else{
        [self displayMessage:@"OOPS! Something went wrong downloading your video.  Please make sure you are connected to the internet and try again." withTitle:@"Alert"];
    }
}*/

//network delegate function called when a response is sent back to the main thread
//this response will let the view and the user know that there is an update available
-(void)updateResponse:(CanonModel *)obj withFlag:(BOOL)flag{
    
    //update available
    if(flag){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update App"
                                                        message:@"There is an update available, do you wish to download now?"
                                                       delegate:self cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}



/*********************************************************************************************************************
 *
 *  Utility Functions for the ViewController
 *
 *********************************************************************************************************************/

//this function builds a data set to use for just the paper table
-(void)buildPaperTableData
{
    
    //get the mill key from the selected mill we are on
    NSString *millKey = model.selectedMill.key;
    
    
    //resets the table row count
    tableRows = 0;
    tableColumns = 7;
    ALog(@"HERE1");
    //loop through the papers in the initial dataset
    for(Paper *p in model.initialSetOfPaper){
        //check to see if the paper is equal to present mills key
        if([millKey isEqualToString:p.mill]){
            
            //the client asked us to create new row for eacy basis weight
            if([p.basis_weight count] > 0){
                //create a new row for each basis weight
                for(NSString *weight in p.basis_weight){
                    NSMutableArray *rowArray = [[NSMutableArray alloc] init];
                    
                    [rowArray addObject:p.title];
                    
                    [rowArray addObject:weight];
                    [rowArray addObject:p.brightness];
                    [rowArray addObject:p.coating];
                
                    [rowArray addObject:p.color_capability];
                    [rowArray addObject:p.category];
                    [rowArray addObject:p.dye_pigment];
                    [rowArray addObject:p.key];
                
                    tableRows++;
                    [paperData addObject:rowArray];
                }
            }else{
                
            }
        }
        
    }
    ALog(@"HERE2");
    //if the dataset is empty, flag it for later display
    if([paperData count] == 0){
        tableEmpty = YES;
    }else{
        tableEmpty = NO;
    }
    ALog(@"HERE3");
}

//this function is more generalized and assembles all of the paper data
-(void)buildAllPaperData
{
    
    tableRows = 0;
    tableColumns = 8;
    
    for(Paper *p in model.initialSetOfPaper){

        if([p.basis_weight count] > 0){
            //create a new row for each basis weight
            for(NSString *weight in p.basis_weight){
                NSMutableArray *rowArray = [[NSMutableArray alloc] init];
                //note this array has one more column in it that the paper data did
                //also, we are not searching for a dataset based upon a key, but selecting all
                SearchablePaper *sp = [[SearchablePaper alloc] init];
                
                [rowArray addObject:p.mill_name];
                sp.mill_name = p.mill_name;
                
                [rowArray addObject:p.title];
                sp.title = p.title;
                
                [rowArray addObject:weight];
                sp.basis_weight = weight;
                
                [rowArray addObject:p.brightness];
                sp.brightness = p.brightness;
                
                [rowArray addObject:p.coating];
                sp.coating = p.coating;
                
                [rowArray addObject:p.color_capability];
                sp.color_capability = p.color_capability;
                
                [rowArray addObject:p.category];
                sp.category = p.category;
                
                [rowArray addObject:p.dye_pigment];
                sp.dye_pigment = p.dye_pigment;
                
                [rowArray addObject:p.key];
                
                [model.searchablePaperDataObjects addObject:sp];
                
                tableRows++;
                [paperData addObject:rowArray];
            }
        }
    }
    //if the dataset is empty, flag it for later display
    if([paperData count] == 0){
        tableEmpty = YES;
    }else{
        tableEmpty = NO;
    }

}


//universal view function to display dynamic alerts
-(void)displayMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *error = [[UIAlertView alloc] initWithTitle:title message: message
                                                   delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
    [error show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
