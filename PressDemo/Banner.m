//
//  Banner.m
//  PressDemo
//
//  Created by Trekk mini-1 on 4/27/15.
//  Copyright (c) 2015 Trekk. All rights reserved.
//

#import "Banner.h"

@implementation Banner
@synthesize title;
@synthesize key;
@synthesize banners;
@synthesize product_series_reference;


-(id)init
{
    //define the class
    self = [super init];
    
    if (self != nil){
        title = @"";
        key = @"";
        banners = [NSMutableArray array];
        product_series_reference = @"";
       
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.key forKey:@"key"];
    [encoder encodeObject:self.banners forKey:@"banners"];
    [encoder encodeObject:self.product_series_reference forKey:@"product_series_reference"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.title = [decoder decodeObjectForKey:@"title"];
        self.key = [decoder decodeObjectForKey:@"key"];
        self.banners = [decoder decodeObjectForKey:@"banners"];
        self.product_series_reference = [decoder decodeObjectForKey:@"product_series_reference"];
    }
    return self;
}

@end
