//
//  CanonMediaGridViewController.m
//  PressDemo
//
//  Created by Trekk mini-1 on 12/10/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "CanonMediaGridViewController.h"
#import "UIImageView+WebCache.h"
#import "CanonMediaMillViewController.h"
#import "AllMillsViewController.h"

#define ResourcePath(path)[[NSBundle mainBundle] pathForResource:path ofType:nil]

#define ImageWithPath(path)[UIImage imageWithContentsOfFile:path]

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation CanonMediaGridViewController
@synthesize topBanner, productScroll, customNavBar;
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
    if ([reachability isReachableViaWiFi]) {
        ALog(@"REACHABLE");
        
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
    
    
    //make sure to check the connectivity again
    if ([model.hostReachability isReachableViaWiFi]) {
        ALog(@"CHECKING FOR UPDATES");
        noConnection.alpha = 0.0;
        //make sure this thread runs in the background
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [network checkForUpdate];
        });
        //resync the UI
        if(!model.layoutSync){
            for (id key in offlineImages) {
                UIImageView *i = [offlineImages objectForKey:key];
                NSArray *url = [key componentsSeparatedByString:@"---"];
                if([url objectAtIndex:1] != nil){
                    [i sd_setImageWithURL:[NSURL URLWithString:[url objectAtIndex:1]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
                }
                
            }
            
            [offlineImages removeAllObjects];
            model.layoutSync = YES;
        }
    }else{
        noConnection.alpha = 1.0;
        [model logData:@"CanonMediaGridViewController" withAction:@"No Internet Connection" withLabel:@"Came back into focus with no connection"];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([model.hostReachability isReachableViaWiFi]) {
        noConnection.alpha = 0.0;
    }else{
        noConnection.alpha = 1.0;
        [model logData:@"CanonMediaGridViewController" withAction:@"No Internet Connection" withLabel:@"Running the app with no internet"];
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
    //remove the observers
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.screenName = @"Media Grid View";
    
    network = [[NetworkData alloc] init];
    network.delegate = self;
    
    model = [self AppDataObj];
    
    //make sure we have data

    if([model.initialSetOfMills count] == 0){

        NSData *millData = [model getFileData:@"initialMills" complete:^(BOOL completeFlag){}];
        model.initialSetOfMills = [NSKeyedUnarchiver unarchiveObjectWithData:millData];
    }

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
    
    impressLogo = [[UIImageView alloc] initWithFrame:CGRectMake(437, 1, 151, 62)];
    [impressLogo setUserInteractionEnabled:YES];
    [impressLogo setImage:[UIImage imageNamed:@"impress-logo.png"]];
    [customNavBar addSubview:impressLogo];
    
    logo = [[UIImageView alloc] initWithFrame:CGRectMake(893, 0, 97, 62)];
    [logo setUserInteractionEnabled:YES];
    [logo setImage:[UIImage imageNamed:@"csa-logo.png"]];
    [customNavBar addSubview:logo];
    
    navBarHomeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navBarHomeButton setFrame:CGRectMake(36, 14, 35, 35)];
    [navBarHomeButton addTarget:self action:@selector(triggerHome:)forControlEvents:UIControlEventTouchDown];
    navBarHomeButton.showsTouchWhenHighlighted = YES;
    navBarHomeButton.tag = 20;
    [customNavBar addSubview:navBarHomeButton];
    
    productScroll = [[ProductScroll alloc] initWithFrame:CGRectMake(36, 145, 962, 620)];
    productScroll.showsHorizontalScrollIndicator = NO;
    productScroll.showsVerticalScrollIndicator = YES;
    productScroll.delaysContentTouches = NO;
    productScroll.delegate = self;
    productScroll.clipsToBounds = YES;
    [self.view addSubview:productScroll];
    
    topBanner = [[UIImageView alloc] initWithFrame:CGRectMake(0, 84, 1024, 89)];
    topBanner.backgroundColor = [UIColor clearColor];
    [topBanner setUserInteractionEnabled:YES];
    [self.view addSubview:topBanner];
    
    UILabel *viewLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 4, 220, 60)];
    [viewLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:36.0]];
    viewLabel.textColor = [UIColor whiteColor];
    viewLabel.numberOfLines = 1;
    viewLabel.backgroundColor = [UIColor clearColor];
    viewLabel.text = @"MEDIA";
    [topBanner addSubview:viewLabel];
    
    UIView *allMillsBackgroundButtonView = [[UIView alloc] initWithFrame:CGRectMake(893, 15, 100, 30)];
    allMillsBackgroundButtonView.backgroundColor = [UIColor whiteColor];
    [topBanner addSubview: allMillsBackgroundButtonView];
    
