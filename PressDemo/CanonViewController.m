//
//  CanonViewController.m
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//
#import "Product.h"
#import "CanonViewController.h"
#import "FilterViewController.h"
#import "CanonMediaGridViewController.h"
#import "CanonSoftwareGridViewController.h"

#define ResourcePath(path)[[NSBundle mainBundle] pathForResource:path ofType:nil]

#define ImageWithPath(path)[UIImage imageWithContentsOfFile:path]

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation CanonViewController
@synthesize model, network, customNavBar;
@synthesize whatDoYouPrint, showAllProducts;
@synthesize whatImageNames, showAllImageNames;

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
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"case-study"] isEqualToString:@""] && !downloadInProgress){
            //this means that the app failed on the initial load and needs to be loaded
            [self runLoadingSequence];
        }
        
    } else {
        //set UI error
        ALog(@"NOT REACHABLE");
    }
}

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
    if ([model.hostReachability isReachableViaWiFi] && !downloadInProgress) {
        //make sure
        if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"case-study"] isEqualToString:@""]){
            ALog(@"CHECKING FOR UPDATES");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [network checkForUpdate];
            });
        }
    }
    
}

//this function is executed to run the initial downloading sequence
-(void)runLoadingSequence
{
    ALog(@"runLoadingSequence");

    //execute the first load sequence load
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"case-study"] isEqualToString:@""] && !downloadInProgress){
        
        model.ui.splash.image = [model.ui getImageWithName:@"/sample@2x.png"];
        [self.view addSubview:model.ui.splash];
        [self.view bringSubviewToFront:model.ui.splash];
       
        if([model.hostReachability isReachableViaWiFi]){
            downloadInProgress = YES;
            UIActivityIndicatorView *ac = (UIActivityIndicatorView *)[model.ui.splash viewWithTag:444];
            ac.alpha = 1.0;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                ALog(@"runLoadingSequence, case study blank, no other download in progress, network is reachable, running download");
                [network runInitialDownload];
            });
        }else{
            UIActivityIndicatorView *ac = (UIActivityIndicatorView *)[model.ui.splash viewWithTag:444];
            ac.alpha = 0.0;
            [self displayMessage:@"Please connect to the internet to initially load up the application" withTitle:@"Alert"];
        }
    
    }else{
        //execute alternative load sequence
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //ALog(@"viewWillAppear HOME");
    
    if(model.needsUpdate && [model.hostReachability isReachableViaWiFi]){
        ALog(@"The app was flagged that it needed updates");
        
        //wipe out all data after first initial load
        [model wipeOutAllModelData];
        
        model.ui.splash.image = [model.ui getImageWithName:@"/sample@2x.png"];
        [self.view addSubview:model.ui.splash];
        [self.view bringSubviewToFront:model.ui.splash];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [network runInitialDownload];
        });
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //ALog(@"viewDidAppear HOME");
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
    
    //remove notification
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
       
    //remove all assets here for future memory enhancements
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Home View";
    
    //this notification is set to the reachability of the application
    //if the application cannot connect, then this function is called
    
    network = [[NetworkData alloc] init];
    network.delegate = self;
   
    model = [self AppDataObj];
    
    downloadInProgress = NO;
    
    ALog(@"Hitting first load");
    [self runLoadingSequence];
    

    //two arrays for generating local filters
    whatImageNames = [NSMutableArray array];
    showAllImageNames = [NSMutableArray array];
    
    //***** Load up views to the local view controller ************//
    //the nav bar
    customNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 1024, 64)];
    [customNavBar setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:customNavBar];
    
    logo = [[UIImageView alloc] initWithFrame:CGRectMake(464, 1, 97, 62)];
    [logo setUserInteractionEnabled:YES];
    [logo setImage:[UIImage imageNamed:@"csa-logo.png"]];
    [customNavBar addSubview:logo];
    
    //the header image
    homeHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 84, 1024, 281)];
    [homeHeader setUserInteractionEnabled:YES];
    [self.view addSubview:homeHeader];
    
    //image header for the scrollview
    whatPrint = [[UIImageView alloc] initWithFrame:CGRectMake(0, 365, 290, 201)];
    whatPrint.backgroundColor = [UIColor clearColor];
    [whatPrint setUserInteractionEnabled:YES];
    [self.view addSubview:whatPrint];
    
    //scroll view for what do you want to print
    whatDoYouPrint = [[WhatDoYouPrint alloc] initWithFrame:CGRectMake(276, 365, 734, 187)];
    whatDoYouPrint.showsHorizontalScrollIndicator = NO;
    whatDoYouPrint.showsVerticalScrollIndicator = NO;
    whatDoYouPrint.delaysContentTouches = NO;
    whatDoYouPrint.delegate = self;
    whatDoYouPrint.clipsToBounds = YES;
    [self.view addSubview:whatDoYouPrint];

    //image header for the scrollview
    showProducts = [[UIImageView alloc] initWithFrame:CGRectMake(0, 566, 290, 201)];
    showProducts.backgroundColor = [UIColor clearColor];
    [showProducts setUserInteractionEnabled:YES];
    [self.view addSubview:showProducts];
    
    //scroll view for show all products
    showAllProducts = [[ShowAll alloc] initWithFrame:CGRectMake(276, 566, 734, 187)];
    showAllProducts.showsHorizontalScrollIndicator = NO;
    showAllProducts.showsVerticalScrollIndicator = NO;
    showAllProducts.delaysContentTouches = NO;
    showAllProducts.delegate = self;
    showAllProducts.clipsToBounds = YES;
    [self.view addSubview:showAllProducts];
    
    
    [self.view bringSubviewToFront:model.ui.splash];
    

    //make sure this is at the bottom of the view
    //at the end of view did load, make sure we have data and load the view up
    //this means that we are running the app again after it has been loaded at least once
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"case-study"] isEqualToString:@""]){
        
        //setup the local UI before I remove the splash screen
        [self setupLocalUserInterface:^(BOOL completeFlag){
            [model.ui.splash removeFromSuperview];
            model.ui.splash.image = nil;
        }];
    }
    
    //GA
    [model logData:@"Home View" withAction:@"View Tracker" withLabel:@"Landed on home view"];
}

