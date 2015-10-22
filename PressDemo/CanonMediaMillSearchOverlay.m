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

@synthesize millNamePicker, mediaNamePicker, brightnessPicker, coatingPicker, colorPicker, capabilityPicker, inksetPicker;
@synthesize basisWeightTextfield, background, model, basisWeightPicker, searchArray, searchBackgroundTitle, iconArray;

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
        
        iconArray = [NSMutableArray array];
        [iconArray addObject:[UIImage imageNamed:@"ico-blackwhite.png"]];
        [iconArray addObject:[UIImage imageNamed:@"ico-color.png"]];
        [iconArray addObject:[UIImage imageNamed:@"ico-color.png"]];
        [iconArray addObject:[UIImage imageNamed:@"ico-color.png"]];
        [iconArray addObject:[UIImage imageNamed:@"ico-color.png"]];
        
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
    
    
    millNamePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(15, 70, 570, 60)];
    millNamePicker.backgroundColor = [UIColor whiteColor];
    millNamePicker.delegate = self;
    [millNamePicker setTintColor:[UIColor whiteColor]];
    millNamePicker.dataSource = self;
    [background addSubview:millNamePicker];
    
    // Mill Label
    millLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 59, 570, 20)];
    millLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    millLabel.text = @"Mill Name";
    millLabel.textColor = model.dullBlack;
    millLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:millLabel];
    
    
    mediaNamePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(15, 137, 570, 60)];
    mediaNamePicker.backgroundColor = [UIColor whiteColor];
    mediaNamePicker.delegate = self;
    [mediaNamePicker setTintColor:[UIColor whiteColor]];
    mediaNamePicker.dataSource = self;
    [background addSubview:mediaNamePicker];
    
    // Media Name Label
    mediaNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 126, 570, 20)];
    mediaNameLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    mediaNameLabel.text = @"Media Name";
    mediaNameLabel.textColor = model.dullBlack;
    mediaNameLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:mediaNameLabel];
    
    
    basisWeightPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(15, 204, 570, 60)];
    basisWeightPicker.backgroundColor = [UIColor whiteColor];
    basisWeightPicker.delegate = self;
    [basisWeightPicker setTintColor:[UIColor whiteColor]];
    basisWeightPicker.dataSource = self;
    [background addSubview:basisWeightPicker];
    
    // Basis Weight Label
    basisWeightLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 193, 570, 20)];
    basisWeightLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    basisWeightLabel.text = @"Basis Weight";
    basisWeightLabel.textColor = model.dullBlack;
    basisWeightLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:basisWeightLabel];
    
    
    brightnessPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(15, 271, 570, 60)];
    brightnessPicker.backgroundColor = [UIColor whiteColor];
    brightnessPicker.delegate = self;
    [brightnessPicker setTintColor:[UIColor whiteColor]];
    brightnessPicker.dataSource = self;
    [background addSubview:brightnessPicker];
    
    // Brightness Label
    brightnessLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 260, 570, 20)];
    brightnessLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    brightnessLabel.text = @"Brightness";
    brightnessLabel.textColor = model.dullBlack;
    brightnessLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:brightnessLabel];
    
    
    coatingPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(15, 338, 570, 60)];
    coatingPicker.backgroundColor = [UIColor whiteColor];
    coatingPicker.delegate = self;
    [coatingPicker setTintColor:[UIColor whiteColor]];
    coatingPicker.dataSource = self;
    [background addSubview:coatingPicker];
    
    // Color Label
    coatingLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 327, 570, 20)];
    coatingLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    coatingLabel.text = @"Coating";
    coatingLabel.textColor = model.dullBlack;
    coatingLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:coatingLabel];
    
    
    colorPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(15, 405, 570, 60)];
    colorPicker.backgroundColor = [UIColor whiteColor];
    colorPicker.delegate = self;
    [colorPicker setTintColor:[UIColor whiteColor]];
    colorPicker.dataSource = self;
    [background addSubview:colorPicker];
    [colorPicker selectRow:2 inComponent:0 animated:NO];
    
    // Color Label
    colorLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 394, 570, 20)];
    colorLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    colorLabel.text = @"Color";
    colorLabel.textColor = model.dullBlack;
    colorLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:colorLabel];
    

    capabilityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(15, 472, 570, 60)];
    capabilityPicker.backgroundColor = [UIColor whiteColor];
    capabilityPicker.delegate = self;
    [capabilityPicker setTintColor:[UIColor whiteColor]];
    capabilityPicker.dataSource = self;
    [background addSubview:capabilityPicker];
    
    // Capability Label
    capabilityLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 461, 570, 20)];
    capabilityLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    capabilityLabel.text = @"Capability";
    capabilityLabel.textColor = model.dullBlack;
    capabilityLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:capabilityLabel];

    
    inksetPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(15, 539, 570, 60)];
    inksetPicker.backgroundColor = [UIColor whiteColor];
    inksetPicker.delegate = self;
    [inksetPicker setTintColor:[UIColor whiteColor]];
    inksetPicker.dataSource = self;
    [background addSubview:inksetPicker];
    
    // Inkset Label
    inksetLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 528, 570, 20)];
    inksetLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0];
    inksetLabel.text = @"Inkset";
    inksetLabel.textColor = model.dullBlack;
    inksetLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:inksetLabel];

    
    search = [UIButton buttonWithType:UIButtonTypeCustom];
    [search setFrame:CGRectMake(15, 598, 80, 44)];
    [search addTarget:self action:@selector(searchTable:)forControlEvents:UIControlEventTouchDown];
    search.showsTouchWhenHighlighted = YES;
    [search setTitle:@"Filter" forState:UIControlStateNormal];
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

