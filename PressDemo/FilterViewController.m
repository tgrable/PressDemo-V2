//
//  FilterViewController.m
//  PressDemo
//
//  Created by Trekk mini-1 on 8/11/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "FilterViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SeriesViewController.h"

#define ResourcePath(path)[[NSBundle mainBundle] pathForResource:path ofType:nil]

#define ImageWithPath(path)[UIImage imageWithContentsOfFile:path]

@implementation FilterViewController
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
        NSLog(@"REACHABLE");
        
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
    //Reachability* reachability = [Reachability reachabilityWithHostname:@"www.google.com"];
    //if we can reach the internet
    NSLog(@"Reachable %@", model.hostReachability);
    if ([model.hostReachability isReachable]) {
        model.reachable = YES;
        NSLog(@"APP came back into focus and it is reachable");
        NSLog(@"CHECKING FOR UPDATES");
        [network checkForUpdate];
        
        //resync the UI
        if(!model.layoutSync){
           for (id key in offlineImages) {
               UIImageView *i = [offlineImages objectForKey:key];
               NSArray *url = [key componentsSeparatedByString:@"---"];
               if([url objectAtIndex:1] != nil){
                  [i setImageWithURL:[NSURL URLWithString:[url objectAtIndex:1]] placeholderImage:[UIImage imageNamed:@"placeholder.png"]
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
                            NSLog(@"Got the image %@", image);
                  }];
               }
                
           }
            
           [offlineImages removeAllObjects];
           model.layoutSync = YES;
        }

    }else{
        model.reachable = NO;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear FILTER");
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear FILTER");
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
    NSLog(@"viewWillDisappear FILTER");
    [[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear FILTER");
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
    
    
    navBarHomeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [navBarHomeButton setFrame:CGRectMake(36, 14, 35, 35)];
    [navBarHomeButton addTarget:self action:@selector(triggerHome:)forControlEvents:UIControlEventTouchDown];
    navBarHomeButton.showsTouchWhenHighlighted = YES;
    navBarHomeButton.tag = 20;
    [customNavBar addSubview:navBarHomeButton];
    
    productScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(36, 145, 952, 620)];
    productScroll.showsHorizontalScrollIndicator = NO;
    productScroll.showsVerticalScrollIndicator = YES;
    productScroll.canCancelContentTouches = YES;
    productScroll.delegate = self;
    productScroll.clipsToBounds = YES;
    [self.view addSubview:productScroll];
    
    topBanner = [[UIImageView alloc] initWithFrame:CGRectMake(0, 84, 1024, 89)];
    topBanner.backgroundColor = [UIColor clearColor];
    [topBanner setUserInteractionEnabled:YES];
    [self.view addSubview:topBanner];
    
    //save the offline images
    offlineImages = [[NSMutableDictionary alloc] init];

    //load up the view with assets
    [self setupLocalUserInterface:^(BOOL completeFlag){}];
    [self loadupProducts];
}

-(void)loadupProducts
{
    NSArray *ends = [NSArray arrayWithObjects:@"0",@"3",@"4",@"7",@"8",@"11",@"12",@"15",@"16",@"19",@"20",@"23", nil];
    int x = 0, y = 24, e = 0, i = 1;
    for(Product *p in model.filteredProducts){
        int width = 241;
        if([ends containsObject:[NSString stringWithFormat:@"%d",e]]) width = 233;


        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, 300)];
        v.backgroundColor = [UIColor whiteColor];
        
        UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
        [back setFrame:CGRectMake(0, 0, width, 300)];
        [back addTarget:self action:@selector(productTouched:)forControlEvents:UIControlEventTouchUpInside];
        back.showsTouchWhenHighlighted = YES;
        [back setUserInteractionEnabled:YES];
        [back setTitle:p.series forState:UIControlStateNormal];
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
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, 0, 224, 151)];
        //check to make sure the everything is reachable
        NSString *u = [[p.images objectForKey:@"grid-image"] stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        __weak typeof(UIImageView) *imgView = iv;
        [iv setImageWithURL:[NSURL URLWithString:u] placeholderImage:[UIImage imageNamed:@"placeholder.png"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
            if(error){
                NSLog(@"Error %@", error);
                NSString *key = [NSString stringWithFormat:@"%d---%@",i,u];
                imgView.image = [UIImage imageNamed:@"placeholder.png"];
                [offlineImages setObject:imgView forKey:key];
                model.layoutSync = NO;
            }
        }];
        [back addSubview:iv];
         
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(imgX, 155, 224, 42)];
        [title setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0]];
        title.textColor = [UIColor blackColor];
        title.numberOfLines = 2;
        title.backgroundColor = [UIColor whiteColor];
        title.text = [p.title uppercaseString];
        [back addSubview:title];
        
        UILabel *desc = [[UILabel alloc] initWithFrame:CGRectMake(imgX, 200, 224, 95)];
        [desc setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:13.0]];
        desc.textColor = [UIColor blackColor];
        desc.numberOfLines = 6;
        desc.backgroundColor = [UIColor whiteColor];
        desc.text = p.description;
        [back addSubview:desc];
        

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
            if(i < [model.filteredProducts count]){
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
    int multi = i / 4, add = multi * 50, mod = [model.filteredProducts count] % 4;
    if(mod >= 1) add += 324;
    [productScroll setContentSize:CGSizeMake(952, ((multi * 300) + add))];

}

-(void)productTouched:(id)sender
{
    UIButton *b = (UIButton *)sender;
    NSLog(@"Series %@",b.titleLabel.text);
    
    NSData *seriesData = [model getFileData:b.titleLabel.text complete:^(BOOL completeFlag){}];
    model.selectedSeries = [NSKeyedUnarchiver unarchiveObjectWithData:seriesData];
    NSLog(@"Series %@", model.selectedSeries.title);
    
    SeriesViewController *series = [[SeriesViewController alloc] initWithNibName:@"SeriesViewController" bundle:nil];
    [self.navigationController pushViewController:series animated:YES];
}

-(void)triggerHome:(id)sender
{
    NSLog(@"HOME!");
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)setupLocalUserInterface:(completeBlock)completeFlag
{
    //setup top banner
    //topBanner.image = [model.ui getImageWithName:[model.topBanners objectForKey:model.currentFilter]];
    topBanner.image = [model.topBanners objectForKey:model.currentFilter];
    
    //home icon
    //[navBarHomeButton setBackgroundImage:[model.ui getImageWithName:@"/icn-home@2x.png"] forState:UIControlStateNormal];
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
        //remove nsuserdefaults
        [model wipeOutAllModelDataForUpdate];
        
        if(model.reachable){
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
