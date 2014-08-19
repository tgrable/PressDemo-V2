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

#define ResourcePath(path)[[NSBundle mainBundle] pathForResource:path ofType:nil]

#define ImageWithPath(path)[UIImage imageWithContentsOfFile:path]

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
        NSLog(@"NIB");
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
        NSLog(@"REACHABLE");
        if([[[NSUserDefaults standardUserDefaults] objectForKey:@"case-study"] isEqualToString:@""] && !downloadInProgress){
            //this means that the app failed on the initial load and needs to be loaded
            [self runLoadingSequence];
        }
        
    } else {
        //set UI error
        model.reachable = NO;
        NSLog(@"NOT REACHABLE");
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
    //if we can reach the internet
    NSLog(@"Reachable %@", model.hostReachability);
    if ([model.hostReachability isReachable] && !downloadInProgress) {
        model.reachable = YES;
        NSLog(@"APP came back into focus and it is reachable");
        if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"case-study"] isEqualToString:@""]){
            NSLog(@"CHECKING FOR UPDATES");
            [network checkForUpdate];
        }else{
            model.reachable = NO;
        }
    }
    
}


-(void)runLoadingSequence
{
    NSLog(@"runLoadingSequence");
    dispatch_queue_t model_queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    //execute the first load sequence load
    if([[[NSUserDefaults standardUserDefaults] objectForKey:@"case-study"] isEqualToString:@""] && !downloadInProgress){
        NSLog(@"runLoadingSequence, case study blank, no other download in progress");
        model.ui.splash.image = [model.ui getImageWithName:@"/sample@2x.png"];
        [self.view addSubview:model.ui.splash];
        [self.view bringSubviewToFront:model.ui.splash];
       
        if([model.hostReachability isReachable]){
            downloadInProgress = YES;
            NSLog(@"runLoadingSequence, case study blank, no other download in progress, network is reachable");
            UIActivityIndicatorView *ac = (UIActivityIndicatorView *)[model.ui.splash viewWithTag:444];
            ac.alpha = 1.0;
            dispatch_async(model_queue, ^{
                NSLog(@"runLoadingSequence, case study blank, no other download in progress, network is reachable, running download");
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
    NSLog(@"viewWillAppear HOME");
    
    if(model.needsUpdate && model.reachable){
        NSLog(@"The app was flagged that it needed updates");
        model.ui.splash.image = [model.ui getImageWithName:@"/sample@2x.png"];
        [self.view addSubview:model.ui.splash];
        [self.view bringSubviewToFront:model.ui.splash];
        dispatch_queue_t model_queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(model_queue, ^{
            [network runInitialDownload];
        });
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear HOME");
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
    NSLog(@"viewWillDisappear HOME");
    
    //remove notification
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear HOME");
    
    //remove all assets here for future memory enhancements
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //this notification is set to the reachability of the application
    //if the application cannot connect, then this function is called
    
    network = [[NetworkData alloc] init];
    network.delegate = self;
   
    model = [self AppDataObj];
    
    downloadInProgress = NO;
    
    NSLog(@"Hitting first load");
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
    whatDoYouPrint = [[UIScrollView alloc] initWithFrame:CGRectMake(276, 365, 734, 187)];
    whatDoYouPrint.showsHorizontalScrollIndicator = YES;
    whatDoYouPrint.showsVerticalScrollIndicator = NO;
    whatDoYouPrint.canCancelContentTouches = YES;
    whatDoYouPrint.delegate = self;
    whatDoYouPrint.clipsToBounds = YES;
    [self.view addSubview:whatDoYouPrint];

    //image header for the scrollview
    showProducts = [[UIImageView alloc] initWithFrame:CGRectMake(0, 566, 290, 201)];
    showProducts.backgroundColor = [UIColor clearColor];
    [showProducts setUserInteractionEnabled:YES];
    [self.view addSubview:showProducts];
    
    //scroll view for show all products
    showAllProducts = [[UIScrollView alloc] initWithFrame:CGRectMake(276, 566, 734, 187)];
    showAllProducts.showsHorizontalScrollIndicator = YES;
    showAllProducts.showsVerticalScrollIndicator = NO;
    showAllProducts.canCancelContentTouches = YES;
    showAllProducts.delegate = self;
    showAllProducts.clipsToBounds = YES;
    [self.view addSubview:showAllProducts];
    
    
    [self.view bringSubviewToFront:model.ui.splash];
    
    NSLog(@"viewDidLoad");

    //make sure this is at the bottom of the view
    //at the end of view did load, make sure we have data and load the view up
    //this means that we are running the app again after it has been loaded at least once
    if(![[[NSUserDefaults standardUserDefaults] objectForKey:@"case-study"] isEqualToString:@""]){
        NSLog(@"Bottom of view did load");
        NSLog(@"Case study before load %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"case-study"]);
        //setup the local UI before I remove the splash screen
        [self setupLocalUserInterface:^(BOOL completeFlag){
            [model.ui.splash removeFromSuperview];
            model.ui.splash.image = nil;
        }];
    }
}


-(void)captureFilterButtons:(id)sender
{
    UIButton *b = (UIButton *)sender;
    model.currentFilter = b.titleLabel.text;
    
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
    
    for(Product *p in model.filteredProducts){
        NSLog(@"Title %@", p.title);
    }
    FilterViewController *filter = [[FilterViewController alloc] initWithNibName:@"FilterViewController" bundle:nil];
    [self.navigationController pushViewController:filter animated:YES];
    
    //@TODO Look at deallocating the memory after you leave this view
    
}

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
        //display the filters in the console
        NSLog(@"HERE is my local filter for what %@", whatImageNames);
        NSLog(@"HERE is my local filter for what %@", showAllImageNames);
        //load all what do your want to print buttons
        
        
        int x1 = 0, e1 = 0;
        for(NSString *wf in whatImageNames){
            x1 = e1 * 204 + 14;
            if(x1 == 0) x1 = 14;
            UIButton *wfButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [wfButton setFrame:CGRectMake(x1, 0, 197, 187)];
            [wfButton addTarget:self action:@selector(captureFilterButtons:)forControlEvents:UIControlEventTouchUpInside];
            wfButton.showsTouchWhenHighlighted = YES;
            //[wfButton setBackgroundImage:[model.ui getImageWithName:[model.whatDoYouWantToPrint objectForKey:wf]] forState:UIControlStateNormal];
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
            //[saButton setBackgroundImage:[model.ui getImageWithName:[model.showAll objectForKey:sa]] forState:UIControlStateNormal];
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
        NSLog(@"Download response");
        
        //wipe out all data after first initial load
        [model wipeOutAllModelData];
        
        //before we send rebuild the ui with updated data, tear down the UI
        if(model.needsUpdate){
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
        [model wipeOutAllModelDataForUpdate];
        model.needsUpdate = YES;
        NSLog(@"The app was flagged that it needed updates");
        model.ui.splash.image = [model.ui getImageWithName:@"/sample@2x.png"];
        [self.view addSubview:model.ui.splash];
        [self.view bringSubviewToFront:model.ui.splash];
        dispatch_queue_t model_queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(model_queue, ^{
            [network runInitialDownload];
        });

        
       
    }
}

//network delegate function called when a response is sent back to the main thread
//this response will let the view and the user know that there is an update available
-(void)updateResponse:(CanonModel *)obj withFlag:(BOOL)flag{
    
    NSLog(@"Update Response, %d.  This tells us if there is an update available.", flag);
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
