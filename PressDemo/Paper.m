//
//  Paper.m
//  PressDemo
//
//  Created by Trekk mini-1 on 12/9/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "Paper.h"

@implementation Paper

@synthesize title;
@synthesize key;
@synthesize mill;
@synthesize mill_name;
@synthesize basis_weight;
@synthesize brightness;
@synthesize coating;
@synthesize color_capacity;
@synthesize category;
@synthesize dye_pigment;
@synthesize region;
@synthesize micr_capable;
@synthesize price_range;
@synthesize opacity_range;
@synthesize caliper;
@synthesize recycled_percentage;
@synthesize type_one;
@synthesize type_two;
@synthesize color_capability;
@synthesize weights_available;
@synthesize boost_sample;
@synthesize house_paper;

-(id)init
{
    //define the class
    self = [super init];
    
    if (self != nil){
        title = @"";
        key  = @"";
        mill = @"";
        mill_name = @"";
        basis_weight = [NSMutableArray array];
        brightness = @"";
        coating = @"";
        color_capacity = @"";
        category = @"";
        dye_pigment = @"";
        region = @"";
        micr_capable = @"";
        price_range = @"";
        opacity_range = @"";
        caliper = @"";
        recycled_percentage = @"";
        type_one = @"";
        type_two = @"";
        color_capability = @"";
        weights_available = @"";
        boost_sample = @"";
        house_paper = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.key forKey:@"key"];
    [encoder encodeObject:self.mill forKey:@"mill"];
    [encoder encodeObject:self.mill_name forKey:@"mill_name"];
    [encoder encodeObject:self.basis_weight forKey:@"basis_weight"];
    [encoder encodeObject:self.brightness forKey:@"brightness"];
    [encoder encodeObject:self.coating forKey:@"coating"];
    [encoder encodeObject:self.color_capacity forKey:@"color_capacity"];
    [encoder encodeObject:self.category forKey:@"category"];
    [encoder encodeObject:self.dye_pigment forKey:@"dye_pigment"];
    [encoder encodeObject:self.region forKey:@"region"];
    [encoder encodeObject:self.micr_capable forKey:@"micr_capable"];
    [encoder encodeObject:self.price_range forKey:@"price_range"];
    [encoder encodeObject:self.opacity_range forKey:@"opacity_range"];
    [encoder encodeObject:self.caliper forKey:@"caliper"];
    [encoder encodeObject:self.recycled_percentage forKey:@"recycled_percentage"];
    [encoder encodeObject:self.type_one forKey:@"type_one"];
    [encoder encodeObject:self.type_two forKey:@"type_two"];
    [encoder encodeObject:self.color_capability forKey:@"color_capability"];
    [encoder encodeObject:self.weights_available forKey:@"weights_available"];
    [encoder encodeObject:self.boost_sample forKey:@"boost_sample"];
    [encoder encodeObject:self.house_paper forKey:@"house_paper"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        
        //decode properties, other class vars
        self.title = [decoder decodeObjectForKey:@"title"];
        self.key = [decoder decodeObjectForKey:@"key"];
        self.mill = [decoder decodeObjectForKey:@"mill"];
        self.mill_name = [decoder decodeObjectForKey:@"mill_name"];
        self.basis_weight = [decoder decodeObjectForKey:@"basis_weight"];
        self.brightness = [decoder decodeObjectForKey:@"brightness"];
        self.coating = [decoder decodeObjectForKey:@"coating"];
        self.color_capacity = [decoder decodeObjectForKey:@"color_capacity"];
        self.category = [decoder decodeObjectForKey:@"category"];
        self.dye_pigment = [decoder decodeObjectForKey:@"dye_pigment"];
        self.region = [decoder decodeObjectForKey:@"region"];
        self.micr_capable = [decoder decodeObjectForKey:@"micr_capable"];
        self.price_range = [decoder decodeObjectForKey:@"price_range"];
        self.opacity_range = [decoder decodeObjectForKey:@"opacity_range"];
        self.caliper = [decoder decodeObjectForKey:@"caliper"];
        self.recycled_percentage = [decoder decodeObjectForKey:@"recycled_percentage"];
        self.type_one = [decoder decodeObjectForKey:@"type_one"];
        self.type_two = [decoder decodeObjectForKey:@"type_two"];
        self.color_capability = [decoder decodeObjectForKey:@"color_capability"];
        self.weights_available = [decoder decodeObjectForKey:@"weights_available"];
        self.boost_sample = [decoder decodeObjectForKey:@"boost_sample"];
        self.house_paper = [decoder decodeObjectForKey:@"house_paper"];
    }
    return self;
}


@end
