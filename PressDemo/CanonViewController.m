//
//  CanonViewController.m
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "CanonViewController.h"

#define ResourcePath(path)[[NSBundle mainBundle] pathForResource:path ofType:nil]

#define ImageWithPath(path)[UIImage imageWithContentsOfFile:path]

@implementation CanonViewController
@synthesize model, network;

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
        NSLog(@"NIB");
        //this notification is set to the reachability of the application
        //if the application cannot connect, then this function is called
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
        model.reachable = YES;
        NSLog(@"REACHABILIY ");
        
    } else {
        //set UI error
        model.reachable = NO;
    }
}

/* suppress anything that should be killed when app moves to the background */
-(void)appWentIntoBackground
{
    NSLog(@"App went into the background");
    //kill anything that is running here
}
/* decided if the app needs to be loaded up again when it comes back to focus */
-(void)appCameBackIntoFocus
{
    //start the update check here
    NSLog(@"App came back into focus");
    Reachability* reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    //if we can reach the internet
    if ([reachability isReachable]) {
        NSLog(@"APP came back into focus and it is reachable");
        if(model.firstLoad){
            NSLog(@"CHECKING FOR UPDATES");
            [network checkForUpdate];
        }
    }
    
}

-(void)runLoadingSequence
{
    NSLog(@"LOADING");
    //execute the first load sequence load
    if(!model.firstLoad){
        model.ui.splash.image = [model.ui getImageWithName:@"/sample@2x.png"];
        [self.view addSubview:model.ui.splash];
        [self.view bringSubviewToFront:model.ui.splash];
        [network runInitialDownload];
    
    }else{
        //execute alternative load sequence
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    network = [[NetworkData alloc] init];
    network.delegate = self;
    
    model = [self AppDataObj];
    
	//app going into background notification
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appWentIntoBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    //set observation notification on completion
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appCameBackIntoFocus) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    //***** First Load ***************/
    
    Reachability* reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    //if we can reach the internet
    if ([reachability isReachable]) {
        if(!model.firstLoad){
            NSLog(@"FIRST LOAD");
            //we know that this is the first load
            [self runLoadingSequence];
        }
    }
    
    //***** Load up Views ************/
    layouViews = [[NSMutableArray alloc] init];

    homeHeader = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 281)];
    [homeHeader setUserInteractionEnabled:YES];
    homeHeader.image = [model.ui getImageWithName:@"/home-banner@2x.png"];
    homeHeader.alpha = 0.0;
    [self.view addSubview:homeHeader];
    
    
    NSLog(@"viewDidLoad");
}



-(void)displayAllViews
{
    for(UIView *v in [self.view subviews]){
        v.alpha = 1.0;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
    //start download routine
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear");
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
        NSLog(@"Download response");
        [self displayAllViews];
        [model.ui.splash removeFromSuperview];
        self.navigationController.navigationBar.translucent = NO;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        model.ui.splash.image = nil;
        model.firstLoad = YES;
    }else{
        
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //dismiss
    if(buttonIndex == 0){
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
    }
    //download
    if (buttonIndex == 1){
        model.firstLoad = NO;
        self.navigationController.navigationBar.translucent = YES;
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        [self runLoadingSequence];
    }
}

//network delegate function called when a response is sent back to the main thread
//this response will let the view and the user know that there is an update available
-(void)updateResponse:(CanonModel *)obj withFlag:(BOOL)flag{
    
    NSLog(@"Update Response, %d", flag);
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
