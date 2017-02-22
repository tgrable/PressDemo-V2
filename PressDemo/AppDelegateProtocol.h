//
//  AppDelegateProtocol.h
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AppDataObject;

//global app delegate
@protocol AppDelegateProtocol

-(AppDataObject *) AppDataObj;

@end
