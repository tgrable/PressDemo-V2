//
//  PartnerViewController.m
//  PressDemo
//
//  Created by Trekk mini-1 on 12/15/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "PartnerViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIButton+Extensions.h"

#define ResourcePath(path)[[NSBundle mainBundle] pathForResource:path ofType:nil]

#define ImageWithPath(path)[UIImage imageWithContentsOfFile:path]
#define kMaxHeight 1000.0f

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation PartnerViewController

@synthesize customNavBar, sideBar, mainView, videoButton;
@synthesize model, network, navBarHomeButton, offlineImages;

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
                        [i setImageWithURL:key placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
                    else
                        [i setImageWithURL:key placeholderImage:[UIImage imageNamed:@"overviewPlaceholder.png"]];
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
    
    self.screenName = @"Partner View";
    
    network = [[NetworkData alloc] init];
    network.delegate = self;
    
    model = [self AppDataObj];
    
    //***** Load up views to the local view controller ************//
    //the nav bar
    customNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 1024, 64)];
    [customNavBar setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:customNavBar];
    
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
    
    /*** actual document banner **/
    actualDocumentView = [[UIView alloc] initWithFrame:CGRectMake(0, 884, 776, 684)];
    actualDocumentView.backgroundColor = [UIColor whiteColor];
    actualDocumentView.userInteractionEnabled = YES;
    [mainView addSubview:actualDocumentView];
    
    documentHeaderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [documentHeaderButton setFrame:CGRectMake(0, 0, 776, 160)];
    [documentHeaderButton addTarget:self action:@selector(loadUpMainTray:)forControlEvents:UIControlEventTouchDown];
    documentHeaderButton.showsTouchWhenHighlighted = YES;
    documentHeaderButton.tag = 25;
    documentHeaderButton.backgroundColor = [UIColor clearColor];
    [actualDocumentView addSubview:documentHeaderButton];
    
    actualDocumentBanner = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 776, 173)];
    actualDocumentBanner.backgroundColor = [UIColor whiteColor];
    [actualDocumentView addSubview:actualDocumentBanner];
    
    documentLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 50, 670, 36)];
    [documentLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:24.0]];
    documentLabel.textColor = [UIColor whiteColor];
    documentLabel.numberOfLines = 1;
    documentLabel.backgroundColor = [UIColor clearColor];
    [actualDocumentBanner addSubview:documentLabel];
    
    webPage = [[UIWebView alloc] initWithFrame:CGRectMake(36, 209, 704, 445)];
    webPage.backgroundColor = [UIColor whiteColor];
    webPage.scrollView.scrollEnabled = YES;
    webPage.userInteractionEnabled = YES;
    webPage.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin ;
    [actualDocumentView addSubview:webPage];
    
    /*** document container views ***/
    documentContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 776, 684)];
    [mainView addSubview:documentContainer];
    
    documentScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(14, 44, 748, 628)];
    documentScroll.showsHorizontalScrollIndicator = NO;
    documentScroll.showsVerticalScrollIndicator = YES;
    documentScroll.scrollEnabled = YES;
    documentScroll.delegate = self;
    documentScroll.backgroundColor = [UIColor clearColor];
    [documentContainer addSubview:documentScroll];
    
    /*** overview container objects/views ***/
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
    
    mainShortBanner = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 776, 64)];
    [mainShortBanner setUserInteractionEnabled:YES];
    mainShortBanner.image = [UIImage imageNamed:@"hdr-short-orange.png"];
    [mainView addSubview:mainShortBanner];
    
    bannerTitle = [[UILabel alloc] initWithFrame:CGRectMake(35, 9, 680, 32)];
    [bannerTitle setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:24.0]];
    bannerTitle.textColor = [UIColor whiteColor];
    bannerTitle.numberOfLines = 1;
    bannerTitle.adjustsFontSizeToFitWidth = YES;
    bannerTitle.backgroundColor = [UIColor clearColor];
    [mainShortBanner addSubview:bannerTitle];
    
    overviewContent = [[UIScrollView alloc] initWithFrame:CGRectMake(36, 342, 712, 342)];
    overviewContent.showsHorizontalScrollIndicator = NO;
    overviewContent.showsVerticalScrollIndicator = YES;
    overviewContent.scrollEnabled = YES;
    overviewContent.delegate = self;
    overviewContent.backgroundColor = [UIColor clearColor];
    [overviewContainer addSubview:overviewContent];
    
    partnerLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120, 120)];
    partnerLogo.contentMode = UIViewContentModeScaleAspectFit;
    partnerLogo.userInteractionEnabled = YES;
    [overviewContent addSubview:partnerLogo];
    
    //name of the mill next to the logo in the overview container
    partnerHeader = [[UILabel alloc] initWithFrame:CGRectMake(140, 12, 350, 32)];
    [partnerHeader setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:22.0]];
    partnerHeader.textColor = model.dullBlack;
    partnerHeader.numberOfLines = 1;
    partnerHeader.adjustsFontSizeToFitWidth = YES;
    partnerHeader.backgroundColor = [UIColor clearColor];
    [overviewContent addSubview:partnerHeader];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(140, 52, 350, 1)];
    line.backgroundColor = model.dullBlack;
    [overviewContent addSubview:line];
    
    partnerDescription = [[UITextView alloc] initWithFrame:CGRectMake(134, 66, 340, 270)];
    partnerDescription.editable = NO;
    partnerDescription.clipsToBounds = YES;
    partnerDescription.font = [UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0];
    partnerDescription.backgroundColor = [UIColor clearColor];
    partnerDescription.scrollEnabled = NO;
    partnerDescription.textColor = model.dullBlack;
    [overviewContent addSubview:partnerDescription];
    
    solutionHeader = [[UILabel alloc] initWithFrame:CGRectMake(524, 14, 188, 32)];
    [solutionHeader setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
    solutionHeader.textColor = model.dullBlack;
    solutionHeader.numberOfLines = 1;
    solutionHeader.backgroundColor = [UIColor clearColor];
    [overviewContent addSubview:solutionHeader];
    
    UIView *lineSolutions = [[UIView alloc] initWithFrame:CGRectMake(524, 52, 350, 1)];
    lineSolutions.backgroundColor = model.dullBlack;
    [overviewContent addSubview:lineSolutions];
    
  
    
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
    
    //white paper button
    whitePaper = [UIButton buttonWithType:UIButtonTypeCustom];
    [whitePaper setFrame:CGRectMake(36, 162, 178, 36)];
    [whitePaper addTarget:self action:@selector(loadUpMainTray:)forControlEvents:UIControlEventTouchDown];
    whitePaper.showsTouchWhenHighlighted = YES;
    whitePaper.tag = 162;
    whitePaper.titleLabel.text = @"white_papers";
    whitePaper.backgroundColor = [UIColor clearColor];
    [sideBar addSubview:whitePaper];
    
    whitePaperIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [whitePaperIcon setImage:[UIImage imageNamed:@"icn-whitepaper.png"]];
    [whitePaper addSubview:whitePaperIcon];
    
    whitePaperLabel = [[UILabel alloc] initWithFrame:CGRectMake(53, 0, 125, 36)];
    [whitePaperLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
    whitePaperLabel.textColor = model.dullBlack;
    whitePaperLabel.numberOfLines = 2;
    whitePaperLabel.backgroundColor = [UIColor clearColor];
    whitePaperLabel.text = @"WHITE PAPERS";
    [whitePaper addSubview:whitePaperLabel];
    
    caseStudy = [UIButton buttonWithType:UIButtonTypeCustom];
    [caseStudy setFrame:CGRectMake(36, 228, 178, 36)];
    [caseStudy addTarget:self action:@selector(loadUpMainTray:)forControlEvents:UIControlEventTouchDown];
    caseStudy.showsTouchWhenHighlighted = YES;
    caseStudy.tag = 228;
    caseStudy.titleLabel.text = @"case_studies";
    caseStudy.backgroundColor = [UIColor clearColor];
    [sideBar addSubview:caseStudy];
    
    caseStudyIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [caseStudyIcon setImage:[UIImage imageNamed:@"icn-casestudy.png"]];
    [caseStudy addSubview:caseStudyIcon];
    
    caseStudyLabel = [[UILabel alloc] initWithFrame:CGRectMake(53, 0, 125, 36)];
    [caseStudyLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
    caseStudyLabel.textColor = model.dullBlack;
    caseStudyLabel.numberOfLines = 2;
    caseStudyLabel.backgroundColor = [UIColor clearColor];
    caseStudyLabel.text = @"CASE STUDIES";
    [caseStudy addSubview:caseStudyLabel];
    
    currentDocumentData = [[NSMutableDictionary alloc] init];
    offlineImages = [[NSMutableDictionary alloc] init];
    offlineVideos = [[NSMutableDictionary alloc] init];
    offlineVideoRows = [NSMutableArray array];
  
    
    [self setupLocalUserInterface:^(BOOL completeFlag){
        //GA
        //[model logData:@"Series View" withAction:@"View Tracker" withLabel:[NSString stringWithFormat:@"Landed on series view: %@", model.selectedPartner.title]];
    }];
    
    downloadingURL = @"";
}


//this function moves around the content in the main view of the app
-(void)loadUpMainTray:(id)sender
{
    UIButton *b = (UIButton *)sender;
    
    //make sure that we are properly displaying the title of the section the user just selected
    
    if([b.titleLabel.text isEqualToString:@"videos"]){
        //add the small main header
        bannerTitle.text = [NSString stringWithFormat:@"%@ : VIDEOS",[model.selectedPartner.title uppercaseString]];
    }else if([b.titleLabel.text isEqualToString:@"white_papers"]){
        //add the small main header
        bannerTitle.text = [NSString stringWithFormat:@"%@ : WHITE PAPERS",[model.selectedPartner.title uppercaseString]];
    }else if([b.titleLabel.text isEqualToString:@"case_studies"]){
        //add the small main header
        bannerTitle.text = [NSString stringWithFormat:@"%@ : CASE STUDIES",[model.selectedPartner.title uppercaseString]];
    }
    
    //if overview is present
    if(sidebarIndicator.frame.origin.y == 30){
        
        [self tearDownAndLoadUpDocuments:b.titleLabel.text withComplete:^(BOOL completeFlag){
            //perform the animation
            [UIView animateWithDuration:1.2f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                overviewContainer.alpha = 0.0;
                overviewImageDots.alpha = 0.0;
                documentContainer.alpha = 1.0;
            }completion:^(BOOL finished) {
                
            }];
        }];
        //switching from document back to overview
    }else if([b.titleLabel.text isEqualToString:@"overview"]){
        [self rearrangeDocumentStack];
 
        //perform the animation
        [UIView animateWithDuration:1.2f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            overviewContainer.alpha = 1.0;
            overviewImageDots.alpha = 1.0;
            documentContainer.alpha = 0.0;
        }completion:^(BOOL finished) {
            
        }];
        //switching from actual document to document
    }else if(actualDocumentView.frame.origin.y < 884){
        overviewContainer.alpha = 0.0;
        [self rearrangeDocumentStack];

        //perform the animation to move the documet
        [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            actualDocumentView.frame = CGRectMake(1040, 44, 776, 684);
            actualDocumentView.alpha = 0.0;
        }completion:^(BOOL finished) {
            [self tearDownAndLoadUpDocuments:b.titleLabel.text withComplete:^(BOOL completeFlag){
                documentScroll.frame = CGRectMake(14, 44, 748, 628);
                [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                    documentScroll.alpha = 1.0;
                }completion:^(BOOL finished) {
                    actualDocumentView.frame = CGRectMake(0, 884, 776, 684);
                }];
            }];
        }];
    }else{
        overviewContainer.alpha = 0.0;
        [self rearrangeDocumentStack];

        [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
            documentScroll.frame = CGRectMake(1040, 44, 748, 628);
            documentScroll.alpha = 0.0;
        }completion:^(BOOL finished) {
            [self tearDownAndLoadUpDocuments:b.titleLabel.text withComplete:^(BOOL completeFlag){
                documentScroll.frame = CGRectMake(14, 44, 748, 628);
                [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                    documentScroll.alpha = 1.0;
                }completion:^(BOOL finished) {
                    
                }];
            }];
        }];
    }
    
    
    //animate the indicator
    [self animateSidebarIndicator:(int)b.tag];
    
}

