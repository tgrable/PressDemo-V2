//
//  CanonMediaMillSearchOverlay.m
//  PressDemo
//
//  Created by Trekk mini-1 on 10/14/15.
//  Copyright © 2015 Trekk. All rights reserved.
//

#import "CanonMediaMillSearchOverlay.h"
#import <QuartzCore/QuartzCore.h>

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation CanonMediaMillSearchOverlay

@synthesize colorButton, savedColorValue;
@synthesize basisWeightTextfield, background, model, searchArray, searchBackgroundTitle, searchTitles;

//Here we are setting up the delegate method
- (CanonModel *) AppDataObj;
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    CanonModel * modelObject;
    modelObject = (CanonModel*) theDelegate.AppDataObj;
    
    return modelObject;
}

- (id)init
{
    self = [super init];
    
    if (self != nil){
        
        model = [self AppDataObj];
        searchArray = [NSMutableArray array];
        savedColorValue = 0;
        
        searchTitles = [NSMutableArray array];
        [searchTitles addObject:@"Mill Name"];
        [searchTitles addObject:@"Media Name"];
        [searchTitles addObject:@"Basis Weight"];
        [searchTitles addObject:@"Brightness"];
        [searchTitles addObject:@"Coating"];
        [searchTitles addObject:@"Color"];
        [searchTitles addObject:@"Capability"];
        [searchTitles addObject:@"Inkset"];
        
        for (int i = 0; i < 8; i++) {
            [searchArray addObject:@""];
        }
        
    }
    return self;
}