//    UILabel *allMillsTextView = [[UILabel alloc] initWithFrame:CGRectMake(893, 17, 100, 30)];
//    allMillsTextView.backgroundColor = [UIColor clearColor];
//    allMillsTextView.text = @"All Mills";
//    allMillsTextView.textAlignment = NSTextAlignmentCenter;
//    allMillsTextView.textColor = [UIColor blackColor];
//    allMillsTextView.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:18.0];
//
//    [allMillsBackgroundButtonView addSubview:allMillsTextView];

    
    UIButton *allMillsButton = [[UIButton alloc] initWithFrame:CGRectMake(893, 15, 100, 30)];
    allMillsButton.backgroundColor = [UIColor clearColor];
    [allMillsButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    allMillsButton.showsTouchWhenHighlighted = YES;
    [allMillsButton addTarget:self action:@selector(moveToAllMillsView)forControlEvents:UIControlEventTouchUpInside];
    [allMillsButton setTitle:@"All Mills" forState:UIControlStateNormal];
    [topBanner addSubview:allMillsButton];
    
    
    
    
    
    
    //save the offline images
    offlineImages = [[NSMutableDictionary alloc] init];
    
    //load up the view with assets
    [self setupLocalUserInterface:^(BOOL completeFlag){}];
    [self loadupProducts];
    
    //GA
    [model logData:@"Media Grid View" withAction:@"View Tracker" withLabel:@"Landed on media filter view"];
}




//this function loads up the products associated with the current filter
-(void)loadupProducts
{

    //a generic set of data to detect formatting the UI
    //cycle through the data and load up a grid of products
    NSArray *ends = [NSArray arrayWithObjects:@"0",@"3",@"4",@"7",@"8",@"11",@"12",@"15",@"16",@"19",@"20",@"23", nil];
    int x = 0, y = 24, e = 0, i = 1;
    for(Mill *m in model.initialSetOfMills){
        int width = 241;
        if([ends containsObject:[NSString stringWithFormat:@"%d",e]]) width = 233;
        
        
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, 300)];
        v.backgroundColor = [UIColor whiteColor];
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setFrame:CGRectMake(0, 0, width, 300)];
        [back addTarget:self action:@selector(productTouched:)forControlEvents:UIControlEventTouchUpInside];
        back.showsTouchWhenHighlighted = YES;
        [back setUserInteractionEnabled:YES];
        [back setTitle:m.key forState:UIControlStateNormal];
        [back setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        back.tag = e;
        [back setBackgroundColor:[UIColor whiteColor]];
        [v addSubview:back];
        
        if(x != 0){
            UIView *leftLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 300)];
            leftLine.backgroundColor = model.lightGray;
            [v addSubview:leftLine];
        }
        
        int imgX = 8;
        if(x == 0) imgX = 0;
        //below we add a placeholder image into the UIImageView, then we try and load the image on a background thread
        //if the image loads, it is placed in the UIImageView, if it does not, the view is placed in a dictionary to be redownloaded when the app comes back online
        //a flag is also set to make sure the app knows that we have to resync the UI
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, 0, 224, 151)];
        //check to make sure the everything is reachable
        NSString *u = [m.logo  stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        [iv sd_setImageWithURL:[NSURL URLWithString:u] placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        iv.contentMode = UIViewContentModeScaleAspectFit;
        [back addSubview:iv];
        
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(imgX, 155, 224, 42)];
        [title setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0]];
        title.textColor = [UIColor blackColor];
        title.numberOfLines = 2;
        title.adjustsFontSizeToFitWidth = YES;
        title.backgroundColor = [UIColor whiteColor];
        title.text = m.title;
        [back addSubview:title];
        
        UITextView *desc = [[UITextView alloc] initWithFrame:CGRectMake(imgX, 200, 224, 100)];
        [desc setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:13.0]];
        desc.textColor = [UIColor blackColor];
        desc.contentSize = CGSizeMake(224, 100);
        desc.editable = NO;
        desc.scrollEnabled = NO;
        desc.backgroundColor = [UIColor whiteColor];
        desc.text = m.description;
        [back addSubview:desc];
        
        
        UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clearButton setFrame:CGRectMake(0, 0, width, 300)];
        [clearButton addTarget:self action:@selector(productTouched:)forControlEvents:UIControlEventTouchUpInside];
        clearButton.showsTouchWhenHighlighted = YES;
        [clearButton setUserInteractionEnabled:YES];
        [clearButton setTitle:m.key forState:UIControlStateNormal];
        [clearButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        clearButton.tag = e;
        [clearButton setBackgroundColor:[UIColor clearColor]];
        [back addSubview:clearButton];
        
        [productScroll addSubview:v];
        
        if((i % 4) == 0){
            y += 350;
            x = 0;
        }else{
            x += width;
        }
        
        //counters
        e++; i++;
        
        //check to add the divider
        if((i % 4) == 0){
            if(i < [model.initialSetOfMills count]){
                int dy = y + 300;
                UIView *shadow = [[UIView alloc] initWithFrame:CGRectMake(0, dy, 952, 50)];
                shadow.backgroundColor = [UIColor whiteColor];
                
                UIImageView *divider = [[UIImageView alloc] initWithFrame:CGRectMake(0, 18, 952, 14)];
                [divider setImage:[UIImage imageNamed:@"img-div-shdw.png"]];
                [shadow addSubview:divider];
                [productScroll addSubview:shadow];
            }
        }
    }
    //below I am calculating the content height for the scrollview that displays the products
    int multi = e / 4, add = multi * 50;
    //set the dynamic content height
    int mod = e % 4;

    if(mod >= 1) add += 344;
    [productScroll setContentSize:CGSizeMake(952, ((multi * 300) + add + 10))];
    
}

