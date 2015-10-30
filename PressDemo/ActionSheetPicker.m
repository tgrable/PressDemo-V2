//
//  ActionSheetPicker.m
//  PressDemo
//
//  Created by Trekk mini-1 on 10/26/15.
//  Copyright © 2015 Trekk. All rights reserved.
//

#import "ActionSheetPicker.h"
#import <QuartzCore/QuartzCore.h>

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation ActionSheetPicker

@synthesize actionSheet, model, generalPickerview, background, titleLabel, delegate, doneButton, colorFlag;

//Here we are setting up the delegate method
- (CanonModel *) AppDataObj;
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    CanonModel * modelObject;
    modelObject = (CanonModel*) theDelegate.AppDataObj;
    
    return modelObject;
}

- (void)viewDidLoad
{
    model = [self AppDataObj];
    
    iconArray = [NSMutableArray array];
    [iconArray addObject:[UIImage imageNamed:@"ico-blackwhite.png"]];
    [iconArray addObject:[UIImage imageNamed:@"ico-color.png"]];
    [iconArray addObject:[UIImage imageNamed:@"ico-color.png"]];
    [iconArray addObject:[UIImage imageNamed:@"ico-color.png"]];
    [iconArray addObject:[UIImage imageNamed:@"ico-color.png"]];
    
    self.view.frame = CGRectMake(0, 0, 600, 220);
    
    
    background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, 220)];
    [background setUserInteractionEnabled:YES];
    [background setBackgroundColor:[UIColor clearColor]];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, 580, 20)];
    titleLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:20.0];
    titleLabel.textColor = model.dullBlack;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.backgroundColor = [UIColor clearColor];
    [background addSubview:titleLabel];
    
    generalPickerview = [[UIPickerView alloc] initWithFrame:CGRectMake(10, 50, 580, 120)];
    generalPickerview.backgroundColor = [UIColor whiteColor];
    generalPickerview.delegate = self;
    [generalPickerview setTintColor:[UIColor whiteColor]];
    generalPickerview.dataSource = self;
    [background addSubview:generalPickerview];
    
    doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setFrame:CGRectMake(10, 174, 580, 34)];
    [doneButton addTarget:self action:@selector(selectItem:)forControlEvents:UIControlEventTouchDown];
    doneButton.showsTouchWhenHighlighted = YES;
    [doneButton setTitle:@"Select" forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneButton setBackgroundColor:model.blue];
    [background addSubview:doneButton];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)selectItem:(id)sender
{
    [delegate closePopUpResponse];
}

-(UIView *)getColorIconSet:(int)value
{
    UIView *iconSet = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 570, 15)];
    iconSet.backgroundColor = [UIColor clearColor];
    //iconSet.tag = value;
    iconSet.tag = 222;
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
    return [model.searchDataArray count];
}

// Pickerview set title
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [model.searchDataArray objectAtIndex:row];
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
        
        label= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 300, 26)];
        label.textAlignment = NSTextAlignmentLeft;
        label.textColor = model.blue;
        label.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:14.0];
        
        colorValue = [[UIView alloc] initWithFrame:CGRectMake(0, 2, 300, 26)];
        colorValue.backgroundColor = [UIColor clearColor];
        [colorValue setUserInteractionEnabled:YES];
        [colorValue addSubview:label];
        
    }
    
    if (colorFlag) {
        int color_value = (int)[[model.searchDataArray objectAtIndex:row] integerValue];
        UIView *iconView = [self getColorIconSet:color_value];
        [colorValue addSubview:iconView];
    } else {
        label.text = [model.searchDataArray objectAtIndex:row];
    }
    
    return colorValue;
}


// The cancel function the camera or the photo picker
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


@end
