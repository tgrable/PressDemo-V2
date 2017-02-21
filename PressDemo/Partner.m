//
//  Partner.m
//  PressDemo
//
//  Created by Trekk mini-1 on 12/9/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "Partner.h"

@implementation Partner

@synthesize title;
@synthesize key;
@synthesize banners;
@synthesize logo;
@synthesize description;
@synthesize website;
@synthesize case_studies;
@synthesize white_papers;
@synthesize videos;
@synthesize solutions;
@synthesize premier_partner;

-(id)init
{
    //define the class
    self = [super init];
    
    if (self != nil){
        title = @"";
        key = @"";
        banners = [NSMutableArray array];
        logo = @"";
        description = @"";
        website = @"";
        case_studies = [NSMutableArray array];
        white_papers = [NSMutableArray array];
        videos = [NSMutableArray array];
        solutions = [NSMutableArray array];
        premier_partner = NO;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.key forKey:@"key"];
    [encoder encodeObject:self.banners forKey:@"banners"];
    [encoder encodeObject:self.logo forKey:@"logo"];
    [encoder encodeObject:self.website forKey:@"website"];
    [encoder encodeObject:self.description forKey:@"description"];
    [encoder encodeObject:self.case_studies forKey:@"case_studies"];
    [encoder encodeObject:self.white_papers forKey:@"white_papers"];
    [encoder encodeObject:self.videos forKey:@"videos"];
    [encoder encodeObject:self.solutions forKey:@"solutions"];
    [encoder encodeBool:self.premier_partner forKey:@"premier_partner"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.title = [decoder decodeObjectForKey:@"title"];
        self.key = [decoder decodeObjectForKey:@"key"];
        self.banners = [decoder decodeObjectForKey:@"banners"];
        self.logo = [decoder decodeObjectForKey:@"logo"];
        self.description = [decoder decodeObjectForKey:@"description"];
        self.website = [decoder decodeObjectForKey:@"website"];
        self.case_studies = [decoder decodeObjectForKey:@"case_studies"];
        self.white_papers = [decoder decodeObjectForKey:@"white_papers"];
        self.videos = [decoder decodeObjectForKey:@"videos"];
        self.solutions = [decoder decodeObjectForKey:@"solutions"];
        self.premier_partner = [decoder decodeBoolForKey:@"premier_partner"];
    }
    return self;
}

@end
