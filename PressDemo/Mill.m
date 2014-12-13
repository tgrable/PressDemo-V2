//
//  Mill.m
//  PressDemo
//
//  Created by Trekk mini-1 on 12/9/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "Mill.h"

@implementation Mill

@synthesize title;
@synthesize key;
@synthesize logo;
@synthesize banners;
@synthesize description;
@synthesize website;
@synthesize address;
@synthesize phone;
@synthesize videos;
@synthesize papers;

-(id)init
{
    //define the class
    self = [super init];
    
    if (self != nil){
        title = @"";
        key = @"";
        logo = @"";
        banners = [NSMutableArray array];
        description = @"";
        website = @"";
        address = @"";
        phone = @"";
        videos = [NSMutableArray array];
        papers = [NSMutableArray array];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.key forKey:@"key"];
    [encoder encodeObject:self.logo forKey:@"logo"];
    [encoder encodeObject:self.banners forKey:@"banners"];
    [encoder encodeObject:self.description forKey:@"description"];
    [encoder encodeObject:self.website forKey:@"website"];
    [encoder encodeObject:self.address forKey:@"address"];
    [encoder encodeObject:self.phone forKey:@"phone"];
    [encoder encodeObject:self.videos forKey:@"videos"];
    [encoder encodeObject:self.papers forKey:@"papers"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.title = [decoder decodeObjectForKey:@"title"];
        self.key = [decoder decodeObjectForKey:@"key"];
        self.logo = [decoder decodeObjectForKey:@"logo"];
        self.banners = [decoder decodeObjectForKey:@"banners"];
        self.description = [decoder decodeObjectForKey:@"description"];
        self.website = [decoder decodeObjectForKey:@"website"];
        self.address = [decoder decodeObjectForKey:@"address"];
        self.phone = [decoder decodeObjectForKey:@"phone"];
        self.videos = [decoder decodeObjectForKey:@"videos"];
        self.papers= [decoder decodeObjectForKey:@"papers"];
    }
    return self;
}

@end