-(void)moveToAllMillsView{
    AllMillsViewController *allMillsView = [[AllMillsViewController alloc] initWithNibName:@"AllMillsViewController" bundle:nil];
    [self.navigationController pushViewController:allMillsView animated:YES];
}


//this function handles a product being touched
//this function also sets the appropriate data so the product series can display the correct data
-(void)productTouched:(id)sender
{
    UIButton *b = (UIButton *)sender;
    
    for(Mill *m in model.initialSetOfMills){
        if([m.key isEqualToString:b.titleLabel.text]){
            model.selectedMill = m;
            break;
            
            //GA
            [model logData:@"Mill Grid View" withAction:@"Action Tracker" withLabel:m.title];
        }
    }
    
    if(model.selectedMill.title != nil){
        CanonMediaMillViewController *millView = [[CanonMediaMillViewController alloc] initWithNibName:@"CanonMediaMillViewController" bundle:nil];
        [self.navigationController pushViewController:millView animated:YES];
    }
 
    
}

//function that pops the view controller off the stack and sends the user back home
-(void)triggerHome:(id)sender
{
    [[self navigationController] popViewControllerAnimated:YES];
}

//function that sets up the disposable views for the view controller
-(void)setupLocalUserInterface:(completeBlock)completeFlag
{
    //setup top banner
    topBanner.image = [model getImageWithName:@"/header-pink@2x.png"];
    
    //home icon;
    [navBarHomeButton setBackgroundImage:[UIImage imageNamed:@"icn-home.png"] forState:UIControlStateNormal];
    
    completeFlag(YES);
}

//universal view function to display dynamic alerts
-(void)displayMessage:(NSString *)message withTitle:(NSString *)title
{
    UIAlertView *error = [[UIAlertView alloc] initWithTitle:title message: message
                                                   delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
    [error show];
}

//the ominous memory function!!!!
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
        if([model.hostReachability isReachableViaWiFi]){
            //we have now loaded
            model.needsUpdate = YES;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [self displayMessage:@"Please connect to the internet to update the application" withTitle:@"Alert"];
        }
    }
}


//network delegate function called when a response is sent back to the main thread
//this response will let the view and the user know that there is an update available
-(void)updateResponse:(CanonModel *)obj withFlag:(BOOL)flag{
    
    //update available, ask the user if they want to update the app
    if(flag){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Update App"
                                                        message:@"There is an update available, do you wish to download now?"
                                                       delegate:self cancelButtonTitle:@"No"
                                              otherButtonTitles:@"Yes", nil];
        [alert show];
    }
}


@end
