//
//  SavedVideos.m
//  PressDemo
//
//  Created by Trekk mini-1 on 8/25/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "SavedVideos.h"

@implementation SavedVideos

@synthesize title;
@synthesize key;
@synthesize savedURL;

-(id)init
{
    
    self = [super init];
    
    if (self != nil){
        title = @"";
        key = @"";
        savedURL = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.key forKey:@"key"];
    [encoder encodeObject:self.savedURL forKey:@"savedURL"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.title = [decoder decodeObjectForKey:@"title"];
        self.key = [decoder decodeObjectForKey:@"key"];
        self.savedURL = [decoder decodeObjectForKey:@"savedURL"];
    }
    return self;
}

@end