//this function captures the event of one of the filter buttons being touched
-(void)captureFilterButtons:(id)sender
{
    UIButton *b = (UIButton *)sender;
    model.currentFilter = b.titleLabel.text;
    
    if([model.currentFilter isEqualToString:@"media"]){
        //filter towards media
        
        CanonMediaGridViewController *mgvc = [[CanonMediaGridViewController alloc] initWithNibName:@"CanonMediaGridViewController" bundle:nil];
        [self.navigationController pushViewController:mgvc animated:YES];
        
    }else if([model.currentFilter isEqualToString:@"software"]){
        //filter towards software
        CanonSoftwareGridViewController *softGrid = [[CanonSoftwareGridViewController alloc] initWithNibName:@"CanonSoftwareGridViewController" bundle:nil];
        [self.navigationController pushViewController:softGrid animated:YES];
    }else{
    
        //make sure and remove and objects this array may contain
        if([model.filteredProducts count] > 0){
            [model.filteredProducts removeAllObjects];
        }
        
        for(Product *p in model.localProds){
            NSArray *w = p.whatDoYouWantToPrint;
            NSArray *s = p.showAll;
            
            if([s containsObject:model.currentFilter] && ![model.filteredProducts containsObject:p]){
                [model.filteredProducts addObject:p];
            }
            
            if([w containsObject:model.currentFilter] && ![model.filteredProducts containsObject:p]){
                [model.filteredProducts addObject:p];
            }
        }
        FilterViewController *filter = [[FilterViewController alloc] initWithNibName:@"FilterViewController" bundle:nil];
        [self.navigationController pushViewController:filter animated:YES];
    }
    
}

