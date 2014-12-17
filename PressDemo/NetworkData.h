//
//  NetworkData.h
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "AppDataObject.h"
#import "CanonModel.h"
#import "AppDelegateProtocol.h"


//network delegate for sending responses and data to the view controllers
@protocol NetworkDelegate <NSObject>
@optional
//functions to be executed when the network calls are finished
-(void)downloadResponse:(CanonModel *)obj withFlag:(BOOL)flag;
-(void)updateResponse:(CanonModel *)obj withFlag:(BOOL)flag;

@end

@interface NetworkData : NSObject{
    
    CanonModel *model;
    NSString *networkURL, *updateURL;
    NSMutableDictionary *threads;
    NSMutableArray *machineName, *downloadURLs;
    NSOperationQueue *queue;
    int status, downloadCount, threadCount;
    BOOL failureFlag, videoDownloading;
    

}
@property(nonatomic, strong)CanonModel *model;
@property (weak, nonatomic) id <NetworkDelegate> delegate;


@property(nonatomic, strong)NSMutableDictionary *threads;
@property(nonatomic, strong)NSMutableArray *machineName, *downloadURLs;
@property(nonatomic, strong)NSString *networkURL, *updateURL;

-(void)runInitialDownload;
-(void)checkForUpdate;
@end