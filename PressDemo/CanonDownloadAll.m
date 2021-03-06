//
//  CanonDownloadAll.m
//  PressDemo
//
//  Created by Trekk mini-1 on 1/12/15.
//  Copyright (c) 2015 Trekk. All rights reserved.
//

#import "CanonDownloadAll.h"

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation CanonDownloadAll
@synthesize model, network, okAction, userStatus;

//Here we are setting up the delegate method
- (CanonModel *) AppDataObj;
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    CanonModel * modelObject;
    modelObject = (CanonModel*) theDelegate.AppDataObj;
    
    return modelObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.screenName = @"Download View";
    
    network = [[NetworkData alloc] init];
    network.delegate = self;
    
    model = [self AppDataObj];
    
    download = [[DownloadFile alloc] init];
    download.delegate = self;
    
    userStatus = [[VerifyUserStatus alloc] init];
    userStatus.delegate = self;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    UIImageView *loadScreen = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    loadScreen.image = [model getImageWithName:@"/launch@2x.png"];
    [loadScreen setUserInteractionEnabled:YES];
    [self.view addSubview:loadScreen];
    
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userEmail"];
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userDownloadUrl"];

    //if we can reach the internet
    if ([self connected]) {
        if ([self getUserEmailFromDefaults].length <= 0) {
            [self collectAndValidateEmail:@"imPRESS" andMessage:@"Please enter your email address."];
        }
        else {
//            [userStatus verifyUser:[self getUserEmailFromDefaults]];
            [self moveFowardIfUserIsAuthorizedForConnectionStatus:YES];
        }
        
    } else {
        //set UI error
        if ([self getUserEmailFromDefaults].length <= 0) {
            [self collectAndValidateEmail:@"imPRESS" andMessage:@"Please enter your email address."];
        }
        else {
//            [self continueLoadingApp];
            [self moveFowardIfUserIsAuthorizedForConnectionStatus:NO];
        }
    }
}

-(void)moveFowardIfUserIsAuthorizedForConnectionStatus:(BOOL)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"userIsAuthorized"] isEqualToString:@"YES"]) {
            if (status == YES) {
                [userStatus verifyUser:[self getUserEmailFromDefaults]];
            }
            else {
                [self continueLoadingApp];
            }
        }
        else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"userIsAuthorized"] isEqualToString:@"NO"]) {
            [self displayMessage:@"You are no longer authorized to use this app." withTitle:@"imPRESS"];
        }
        else if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"userIsAuthorized"] isEqualToString:@"ERROR"]) {
            if (status == YES) {
                [self collectAndValidateEmail:@"Error" andMessage:[NSString stringWithFormat:@"There was an error validating your access. \n\n Please enter your email address."]];
            }
            else {
                [self displayMessage:@"There was an error validating your access. \n\n Please try again when you have internet access." withTitle:@"imPRESS"];
            }
        }
        else {
            NSLog(@"First time the user hits this update but they dont enter an email. Then hit the home button but do not completly close out the app.");
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    //reset the animation flag
    model.animationRun = NO;
    
    if(model.needsUpdate && [model.hostReachability isReachableViaWiFi]){
        ALog(@"The app was flagged that it needed updates");
        //clear all image memory
        [download clearImageMemory];
        
        //build the user interface
        [self loadUpUserInterface];
        
        //reset the counts and indexes
        download.imageIndex = 0;
        download.index = 0;
        download.totaldata = 0.0;
        
        //reset model arrays
        [model.initialFilesToDownload removeAllObjects];
        [model.downloadedImages removeAllObjects];
        
        //wipe out data for update
        [model wipeOutAllModelDataForUpdate];
        
        //set the initial update messages
        downloadStatus.text = @"Download Status: Stage 1 of 3. Downloading Data";
        [downloadAll setTitle:@"BEGIN UPDATE" forState:UIControlStateNormal];
        message.text = @"NOTE: Before starting the application data download, please make sure you are connected to a Wi-Fi network.\n The initial download could take up to 20 minutes based on your connection.\n Subsequent updates will have shorter download times.";
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
    
    //remove notification
    [[NSNotificationCenter defaultCenter] removeObserver: self];
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
}

-(void)loadUpUserInterface
{
    mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [mainView setUserInteractionEnabled:YES];
    [self.view addSubview:mainView];
    
    message = [[UILabel alloc] initWithFrame:CGRectMake(130, 500, 764, 50)];
    [message setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
    message.textColor = [UIColor whiteColor];
    message.numberOfLines = 4;
    message.textAlignment = NSTextAlignmentCenter;
    message.backgroundColor = [UIColor clearColor];
    message.text = @"NOTE: Before starting the application data download, please make sure you are connected to a Wi-Fi network.\n The initial download could take up to an hour based on your connection.\n Subsequent updates will have shorter download times.";
    [mainView addSubview:message];
    
    
    downloadAll = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadAll setFrame:CGRectMake(412, 574, 200, 32)];
    [downloadAll addTarget:self action:@selector(beginDownload:)forControlEvents:UIControlEventTouchDown];
    downloadAll.showsTouchWhenHighlighted = YES;
    [downloadAll setTitle:@"BEGIN DOWNLOAD" forState:UIControlStateNormal];
    downloadAll.backgroundColor = model.lightGray;
    downloadAll.contentEdgeInsets = UIEdgeInsetsMake(4.0, 0.0, 0.0, 0.0);
    downloadAll.titleLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0];
    [downloadAll setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [mainView addSubview:downloadAll];
    
    activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake(490.0, 625.0, 35.0, 35.0);
    [activityIndicator setColor:[UIColor whiteColor]];
    activityIndicator.alpha = 0.0;
    [activityIndicator startAnimating];
    [mainView addSubview:activityIndicator];
    
    downloadStatus = [[UILabel alloc] initWithFrame:CGRectMake(150, 690, 724, 20)];
    [downloadStatus setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:14.0]];
    downloadStatus.textColor = [UIColor whiteColor];
    downloadStatus.numberOfLines = 1;
    downloadStatus.alpha = 0.0;
    downloadStatus.textAlignment = NSTextAlignmentCenter;
    downloadStatus.backgroundColor = [UIColor clearColor];
    downloadStatus.text = @"Download Status: Stage 1 of 3. Downloading Data";
    [mainView addSubview:downloadStatus];
}

