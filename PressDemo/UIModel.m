//
//  UIModel.m
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "UIModel.h"

@implementation UIModel
@synthesize splash;

-(id)init
{
    self = [super init];
    
    if (self != nil){
        
        splash = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
        [splash setUserInteractionEnabled:YES];
        
        activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.frame = CGRectMake(490.0, 500.0, 35.0, 35.0);
        [activityIndicator setColor:[UIColor whiteColor]];
        [activityIndicator startAnimating];
        [splash addSubview:activityIndicator];
    }
    return self;
}

-(UIImage *)getImageWithName:(NSString *)filename
{
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    return [UIImage imageWithContentsOfFile:path];
}

@end
