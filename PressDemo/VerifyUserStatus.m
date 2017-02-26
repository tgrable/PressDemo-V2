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
// -(void)authorizationStatusWasReturned:(int)isCurrentlyAuthorized userURL:(NSString *)currentURL errorCode:(NSString *)currentError is sent with this method.

-(void)verifyUser:(NSString *)userEmail{
    
    

    
        NSString *currentURL = [NSString stringWithFormat:@"https://downloadimpress.com/validate/%@/", userEmail];; //Dummy URL
        NSURL *verificationURL = [NSURL URLWithString:currentURL];
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:verificationURL
                                          completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error) {
                                              
                                             
                                              if (error){
                                                  return;
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
    
    if (currentData != nil){
        currentAuthorizationStatus = [currentData objectForKey:@"status"];
        URL = [currentData objectForKey:@"url"];
        userMsg = [currentData objectForKey:@"msg"];
    }
    
    // Sterilize the URL...probably
    if (![URL isEqualToString:@""]){
     sterileURLString = [URL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    // parse the data here
    

    if ([currentAuthorizationStatus  isEqual: @"y"]){
        [_delegate authorizationStatusWasReturned:0 userURL:sterileURLString message:userMsg];
    }else if ([currentAuthorizationStatus  isEqual: @"n"]){
        [_delegate authorizationStatusWasReturned:1 userURL:sterileURLString message:userMsg];
    }else if([currentAuthorizationStatus  isEqual: @"e"]){
        [_delegate authorizationStatusWasReturned:2 userURL:sterileURLString message:userMsg];
    }
    

 }






@end


