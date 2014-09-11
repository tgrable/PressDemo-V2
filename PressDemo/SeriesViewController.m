//
//  SeriesViewController.m
//  PressDemo
//
//  Created by Trekk mini-1 on 8/12/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "SeriesViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIButton+Extensions.h"

#define ResourcePath(path)[[NSBundle mainBundle] pathForResource:path ofType:nil]

#define ImageWithPath(path)[UIImage imageWithContentsOfFile:path]
#define kMaxHeight 1000.0f

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation SeriesViewController
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
    //Reachability* reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    //if we can reach the internet
    ALog(@"Reachable %@", model.hostReachability);
    if ([model.hostReachability isReachable]) {
        ALog(@"APP came back into focus and it is reachable");
        ALog(@"CHECKING FOR UPDATES");
        [network checkForUpdate];
        
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
    ALog(@"viewWillAppear SERIES");
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    ALog(@"viewDidAppear SERIES");
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
    ALog(@"viewWillDisappear SERIES");
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    ALog(@"viewDidDisappear SERIES");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    actualDocumentBanner = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 776, 173)];
    actualDocumentBanner.backgroundColor = [UIColor whiteColor];
    [actualDocumentView addSubview:actualDocumentBanner];
    
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
    [mainView addSubview:mainShortBanner];
    
    overviewContent = [[UIScrollView alloc] initWithFrame:CGRectMake(36, 342, 704, 342)];
    overviewContent.showsHorizontalScrollIndicator = NO;
    overviewContent.showsVerticalScrollIndicator = YES;
    overviewContent.scrollEnabled = YES;
    overviewContent.delegate = self;
    overviewContent.backgroundColor = [UIColor clearColor];
    [overviewContainer addSubview:overviewContent];


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
    
    //product spec button
    productSpec = [UIButton buttonWithType:UIButtonTypeCustom];
    [productSpec setFrame:CGRectMake(36, 162, 178, 36)];
    [productSpec addTarget:self action:@selector(loadUpMainTray:)forControlEvents:UIControlEventTouchDown];
    productSpec.showsTouchWhenHighlighted = YES;
    productSpec.tag = 162;
    productSpec.titleLabel.text = @"product_spec";
    productSpec.backgroundColor = [UIColor clearColor];
    [sideBar addSubview:productSpec];
    
    productSpecIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    [productSpecIcon setImage:[UIImage imageNamed:@"icn-specs.png"]];
    [productSpec addSubview:productSpecIcon];
    
    productSpecLabel = [[UILabel alloc] initWithFrame:CGRectMake(53, 0, 125, 36)];
    [productSpecLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
    productSpecLabel.textColor = model.dullBlack;
    productSpecLabel.numberOfLines = 2;
    productSpecLabel.backgroundColor = [UIColor clearColor];
    productSpecLabel.text = @"PRODUCT SPECIFICATIONS";
    [productSpec addSubview:productSpecLabel];
    
    //white paper button
    whitePaper = [UIButton buttonWithType:UIButtonTypeCustom];
    [whitePaper setFrame:CGRectMake(36, 228, 178, 36)];
    [whitePaper addTarget:self action:@selector(loadUpMainTray:)forControlEvents:UIControlEventTouchDown];
    whitePaper.showsTouchWhenHighlighted = YES;
    whitePaper.tag = 228;
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
    [caseStudy setFrame:CGRectMake(36, 294, 178, 36)];
    [caseStudy addTarget:self action:@selector(loadUpMainTray:)forControlEvents:UIControlEventTouchDown];
    caseStudy.showsTouchWhenHighlighted = YES;
    caseStudy.tag = 294;
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
    
    [self setupLocalUserInterface:^(BOOL completeFlag){}];
    
    downloadingURL = @"";
}


