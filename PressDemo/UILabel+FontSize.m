//
//  UILabel+FontSize.m
//  PressDemo
//
//  Created by Trekk mini-1 on 1/21/15.
//  Copyright (c) 2015 Trekk. All rights reserved.
//

#import "UILabel+FontSize.h"

@implementation UILabel (FontSize)

- (void)alterRange:(NSRange)range withSize:(int)size {
    if (![self respondsToSelector:@selector(setAttributedText:)]) {
        return;
    }
    
    //NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    //style.headIndent = -100.0;
    
    NSMutableAttributedString *attributedText;
    if (!self.attributedText) {
        attributedText = [[NSMutableAttributedString alloc] initWithString:self.text];
    } else {
        attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    }
    //[attributedText setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:size], NSParagraphStyleAttributeName : style} range:range];
    [attributedText setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:size]} range:range];
    self.attributedText = attributedText;
    

    
    }

- (void)alterSubstring:(NSString*)substring withSize:(int)size {
    NSRange range = [self.text rangeOfString:substring];
    [self alterRange:range withSize:size];
}
@end