//this function switches around the view index in the stack
-(void)rearrangeDocumentStack
{
    [mainView sendSubviewToBack:actualDocumentView];
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
    NSMutableArray *data = [model.selectedPartner valueForKey:flag];

    
    //remove video rows
    [offlineVideoRows removeAllObjects];
    
    
    //make sure we are dealing with an array, otherwise we can assume that their is no content assigned to this
    if([data isKindOfClass:[NSArray class]] && [data count] > 0){
        
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
            title.backgroundColor = [UIColor clearColor];
            [back addSubview:title];
            
            UIView *horizontalLine = [[UIView alloc] initWithFrame:CGRectMake(328, 40, 360, 1)];
            horizontalLine.backgroundColor = [UIColor blackColor];
            [back addSubview:horizontalLine];
            
            UITextView *desc = [[UITextView alloc] initWithFrame:CGRectMake(328, 47, 400, 121)];
            desc.textColor = model.dullBlack;
            desc.backgroundColor = [UIColor clearColor];
            [desc setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
            [desc setEditable:NO];
            [desc setScrollEnabled:NO];
            [back addSubview:desc];
            
            int offset = 0;
            
            /**** if the document is a video ****/
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
                    __weak typeof(UIImageView) *imgView = iv;
                    [iv setImageWithURL:[NSURL URLWithString:u] placeholderImage:[UIImage imageNamed:@"placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                        if(error){
                            ALog(@"Error %@", error);
                            imgView.image = [UIImage imageNamed:@"placeholder.png"];
                            //load the image view in an
                            [offlineImages setObject:imgView forKey:[NSURL URLWithString:u]];
                            model.layoutSync = NO;
                        }
                    }];
                    
                }
                
                //add the download video image to the video top right corner
                UIButton *download = [UIButton buttonWithType:UIButtonTypeCustom];
                [download setFrame:CGRectMake(717, 7, 24, 24)];
                [download addTarget:self action:@selector(downloadVideo:)forControlEvents:UIControlEventTouchUpInside];
                download.showsTouchWhenHighlighted = YES;
                [download setUserInteractionEnabled:YES];
                [download setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
                
                
                NSString *rawVideo = [v.rawVideo stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                
                NSString *name = [model getVideoFileName:rawVideo];
                NSString *lookupName = [name stringByReplacingOccurrencesOfString:@"%20" withString:@"_"];
                
                if([model fileExists:lookupName]){
                    [download setImage:[UIImage imageNamed:@"icn-load.png"] forState:UIControlStateNormal];
                    [download setTitle:[model returnFilePath:lookupName] forState:UIControlStateNormal];
                    download.tag = 777;
                }else{
                    [download setImage:[UIImage imageNamed:@"icn-download.png"] forState:UIControlStateNormal];
                    [download setTitle:rawVideo forState:UIControlStateNormal];
                    download.tag = 555;
                }
                
                [download setBackgroundColor:[UIColor whiteColor]];
                [download setHitTestEdgeInsets:UIEdgeInsetsMake(-15, -15, -15, -15)];
                [rowContainer addSubview:download];
                [rowContainer bringSubviewToFront:download];
                
                
                //set the data for the rest of the row
                title.text = v.title;
                desc.text = v.description;
                
                //make sure to resize the description after the text is added
                desc.frame = CGRectMake(328, 47, 400, desc.contentSize.height);
                [desc sizeToFit];
                //determine if our new size of the desc frame overflows the current frame
                if(desc.frame.size.height > 121){
                    //create an offset value if it does to alter the layou
                    offset =  desc.frame.size.height - 121;
                    rowContainer.frame = CGRectMake(0, y, 748, (179 + offset));
                }
                
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
            }else{
                
                /*************** Documents ************************/
                
                //set a document object from the selected object
                Document *d = [NSKeyedUnarchiver unarchiveObjectWithData:doc];
                //set the key for the object
                [back setTitle:d.key forState:UIControlStateNormal];
                
                if([d.image isEqualToString:@""]){
                    //if there is no url set for the image at all, use the fallback jason gave me
                    if([flag isEqualToString:@"case_study"]){
                        [iv setImage:[UIImage imageNamed:@"tmb-FPO-casestudy.png"]];
                    }else if([flag isEqualToString:@"white_paper"]){
                        [iv setImage:[UIImage imageNamed:@"tmb-FPO-whitepaper.png"]];
                    }
                    
                }else{
                    //try and load the image via the internet, otherwise use placeholder as a fallback
                    NSString *u = [d.image stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
                    __weak typeof(UIImageView) *imgView = iv;
                    [iv setImageWithURL:[NSURL URLWithString:u] placeholderImage:[UIImage imageNamed:@"placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                        if(error){
                            ALog(@"Error %@", error);
                            imgView.image = [UIImage imageNamed:@"placeholder.png"];
                            [offlineImages setObject:imgView forKey:[NSURL URLWithString:u]];
                            model.layoutSync = NO;
                        }
                    }];
                }
                
                //set the data for the rest of the row
                title.frame = CGRectMake(328, 16, 400, 24);
                title.text = d.title;
                
                //add the text
                desc.text = d.description;
                //make sure to resize the description after the text is added
                desc.frame = CGRectMake(328, 47, 400, desc.contentSize.height);
                [desc sizeToFit];
                //determine if our new size of the desc frame overflows the current frame
                if(desc.frame.size.height > 121){
                    //create an offset value if it does to alter the layou
                    offset =  desc.frame.size.height - 121;
                    rowContainer.frame = CGRectMake(0, y, 748, (179 + offset));
                }

                horizontalLine.frame = CGRectMake(328, 40, 400, 1);
                
                //add the data set of data being held for easy reference
                [currentDocumentData setObject:d forKey:d.key];
            }
            //add sub view to the scroll container
            [documentScroll addSubview:rowContainer];
            i++;
            y += offset;
            
            //make sure to adjust the top of the image container if the row was expanded
            iv.frame = CGRectMake(3, (offset / 2) + 3, 308, 173);
            
            if(i == count){
                [documentScroll setContentSize:CGSizeMake(748, (y + 193))];
                completeFlag(YES);
            }
        }
        
    }else{
        //this mean there is not results
        //UIView *rowContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 748, 179)];
        //rowContainer.backgroundColor = [UIColor whiteColor];
        
        UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, 748, 80)];
        [desc setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:16.0]];
        desc.textColor = [UIColor whiteColor];
        desc.textAlignment = NSTextAlignmentCenter;
        desc.text = @"- NO CONTENT ASSOCIATED WITH THIS ITEM -";
        desc.numberOfLines = 2;
        desc.backgroundColor = [UIColor clearColor];
        //[rowContainer addSubview:desc];
        
        [documentScroll addSubview:desc];
        
        [documentScroll setContentSize:CGSizeMake(748, 300)];
        completeFlag(YES);
    }
    
    
}



