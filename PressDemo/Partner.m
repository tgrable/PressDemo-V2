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
@synthesize case_study;
@synthesize white_paper;
@synthesize videos;
@synthesize solutions;

-(id)init
{
    //define the class
    self = [super init];
    
    if (self != nil){
        title = @"";
        key = @"";
        banners = [NSMutableArray array];
        description = @"";
        case_study = [NSMutableArray array];
        white_paper = [NSMutableArray array];
        videos = [NSMutableArray array];
        solutions = [NSMutableArray array];
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.key forKey:@"key"];
    [encoder encodeObject:self.banners forKey:@"banners"];
    [encoder encodeObject:self.description forKey:@"description"];
    [encoder encodeObject:self.case_study forKey:@"case_study"];
    [encoder encodeObject:self.white_paper forKey:@"white_paper"];
    [encoder encodeObject:self.videos forKey:@"videos"];
    [encoder encodeObject:self.solutions forKey:@"solutions"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.title = [decoder decodeObjectForKey:@"title"];
        self.key = [decoder decodeObjectForKey:@"key"];
        self.banners = [decoder decodeObjectForKey:@"banners"];
        self.description = [decoder decodeObjectForKey:@"description"];
        self.case_study = [decoder decodeObjectForKey:@"case_study"];
        self.white_paper = [decoder decodeObjectForKey:@"white_paper"];
        self.videos = [decoder decodeObjectForKey:@"videos"];
        self.solutions = [decoder decodeObjectForKey:@"solutions"];
    }
    return self;
}

@end
