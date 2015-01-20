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


@interface CanonModel : AppDataObject{
    UIColor *orange, *pink, *red, *blue, *dullBlack, *green, *purple, *gray, *yellow, *lightGray;
    int imageCount;
    
}
//Model Properties
@property(nonatomic, assign) id tracker;
@property(nonatomic, strong)ProductSeries *selectedSeries;
@property(nonatomic, strong)Mill *selectedMill;
@property(nonatomic, strong)Partner *selectedPartner;
@property(nonatomic, strong)Software *selectedSoftware;
@property(nonatomic, strong)NSString *testingString, *currentFilter;
@property(nonatomic, strong)NSMutableArray *localProds, *filteredProducts;
@property(nonatomic, strong)UIColor *orange, *pink, *red, *blue, *dullBlack, *green, *purple, *gray, *yellow, *lightGray;
@property(nonatomic) Reachability *hostReachability;
typedef void(^completeBlock)(BOOL);

//Function prototypes
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
-(void)breakoutPartnerData:(NSArray *)partners;
-(void)breakoutSoftwareData:(NSArray *)software;
-(void)breakoutMillData:(NSArray *)mills;
-(void)breakoutPaperData:(NSArray *)papers;
-(void)breakoutSolutionData:(NSArray* )solution;

-(BOOL)breakoutUpdateData:(NSData *)data;
-(void)breakoutProductSeriesData:(NSArray *)series;
-(void)saveAllDataToDisk:(completeBlock)completeFlagArgument;
-(NSString *)cleanseStringName:(NSString *)filename;
-(CGFloat)widthOfString:(NSString *)string withStringSize:(float)size andFontKey:(NSString *)key;

-(NSString *)addAccentToOCEString:(NSString *)string;
-(UIImage *)getImageWithName:(NSString *)filename;
-(void)wipeOutAllModelData;
-(NSString *)getVideoFileName:(NSString *)url;
-(NSMutableArray *)getInitialSetofPorducts;
-(BOOL)videoExists:(NSString *)videoURL;
-(NSString *)returnFilePath:(NSString *)name;
-(BOOL)deleteFile:(NSString *)filename;
-(NSMutableArray *)cleanArray:(NSMutableArray *)array;
//google analytics
-(void)logData:(NSString *)category withAction:(NSString *)action withLabel:(NSString *)label;
-(void)sortInitialPaperDataAlpha:(NSString *)key complete:(completeBlock)completeFlag;
@end