- (void)searchTable:(id)sender
{
    NSString * color = [[model.searchableMillData objectAtIndex:5] objectAtIndex:[colorPicker selectedRowInComponent:0]];
    
    [searchArray replaceObjectAtIndex:0 withObject:[[model.searchableMillData objectAtIndex:0] objectAtIndex:[millNamePicker selectedRowInComponent:0]]];
    [searchArray replaceObjectAtIndex:1 withObject:[[model.searchableMillData objectAtIndex:1] objectAtIndex:[mediaNamePicker selectedRowInComponent:0]]];
    [searchArray replaceObjectAtIndex:2 withObject:[[model.searchableMillData objectAtIndex:2] objectAtIndex:[basisWeightPicker selectedRowInComponent:0]]];
    [searchArray replaceObjectAtIndex:3 withObject:[[model.searchableMillData objectAtIndex:3] objectAtIndex:[brightnessPicker selectedRowInComponent:0]]];
    [searchArray replaceObjectAtIndex:4 withObject:[[model.searchableMillData objectAtIndex:4] objectAtIndex:[coatingPicker selectedRowInComponent:0]]];
    [searchArray replaceObjectAtIndex:5 withObject:color];
    [searchArray replaceObjectAtIndex:6 withObject:[[model.searchableMillData objectAtIndex:6] objectAtIndex:[capabilityPicker selectedRowInComponent:0]]];
    [searchArray replaceObjectAtIndex:7 withObject:[[model.searchableMillData objectAtIndex:7] objectAtIndex:[inksetPicker selectedRowInComponent:0]]];
    

    ALog(@"Search Array %@", searchArray);
    [_delegate searchResponse];
}

-(void)closeTable:(id)sender
{
    [_delegate closeResponse];
}

-(UIView *)getColorIconSet:(int)value
{
    UIView *iconSet = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 570, 15)];
    iconSet.backgroundColor = [UIColor clearColor];
    iconSet.tag = value;
    
    int i = 0;
    
    //small view
    iconSet.frame = CGRectMake(0, 0, 88, 15);
    while(i < value){
        int xOffset = i * 18;
        UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(xOffset, 3, 15, 15)];
        [icon setImage:[iconArray objectAtIndex:i]];
        
        [iconSet addSubview:icon];
        i++;
    }
    
    return iconSet;
}

