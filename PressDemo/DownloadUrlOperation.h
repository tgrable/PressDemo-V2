//
//  DownloadUrlOperation.h
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadUrlOperation : NSOperation{
    // In concurrent operations to manage the operation's state
    BOOL executing_;
    BOOL finished_;
    // The actual NSURLConnection management
    NSURL*    connectionURL_;
    NSURLConnection*  connection_;
    NSMutableData*    data_;
}
@property (nonatomic,readonly) NSError* error;
@property (nonatomic,readonly) NSMutableData *data;
@property (nonatomic,readonly) NSURL *connectionURL;
- (id)initWithURL:(NSURL*)url;
@end