//this function moves around the content in the main view of the app
-(void)loadUpMainTray:(id)sender
{
    UIButton *b = (UIButton *)sender;
    
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
    NSMutableArray *data = [model.selectedSeries valueForKey:flag];
    
    //remove video rows
    [offlineVideoRows removeAllObjects];
    //make sure that when we are drawing in from the dynamic property that we are using the
    //assigned data class correctly.  Check the data class to make sure before using
    
    //make sure we are dealing with an array, otherwise we can assume that their is no content assigned to this 
    if([data isKindOfClass:[NSArray class]]){
        
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
            
            UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(328, 47, 360, 121)];
            [desc setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
            desc.textColor = model.dullBlack;
            desc.numberOfLines = 15;
            desc.backgroundColor = [UIColor clearColor];
            [back addSubview:desc];
            
            
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
                //[download setTitle:splicedName forState:UIControlStateNormal];
                [download setBackgroundColor:[UIColor whiteColor]];
                [download setHitTestEdgeInsets:UIEdgeInsetsMake(-15, -15, -15, -15)];
                [rowContainer addSubview:download];
                [rowContainer bringSubviewToFront:download];
                
                
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
                    }else if([flag isEqualToString:@"product_spec"]){
                        [iv setImage:[UIImage imageNamed:@"placeholder.png"]];
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
                if([flag isEqualToString:@"product_spec"]){
                    desc.text = @"Specifications document for the whole product series.";
                }else{
                    desc.text = d.description;
                }
                desc.frame = CGRectMake(328, 48, 400, 121);
                horizontalLine.frame = CGRectMake(328, 40, 400, 1);
                
                //add the data set of data being held for easy reference
                [currentDocumentData setObject:d forKey:d.key];
            }
            //add sub view to the scroll container
            [documentScroll addSubview:rowContainer];
            i++;
            
            if(i == count){
              [documentScroll setContentSize:CGSizeMake(748, (y + 193))];
              completeFlag(YES);
            }
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

//this function tells the application to either download the video or load the video from disk
-(void)downloadVideo:(id)sender
{
    UIButton *b = (UIButton *)sender;
    NSString *videoURLString = [b.titleLabel.text stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    /************ Download the video to disk ************************/
    if(b.tag == 555){
        ALog(@"download video %@", b.titleLabel.text);
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
                dispatch_queue_t model_queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(model_queue, ^{
                    ALog(@"Video string %@", videoURLString);
                    [network downloadVideo:videoURLString];
                });
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
            webPage.frame = CGRectMake(36, 209, 704, 445);
            //white paper image assignement
            [actualDocumentBanner setImage:[UIImage imageNamed:@"hdr-doc-whitepaper.png"]];
            
        }else if([d.type isEqualToString:@"case-study"]){
            //case study image assignment
            actualDocumentBanner.frame = CGRectMake(0, 0, 776, 173);
            webPage.frame = CGRectMake(36, 209, 704, 445);
            [actualDocumentBanner setImage:[UIImage imageNamed:@"hdr-doc-casestudy.png"]];
            
        }else if([d.type isEqualToString:@"product-spec"]){
            //product spec image assignment
            actualDocumentBanner.frame = CGRectMake(0, 0, 0, 0);
            actualDocumentBanner.image = nil;
            webPage.frame = CGRectMake(36, 45, 704, 555);
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
            ALog(@"Stream %@", v.streamingURL);
            NSString *videoURLString = [v.streamingURL stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
            NSURL *videoURL = [NSURL URLWithString:videoURLString];
            MPMoviePlayerViewController *moviePlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
            [self presentMoviePlayerViewControllerAnimated:moviePlayerView];
        }else{
            NSString *lookupNameAdvanced = [lookupName stringByReplacingOccurrencesOfString:@" " withString:@"_"];
            
            ALog(@"Inline %@",  lookupNameAdvanced);
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
    ALog(@"HOME!");
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//this function sets up the disposable views and also sets up the overview view in the main portion of the app
-(void)setupLocalUserInterface:(completeBlock)completeFlag
{
    //back button
    [backButton setBackgroundImage:[UIImage imageNamed:@"btn-backgrid.png"] forState:UIControlStateNormal];
    
    //home icon
    [navBarHomeButton setBackgroundImage:[UIImage imageNamed:@"icn-home.png"] forState:UIControlStateNormal];
    
    //add the small main header
    //mainShortBanner.image = [model.ui getImageWithName:[model.seriesBanners objectForKey:model.selectedSeries.key]];
    mainShortBanner.image = [model.seriesBanners objectForKey:model.selectedSeries.key];
    
    //#### setup image slider in overview view ####
    NSMutableArray *images = [self generateSeriesProductImages:model.selectedSeries.products];
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
    
    //#### setup the overview description boxes ###
    int descCount = (int)[model.selectedSeries.description count], y = 0, e = 0, x = 0;
    int offset = descCount / 2;
    while(e < descCount){
        
        //get the data out of the dictionary
        NSString *key = [NSString stringWithFormat:@"%d", e];
        NSDictionary *desc = [model.selectedSeries.description objectForKey:key];
        
        //start to define the description text so it can be measured for its text length to determine the height
        UILabel *descLabel = [[UILabel alloc] init];
        [descLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
        CGSize sizeNew = [[desc objectForKey:@"description"] sizeWithFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]
                              constrainedToSize:CGSizeMake(334, kMaxHeight)
                                  lineBreakMode:NSLineBreakByWordWrapping];
        int height = sizeNew.height + 10;
        descLabel.textColor = model.dullBlack;
        descLabel.numberOfLines = 25;
        descLabel.text = [desc objectForKey:@"description"];
        descLabel.backgroundColor = [UIColor whiteColor];
        descLabel.frame = CGRectMake(0, 44, 334, height);
        
        //define the cell that holds the text
        UIView *cell = [[UIView alloc] initWithFrame:CGRectMake(x, y, 334, (height + 71))];
        
        //define the title and apply the data to it
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 334, 24)];
        [title setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:14.0]];
        title.textColor = [UIColor blackColor];
        title.numberOfLines = 2;
        title.backgroundColor = [UIColor whiteColor];
        title.text = [desc objectForKey:@"title"];
        [cell addSubview:title];
        
        //add the description label
        [cell addSubview:descLabel];
        
        //add the bottom border
        UIView *bottomBorder = [[UIView alloc] initWithFrame:CGRectMake(0, (height + 64), 334, 1)];
        bottomBorder.backgroundColor = [UIColor colorWithRed:202.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0];
        [cell addSubview:bottomBorder];
        
        //add the complete cell to the scrollview
        [overviewContent addSubview:cell];
        
        //y equals the height of the description, plus the height of the rest of the view space
        y += (height + 65);
        
        //increment the iterator
        e++;
        //define what row we are in
        if(e == offset){
            x = 370;
            y = 0;
        }
        
    }
    //setup the contentSize for the desc text boxes
    [overviewContent setContentSize:CGSizeMake(704, (y + 50))];
    
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
        [model wipeOutAllModelDataForUpdate];
        
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
    ALog(@"Made it with my video download response! %d", flag);
    UIView *v = [videoButton viewWithTag:110];
    [v removeFromSuperview];
    
    if(flag){
        [videoButton setImage:[UIImage imageNamed:@"icn-load.png"] forState:UIControlStateNormal];
        videoButton.tag = 777;
        ALog(@"######### %@", downloadingURL);
        [videoButton setTitle:[self.model returnFilePath:downloadingURL] forState:UIControlStateNormal];
    }else{
        [self displayMessage:@"OOPS! Something went wrong downloading your video.  Please make sure you are connected to the internet and try again." withTitle:@"Alert"];
    }
}

//network delegate function called when a response is sent back to the main thread
//this response will let the view and the user know that there is an update available
-(void)updateResponse:(CanonModel *)obj withFlag:(BOOL)flag{
    
    ALog(@"Update Response, %d.  This tells us if there is an update available.", flag);
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
-(NSMutableArray *)generateSeriesProductImages:(NSMutableArray *)products
{
    NSMutableArray *images = [NSMutableArray array];
    NSMutableArray *filteredImages = [NSMutableArray array];
    for(NSString *filename in products){
        NSData *prod = [model getFileData:filename complete:^(BOOL completeFlag){}];
        Product *p = [NSKeyedUnarchiver unarchiveObjectWithData:prod];
        [images addObject:[p.images objectForKey:@"hero-image"]];
        
    }
    //filter the array of images
    for(NSString *url in images){
        if(![filteredImages containsObject:url]){
            [filteredImages addObject:url];
        }
    }
    return filteredImages;
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
