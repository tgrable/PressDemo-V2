//
//  DownloadVideo.m
//  PressDemo
//
//  Created by Trekk mini-1 on 12/17/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "DownloadVideo.h"

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation DownloadVideo
@synthesize videoDownloading, model;

- (id)init
{
    self = [super init];
    
    if (self != nil){
        
        videoDownloading = NO;
        model = [self AppDataObj];
    }
    return self;
}

//Here we are setting up the delegate method
- (CanonModel *) AppDataObj;
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    CanonModel * modelObject;
    modelObject = (CanonModel*) theDelegate.AppDataObj;
    
    return modelObject;
}

-(void)downloadVideo:(NSString *)url
{

    @autoreleasepool {
        videoDownloading = YES;
        NSURL *URL = [NSURL URLWithString:url];
        [self downloadFile:URL complete:^(BOOL completeFlag){
            if(completeFlag){
                //success
                videoDownloading = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate videoDownloadResponse:YES];
                });
                
            }else{
                //error
                videoDownloading = NO;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_delegate videoDownloadResponse:NO];
                });
            }
        }];
        
    }
}

-(void)downloadFile:(NSURL *)downloadURL complete:(completeBlock)completeFlagLocal
{
   
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSString *filename = [NSString stringWithFormat:@"%@",[downloadURL lastPathComponent]];
    NSString *cleansedFilename = [filename stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0]; //filepath to documents directory!
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[path stringByAppendingPathComponent:cleansedFilename] append:NO];
    
    
    [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        ALog(@"bytesRead: %u, totalBytesRead: %lld, totalBytesExpectedToRead: %lld", bytesRead, totalBytesRead, totalBytesExpectedToRead);
    }];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        ALog(@"RES: %@", [[[operation response] allHeaderFields] description]);
               
        NSError *error;
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
        
        if (error) {
            ALog(@"ERR: %@", [error description]);
            completeFlagLocal(NO);
        } else {
            NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
            long long fileSize = [fileSizeNumber longLongValue];
            ALog(@"File size %lldl File download path %@", fileSize, [path stringByAppendingPathComponent:cleansedFilename]);
            
            if([model fileExists:cleansedFilename]){
                ALog(@"YES data is there");
            }else{
                ALog(@"NO data is not there");
            }
            completeFlagLocal(YES);
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        ALog(@"ERR: %@", [error description]);
        completeFlagLocal(NO);
    }];
    
    [operation start];
    
}



@end
