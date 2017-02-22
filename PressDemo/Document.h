//
//  Document.h
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Document : NSObject <NSCoding>

@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *key;
@property(nonatomic, copy)NSString *type;
@property(nonatomic, copy)NSString *description;
@property(nonatomic, copy)NSString *image;
@property(nonatomic, copy)NSString *data;

@end
