//
//  ProductSeries.m
//  PressDemo
//
//  Created by Trekk mini-1 on 8/7/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "ProductSeries.h"

@implementation ProductSeries

@synthesize title;
@synthesize key;
@synthesize description;
@synthesize case_studies;
@synthesize white_papers;
@synthesize product_spec;
@synthesize videos;
@synthesize products;
@synthesize solutions;

-(id)init
{
    //define the class
    self = [super init];
    
    if (self != nil){
        title = @"";
        key = @"";
        description = [[NSMutableDictionary alloc] init];
        case_studies = [NSMutableArray array];
        product_spec = [NSMutableArray array];
        white_papers = [NSMutableArray array];
        videos = [NSMutableArray array];
        products = [NSMutableArray array];
        solutions = [NSMutableArray array];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.key forKey:@"key"];
    [encoder encodeObject:self.description forKey:@"description"];
    [encoder encodeObject:self.case_studies forKey:@"case_studies"];
    [encoder encodeObject:self.white_papers forKey:@"white_papers"];
    [encoder encodeObject:self.product_spec forKey:@"product_spec"];
    [encoder encodeObject:self.videos forKey:@"videos"];
    [encoder encodeObject:self.products forKey:@"products"];
    [encoder encodeObject:self.solutions forKey:@"solutions"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.title = [decoder decodeObjectForKey:@"title"];
        self.key = [decoder decodeObjectForKey:@"key"];
        self.description = [decoder decodeObjectForKey:@"description"];
        self.case_studies = [decoder decodeObjectForKey:@"case_studies"];
        self.white_papers = [decoder decodeObjectForKey:@"white_papers"];
        self.product_spec = [decoder decodeObjectForKey:@"product_spec"];
        self.videos = [decoder decodeObjectForKey:@"videos"];
        self.products = [decoder decodeObjectForKey:@"products"];
        self.solutions = [decoder decodeObjectForKey:@"solutions"];
    }
    return self;
}


@end
