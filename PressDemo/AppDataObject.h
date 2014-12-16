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
#import "Mill.h"
#import "Paper.h"
#import "Partner.h"
#import "Software.h"
#import "Solution.h"

@interface AppDataObject : NSObject{
    BOOL layoutSync, needsUpdate;
    NSMutableDictionary *whatDoYouWantToPrint, *showAll;
    NSMutableDictionary *taxonomyReadableNames, *topBanners;
    NSMutableDictionary *seriesBanners, *documentBanners;
    NSMutableDictionary *lastUpdated, *documentData, *productData, *productSeriesData, *videoData;
    NSMutableDictionary *millData, *paperData, *softwareData;
    NSMutableArray *downloadedImages, *initialSetOfMills, *initialSetOfPaper, *initialSolutionData, *initialPartnerData, *initialSofware;
}

@property (nonatomic, strong)NSMutableDictionary *whatDoYouWantToPrint, *showAll, *taxonomyReadableNames, *topBanners;
@property (nonatomic, strong)NSMutableDictionary *lastUpdated, *documentData, *productData, *productSeriesData, *videoData;
@property (nonatomic, strong)NSMutableDictionary *seriesBanners, *millData, *paperData, *softwareData;
@property (nonatomic, strong)NSMutableArray *downloadedImages, *initialSetOfMills, *initialSetOfPaper, *initialSolutionData, *initialPartnerData, *initialSofware;
@property BOOL layoutSync, needsUpdate;
@end
