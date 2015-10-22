//
//  NetworkData.m
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//


#import "NetworkData.h"
#import "DownloadUrlOperation.h"

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation NetworkData
@synthesize networkURL, threads, machineName;
@synthesize downloadURLs, model, updateURL;

- (id)init
{
    self = [super init];
    
    if (self != nil){
        
        //The production URL
        //networkURL = "";
        //The staging URL
        networkURL = @"http://pressdemo.trekkweb.com";
        //networkURL = @"http://dev-pressdemo.pantheon.io";
        updateURL = @"/data/update";
        threads = [[NSMutableDictionary alloc] init];
        status = 0;
        threadCount = 0;
        failureFlag = NO;
        videoDownloading = NO;
        model = [self AppDataObj];
        // add product back to the machine name
        machineName = [[NSMutableArray alloc] initWithObjects:@"case-study",
                                                              @"product",
                                                              @"product-spec",
                                                              @"video",
                                                              @"white-paper",
                                                              @"product-series",
                                                              @"paper",
                                                              @"mill",
                                                              @"partner",
                                                              @"software",
                                                              @"datasheet",
                                                              @"solution",
                                                              @"brochure",
                                                              @"banner", nil];
        downloadCount = (int)[machineName count];
        downloadURLs = [[NSMutableArray alloc] init];
    }
    return self;
}

//function that runs the initial download sequence
-(void)runInitialDownload
{
    @autoreleasepool {
        for(NSString *value in machineName){
            //the opration queues
            queue = [NSOperationQueue new];
            [queue setMaxConcurrentOperationCount:3];
            
            //set the status to one for the initial download
            status = 1;
            
            NSString *url = [NSString stringWithFormat:@"%@/data/api/%@", networkURL, value];

            [downloadURLs addObject:url];
            
            //initiate the downloadoperation class and set the class properties for user authentication
            DownloadUrlOperation *_downLoad = [[DownloadUrlOperation alloc] initWithURL:[NSURL URLWithString:url]];
            [_downLoad addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:NULL];
            [queue addOperation:_downLoad];
        }
    }
}

//function that runs the initial download sequence
-(void)checkForUpdate
{
    @autoreleasepool {
        //the opration queues
        
        queue = [NSOperationQueue new];
        [queue setMaxConcurrentOperationCount:1];
        
        //set the status to one for the initial download
        status = 2;
        
        NSString *url = [NSString stringWithFormat:@"%@%@", networkURL, updateURL];

        [downloadURLs addObject:url];
        
        //initiate the downloadoperation class and set the class properties for user authentication
        DownloadUrlOperation *_downLoad = [[DownloadUrlOperation alloc] initWithURL:[NSURL URLWithString:url]];
        [_downLoad addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:NULL];
        [queue addOperation:_downLoad];
    
    }
}




//Here we are setting up the delegate method
- (CanonModel *) AppDataObj;
{
	id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
	CanonModel * modelObject;
	modelObject = (CanonModel*) theDelegate.AppDataObj;
    
	return modelObject;
}


//function being used for key-value listening on everything being run through our DownloadUrlOperation object
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)operation change:(NSDictionary *)change context:(void *)context {
    NSString *source = nil;
    NSString *responseStr = @"";
    NSData *data = nil;
    NSError *error = nil;
    //NSString *threadKey = @"";
    
    //make sure the operation is of DownloadUrlOperation
    if ([operation isKindOfClass:[DownloadUrlOperation class]]) {
        DownloadUrlOperation *downloadOperation = (DownloadUrlOperation *)operation;
        
        //make sure we have the download url in queue
        if ([downloadURLs containsObject:[downloadOperation.connectionURL absoluteString]]) {
            source = [downloadOperation.connectionURL absoluteString];
        }
        
        //if we have a valid source, load the NSData return to a local variable
        if (source) {
            data = [downloadOperation data];
            responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            error = [downloadOperation error];
        }
    }
    
    //if source
    if (source) {
        if (error != nil) {
            // handle error
            // Notify that we have got an error downloading this data;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Download Failed"
                                                                object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:source, @"source", error, @"error", nil]];
            
            if(status == 1){
                ALog(@"Error %@", error);
                //let user know we have an error
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate initialDownloadResponse:model withFlag:NO];
                });
            }
        }else {
            //here I am checking to see the what type of download routine we are doing so I can
            //route the routine to the model to break out the data
            if(status == 1){
                //break out the initial data
                [model breakoutIncomingData:data complete:^(BOOL completeFlag){
                    //keep track of all of the running threads
                    threadCount++;
                    // make sure the failure flag is notified that something went wrong
                    if(completeFlag == NO) failureFlag = YES;
                    
                    if(threadCount == downloadCount){
                        //success
                        if(!failureFlag){
                            //sync data and wipe out model
                            ALog(@"Saving data to disk");
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                                [model saveAllDataToDisk:^(BOOL completeFlagArgument){
                                    if(completeFlagArgument){
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [_delegate initialDownloadResponse:model withFlag:YES];
                                        });
                                    }else{
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            [_delegate initialDownloadResponse:model withFlag:NO];
                                        });
                                    }
                                }];
                            });
                            
                        }else{
                            //failure
                            ALog(@"Failure!");
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [_delegate initialDownloadResponse:model withFlag:NO];
                            });
                        }
                        threadCount = 0;
                        failureFlag = NO;
                        [downloadURLs removeAllObjects];
                    }
                }];
            }else if(status == 2){
                //delegate update routine
                BOOL response = [model breakoutUpdateData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate updateResponse:model withFlag:response];
                });
                
            }
        }
    }
    
}

@end
