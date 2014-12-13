//
//  Software.m
//  PressDemo
//
//  Created by Trekk mini-1 on 12/9/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "Software.h"

@implementation Software

@synthesize title;
@synthesize key;
@synthesize logo;
@synthesize short_desc;
@synthesize banners;
@synthesize description;
@synthesize overview;
@synthesize datasheets;
@synthesize videos;
@synthesize brochures;

-(id)init
{
    //define the class
    self = [super init];
    
    if (self != nil){
        title = @"";
        key = @"";
        logo = @"";
        short_desc = @"";
        banners = [NSMutableArray array];
        description = @"";
        overview = [[NSMutableDictionary alloc] init];
        datasheets = [NSMutableArray array];
        videos = [NSMutableArray array];
        brochures = [NSMutableArray array];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.key forKey:@"key"];
    [encoder encodeObject:self.logo forKey:@"logo"];
    [encoder encodeObject:self.short_desc forKey:@"short_desc"];
    [encoder encodeObject:self.banners forKey:@"banners"];
    [encoder encodeObject:self.description forKey:@"description"];
    [encoder encodeObject:self.overview forKey:@"overview"];
    [encoder encodeObject:self.datasheets forKey:@"datasheets"];
    [encoder encodeObject:self.videos forKey:@"videos"];
    [encoder encodeObject:self.brochures forKey:@"brochures"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.title = [decoder decodeObjectForKey:@"title"];
        self.key = [decoder decodeObjectForKey:@"key"];
        self.logo = [decoder decodeObjectForKey:@"logo"];
        self.short_desc = [decoder decodeObjectForKey:@"short_desc"];
        self.banners = [decoder decodeObjectForKey:@"banners"];
        self.description = [decoder decodeObjectForKey:@"description"];
        self.overview = [decoder decodeObjectForKey:@"overview"];
        self.datasheets = [decoder decodeObjectForKey:@"datasheets"];
        self.videos = [decoder decodeObjectForKey:@"videos"];
        self.brochures = [decoder decodeObjectForKey:@"brochures"];
    }
    return self;
}


@end