//this function tells the application to either download the video or load the video from disk
-(void)downloadVideo:(id)sender
{
    UIButton *b = (UIButton *)sender;
    NSString *videoURLString = [b.titleLabel.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    /************ Download the video to disk ************************/
    if(b.tag == 555){

        if(network.videoDownloading){
            [self displayMessage:@"Another video is currently downloading." withTitle:@"Alret"];
        }else{
            //make sure we can access the internet first
            if([model.hostReachability isReachableViaWiFi]){
                videoButton = b;
                [b setImage:nil forState:UIControlStateNormal];
                UIActivityIndicatorView *gear = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                gear.frame = CGRectMake(0, 0, 16, 16);
                gear.alpha = 1.0;
                gear.tag = 110;
                [b addSubview:gear];
                [gear startAnimating];
                
                downloadingURL = [model getVideoFileName:videoURLString];
                downloadingURL = [downloadingURL stringByReplacingOccurrencesOfString:@"%20" withString:@"_"];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                    [network downloadVideo:videoURLString];
                });
                //GA
                [model logData:@"Series View" withAction:@"Action Tracker" withLabel:[NSString stringWithFormat:@"Selected Video to download: %@",videoURLString]];
            }else{
                [self displayMessage:@"Please connect to the internet to download this video" withTitle:@"Alret"];
            }
        }
        /************ Play the video from disk ************************/
    }else if(b.tag == 777){
        
        NSString *path = [videoURLString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if([model videoExists:path]){
            
            //NSString *p  = @"file:///var/mobile/Applications/B751E322-DE11-4813-8D8B-0F7589B9FDEF/Documents/CS3000_Flexibility_1.mp4";
            //apply the file transfer protocol on to this path to make it a url
            NSString *urlPath = [NSString stringWithFormat:@"file://%@", path];
            NSURL *videoURL = [NSURL URLWithString:urlPath];
            MPMoviePlayerViewController *moviePlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
            [self presentMoviePlayerViewControllerAnimated:moviePlayerView];
            //GA
            [model logData:@"Series View" withAction:@"Action Tracker" withLabel:[NSString stringWithFormat:@"Selected Video to play from disk: %@",videoURLString]];
        }else{
            [self displayMessage:@"There was an error referencing your file" withTitle:@"Alert"];
        }
    }
    
    
}


