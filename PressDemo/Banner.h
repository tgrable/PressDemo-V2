//
//  Banner.h
//  PressDemo
//
//  Created by Trekk mini-1 on 4/27/15.
//  Copyright (c) 2015 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Banner : NSObject <NSCoding>
@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *key;
@property(nonatomic, copy)NSMutableArray *banners;
@property(nonatomic, copy)NSString *product_series_reference;

@end
