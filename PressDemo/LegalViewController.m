//
//  LegalViewController.m
//  PressDemo
//
//  Created by Trekk mini-1 on 1/26/15.
//  Copyright (c) 2015 Trekk. All rights reserved.
//

#import "LegalViewController.h"

@implementation LegalViewController
@synthesize customNavBar, model;

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
    
    //***** Load up views to the local view controller ************//
    //the nav bar
    customNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 1024, 64)];
    [customNavBar setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:customNavBar];
    
    UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
    [close setFrame:CGRectMake(20, 40, 80, 20)];
    [close addTarget:self action:@selector(closeTapped:)forControlEvents:UIControlEventTouchUpInside];
    close.showsTouchWhenHighlighted = YES;
    [close setUserInteractionEnabled:YES];
    [close setTitle:@"CLOSE" forState:UIControlStateNormal];
    [close setTitleColor:model.blue forState:UIControlStateNormal];
    [close setBackgroundColor:[UIColor clearColor]];
    close.titleLabel.font = [UIFont fontWithName:@"ITCAvantGardeStd-Md" size:18.0];
    [self.view addSubview:close];
    
    impressLogo = [[UIImageView alloc] initWithFrame:CGRectMake(437, 1, 151, 62)];
    [impressLogo setUserInteractionEnabled:YES];
    [impressLogo setImage:[UIImage imageNamed:@"impress-logo.png"]];
    [customNavBar addSubview:impressLogo];
    
    logo = [[UIImageView alloc] initWithFrame:CGRectMake(893, 0, 97, 62)];
    [logo setUserInteractionEnabled:YES];
    [logo setImage:[UIImage imageNamed:@"csa-logo.png"]];
    [customNavBar addSubview:logo];
    
    UIImageView *divider = [[UIImageView alloc] initWithFrame:CGRectMake(0, 84, 1024, 14)];
    [divider setImage:[UIImage imageNamed:@"img-div-shdw.png"]];
    [self.view addSubview:divider];

    
    UITextView *legalText = [[UITextView alloc] initWithFrame:CGRectMake(36, 120, 952, 150)];
    [legalText setFont:[UIFont fontWithName:@"ITCAvantGardeStd-Bk" size:13.0]];
    legalText.textColor = [UIColor blackColor];
    legalText.contentSize = CGSizeMake(952, 150);
    legalText.editable = NO;
    legalText.scrollEnabled = NO;
    legalText.backgroundColor = [UIColor whiteColor];
    legalText.text = @"Canon and imagePRESS are registered trademarks of Canon Inc. in the US and elsewhere. Océ ColorStream, Océ ImageStream, Océ JetStream, Océ PRISMA, OcePRISMAaccess, Océ PRISMAprepare, Océ PRISMAproduction, Océ TrueProof, Océ VarioPrint, Océ VarioStream, and Océ are either registered trademarks or trademarks of Océ-Technologies B.V. in the US and elsewhere. All other referenced product names and marks are trademarks of their respective owners and are hereby acknowledged.\n\n© 2015 Canon Solutions America, Inc. All rights reserved.";
    [self.view addSubview:legalText];
    
}

-(void)closeTapped:(id)sender
{
     [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
