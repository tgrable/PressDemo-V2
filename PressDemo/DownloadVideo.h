//
//  DownloadVideo.h
//  PressDemo
//
//  Created by Trekk mini-1 on 12/17/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperation.h"
#import "CanonModel.h"
#import "AppDelegateProtocol.h"
typedef void(^completeBlock)(BOOL);

//network delegate for sending responses and data to the view controllers
@protocol VideoDelegate <NSObject>
@optional
-(void)videoDownloadResponse:(BOOL)flag;

@end

@interface DownloadVideo : NSObject{
    BOOL videoDownloading;
}
@property(nonatomic, strong)CanonModel *model;
@property (weak, nonatomic) id <VideoDelegate> delegate;
@property BOOL videoDownloading;

-(void)downloadVideo:(NSString *)url;
@end
