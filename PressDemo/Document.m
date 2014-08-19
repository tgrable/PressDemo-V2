//
//  Document.m
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "Document.h"

@implementation Document

@synthesize title;
@synthesize key;
@synthesize type;
@synthesize description;
@synthesize image;
@synthesize data;

-(id)init
{
    self = [super init];
    
    if (self != nil){
        title = @"";
        key = @"";
        description = @"";
        type = @"";
        image = @"";
        data = @"";

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.key forKey:@"key"];
    [encoder encodeObject:self.type forKey:@"type"];
    [encoder encodeObject:self.description forKey:@"description"];
    [encoder encodeObject:self.image forKey:@"image"];
    [encoder encodeObject:self.data forKey:@"data"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.title = [decoder decodeObjectForKey:@"title"];
        self.key = [decoder decodeObjectForKey:@"key"];
        self.type = [decoder decodeObjectForKey:@"type"];
        self.description = [decoder decodeObjectForKey:@"description"];
        self.image = [decoder decodeObjectForKey:@"image"];
        self.data = [decoder decodeObjectForKey:@"data"];
    }
    return self;
}


@end
