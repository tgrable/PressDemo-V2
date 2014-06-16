//
//  CanonModel.h
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "AppDataObject.h"
#import "UIModel.h"

@interface CanonModel : AppDataObject{
    
    UIModel *ui;
    UIColor *orange, *blue, *pink, *green, *purple, *gray, *textColor;
    NSString *testingString;
    
}
@property(nonatomic, strong)UIModel *ui;
@property(nonatomic, strong)NSString *testingString;
@property(nonatomic, strong)UIColor *orange, *blue, *pink, *green, *purple, *gray, *textColor;
typedef void(^completeBlock)(BOOL);

-(void)breakoutIncomingData:(NSData *)data complete:(completeBlock)completeFlag;
-(void)saveHTMLFile:(NSData *)data andFileName:(NSString *)filename complete:(completeBlock)completeFlag;
-(NSData *)getFileData:(NSString *)fileName complete:(completeBlock)completeFlag;
-(BOOL)fileExists:(NSString *)filename;
-(void)breakoutDocumentData:(NSArray *)documents withType:(NSString *)type;
-(NSData *)getHTMLFile:(NSString *)filename complete:(completeBlock)completeFlag;
-(void)breakoutProductData:(NSArray* )products;
-(void)wipeOutAllModelDataForUpdate;
-(BOOL)breakoutUpdateData:(NSData *)data;
@end
