//
//  AppDataObject.h
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Video.h"
#import "Document.h"
#import "Product.h"

@interface AppDataObject : NSObject{
    BOOL reachable, firstLoad;
    NSMutableDictionary *documentData;
    NSMutableDictionary *videoData;
    NSMutableDictionary *productData;
    NSMutableDictionary *whatDoYouWantToPrint, *showAll;
    NSMutableDictionary *taxonomyReadableNames;
    NSMutableDictionary *lastUpdated;
}
@property (nonatomic, strong)NSMutableDictionary *documentData, *videoData, *productData;
@property (nonatomic, strong)NSMutableDictionary *whatDoYouWantToPrint, *showAll, *taxonomyReadableNames;
@property (nonatomic, strong)NSMutableDictionary *lastUpdated;
@property BOOL reachable, firstLoad;
@end
