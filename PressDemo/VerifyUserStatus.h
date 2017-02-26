//
//  VerifyUserStatus.h
//  PressDemo
//
//  Created by Justin Davis on 2/24/17.
//  Copyright © 2017 Trekk. All rights reserved.
//

#import <Foundation/Foundation.h>


@protocol UserStatusDelegate <NSObject>
@required

-(void)authorizationStatusWasReturned:(int)isCurrentlyAuthorized userURL:(NSString *)currentURL message:(NSString *)currentMsg;

@end

@interface VerifyUserStatus : NSObject

-(void)verifyUser:(NSString *)userEmail;

@property (weak, nonatomic) id <UserStatusDelegate> delegate;
@property (strong, nonatomic) NSDictionary *currentJSONDict;


@end