-(void)beginDownload:(id)sender
{
    ALog("Begin Download");
    if ([model.hostReachability isReachableViaWiFi]) {
        ALog(@"REACHABLE via WiFi");
        downloadStatus.alpha = 1.0;
        activityIndicator.alpha = 1.0;
        downloadAll.enabled = NO;
        downloadAll.alpha = 0.6;
        [downloadAll setTitle:@"DOWNLOADING" forState:UIControlStateNormal];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [network runInitialDownload];
        });
        
    }else{
        [self displayMessage:@"Please connect to WiFi to start the download" withTitle:@"Alert"];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

//universal view function to display dynamic alerts
-(void)displayMessage:(NSString *)messageLocal withTitle:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *error = [[UIAlertView alloc] initWithTitle:title message: messageLocal
                                                       delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
        [error show];
    });
}

/***************************************
 *
 *  Network Delegate Functions
 *
 ***************************************/

//called after all of the network threads have finished downloading the data
//perform updates to the main thread here
-(void)initialDownloadResponse:(CanonModel *)obj withFlag:(BOOL)flag{
   
    if(flag){
        
        ALog(@"Initial download response %d", flag);
        ALog(@"Inititial Dictionary Count %d", (int)[model.initialFilesToDownload count]);
        download.downloadCount = (int)[model.initialFilesToDownload count];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
          [download getThreadIndex];
        });
    }else{
        downloadAll.enabled = YES;
        downloadAll.alpha = 1.0;
        [self displayMessage:@"There was an error loading the app.  Please close, kill the app, make sure you are initially connected to the internet via WiFi, and restart it." withTitle:@"ALERT"];
    }
}

//this gets called after the download function completely runs
-(void)fileDownloadResponse:(BOOL)flag
{

    if(flag){
        ALog(@"File download response %d", flag);
        download.imageCount = (int)[model.downloadedImages count];
        download.index = 0;
        
        //set the status to download images
        downloadStatus.text = [NSString stringWithFormat:@"Download Status: Stage 3 of 3. Downloading Image: %d / %d", 0, download.imageCount];
        
        NSString *url = [model.downloadedImages objectAtIndex:0];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
          [download downloadAllImagesAndSaveThem:url];
        });
        
    }else{
        downloadAll.enabled = YES;
        downloadAll.alpha = 1.0;
        [self displayMessage:@"There was an error loading the app.  Please close, kill the app, make sure you are initially connected to the internet via WiFi, and restart it." withTitle:@"ALERT"];
    }
    
}

