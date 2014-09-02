//
//  Video.m
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "Video.h"

@implementation Video

@synthesize title;
@synthesize key;
@synthesize description;
@synthesize image;
@synthesize streamingURL;
@synthesize rawVideo;

-(id)init
{
    self = [super init];
    
    if (self != nil){
        title = @"";
        key = @"";
        description = @"";
        image = @"";
        streamingURL = @"";
        rawVideo = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.key forKey:@"key"];
    [encoder encodeObject:self.description forKey:@"description"];
    [encoder encodeObject:self.image forKey:@"image"];
    [encoder encodeObject:self.streamingURL forKey:@"streamingURL"];
    [encoder encodeObject:self.rawVideo forKey:@"rawVideo"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.title = [decoder decodeObjectForKey:@"title"];
        self.key = [decoder decodeObjectForKey:@"key"];
        self.description = [decoder decodeObjectForKey:@"description"];
        self.image = [decoder decodeObjectForKey:@"image"];
        self.streamingURL = [decoder decodeObjectForKey:@"streamingURL"];
        self.rawVideo = [decoder decodeObjectForKey:@"rawVideo"];
    }
    return self;
}

@end