#pragma mark -
#pragma mark PickerView DataSource
// Called by the picker view when it needs the number of components.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// Called by the picker view when it needs the number of rows for a specified component.
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    
    if ([pickerView isEqual:millNamePicker]) {
        return [[model.searchableMillData objectAtIndex:0] count];
    }
    
    if ([pickerView isEqual:mediaNamePicker]) {
        return [[model.searchableMillData objectAtIndex:1] count];
    }
    
    if ([pickerView isEqual:basisWeightPicker]) {
        return [[model.searchableMillData objectAtIndex:2] count];
    }
    
    if ([pickerView isEqual:brightnessPicker]) {
        return [[model.searchableMillData objectAtIndex:3] count];
    }
    
    if ([pickerView isEqual:coatingPicker]) {
        return [[model.searchableMillData objectAtIndex:4] count];
    }
    
    if ([pickerView isEqual:colorPicker]) {
        return [[model.searchableMillData objectAtIndex:5] count];
    }
    
    if ([pickerView isEqual:capabilityPicker]) {
        return [[model.searchableMillData objectAtIndex:6] count];
    }
    
    if ([pickerView isEqual:inksetPicker]) {
        return [[model.searchableMillData objectAtIndex:7] count];
    }
    
    return 0;
}

// Pickerview set title
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    if ([pickerView isEqual:millNamePicker]) {
        return [[model.searchableMillData objectAtIndex:0] objectAtIndex:row];
    }
    
    if ([pickerView isEqual:mediaNamePicker]) {
        return [[model.searchableMillData objectAtIndex:1] objectAtIndex:row];
    }
    
    if ([pickerView isEqual:basisWeightPicker]) {
        return [[model.searchableMillData objectAtIndex:2] objectAtIndex:row];
    }
    
    if ([pickerView isEqual:brightnessPicker]) {
        return [[model.searchableMillData objectAtIndex:3] objectAtIndex:row];
    }
    
    if ([pickerView isEqual:coatingPicker]) {
        return [[model.searchableMillData objectAtIndex:4] objectAtIndex:row];
    }
    
    if ([pickerView isEqual:colorPicker]) {
        return [[model.searchableMillData objectAtIndex:5] objectAtIndex:row];
    }
    
    if ([pickerView isEqual:capabilityPicker]) {
        return [[model.searchableMillData objectAtIndex:6] objectAtIndex:row];
    }
    
    if ([pickerView isEqual:inksetPicker]) {
        return [[model.searchableMillData objectAtIndex:7] objectAtIndex:row];
    }
    
    return NULL;
}

- (CGFloat)pickerView:(UIPickerView * _Nonnull)pickerView rowHeightForComponent:(NSInteger)component
{
    return 26;
}

// Pickerview build a view for te row
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    
    UILabel* label = (UILabel*)view;
    UIView *colorValue;
    if (view == nil){
        
        label= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 570, 26)];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = model.blue;
        label.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:14.0];
        
        colorValue = [[UIView alloc] initWithFrame:CGRectMake(0, 2, 570, 26)];
        colorValue.backgroundColor = [UIColor clearColor];
        [colorValue setUserInteractionEnabled:YES];
        [colorValue addSubview:label];
        
    }
    
    if ([pickerView isEqual:millNamePicker]) {
        label.text = [[model.searchableMillData objectAtIndex:0] objectAtIndex:row];
    }
    
    if ([pickerView isEqual:mediaNamePicker]) {
        label.text = [[model.searchableMillData objectAtIndex:1] objectAtIndex:row];
    }
    
    if ([pickerView isEqual:basisWeightPicker]) {
        label.text = [[model.searchableMillData objectAtIndex:2] objectAtIndex:row];
    }
    
    if ([pickerView isEqual:brightnessPicker]) {
        label.text = [[model.searchableMillData objectAtIndex:3] objectAtIndex:row];
    }
    
    if ([pickerView isEqual:coatingPicker]) {
        label.text = [[model.searchableMillData objectAtIndex:4] objectAtIndex:row];
    }
    
    if ([pickerView isEqual:colorPicker]) {
        int color_value = [[[model.searchableMillData objectAtIndex:5] objectAtIndex:row] integerValue];
        UIView *iconView = [self getColorIconSet:color_value];
        [colorValue addSubview:iconView];
        
    }
    
    if ([pickerView isEqual:capabilityPicker]) {
        label.text = [[model.searchableMillData objectAtIndex:6] objectAtIndex:row];
    }
    
    if ([pickerView isEqual:inksetPicker]) {
        label.text = [[model.searchableMillData objectAtIndex:7] objectAtIndex:row];
    }
    return colorValue;
}


// The cancel function the camera or the photo picker
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

@end
