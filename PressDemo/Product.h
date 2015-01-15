//
//  Product.h
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject <NSCoding>

@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *key;
@property(nonatomic, copy)NSString *series;
@property(nonatomic, copy)NSMutableDictionary *images;
@property(nonatomic, copy)NSString *description;
@property(nonatomic, copy)NSMutableArray *whatDoYouWantToPrint;
@property(nonatomic, copy)NSMutableArray *showAll;
@property(nonatomic, copy)NSString *series_title;
@property(nonatomic, copy)NSString *short_series_description;
@end

