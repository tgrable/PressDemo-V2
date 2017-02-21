//
//  SearchablePaper.h
//  PressDemo
//
//  Created by Trekk mini-1 on 10/21/15.
//  Copyright © 2015 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchablePaper : NSObject <NSCoding>

@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *mill_name;
@property(nonatomic, copy)NSString *basis_weight;
@property(nonatomic, copy)NSString *brightness;
@property(nonatomic, copy)NSString *coating;
@property(nonatomic, copy)NSString *color_capability;
@property(nonatomic, copy)NSString *category;
@property(nonatomic, copy)NSString *dye_pigment;
@end
