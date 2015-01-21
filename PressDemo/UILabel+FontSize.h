//
//  UILabel+FontSize.h
//  PressDemo
//
//  Created by Trekk mini-1 on 1/21/15.
//  Copyright (c) 2015 Trekk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (FontSize)
- (void)alterRange:(NSRange)range withSize:(int)size;
- (void)alterSubstring:(NSString*)substring withSize:(int)size;
@end