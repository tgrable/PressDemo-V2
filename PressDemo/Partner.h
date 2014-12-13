//
//  Partner.h
//  PressDemo
//
//  Created by Trekk mini-1 on 12/9/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Partner : NSObject <NSCoding>

@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *key;
@property(nonatomic, copy)NSMutableArray *banners;
@property(nonatomic, copy)NSString *logo;
@property(nonatomic, copy)NSString *description;
@property(nonatomic, copy)NSMutableArray *case_study;
@property(nonatomic, copy)NSMutableArray *white_paper;
@property(nonatomic, copy)NSMutableArray *videos;
@property(nonatomic, copy)NSMutableArray *solutions;


@end
