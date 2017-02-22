//
//  UIBorderLabel.m
//  PressDemo
//
//  Created by Trekk mini-1 on 12/18/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "UIBorderLabel.h"

@implementation UIBorderLabel


@synthesize topInset, leftInset, bottomInset, rightInset;

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = {self.topInset, self.leftInset, self.bottomInset, self.rightInset};
    
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
