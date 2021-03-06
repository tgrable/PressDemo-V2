//
//  CanonModel.h
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

/*******************************
 SDWebImage has been commented out of this application because it still is on the table to be used for a later version.
 SDWebImage downloads all of the images locally and saves them to the device to be used offline
*******************************/

#import "AppDataObject.h"
#import <AVFoundation/AVFoundation.h>
#import "Reachability.h"
#import "SDWebImage/SDWebImageManager.h"
#import <sys/utsname.h>

@interface CanonModel : AppDataObject{
    UIColor *orange, *pink, *red, *blue, *dullBlack, *green, *purple, *gray, *yellow, *lightGray;
    int imageCount;
    BOOL animationRun;
}
//Model Properties
@property(nonatomic, assign) id tracker;
@property(nonatomic, strong)ProductSeries *selectedSeries;
@property(nonatomic, strong)Mill *selectedMill;
@property(nonatomic, strong)Partner *selectedPartner;
@property(nonatomic, strong)Software *selectedSoftware;
@property(nonatomic, strong)NSMutableDictionary *initialBannerDictionary;
@property(nonatomic, strong)NSString *testingString, *currentFilter;
@property(nonatomic, strong)NSMutableArray *localProds, *filteredProducts;
@property(nonatomic, strong)UIColor *orange, *pink, *red, *blue, *dullBlack, *green, *purple, *gray, *yellow, *lightGray;
@property(nonatomic) Reachability *hostReachability;
@property BOOL animationRun;

/** type definitions **/
typedef void(^completeBlock)(BOOL);

//Function prototypes
/** model functions **/
-(void)breakoutProductData:(NSArray* )products;
-(void)wipeOutAllModelDataForUpdate;
-(void)breakoutVideoData:(NSArray *)videos;
-(void)breakoutPartnerData:(NSArray *)partners;
-(void)breakoutSoftwareData:(NSArray *)software;
-(void)breakoutMillData:(NSArray *)mills;
-(void)breakoutPaperData:(NSArray *)papers;
-(void)breakoutSolutionData:(NSArray* )solution;
-(BOOL)breakoutUpdateData:(NSData *)data;
-(void)breakoutProductSeriesData:(NSArray *)series;
-(void)breakoutIncomingData:(NSData *)data complete:(completeBlock)completeFlag;
-(void)breakoutDocumentData:(NSArray *)documents withType:(NSString *)type;

/** file functions **/
-(UIImage *)getImageWithName:(NSString *)filename;
-(NSString *)getVideoFileName:(NSString *)url;
-(BOOL)videoExists:(NSString *)videoURL;
-(NSString *)returnFilePath:(NSString *)name;
-(BOOL)deleteFile:(NSString *)filename;
-(void)saveAllDataToDisk:(completeBlock)completeFlagArgument;
-(NSData *)getHTMLFile:(NSString *)filename complete:(completeBlock)completeFlag;
-(BOOL)fileExists:(NSString *)filename;
-(void)saveHTMLFile:(NSData *)data andFileName:(NSString *)filename complete:(completeBlock)completeFlag;
-(void)saveFile:(NSData *)data andFileName:(NSString *)filename complete:(completeBlock)completeFlag;
-(NSData *)getFileData:(NSString *)fileName complete:(completeBlock)completeFlag;
-(NSURL *)getProperURL:(NSString *)url;

/** google analytics **/
-(void)logData:(NSString *)category withAction:(NSString *)action withLabel:(NSString *)label;

/** utility functions **/
-(void)sortInitialPaperDataAlpha:(NSString *)key complete:(completeBlock)completeFlag;
-(void)searchInitialPaperData:(NSMutableDictionary *)searchTerms complete:(completeBlock)completeFlag;
-(NSMutableArray *)cleanArray:(NSMutableArray *)array;
-(NSMutableArray *)getInitialSetofPorducts;
-(NSMutableDictionary *)getInitialBannerData;
-(void)wipeOutAllModelData;
-(NSString *)addAccentToOCEString:(NSString *)string;
-(NSString *)cleanseStringName:(NSString *)filename;
-(CGFloat)widthOfString:(NSString *)string withStringSize:(float)size andFontKey:(NSString *)key;
-(void)buildSearchableDataSource:(NSMutableArray *)incomingPaperData sourceFlag:(BOOL)flag complete:(completeBlock)completeFlag;
-(NSString *)deviceInformation;
@end
