//
//  NetworkData.m
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//


#import "NetworkData.h"
#import "DownloadUrlOperation.h"

@implementation NetworkData
@synthesize networkURL, threads, machineName;
@synthesize downloadURLs, model, updateURL, videoDownloading;
- (id)init
{
    self = [super init];
    
    if (self != nil){
        
        //The production URL
        //networkURL = "";
        //The staging URL
        networkURL = @"http://pressdemo.trekkweb.com";
        updateURL = @"/data/update";
        threads = [[NSMutableDictionary alloc] init];
        status = 0;
        threadCount = 0;
        failureFlag = NO;
        videoDownloading = NO;
        model = [self AppDataObj];
        // add product back to the machine name
        machineName = [[NSMutableArray alloc] initWithObjects:@"case-study", @"product", @"product-spec", @"video", @"white-paper", @"product-series", nil];
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
            NSLog(@"URLs %@", url);
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
        NSLog(@"MADE IT HERE %@", url);
        [downloadURLs addObject:url];
        
        //initiate the downloadoperation class and set the class properties for user authentication
        DownloadUrlOperation *_downLoad = [[DownloadUrlOperation alloc] initWithURL:[NSURL URLWithString:url]];
        [_downLoad addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:NULL];
        [queue addOperation:_downLoad];
    
    }
}

-(void)downloadVideo:(NSString *)url
{
    @autoreleasepool {
        //NSURL *videoURL = [NSURL URLWithString:url];
        //MPMoviePlayerViewController *moviePlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        //http://mediavaletcsa.origin.mediaservices.windows.net/c0a9837b-e284-402b-a84e-60be63503e0c/CS3000 Sustainability.ism/manifest(format=m3u8-aapl)
       
        /*
        //clear out the download array
        [downloadURLs removeAllObjects];
        //the opration queues
        queue = [NSOperationQueue new];
        [queue setMaxConcurrentOperationCount:1];
        
        //set the status to one for the initial download
        status = 3;
        videoDownloading = YES;
        NSLog(@"MADE IT HERE %@", url);
        [downloadURLs addObject:url];
        
        //initiate the downloadoperation class and set the class properties for user authentication
        DownloadUrlOperation *_downLoad = [[DownloadUrlOperation alloc] initWithURL:[NSURL URLWithString:url]];
        [_downLoad addObserver:self forKeyPath:@"isFinished" options:NSKeyValueObservingOptionNew context:NULL];
        [queue addOperation:_downLoad];
         */
        
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
                NSLog(@"Error %@", error);
                //let user know we have an error
                [_delegate downloadResponse:model withFlag:NO];
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
                    NSLog(@"Thread count %d", threadCount);
                    if(threadCount == downloadCount){
                        //success
                        if(!failureFlag){
                            //sync data and wipe out model
                            NSLog(@"Saving data to disk");
                            [model saveAllDataToDisk:^(BOOL completeFlagArgument){
                                NSLog(@"Success!");
                                //Just as an option to have
                                //[model downloadAllImagesAndSaveThem:^(BOOL completeFlagParent){
                                    [_delegate downloadResponse:model withFlag:YES];
                                //}];
                            }];
                            
                        }else{
                            //failure
                            NSLog(@"Failure!");
                            [_delegate downloadResponse:model withFlag:NO];
                        }
                        threadCount = 0;
                        failureFlag = NO;
                        [downloadURLs removeAllObjects];
                    }
                }];
            }else if(status == 2){
                //delegate update routine
                BOOL response = [model breakoutUpdateData:data];
                [_delegate updateResponse:model withFlag:response];
                
            }else if(status == 3){
                //delegate the video download routine
                if([downloadURLs count] > 0){
                    NSString *videoName = [downloadURLs objectAtIndex:0];
                    NSLog(@"Save file %@", videoName);
                    NSString *name = [model getVideoFileName:videoName];
                    name = [NSString stringWithFormat:@"%@.mp4", name];
                    [model saveFile:data andFileName:name complete:^(BOOL completeFlag) {
                        if(completeFlag){
                            //success
                            [_delegate videoDownloadResponse:model withFlag:YES];
                            videoDownloading = NO;
                        }else{
                            //error
                            [_delegate videoDownloadResponse:model withFlag:NO];
                            videoDownloading = NO;
                        }
                    }];
                }else{
                    //error
                    [_delegate videoDownloadResponse:model withFlag:NO];
                    videoDownloading = NO;
                }
            }
        }
    }
    
}

@end
