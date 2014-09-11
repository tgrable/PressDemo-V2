//
//  Product.m
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "Product.h"

@implementation Product

@synthesize title;
@synthesize key;
@synthesize description;
@synthesize images;
@synthesize whatDoYouWantToPrint;
@synthesize showAll;
@synthesize series;

-(id)init
{
    //define the class
    self = [super init];
    
    if (self != nil){
        title = @"";
        key = @"";
        series = @"";
        description = @"";
        images = [[NSMutableDictionary alloc] init];
        whatDoYouWantToPrint = [NSMutableArray array];
        showAll = [NSMutableArray array];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.key forKey:@"key"];
    [encoder encodeObject:self.series forKey:@"series"];
    [encoder encodeObject:self.description forKey:@"description"];
    [encoder encodeObject:self.images forKey:@"images"];
    [encoder encodeObject:self.whatDoYouWantToPrint forKey:@"whatDoYouWantToPrint"];
    [encoder encodeObject:self.showAll forKey:@"showAll"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.title = [decoder decodeObjectForKey:@"title"];
        self.key = [decoder decodeObjectForKey:@"key"];
        self.series = [decoder decodeObjectForKey:@"series"];
        self.description = [decoder decodeObjectForKey:@"description"];
        self.images = [decoder decodeObjectForKey:@"images"];
        self.whatDoYouWantToPrint = [decoder decodeObjectForKey:@"whatDoYouWantToPrint"];
        self.showAll = [decoder decodeObjectForKey:@"showAll"];
        
    }
    return self;
}


@end
