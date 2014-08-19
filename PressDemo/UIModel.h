//
//  UIModel.h
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIModel;

@interface UIModel : NSObject{
    UIActivityIndicatorView *activityIndicator;
    UIImageView *splash;
}
@property(nonatomic, strong)UIImageView *splash;
-(UIImage *)getImageWithName:(NSString *)filename;
@end