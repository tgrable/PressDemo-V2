//
//  Paper.h
//  PressDemo
//
//  Created by Trekk mini-1 on 12/9/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Paper : NSObject <NSCoding>

@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *key;
@property(nonatomic, copy)NSString *mill;
@property(nonatomic, copy)NSString *mill_name;
@property(nonatomic, copy)NSMutableArray *basis_weight;
@property(nonatomic, copy)NSString *brightness;
@property(nonatomic, copy)NSString *coating;
@property(nonatomic, copy)NSString *color_capacity;
@property(nonatomic, copy)NSString *category;
@property(nonatomic, copy)NSString *dye_pigment;
@property(nonatomic, copy)NSString *region;
@property(nonatomic, copy)NSString *micr_capable;
@property(nonatomic, copy)NSString *price_range;
@property(nonatomic, copy)NSString *opacity_range;
@property(nonatomic, copy)NSString *caliper;
@property(nonatomic, copy)NSString *recycled_percentage;
@property(nonatomic, copy)NSString *type_one;
@property(nonatomic, copy)NSString *type_two;
@property(nonatomic, copy)NSString *color_capability;
@property(nonatomic, copy)NSString *weights_available;
@property(nonatomic, copy)NSString *boost_sample;
@property(nonatomic, copy)NSString *house_paper;
@end
