//
//  Product.h
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Product : NSObject

@property(nonatomic, retain)NSString *title;
@property(nonatomic, retain)NSString *key;
@property(nonatomic, retain)NSArray *description;
@property(nonatomic, retain)NSDictionary *productSpec;
@property(nonatomic, retain)NSDictionary *whitePaper;
@property(nonatomic, retain)NSDictionary *caseStudy;
@property(nonatomic, retain)NSString *whatDoYouWantToPrint;
@property(nonatomic, retain)NSString *showAll;

@end

