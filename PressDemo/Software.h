//
//  Software.h
//  PressDemo
//
//  Created by Trekk mini-1 on 12/9/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Software : NSObject <NSCoding>

@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *key;
@property(nonatomic, copy)NSString *logo;
@property(nonatomic, copy)NSString *short_desc;
@property(nonatomic, copy)NSMutableArray *banners;
@property(nonatomic, copy)NSString *description;
@property(nonatomic, copy)NSMutableDictionary *overview;
@property(nonatomic, copy)NSMutableArray *datasheets;
@property(nonatomic, copy)NSMutableArray *case_studies;
@property(nonatomic, copy)NSMutableArray *white_papers;
@property(nonatomic, copy)NSMutableArray *videos;
@property(nonatomic, copy)NSMutableArray *brochures;

@end
