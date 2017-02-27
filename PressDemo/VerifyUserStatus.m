//
//  VerifyUserStatus.m
//  PressDemo
//
//  Created by Justin Davis on 2/24/17.
//  Copyright © 2017 Trekk. All rights reserved.
//

#import "VerifyUserStatus.h"

@implementation VerifyUserStatus


// This method will send the email provided by the protocol delegate and handle the return code and verification status of a given user.
// If the user fails to pass the verification check, an error code will be sent along with the returned data.

// Additionally, since we want the users to update their apps as soon as new versions are made available,
// the current version of the app is pulled down with the user verification data. To ensure that the version
// numbers are always matching, the version number of the current app is pulled from the app's manifest
// file. The current version number is delivered and sent to delegates with the same deletate method.

// Current delegate method signature:
//-(void)authorizationStatusWasReturned:(int)isCurrentlyAuthorized userURL:(NSString *)currentURL message:(NSString *)currentMsg currentVersion:(NSString *)versionNumber;

-(void)verifyUser:(NSString *)userEmail{
    
    
    
    
    NSString *currentURL = [NSString stringWithFormat:@"https://downloadimpress.com/validate/%@/", userEmail];; //Live URL
    NSURL *verificationURL = [NSURL URLWithString:currentURL];
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:verificationURL
                                          completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error) {
                                              
                                              if (error){
                                                  NSLog(@"%@",error.localizedDescription);
                                              }
                                              if (data != nil){
                                                  _currentJSONDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                                  [self parseJSONData:_currentJSONDict];
                                              }
                                          }];
    
    [downloadTask resume];
}

-(void)parseJSONData:(NSDictionary *)currentData{
    
    
    NSString *currentAuthorizationStatus;
    NSString *URL;
    NSString *userMsg;
    NSString *sterileURLString;
    NSString *currentAppVersion; //
    
    
    currentAuthorizationStatus = [currentData objectForKey:@"status"];
    URL = [currentData objectForKey:@"url"];
    userMsg = [currentData objectForKey:@"msg"];
    currentAppVersion = [currentData objectForKey:@"ver"];
    
    
    // Sterilize the URL...probably
    if (![URL isEqualToString:@""]){
        sterileURLString = [URL stringByRemovingPercentEncoding];
    }
    
    if ([currentAuthorizationStatus  isEqual: @"y"]){
        NSLog(@"Delegate Called -> User Authentication Succeeded");
        [_delegate authorizationStatusWasReturned:0 userURL:sterileURLString message:userMsg currentVersion:currentAppVersion];
    }else if ([currentAuthorizationStatus  isEqual: @"n"]){
        NSLog(@"Delegate Called -> User Authentication Failed");
        [_delegate authorizationStatusWasReturned:1 userURL:sterileURLString message:userMsg currentVersion:currentAppVersion];
    }else if([currentAuthorizationStatus  isEqual: @"e"]){
        NSLog(@"Delegate Called -> User Authentication Error");
        [_delegate authorizationStatusWasReturned:2 userURL:sterileURLString message:userMsg currentVersion:currentAppVersion];
    }
    
    
}


@end