-(void)imageDownloadResponse:(BOOL)flag
{
    activityIndicator.alpha = 0.0;
    downloadStatus.text = @"FINISHED!";
    if(flag){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"initialDownload"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        downloadAll.alpha = 1.0;
        [downloadAll setTitle:@"BEGIN DOWNLOAD" forState:UIControlStateNormal];
        downloadAll.enabled = YES;
        
        //make sure the update flag is set to no
        model.needsUpdate = NO;
        
        //wipe out all data after first initial load
        [model wipeOutAllModelData];
        
        //wipe out the UI
        [mainView removeFromSuperview];
        
        ALog(@"ALL DOWNLOADING COMPLETE!");
        
        //send the user to the first view after the build
        CanonViewController *vc = [[CanonViewController alloc] initWithNibName:@"CanonViewController" bundle:nil];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{
        downloadAll.enabled = YES;
        downloadAll.alpha = 1.0;
        [self displayMessage:@"There was an error loading the app.  Please close, kill the app, make sure you are initially connected to the internet via WiFi, and restart it." withTitle:@"ALERT"];
    }
}

-(void)dowloadStatus:(int)stage withDocumentIndex:(int)index
{
    if(stage == 1){
        downloadStatus.text = [NSString stringWithFormat:@"Download Status: Stage 2 of 3. Downloading Document: %d / %d", (index +1), (int)[model.initialFilesToDownload count]];
    }else if(stage == 2){
        downloadStatus.text = [NSString stringWithFormat:@"Download Status: Stage 3 of 3. Downloading Image: %d / %d", (index +1), download.imageCount];
    }
}

-(void)continueLoadingApp {
    dispatch_async(dispatch_get_main_queue(), ^{
        //if we have made the initial download, push the user to the home screen
        if([[NSUserDefaults standardUserDefaults] boolForKey:@"initialDownload"]){
            //send the user to the first view after the build
            CanonViewController *vc = [[CanonViewController alloc] initWithNibName:@"CanonViewController" bundle:nil];
            [self.navigationController pushViewController:vc animated:NO];
        }else{
            //build the user interface
            [self loadUpUserInterface];
        }
        
        //get the data about the device
        NSString *dimensions = @"1024x768";
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            dimensions = @"2048x1536";
        }
        NSString *deviceData = [NSString stringWithFormat:@"%@ - %@", [model deviceInformation], dimensions];
        [model logData:@"CanonViewController" withAction:@"Device Name" withLabel:deviceData];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma -
#pragma - Collect and Validate Email
-(void)collectAndValidateEmail:(NSString *)title andMessage:(NSString *)msg {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    okAction = [UIAlertAction actionWithTitle:@"OK"
                                        style:UIAlertActionStyleDefault
                                      handler:^(UIAlertAction *action) {
                                            UITextField *textField = [alert.textFields firstObject];
                                            if ([self validateEmailWithString:textField.text]) {
                                                currentEmail = textField.text;

                                                //if we can reach the internet
                                                if ([self connected]) {
                                                    [userStatus verifyUser:currentEmail];
                                                }
                                                else {
                                                    [[NSUserDefaults standardUserDefaults] setObject:currentEmail forKey:@"userEmail"];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    [self continueLoadingApp];
                                                }
                                                
                                            }
                                        }];
    okAction.enabled = NO;
    
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        // optionally configure the text field
        textField.keyboardType = UIKeyboardTypeEmailAddress;
        textField.delegate = self;
    }];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)validateEmailWithString:(NSString*)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self.okAction setEnabled:([self validateEmailWithString:finalString])];
    return YES;
}

#pragma -
#pragma - Justins Delegate Method

-(void)authorizationStatusWasReturned:(int)isCurrentlyAuthorized userURL:(NSString *)currentURL message:(NSString *)currentMsg currentVersion:(NSString *)versionNumber{
    // 0 = yes
    // 1 = no
    // 2 = error
    
    if ([self getUserEmailFromDefaults].length <= 0) {
        [[NSUserDefaults standardUserDefaults] setObject:currentEmail forKey:@"userEmail"];
    }
    [[NSUserDefaults standardUserDefaults] setObject:currentURL forKey:@"userDownloadUrl"];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    switch (isCurrentlyAuthorized) {
        case 0:
            [[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"userIsAuthorized"];
            if (![version isEqualToString:versionNumber]) {
                [self alertUserVersionIsOutOfDate:@"imPRESS" andMessage:@"There is a new version of the app available."];
            }
            else {
                [self continueLoadingApp];
            }
            break;
        case 1:
            [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"userIsAuthorized"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userEmail"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userDownloadUrl"];
            [self displayMessage:@"You are no longer authorized to use this app." withTitle:@"imPRESS"];
            break;
        case 2:
            [[NSUserDefaults standardUserDefaults] setObject:@"ERROR" forKey:@"userIsAuthorized"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userEmail"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userDownloadUrl"];
            [self collectAndValidateEmail:@"Error" andMessage:[NSString stringWithFormat:@"%@ \n\n Please enter your email address.", currentMsg]];
            break;
        default:
            break;
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (void)alertUserVersionIsOutOfDate:(NSString *)title andMessage:(NSString *)alertMsg {
    UIAlertController *alertController  = [UIAlertController
                                           alertControllerWithTitle:title
                                           message:alertMsg
                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction         = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel")
                                           style:UIAlertActionStyleCancel
                                           handler:^(UIAlertAction *action)
                                           {
                                               [self continueLoadingApp];
                                           }];
    
    UIAlertAction *updateAction         = [UIAlertAction
                                           actionWithTitle:NSLocalizedString(@"Update App", @"Update App")
                                           style:UIAlertActionStyleDefault
                                           handler:^(UIAlertAction *action)
                                           {
                                               [self openSafariToDownloadUpdatedVersion];
                                           }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:updateAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}



- (NSString *)getUserEmailFromDefaults {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"userEmail"];
}

- (void)openSafariToDownloadUpdatedVersion {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] stringForKey:@"userDownloadUrl"]]];
}

#pragma mark
#pragma mark - Reachability
- (BOOL)connected
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

@end