- (void)buildViews
{
    
    background = [[UIView alloc] initWithFrame:CGRectMake(212, 55, 600, 657)];
    background.alpha = 0.0;
    background.backgroundColor = [UIColor whiteColor];
    background.userInteractionEnabled = YES;
    background.layer.masksToBounds = NO;
    background.layer.shadowOffset = CGSizeMake(-4, 6);
    background.layer.shadowRadius = 4;
    background.layer.shadowOpacity = 0.5;
    
    UIView *headerBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, 44)];
    headerBackground.backgroundColor = model.blue;
    [background addSubview:headerBackground];
    
    searchBackgroundTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 600, 24)];
    searchBackgroundTitle.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:24.0];
    searchBackgroundTitle.text = @"";
    searchBackgroundTitle.textAlignment = NSTextAlignmentCenter;
    searchBackgroundTitle.textColor = [UIColor whiteColor];
    searchBackgroundTitle.backgroundColor = [UIColor clearColor];
    [headerBackground addSubview:searchBackgroundTitle];
    
    // Mill Label
    millLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 59, 570, 20)];
    millLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    millLabel.text = @"Mill Name";
    millLabel.textColor = model.dullBlack;
    millLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:millLabel];
    
    millButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [millButton setFrame:CGRectMake(15, 82, 570, 26)];
    [millButton addTarget:self action:@selector(bringUpSearchPicker:)forControlEvents:UIControlEventTouchDown];
    millButton.showsTouchWhenHighlighted = YES;
    millButton.tag = 1;
    [[millButton layer] setBorderWidth:1.0f];
    [[millButton layer] setBorderColor:model.dullBlack.CGColor];
    [millButton setTitle:@"- NONE -" forState:UIControlStateNormal];
    [millButton setTitleColor:model.dullBlack forState:UIControlStateNormal];
    [millButton setBackgroundColor:[UIColor clearColor]];
    [background addSubview:millButton];
    
    // Media Name Label
    mediaNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 126, 570, 20)];
    mediaNameLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    mediaNameLabel.text = @"Media Name";
    mediaNameLabel.textColor = model.dullBlack;
    mediaNameLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:mediaNameLabel];
    
    //millButton, *mediaButton, *basisWeightButton, *brightnessButton, *coatingButton, *colorButton, *capabilityButton, *inksetButton
    mediaButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [mediaButton setFrame:CGRectMake(15, 149, 570, 26)];
    [mediaButton addTarget:self action:@selector(bringUpSearchPicker:)forControlEvents:UIControlEventTouchDown];
    mediaButton.showsTouchWhenHighlighted = YES;
    mediaButton.tag = 2;
    [[mediaButton layer] setBorderWidth:1.0f];
    [[mediaButton layer] setBorderColor:model.dullBlack.CGColor];
    [mediaButton setTitle:@"- NONE -" forState:UIControlStateNormal];
    [mediaButton setTitleColor:model.dullBlack forState:UIControlStateNormal];
    [mediaButton setBackgroundColor:[UIColor clearColor]];
    [background addSubview:mediaButton];
    
    // Basis Weight Label
    basisWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 193, 570, 20)];
    basisWeightLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    basisWeightLabel.text = @"Basis Weight";
    basisWeightLabel.textColor = model.dullBlack;
    basisWeightLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:basisWeightLabel];
    
    basisWeightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [basisWeightButton setFrame:CGRectMake(15, 216, 570, 26)];
    [basisWeightButton addTarget:self action:@selector(bringUpSearchPicker:)forControlEvents:UIControlEventTouchDown];
    basisWeightButton.showsTouchWhenHighlighted = YES;
    basisWeightButton.tag = 3;
    [[basisWeightButton layer] setBorderWidth:1.0f];
    [[basisWeightButton layer] setBorderColor:model.dullBlack.CGColor];
    [basisWeightButton setTitle:@"- NONE -" forState:UIControlStateNormal];
    [basisWeightButton setTitleColor:model.dullBlack forState:UIControlStateNormal];
    [basisWeightButton setBackgroundColor:[UIColor clearColor]];
    [background addSubview:basisWeightButton];
    
    // Brightness Label
    brightnessLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 260, 570, 20)];
    brightnessLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    brightnessLabel.text = @"Brightness";
    brightnessLabel.textColor = model.dullBlack;
    brightnessLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:brightnessLabel];
    
    brightnessButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [brightnessButton setFrame:CGRectMake(15, 283, 570, 26)];
    [brightnessButton addTarget:self action:@selector(bringUpSearchPicker:)forControlEvents:UIControlEventTouchDown];
    brightnessButton.showsTouchWhenHighlighted = YES;
    brightnessButton.tag = 4;
    [[brightnessButton layer] setBorderWidth:1.0f];
    [[brightnessButton layer] setBorderColor:model.dullBlack.CGColor];
    [brightnessButton setTitle:@"- NONE -" forState:UIControlStateNormal];
    [brightnessButton setTitleColor:model.dullBlack forState:UIControlStateNormal];
    [brightnessButton setBackgroundColor:[UIColor clearColor]];
    [background addSubview:brightnessButton];
    
    // Color Label
    coatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 327, 570, 20)];
    coatingLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    coatingLabel.text = @"Coating";
    coatingLabel.textColor = model.dullBlack;
    coatingLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:coatingLabel];
    
    coatingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [coatingButton setFrame:CGRectMake(15, 350, 570, 26)];
    [coatingButton addTarget:self action:@selector(bringUpSearchPicker:)forControlEvents:UIControlEventTouchDown];
    coatingButton.showsTouchWhenHighlighted = YES;
    coatingButton.tag = 5;
    [[coatingButton layer] setBorderWidth:1.0f];
    [[coatingButton layer] setBorderColor:model.dullBlack.CGColor];
    [coatingButton setTitle:@"- NONE -" forState:UIControlStateNormal];
    [coatingButton setTitleColor:model.dullBlack forState:UIControlStateNormal];
    [coatingButton setBackgroundColor:[UIColor clearColor]];
    [background addSubview:coatingButton];
    
    // Color Label
    colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 394, 570, 20)];
    colorLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    colorLabel.text = @"Color";
    colorLabel.textColor = model.dullBlack;
    colorLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:colorLabel];
    
    colorButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [colorButton setFrame:CGRectMake(15, 417, 570, 26)];
    [colorButton addTarget:self action:@selector(bringUpSearchPicker:)forControlEvents:UIControlEventTouchDown];
    colorButton.showsTouchWhenHighlighted = YES;
    colorButton.tag = 6;
    [[colorButton layer] setBorderWidth:1.0f];
    [[colorButton layer] setBorderColor:model.dullBlack.CGColor];
    [colorButton setTitle:@"- NONE -" forState:UIControlStateNormal];
    [colorButton setTitleColor:model.dullBlack forState:UIControlStateNormal];
    [colorButton setBackgroundColor:[UIColor clearColor]];
    [background addSubview:colorButton];
    
    // Capability Label
    capabilityLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 461, 570, 20)];
    capabilityLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    capabilityLabel.text = @"Capability";
    capabilityLabel.textColor = model.dullBlack;
    capabilityLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:capabilityLabel];
    
    capabilityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [capabilityButton setFrame:CGRectMake(15, 484, 570, 26)];
    [capabilityButton addTarget:self action:@selector(bringUpSearchPicker:)forControlEvents:UIControlEventTouchDown];
    capabilityButton.showsTouchWhenHighlighted = YES;
    capabilityButton.tag = 7;
    [[capabilityButton layer] setBorderWidth:1.0f];
    [[capabilityButton layer] setBorderColor:model.dullBlack.CGColor];
    [capabilityButton setTitle:@"- NONE -" forState:UIControlStateNormal];
    [capabilityButton setTitleColor:model.dullBlack forState:UIControlStateNormal];
    [capabilityButton setBackgroundColor:[UIColor clearColor]];
    [background addSubview:capabilityButton];
    
    // Inkset Label
    inksetLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 528, 570, 20)];
    inksetLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    inksetLabel.text = @"Inkset";
    inksetLabel.textColor = model.dullBlack;
    inksetLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:inksetLabel];
    
    inksetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [inksetButton setFrame:CGRectMake(15, 551, 570, 26)];
    [inksetButton addTarget:self action:@selector(bringUpSearchPicker:)forControlEvents:UIControlEventTouchDown];
    inksetButton.showsTouchWhenHighlighted = YES;
    inksetButton.tag = 8;
    [[inksetButton layer] setBorderWidth:1.0f];
    [[inksetButton layer] setBorderColor:model.dullBlack.CGColor];
    [inksetButton setTitle:@"- NONE -" forState:UIControlStateNormal];
    [inksetButton setTitleColor:model.dullBlack forState:UIControlStateNormal];
    [inksetButton setBackgroundColor:[UIColor clearColor]];
    [background addSubview:inksetButton];

    
    search = [UIButton buttonWithType:UIButtonTypeCustom];
    [search setFrame:CGRectMake(15, 598, 80, 44)];
    [search addTarget:self action:@selector(applyFilter:)forControlEvents:UIControlEventTouchDown];
    search.showsTouchWhenHighlighted = YES;
    [search setTitle:@"Apply" forState:UIControlStateNormal];
    [search setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [search setBackgroundColor:model.blue];
    [background addSubview:search];
    
    close = [UIButton buttonWithType:UIButtonTypeCustom];
    [close setFrame:CGRectMake(110, 598, 80, 44)];
    [close addTarget:self action:@selector(closeTable:)forControlEvents:UIControlEventTouchDown];
    close.showsTouchWhenHighlighted = YES;
    [close setTitle:@"Close" forState:UIControlStateNormal];
    [close setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [close setBackgroundColor:model.blue];
    [background addSubview:close];
}

- (void)applyFilter:(id)sender
{
    NSString *colorValue = @"";
    if (savedColorValue == -1 || savedColorValue == 0) {
       colorValue = @"- NONE -";
    } else {
       colorValue = [NSString stringWithFormat:@"%d", savedColorValue];
    }
    [searchArray removeAllObjects];
    [searchArray insertObject:millButton.currentTitle atIndex:0];
    [searchArray insertObject:mediaButton.currentTitle atIndex:1];
    [searchArray insertObject:basisWeightButton.currentTitle atIndex:2];
    [searchArray insertObject:brightnessButton.currentTitle atIndex:3];
    [searchArray insertObject:coatingButton.currentTitle atIndex:4];
    [searchArray insertObject:colorValue atIndex:5];
    [searchArray insertObject:capabilityButton.currentTitle atIndex:6];
    [searchArray insertObject:inksetButton.currentTitle atIndex:7];
    [searchArray insertObject:@"key" atIndex:8];
    
    [_delegate searchResponse];
}

-(void)closeTable:(id)sender
{
    [_delegate closeResponse];
}

-(void)bringUpSearchPicker:(id)sender
{
    UIButton *b = (UIButton *)sender;
    int t = (int)(b.tag - 1);
    [_delegate bringUpSearchDialog:t withTitle:[searchTitles objectAtIndex:t]];
}


@end
