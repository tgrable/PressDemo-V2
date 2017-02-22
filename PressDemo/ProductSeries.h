//
//  ProductSeries.h
//  PressDemo
//
//  Created by Trekk mini-1 on 8/7/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductSeries : NSObject <NSCoding>

@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *key;
@property(nonatomic, copy)NSMutableDictionary *description;
@property(nonatomic, copy)NSMutableArray *case_studies;
@property(nonatomic, copy)NSMutableArray *white_papers;
@property(nonatomic, copy)NSMutableArray *product_spec;
@property(nonatomic, copy)NSMutableArray *videos;
@property(nonatomic, copy)NSMutableArray *products;
@property(nonatomic, copy)NSMutableArray *solutions;
@end
