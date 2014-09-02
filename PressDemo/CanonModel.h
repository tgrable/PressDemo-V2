//
//  CanonModel.h
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "AppDataObject.h"
#import "UIModel.h"
#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"
//#import <SDWebImage/SDImageCache.h>

@interface CanonModel : AppDataObject{
    
    ProductSeries *selectedSeries;
    UIModel *ui;
    UIColor *orange, *pink, *red, *blue, *dullBlack, *green, *purple, *gray, *yellow, *lightGray;
    NSString *testingString, *currentFilter;
    NSMutableArray *localProds, *filteredProducts;
    //SDWebImageManager *manager;
}
@property(nonatomic, strong)UIModel *ui;
@property(nonatomic, strong)ProductSeries *selectedSeries;
@property(nonatomic, strong)NSString *testingString, *currentFilter;
@property(nonatomic, strong)NSMutableArray *localProds, *filteredProducts;
@property(nonatomic, strong)UIColor *orange, *pink, *red, *blue, *dullBlack, *green, *purple, *gray, *yellow, *lightGray;
@property(nonatomic) Reachability *hostReachability;
typedef void(^completeBlock)(BOOL);

-(void)breakoutIncomingData:(NSData *)data complete:(completeBlock)completeFlag;
-(void)saveHTMLFile:(NSData *)data andFileName:(NSString *)filename complete:(completeBlock)completeFlag;
-(void)saveFile:(NSData *)data andFileName:(NSString *)filename complete:(completeBlock)completeFlag;
-(NSData *)getFileData:(NSString *)fileName complete:(completeBlock)completeFlag;
-(BOOL)fileExists:(NSString *)filename;
-(void)breakoutDocumentData:(NSArray *)documents withType:(NSString *)type;
-(NSData *)getHTMLFile:(NSString *)filename complete:(completeBlock)completeFlag;
-(void)breakoutProductData:(NSArray* )products;
-(void)wipeOutAllModelDataForUpdate;
-(void)breakoutVideoData:(NSArray *)videos;
-(BOOL)breakoutUpdateData:(NSData *)data;
-(void)breakoutProductSeriesData:(NSArray *)series;
-(void)saveAllDataToDisk:(completeBlock)completeFlagArgument;
//-(void)saveAllImagesToDisk:(NSMutableDictionary *)images complete:(completeBlock)completeFlagParent;
//-(void)downloadAllImagesAndSaveThem:(completeBlock)completeFlagFirstParent;
-(void)wipeOutAllModelData;
-(NSString *)getVideoFileName:(NSString *)url;
-(NSMutableArray *)getInitialSetofPorducts;
-(BOOL)videoExists:(NSString *)videoURL;
-(NSString *)returnFilePath:(NSString *)name;
@end
