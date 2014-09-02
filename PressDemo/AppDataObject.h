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
#import "ProductSeries.h"
#import "SavedVideos.h"

@interface AppDataObject : NSObject{
    BOOL reachable, layoutSync, needsUpdate;
    NSMutableDictionary *whatDoYouWantToPrint, *showAll;
    NSMutableDictionary *taxonomyReadableNames, *topBanners;
    NSMutableDictionary *seriesBanners, *documentBanners;
    NSMutableDictionary *lastUpdated, *documentData, *productData, *productSeriesData, *videoData;
    NSMutableArray *downloadedImages;
}

@property (nonatomic, strong)NSMutableDictionary *whatDoYouWantToPrint, *showAll, *taxonomyReadableNames, *topBanners;
@property (nonatomic, strong)NSMutableDictionary *lastUpdated, *documentData, *productData, *productSeriesData, *videoData;
@property (nonatomic, strong)NSMutableDictionary *seriesBanners;
@property (nonatomic, strong)NSMutableArray *downloadedImages;
@property BOOL reachable, layoutSync, needsUpdate;
@end