//this function acts as a central filter to setup assets that can be deallocated once the view is left
-(void)setupLocalUserInterface:(completeBlock)completeFlag
{
    //add image to the header
    homeHeader.image = [model.ui getImageWithName:@"/home-banner@2x.png"];
    
    //add first filter image for what do you want to print
    //whatPrint.image = [model.ui getImageWithName:@"/home-header-what@2x.png"];
    whatPrint.image = [UIImage imageNamed:@"home-header-what.png"];
    
    //add second filter image for show all
    //showProducts.image = [model.ui getImageWithName:@"/home-header-all@2x.png"];
    showProducts.image = [UIImage imageNamed:@"home-header-all.png"];
    
    //get the local set of products from disk
    model.localProds = [model getInitialSetofPorducts];
    
    if(model.localProds != nil){
        
        for(Product *p in model.localProds){
            for(NSString *w in p.whatDoYouWantToPrint){
                if(![whatImageNames containsObject:w]){
                    [whatImageNames addObject:w];
                }
            }
            for(NSString *s in p.showAll){
                if(![showAllImageNames containsObject:s]){
                    [showAllImageNames addObject:s];
                }
            }
        }
        
        if(![showAllImageNames containsObject:@"media"]){
            //add media into the show all array by default
            [showAllImageNames addObject:@"media"];
        }
        
        if(![showAllImageNames containsObject:@"software"]){
            //add media into the show all array by default
            [showAllImageNames addObject:@"software"];
        }
   
        //load all what do your want to print buttons
        int x1 = 0, e1 = 0;
        for(NSString *wf in whatImageNames){
            x1 = e1 * 204 + 14;
            if(x1 == 0) x1 = 14;
            UIButton *wfButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [wfButton setFrame:CGRectMake(x1, 0, 197, 187)];
            [wfButton addTarget:self action:@selector(captureFilterButtons:)forControlEvents:UIControlEventTouchUpInside];
            wfButton.showsTouchWhenHighlighted = YES;
            [wfButton setBackgroundImage:[model.whatDoYouWantToPrint objectForKey:wf] forState:UIControlStateNormal];
            [wfButton setTitle:wf forState:UIControlStateNormal];
            [wfButton setBackgroundColor:[UIColor yellowColor]];
            [wfButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [whatDoYouPrint addSubview:wfButton];
            e1++;
        }
        //set the content size so the view scrolls
        [whatDoYouPrint setContentSize:CGSizeMake((x1 + 201), 187)];
        
        //load all of the show all products
        int x2 = 0, e2 = 0;
        for(NSString *sa in showAllImageNames){
            x2 = e2 * 204 + 14;
            if(x2 == 0) x2 = 14;
            UIButton *saButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [saButton setFrame:CGRectMake(x2, 0, 197, 187)];
            [saButton addTarget:self action:@selector(captureFilterButtons:)forControlEvents:UIControlEventTouchUpInside];
            saButton.showsTouchWhenHighlighted = YES;
            [saButton setBackgroundImage:[model.showAll objectForKey:sa] forState:UIControlStateNormal];
            [saButton setTitle:sa forState:UIControlStateNormal];
            [saButton setBackgroundColor:[UIColor redColor]];
            [saButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [showAllProducts addSubview:saButton];
            e2++;
        }
        //set the content size so the view scrolls
        [showAllProducts setContentSize:CGSizeMake((x2 + 201), 187)];

    }else{
        [self displayMessage:@"There was an error loading the app.  Please close, kill the app, make sure you are initially connected to the internet, and restart it." withTitle:@"ALERT"];
    }
    
    completeFlag(YES);
}

//universal view function to display dynamic alerts
-(void)displayMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *error = [[UIAlertView alloc] initWithTitle:title message: message
                                                   delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
    [error show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/***************************************
 *
 *  Network Delegate Functions
 *
 ***************************************/

//called after all of the network threads have finished downloading the data
//perform updates to the main thread here
-(void)downloadResponse:(CanonModel *)obj withFlag:(BOOL)flag{
    //the download response was successful
    if(flag){
        
        //wipe out all data after first initial load
        [model wipeOutAllModelData];
        
        //before we send rebuild the ui with updated data, tear down the UI
        if(model.needsUpdate){
            //remove all of the what do you want to print items and the show all items
            for(UIView *v in [showAllProducts subviews]){
                [v removeFromSuperview];
            }
            for(UIView *v in [whatDoYouPrint subviews]){
                [v removeFromSuperview];
            }
            model.needsUpdate = NO;
        }
        
        //setup the local UI before I remove the splash screen
        [self setupLocalUserInterface:^(BOOL completeFlag){
            downloadInProgress = NO;
            [model.ui.splash removeFromSuperview];
            model.ui.splash.image = nil;
            
        }];
        
    }else{
        downloadInProgress = NO;
        [self displayMessage:@"There was an error loading the app.  Please close, kill the app, make sure you are initially connected to the internet, and restart it." withTitle:@"ALERT"];
    }
    
}

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
        if([model.hostReachability isReachableViaWiFi]){
            [model wipeOutAllModelDataForUpdate];
            model.needsUpdate = YES;
            model.ui.splash.image = [model.ui getImageWithName:@"/sample@2x.png"];
            [self.view addSubview:model.ui.splash];
            [self.view bringSubviewToFront:model.ui.splash];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [network runInitialDownload];
            });
        }else{
            [self displayMessage:@"Please connect to the internet to update the application" withTitle:@"Alert"];
        }
       
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


@end
