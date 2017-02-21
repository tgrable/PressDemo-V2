//
//  DownloadFile.m
//  PressDemo
//
//  Created by Trekk mini-1 on 12/17/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "DownloadFile.h"

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation DownloadFile
@synthesize videoDownloading, model, index, downloadCount, totaldata, errors, threadData, imageCount, imageIndex;

- (id)init
{
    self = [super init];
    
    if (self != nil){
        manager = [SDWebImageManager sharedManager];
        imageCache = [[SDImageCache alloc] initWithNamespace:@"imPRESS"];
        
        videoDownloading = NO;
        errors = [[NSMutableDictionary alloc] init];
        threadData = [[NSMutableDictionary alloc] init];
        model = [self AppDataObj];
        downloadCount = 0;
        index = 0;
        imageIndex = 0;
        imageCount = 0;
        totaldata = 0.0;
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



-(void)downloadFile:(NSURL *)downloadURL
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:downloadURL];
    [request setTimeoutInterval:120];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSString *filename = [NSString stringWithFormat:@"%@",[downloadURL lastPathComponent]];
    NSString *cleansedFilename = [filename stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    
    //check to see if the file is on disk
    //if it is not, then run the download routine
    if(![model fileExists:cleansedFilename]){
    
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [paths objectAtIndex:0]; //filepath to documents directory!
            operation.outputStream = [NSOutputStream outputStreamToFileAtPath:[path stringByAppendingPathComponent:cleansedFilename] append:NO];
            ALog(@"HERE %@", cleansedFilename);
            
            [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
                totaldata += bytesRead;
            }];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                ALog(@"RES: %@", [[[operation response] allHeaderFields] description]);
                
                NSError *error;
                NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
                NSNumber *fileSizeNumber = [fileAttributes objectForKey:NSFileSize];
                long long fileSize = [fileSizeNumber longLongValue];
                ALog(@"File size %lldl File download path %@", fileSize, [path stringByAppendingPathComponent:filename]);
                
                //if there was an error accessing the file attributes, chances are that this file was not save correctly
                if (error) {
                    ALog(@"ERR: %@", [error description]);
                    index++;
                    
                    NSDictionary *e = [error userInfo];
                    //ALog(@"USER INFO FROM ERROR %@", e);
                    ALog(@"Index %d", index);
                    if([e objectForKey:@"NSErrorFailingURLStringKey"] != nil){
                        NSMutableDictionary *thread = [[NSMutableDictionary alloc] init];
                        [thread setObject:[e objectForKey:@"NSErrorFailingURLStringKey"] forKey:@"URL"];
                        [thread setObject:[[e objectForKey:@"NSErrorFailingURLStringKey"] lastPathComponent] forKey:@"name"];
                        [errors setObject:thread forKey:[[e objectForKey:@"NSErrorFailingURLStringKey"] lastPathComponent]];
                    }
                    [self getThreadIndex];
                } else {
                   
                    //check to see if the file we just saved exists
                    if([model fileExists:cleansedFilename]){
                        index++;
                        NSString *megs = [NSString stringWithFormat:@"%f MB", (totaldata/1024/1024)];
                        ALog(@"Index %d", index);
                        ALog(@"The File is on Disk. Total MBs read %@", megs);
                    
                        if(index == downloadCount){
                        //if(index == 2){
                            //this lets the UI know that we are complete
                            dispatch_async(dispatch_get_main_queue(), ^{
                               [_delegate fileDownloadResponse:YES];
                            });
                        }else{
                            //if we are not complete move on to the next document
                            [self getThreadIndex];
                        }
                    }else{
                        ALog(@"The file is not there on the disk");
                        index++;
                        ALog(@"Index %d", index);
                        [self getThreadIndex];
                    }
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                ALog(@"ERR: %@", [error description]);
                //ALog(@"ERROR!");
                index++;
                NSDictionary *e = [error userInfo];
                ALog(@"Index %d", index);
                if([e objectForKey:@"NSErrorFailingURLStringKey"] != nil){
                    NSMutableDictionary *thread = [[NSMutableDictionary alloc] init];
                    [thread setObject:[e objectForKey:@"NSErrorFailingURLStringKey"] forKey:@"URL"];
                    [thread setObject:[[e objectForKey:@"NSErrorFailingURLStringKey"] lastPathComponent] forKey:@"name"];
                    [errors setObject:thread forKey:[[e objectForKey:@"NSErrorFailingURLStringKey"] lastPathComponent]];
                }
                [self getThreadIndex];
                
            }];
            
            [operation start];
    }else{
        //move on to the next file
        index++;
        [self getThreadIndex];
    }
    
}

-(void)getThreadIndex
{
    if(index < downloadCount){
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate dowloadStatus:1 withDocumentIndex:index];
        });
        NSMutableDictionary *thread = [[NSMutableDictionary alloc] init];
        thread = [model.initialFilesToDownload objectAtIndex:index];
       
        [self downloadFile:[NSURL URLWithString:[thread objectForKey:@"URL"]]];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_delegate fileDownloadResponse:YES];
        });
    }
    
}

/*******************************************************************
 
 SDWebImage Persistant Image Functions
 The two functions below download and save UIImages to disk for offline usage
 
 *******************************************************************/


-(void)downloadAllImagesAndSaveThem:(NSString *)url
{
    
    __block int count = (int)[model.downloadedImages count];
    __block NSString *u = [url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];

    
    [manager downloadImageWithURL:[NSURL URLWithString:u] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize){
        // progression tracking code
        totaldata += receivedSize;
    }completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *url){

        if(finished){
            //notifiy the main thread of the file update
            dispatch_async(dispatch_get_main_queue(), ^{
                [_delegate dowloadStatus:2 withDocumentIndex:imageIndex];
            });
            
            //storing the image to disk takes a ton of memory, for right now I will cahce the image
            //[imageCache storeImage:image forKey:u toDisk:YES];
            imageIndex++;
            
            //if we have download the image, then notify the ui
            if(imageIndex == count){
                dispatch_async(dispatch_get_main_queue(), ^{
                   //finished with the download
                    [_delegate imageDownloadResponse:YES];
                });
            }else{
                if(imageIndex < count){
                    //ALog(@"Index %d", imageIndex);
                    NSString *megs = [NSString stringWithFormat:@"%f MB", (totaldata/1024/1024)];
                    ALog(@"Total MBs read %@", megs);
                    
                    NSString *urlString = [model.downloadedImages objectAtIndex:imageIndex];
                    [self downloadAllImagesAndSaveThem:urlString];
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [_delegate imageDownloadResponse:YES];
                    });
                }
            }
        }
    }];
    
    
}

-(void)clearImageMemory
{
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
}


@end
