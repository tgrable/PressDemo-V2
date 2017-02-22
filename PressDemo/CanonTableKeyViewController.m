//
//  CanonTableKeyViewController.m
//  PressDemo
//
//  Created by Trekk mini-1 on 12/11/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "CanonTableKeyViewController.h"



@implementation CanonTableKeyViewController
@synthesize keyTitle, textLabel, textValue, textPlusLabel, textPlusValue;
@synthesize productionLabel, productionValue, productionPlusLabel, productionPlusValue;
@synthesize premiumLabel, premiumPlusValue, model;

//Here we are setting up the delegate method
- (CanonModel *) AppDataObj;
{
    id<AppDelegateProtocol> theDelegate = (id<AppDelegateProtocol>) [UIApplication sharedApplication].delegate;
    CanonModel * modelObject;
    modelObject = (CanonModel*) theDelegate.AppDataObj;
    
    return modelObject;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    model = [self AppDataObj];
    
    keyTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 22, 540, 30)];
    [keyTitle setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:18.0]];
    keyTitle.textColor = [UIColor blackColor];
    keyTitle.numberOfLines = 1;
    keyTitle.backgroundColor = [UIColor clearColor];
    keyTitle.text = @"CATEGORY KEY";
    [self.view addSubview:keyTitle];
    
    textLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 50, 190, 30)];
    [textLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0]];
    textLabel.textColor = [UIColor blackColor];
    textLabel.numberOfLines = 1;
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.text = @"TEXT";
    [self.view addSubview:textLabel];
    
    textValue = [[UILabel alloc] initWithFrame:CGRectMake(205, 50, 270, 30)];
    [textValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:16.0]];
    textValue.textColor = model.dullBlack;
    textValue.numberOfLines = 1;
    textValue.backgroundColor = [UIColor clearColor];
    textValue.text = @"UNTREATED B&W TEXT";
    [self.view addSubview:textValue];
    
    UIImageView *bwText = [[UIImageView alloc] initWithFrame:CGRectMake(485, 53, 21, 21)];
    [bwText setImage:[UIImage imageNamed:@"ico-blackwhite.png"]];
    [self.view addSubview:bwText];
    
    textPlusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 190, 30)];
    [textPlusLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0]];
    textPlusLabel.textColor = [UIColor blackColor];
    textPlusLabel.numberOfLines = 1;
    textPlusLabel.backgroundColor = [UIColor clearColor];
    textPlusLabel.text = @"TEXT PLUS";
    [self.view addSubview:textPlusLabel];
    
    textPlusValue = [[UILabel alloc] initWithFrame:CGRectMake(205, 80, 270, 30)];
    [textPlusValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:16.0]];
    textPlusValue.textColor = model.dullBlack;
    textPlusValue.numberOfLines = 1;
    textPlusValue.backgroundColor = [UIColor clearColor];
    textPlusValue.text = @"UNTREATED B & W 2/C, LIGHT 4/C";
    [self.view addSubview:textPlusValue];
    
    UIImageView *bwTextPlus = [[UIImageView alloc] initWithFrame:CGRectMake(485, 83, 21, 21)];
    [bwTextPlus setImage:[UIImage imageNamed:@"ico-blackwhite.png"]];
    [self.view addSubview:bwTextPlus];
    
    UIImageView *colorOneTextPlus = [[UIImageView alloc] initWithFrame:CGRectMake(515, 83, 21, 21)];
    [colorOneTextPlus setImage:[UIImage imageNamed:@"ico-color.png"]];
    [self.view addSubview:colorOneTextPlus];
    
    productionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 190, 30)];
    [productionLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0]];
    productionLabel.textColor = [UIColor blackColor];
    productionLabel.numberOfLines = 1;
    productionLabel.backgroundColor = [UIColor clearColor];
    productionLabel.text = @"PRODUCTION";
    [self.view addSubview:productionLabel];
    
    productionValue = [[UILabel alloc] initWithFrame:CGRectMake(205, 110, 270, 30)];
    [productionValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:16.0]];
    productionValue.textColor = model.dullBlack;
    productionValue.numberOfLines = 1;
    productionValue.backgroundColor = [UIColor clearColor];
    productionValue.text = @"TREATED 2/C, 4/C";
    [self.view addSubview:productionValue];
    
    UIImageView *bwProduction = [[UIImageView alloc] initWithFrame:CGRectMake(485, 113, 21, 21)];
    [bwProduction setImage:[UIImage imageNamed:@"ico-blackwhite.png"]];
    [self.view addSubview:bwProduction];
    
    UIImageView *colorOneProduction = [[UIImageView alloc] initWithFrame:CGRectMake(515, 113, 21, 21)];
    [colorOneProduction setImage:[UIImage imageNamed:@"ico-color.png"]];
    [self.view addSubview:colorOneProduction];
    
    UIImageView *colorTwoProduction = [[UIImageView alloc] initWithFrame:CGRectMake(545, 113, 21, 21)];
    [colorTwoProduction setImage:[UIImage imageNamed:@"ico-color.png"]];
    [self.view addSubview:colorTwoProduction];
    
    productionPlusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 140, 190, 30)];
    [productionPlusLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0]];
    productionPlusLabel.textColor = [UIColor blackColor];
    productionPlusLabel.numberOfLines = 1;
    productionPlusLabel.backgroundColor = [UIColor clearColor];
    productionPlusLabel.text = @"PRODUCTION PLUS";
    [self.view addSubview:productionPlusLabel];
    
    productionPlusValue = [[UILabel alloc] initWithFrame:CGRectMake(205, 140, 270, 30)];
    [productionPlusValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:16.0]];
    productionPlusValue.textColor = model.dullBlack;
    productionPlusValue.numberOfLines = 1;
    productionPlusValue.backgroundColor = [UIColor clearColor];
    productionPlusValue.text = @"TREATED HIGH QUALITY 4/C";
    [self.view addSubview:productionPlusValue];
    
    UIImageView *bwProductionPlus = [[UIImageView alloc] initWithFrame:CGRectMake(485, 143, 21, 21)];
    [bwProductionPlus setImage:[UIImage imageNamed:@"ico-blackwhite.png"]];
    [self.view addSubview:bwProductionPlus];
    
    UIImageView *colorOneProductionPlus = [[UIImageView alloc] initWithFrame:CGRectMake(515, 143, 21, 21)];
    [colorOneProductionPlus setImage:[UIImage imageNamed:@"ico-color.png"]];
    [self.view addSubview:colorOneProductionPlus];
    
    UIImageView *colorTwoProductionPlus = [[UIImageView alloc] initWithFrame:CGRectMake(545, 143, 21, 21)];
    [colorTwoProductionPlus setImage:[UIImage imageNamed:@"ico-color.png"]];
    [self.view addSubview:colorTwoProductionPlus];
    
    UIImageView *colorThreeProductionPlus = [[UIImageView alloc] initWithFrame:CGRectMake(575, 143, 21, 21)];
    [colorThreeProductionPlus setImage:[UIImage imageNamed:@"ico-color.png"]];
    [self.view addSubview:colorThreeProductionPlus];
    
    premiumLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 170, 190, 30)];
    [premiumLabel setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Md" size:16.0]];
    premiumLabel.textColor = [UIColor blackColor];
    premiumLabel.numberOfLines = 1;
    premiumLabel.backgroundColor = [UIColor clearColor];
    premiumLabel.text = @"PREMIUM";
    [self.view addSubview:premiumLabel];
    
    premiumPlusValue = [[UILabel alloc] initWithFrame:CGRectMake(205, 170, 270, 30)];
    [premiumPlusValue setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:16.0]];
    premiumPlusValue.textColor = model.dullBlack;
    premiumPlusValue.numberOfLines = 1;
    premiumPlusValue.backgroundColor = [UIColor clearColor];
    premiumPlusValue.text = @"COATED PREMIUM QUALITY 4/C";
    [self.view addSubview:premiumPlusValue];
    
    UIImageView *bwPremium = [[UIImageView alloc] initWithFrame:CGRectMake(485, 173, 21, 21)];
    [bwPremium setImage:[UIImage imageNamed:@"ico-blackwhite.png"]];
    [self.view addSubview:bwPremium];
    
    UIImageView *colorOnePremium = [[UIImageView alloc] initWithFrame:CGRectMake(515, 173, 21, 21)];
    [colorOnePremium setImage:[UIImage imageNamed:@"ico-color.png"]];
    [self.view addSubview:colorOnePremium];
    
    UIImageView *colorTwoPremium = [[UIImageView alloc] initWithFrame:CGRectMake(545, 173, 21, 21)];
    [colorTwoPremium setImage:[UIImage imageNamed:@"ico-color.png"]];
    [self.view addSubview:colorTwoPremium];
    
    UIImageView *colorThreePremium = [[UIImageView alloc] initWithFrame:CGRectMake(575, 173, 21, 21)];
    [colorThreePremium setImage:[UIImage imageNamed:@"ico-color.png"]];
    [self.view addSubview:colorThreePremium];
    
    UIImageView *colorFourPremium = [[UIImageView alloc] initWithFrame:CGRectMake(605, 173, 21, 21)];
    [colorFourPremium setImage:[UIImage imageNamed:@"ico-color.png"]];
    [self.view addSubview:colorFourPremium];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
