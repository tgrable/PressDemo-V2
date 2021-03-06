//
//  CanonAppDelegate.m
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "CanonAppDelegate.h"
#import "CanonModel.h"
#import "Reachability.h"
#import "GAI.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation CanonAppDelegate
@synthesize AppDataObj;

- (id) init;
{
	self.AppDataObj = [[CanonModel alloc] init];
   
    return [super init];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    //Register the Google Analytics Library
    // Optional: automatically send uncaught exceptions to Google Analytics.
    //[GAI sharedInstance].trackUncaughtExceptions = YES;
    
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 120;
    
    // Optional: set Logger to VERBOSE for debug information.
    //[[[GAI sharedInstance] logger] setLogLevel:kGAILogLevelVerbose];
    
    // Initialize tracker.
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-49102313-4"];
    
    [GAI sharedInstance].dryRun = YES;
    
    //setup NSUserDefaults for LastUpdated
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"LastUpdated" ofType:@"plist"]]];
    
    //setup NSUserDefaults for InitialDownload
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"InitialDownload" ofType:@"plist"]]];
    
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    //make the splash screen appear for 3 seconds
    [NSThread sleepForTimeInterval:3.0];
    
    
    //load the root view controller
    self.downloadViewController = [[CanonDownloadAll alloc] initWithNibName:@"CanonDownloadAll" bundle:nil];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.downloadViewController];
    [navController.navigationBar setBounds:CGRectMake(0, 0, 1024, 64)];
    
    [navController setNavigationBarHidden:YES animated:NO];
    [self.window setRootViewController: navController];
    [self.window makeKeyAndVisible];
    
    [[Fabric sharedSDK] setDebug:NO];
    [Fabric with:@[[Crashlytics class]]];
 
    return YES;
}

# pragma mark - Rotation

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    if ([[self.window.rootViewController.childViewControllers lastObject] isKindOfClass:[ReaderViewController class]]) {
        // Get topmost/visible view controller
        UIViewController *currentViewController = [self.window.rootViewController.childViewControllers lastObject];
        // Check whether it implements a dummy methods called canRotate
        if ([currentViewController respondsToSelector:@selector(canRotate)]) {
            // Unlock landscape view orientations for this view controller
            return UIInterfaceOrientationMaskAll;
        }
    }
    
    // Only allow portrait (standard behaviour)
    return UIInterfaceOrientationMaskLandscape;
}

-(void)canRotate
{
   
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
