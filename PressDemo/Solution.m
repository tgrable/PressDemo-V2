//
//  Solution.m
//  PressDemo
//
//  Created by Trekk mini-1 on 12/12/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "Solution.h"

@implementation Solution
@synthesize title;
@synthesize key;
@synthesize description;

-(id)init
{
    
    self = [super init];
    
    if (self != nil){
        title = @"";
        key = @"";
        description = @"";
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.key forKey:@"key"];
    [encoder encodeObject:self.description forKey:@"description"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.title = [decoder decodeObjectForKey:@"title"];
        self.key = [decoder decodeObjectForKey:@"key"];
        self.description = [decoder decodeObjectForKey:@"description"];
    }
    return self;
}
@end