//This function executes the functionality when a row is tapped on either a document of a video
-(void)rowTapped:(id)sender
{
    UIButton *b = (UIButton *)sender;
    
    //type of document
    if([[currentDocumentData objectForKey: b.titleLabel.text] isKindOfClass:[Document class]]){
        
        Document *d = [currentDocumentData objectForKey: b.titleLabel.text];
        
        if([d.type isEqualToString:@"white-paper"]){
            actualDocumentBanner.frame = CGRectMake(0, 0, 776, 173);
            webPage.frame = CGRectMake(36, 164, 704, 445);
            //white paper image assignement
            documentLabel.text = d.title;
            documentHeaderButton.titleLabel.text = @"white_papers";
            documentHeaderButton.tag = 228;
            [actualDocumentBanner setImage:[UIImage imageNamed:@"hdr-doc-whitepaper.png"]];
            //GA
            [model logData:@"Series View" withAction:@"Action Tracker" withLabel:[NSString stringWithFormat:@"Selected White Paper Document: %@",d.title]];
            
        }else if([d.type isEqualToString:@"case-study"]){
            //case study image assignment
            actualDocumentBanner.frame = CGRectMake(0, 0, 776, 173);
            webPage.frame = CGRectMake(36, 164, 704, 445);
            documentLabel.text = d.title;
            documentHeaderButton.titleLabel.text = @"case_studies";
            documentHeaderButton.tag = 294;
            [actualDocumentBanner setImage:[UIImage imageNamed:@"hdr-doc-casestudy.png"]];
            //GA
            [model logData:@"Series View" withAction:@"Action Tracker" withLabel:[NSString stringWithFormat:@"Selected Case Study Document: %@",d.title]];
            
        }
        //rearrange view stack
        [mainView bringSubviewToFront:actualDocumentView];
        [actualDocumentView bringSubviewToFront:webPage];
        [mainView bringSubviewToFront:mainShortBanner];
        
        NSData *html = [model getHTMLFile:d.data complete:^(BOOL completeFlag){}];
        [self loadUPWebpage:html complete:^(BOOL completeFlag){
            [UIView animateWithDuration:0.6f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                documentScroll.frame = CGRectMake(1040, 44, 748, 628);
                documentScroll.alpha = 0.0;
            }completion:^(BOOL finished) {
                documentScroll.frame = CGRectMake(14, 44, 748, 628);
                actualDocumentView.alpha = 1.0;
                
                [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionAllowAnimatedContent animations:^{
                    actualDocumentView.frame = CGRectMake(0, 44, 776, 684);
                }completion:^(BOOL finished) {
                    
                }];
            }];
        }];
        
        //**************type of video***********************
    }else{
        
        Video *v = [currentDocumentData objectForKey: b.titleLabel.text];
        NSString *name = [model getVideoFileName:v.rawVideo];
        NSString *lookupName = [name stringByReplacingOccurrencesOfString:@"%20" withString:@"_"];
        
        
        if([model.hostReachability isReachableViaWiFi]){
            //stream if reachable
            NSString *videoURLString = [v.streamingURL stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            NSURL *videoURL = [NSURL URLWithString:videoURLString];
            MPMoviePlayerViewController *moviePlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
            [self presentMoviePlayerViewControllerAnimated:moviePlayerView];
        }else{
            NSString *lookupNameAdvanced = [lookupName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            
            if([model fileExists:lookupNameAdvanced]){
                
                NSString *fullPath = [model returnFilePath:lookupNameAdvanced];
                NSString *urlPath = [NSString stringWithFormat:@"file://%@", fullPath];
                NSURL *videoURL = [NSURL URLWithString:urlPath];
                MPMoviePlayerViewController *moviePlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
                [self presentMoviePlayerViewControllerAnimated:moviePlayerView];
            }else{
                [self displayMessage:@"This video has not been downloaded to the device.  Please connect to the internet and stream the video, or download the video for offline usage." withTitle:@"Alert!"];
            }
        }
        
    }
    
}
//this function loads up the UIWebView with data and sends back a completed flag when done
-(void)loadUPWebpage:(NSData *)data complete:(completeBlock)completeFlag
{
    [webPage loadData:data MIMEType: @"text/html" textEncodingName: @"UTF-8" baseURL:nil];
    completeFlag(YES);
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
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//this function sets up the disposable views and also sets up the overview view in the main portion of the app
-(void)setupLocalUserInterface:(completeBlock)completeFlag
{
    //back button
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn-backarrow.png"] forState:UIControlStateNormal];
    
    //home icon
    [navBarHomeButton setBackgroundImage:[UIImage imageNamed:@"icn-home.png"] forState:UIControlStateNormal];
    
    //add the small main header
    bannerTitle.text = [NSString stringWithFormat:@"PRE/POST SOLUTION : %@", [model.selectedPartner.title uppercaseString]];
    
    //####################################### setup image slider in overview view ##############
    //set the images
    NSMutableArray *images = model.selectedPartner.banners;
    
    int i = 0, width = 0;
    overviewImageDots.numberOfPages = [images count];
    for(NSString *url in images){
        width = i * 776;
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(width, 0, 776, 264)];
        
        NSString *u = [url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        //check to make sure the value exists on disk
        __weak typeof(UIImageView) *imgView = img;
        [img setImageWithURL:[NSURL URLWithString:u] placeholderImage:[UIImage imageNamed:@"overviewPlaceholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
            if(error){
                ALog(@"Error %@", error);
                imgView.image = [UIImage imageNamed:@"overviewPlaceholder.png"];
                [offlineImages setObject:imgView forKey:[NSURL URLWithString:u]];
                model.layoutSync = NO;
            }
        }];
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
    
    //################### Setup the content for the partner #########################
    //the actual titke if the partner
    float descHeight = 270;
    
    partnerHeader.text = [model.selectedPartner.title uppercaseString];
    
    //set the logo, or try and set the logo
    [partnerLogo setImageWithURL:[NSURL URLWithString:model.selectedPartner.logo] placeholderImage:[UIImage imageNamed:@"overviewPlaceholder.png"]];
    
    partnerDescription.text = model.selectedPartner.description;
    [partnerDescription sizeToFit];
    descHeight = partnerDescription.frame.size.height;
    
    
    solutionHeader.text = @"SOLUTIONS CATEGORY:";
    
    //build out all of the solutions
    NSMutableArray *solutions = [self breakOutSolutionSet:model.selectedPartner.solutions];
    
    int dy = 72;
    for(NSString *sol in solutions){
        
        int numLines = 1, labelHeight = 16, offset = 0, w = 0;
        w = [model widthOfString:[sol uppercaseString] withStringSize:14 andFontKey:@"ITCAvantGardeStd-Bk"];

        if(w > 188 && w < 310){
            numLines = 2;
            labelHeight = 32;
            offset = 16;
        }else if(w >= 310){
            numLines = 3;
            labelHeight = 48;
            offset = 32;
        }
        
        UILabel *solutionLabel = [[UILabel alloc] initWithFrame:CGRectMake(524, dy, 188, labelHeight)];
        [solutionLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
        solutionLabel.textColor = model.dullBlack;
        solutionLabel.numberOfLines = numLines;
        solutionLabel.text = [sol uppercaseString];
        solutionLabel.backgroundColor = [UIColor clearColor];
        [overviewContent addSubview:solutionLabel];
        
        dy += 24 + offset;
    }
   
    //break out the scrollview height
    float hightestNumber = 0;
    if(dy > descHeight) hightestNumber = dy;
    else hightestNumber = (descHeight + 76);

    if(hightestNumber < 270)
        hightestNumber = 270;
    
    [overviewContent setContentSize:CGSizeMake(704, hightestNumber)];
    completeFlag(YES);
}

//this function updates the dots for the current image the the user is on
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = scrollView.bounds.size.width;
    //display the appropriate dot when scrolled
    NSInteger pageNumber = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    overviewImageDots.currentPage = pageNumber;
    
}

/***************************************
 *
 *  Network Delegate Functions
 *
 ***************************************/

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
        //remove nsuserdefaults
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [model wipeOutAllModelDataForUpdate];
        });
        
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
-(void)videoDownloadResponse:(CanonModel *)model withFlag:(BOOL)flag
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
}

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

/*-----------------------------------------------------
 
 Utility Functions for this view controller
 
 -------------------------------------------------------*/
-(NSMutableArray *)breakOutSolutionSet:(NSMutableArray *)existingSolutions
{
    NSMutableArray *returnedSolutions = [NSMutableArray array];
    
    for(NSString *sol in existingSolutions){
        NSString *newString = [sol stringByReplacingOccurrencesOfString:@"--solution" withString:@""];
        newString = [newString stringByReplacingOccurrencesOfString:@"-" withString:@" "];
        [returnedSolutions addObject:[newString capitalizedString]];
    }
    return returnedSolutions;
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
