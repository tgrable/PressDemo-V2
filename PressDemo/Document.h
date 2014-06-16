//
//  Document.h
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Document : NSObject

@property(nonatomic, retain)NSString *title;
@property(nonatomic, retain)NSString *key;
@property(nonatomic, retain)NSString *type;
@property(nonatomic, retain)NSString *description;
@property(nonatomic, retain)NSString *image;
@property(nonatomic, retain)NSString *data;

@end
