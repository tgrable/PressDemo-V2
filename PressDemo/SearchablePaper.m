//
//  SearchablePaper.m
//  PressDemo
//
//  Created by Trekk mini-1 on 10/21/15.
//  Copyright © 2015 Trekk. All rights reserved.
//

#import "SearchablePaper.h"

@implementation SearchablePaper

@synthesize title;
@synthesize mill_name;
@synthesize basis_weight;
@synthesize brightness;
@synthesize coating;
@synthesize category;
@synthesize dye_pigment;
@synthesize color_capability;
@synthesize key;

-(id)init
{
    //define the class
    self = [super init];
    
    if (self != nil){
        title = @"";
        mill_name = @"";
        basis_weight = @"";
        brightness = @"";
        coating = @"";
        color_capability = @"";
        category = @"";
        dye_pigment = @"";
        key = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.mill_name forKey:@"mill_name"];
    [encoder encodeObject:self.basis_weight forKey:@"basis_weight"];
    [encoder encodeObject:self.brightness forKey:@"brightness"];
    [encoder encodeObject:self.coating forKey:@"coating"];
    [encoder encodeObject:self.color_capability forKey:@"color_capability"];
    [encoder encodeObject:self.category forKey:@"category"];
    [encoder encodeObject:self.dye_pigment forKey:@"dye_pigment"];
    [encoder encodeObject:self.key forKey:@"key"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        
        //decode properties, other class vars
        self.title = [decoder decodeObjectForKey:@"title"];
        self.mill_name = [decoder decodeObjectForKey:@"mill_name"];
        self.basis_weight = [decoder decodeObjectForKey:@"basis_weight"];
        self.brightness = [decoder decodeObjectForKey:@"brightness"];
        self.coating = [decoder decodeObjectForKey:@"coating"];
        self.color_capability = [decoder decodeObjectForKey:@"color_capability"];
        self.category = [decoder decodeObjectForKey:@"category"];
        self.dye_pigment = [decoder decodeObjectForKey:@"dye_pigment"];
        self.key = [decoder decodeObjectForKey:@"key"];
    }
    return self;
}
@end
