//
//  SavedVideos.h
//  PressDemo
//
//  Created by Trekk mini-1 on 8/25/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SavedVideos : NSObject <NSCoding>

@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *key;
@property(nonatomic, copy)NSString *savedURL;

@end
