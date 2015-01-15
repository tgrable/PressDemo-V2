//
//  DownloadFile.h
//  PressDemo
//
//  Created by Trekk mini-1 on 12/17/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"
#import "AppDataObject.h"
#import "CanonModel.h"
#import "AppDelegateProtocol.h"
#import <SDWebImage/UIImageView+WebCache.h>

@protocol FileDelegate <NSObject>
@optional
-(void)fileDownloadResponse:(BOOL)flag;
-(void)dowloadStatus:(int)stage withDocumentIndex:(int)index;
-(void)imageDownloadResponse:(BOOL)flag;

@end

@interface DownloadFile : NSObject{
    BOOL videoDownloading;
    int downloadCount, index, imageCount, imageIndex;
    double totaldata;
    NSMutableDictionary *errors;
    SDWebImageManager  *manager;
    SDImageCache *imageCache;
   
}
@property(nonatomic, strong)CanonModel *model;
@property(nonatomic)NSMutableDictionary *errors, *threadData;
@property BOOL videoDownloading;
@property int downloadCount, index, imageCount, imageIndex;
@property double totaldata;
@property (weak, nonatomic) id <FileDelegate> delegate;

-(void)getThreadIndex;
-(void)downloadFile:(NSURL *)downloadURL;
-(void)downloadAllImagesAndSaveThem:(NSString *)url;
-(void)clearImageMemory;
@end
