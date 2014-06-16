//
//  CanonModel.m
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "CanonModel.h"
#import "UIModel.h"
#import "SBJson.h"

@implementation CanonModel
@synthesize orange, blue, green, textColor, pink, purple, gray, testingString, ui;

- (id)init
{
    self = [super init];
    
    if (self != nil){
        ui = [[UIModel alloc] init];
        documentData = [[NSMutableDictionary alloc] init];
        videoData = [[NSMutableDictionary alloc] init];
        productData = [[NSMutableDictionary alloc] init];
        
        whatDoYouWantToPrint = [[NSMutableDictionary alloc] init];
        [whatDoYouWantToPrint setObject:[[NSMutableArray alloc] init] forKey:@"books"];
        [whatDoYouWantToPrint setObject:[[NSMutableArray alloc] init] forKey:@"brochures-&-collateral"];
        [whatDoYouWantToPrint setObject:[[NSMutableArray alloc] init] forKey:@"catalogs"];
        [whatDoYouWantToPrint setObject:[[NSMutableArray alloc] init] forKey:@"direct-mail"];
        [whatDoYouWantToPrint setObject:[[NSMutableArray alloc] init] forKey:@"healthcare-eobs"];
        [whatDoYouWantToPrint setObject:[[NSMutableArray alloc] init] forKey:@"manuals"];
        [whatDoYouWantToPrint setObject:[[NSMutableArray alloc] init] forKey:@"specialty"];
        [whatDoYouWantToPrint setObject:[[NSMutableArray alloc] init] forKey:@"statements"];
        
        showAll = [[NSMutableDictionary alloc] init];
        [showAll setObject:[[NSMutableArray alloc] init] forKey:@"color"];
        [showAll setObject:[[NSMutableArray alloc] init] forKey:@"continuous-feed"];
        [showAll setObject:[[NSMutableArray alloc] init] forKey:@"cutsheet"];
        [showAll setObject:[[NSMutableArray alloc] init] forKey:@"monochrome"];
        [showAll setObject:[[NSMutableArray alloc] init] forKey:@"workflow"];
        
        //readable names to be displayed to the user
        taxonomyReadableNames = [[NSMutableDictionary alloc] init];
        [taxonomyReadableNames setObject:@"Books" forKey:@"books"];
        [taxonomyReadableNames setObject:@"Brochures & Collateral" forKey:@"brochures-&-collateral"];
        [taxonomyReadableNames setObject:@"Catalogs" forKey:@"catalogs"];
        [taxonomyReadableNames setObject:@"Direct Mail" forKey:@"direct-mail"];
        [taxonomyReadableNames setObject:@"Healthcare EOB's" forKey:@"healthcare-eobs"];
        [taxonomyReadableNames setObject:@"Manuals" forKey:@"manuals"];
        [taxonomyReadableNames setObject:@"Specialty" forKey:@"specialty"];
        [taxonomyReadableNames setObject:@"Statements" forKey:@"statements"];
        [taxonomyReadableNames setObject:@"Color" forKey:@"color"];
        [taxonomyReadableNames setObject:@"Continuous Feed" forKey:@"continuous-feed"];
        [taxonomyReadableNames setObject:@"Cutsheet" forKey:@"cutsheet"];
        [taxonomyReadableNames setObject:@"Monochrome" forKey:@"monochrome"];
        [taxonomyReadableNames setObject:@"Workflow" forKey:@"workflow"];
        
        lastUpdated = [[NSMutableDictionary alloc] init];
        [lastUpdated setObject:@"" forKey:@"case-study"];
        [lastUpdated setObject:@"" forKey:@"product"];
        [lastUpdated setObject:@"" forKey:@"product-spec"];
        [lastUpdated setObject:@"" forKey:@"video"];
        [lastUpdated setObject:@"" forKey:@"white-paper"];
        
        textColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0];
        orange = [UIColor colorWithRed:242.0f/255.0f green:103.0f/255.0f blue:42.0f/255.0f alpha:1.0];
        blue = [UIColor colorWithRed:0.0f/255.0f green:120.0f/255.0f blue:181.0f/255.0f alpha:1.0];
        green = [UIColor colorWithRed:119.0f/255.0f green:188.0f/255.0f blue:31.0f/255.0f alpha:1.0];
        gray = [UIColor colorWithRed:117.0f/255.0f green:115.0f/255.0f blue:113.0f/255.0f alpha:1.0];
        pink = [UIColor colorWithRed:234.0f/255.0f green:29.0f/255.0f blue:118.0f/255.0f alpha:1.0];
        purple = [UIColor colorWithRed:170.0f/255.0f green:25.0f/255.0f blue:141.0f/255.0f alpha:1.0];
        firstLoad = NO;
    }
    return self;
}

-(BOOL)breakoutUpdateData:(NSData *)data
{
    NSString *responseValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *localData = [(NSDictionary*)[responseValue JSONValue] objectForKey:@"last-update"];
    
    for(id key in localData){
        if(![[lastUpdated objectForKey:key] isEqualToString:[localData objectForKey:key]]){
            NSLog(@"INCOMING DATES %@ and local dates %@", [localData objectForKey:key], [lastUpdated objectForKey:key]);
            return YES;
        }
    }
    return NO;
}


-(void)breakoutIncomingData:(NSData *)data complete:(completeBlock)completeFlag
{
    NSString *responseValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *localData = [(NSDictionary*)[responseValue JSONValue] objectForKey:@"data"];
    
    //case studies
    if([localData objectForKey:@"case-study"]){
        //set when the case studies content type was last updated
        [lastUpdated setObject:[localData objectForKey:@"last-updated"] forKey:@"case-study"];
        //break out the data in files to be save to disk
        [self breakoutDocumentData:[localData objectForKey:@"case-study"] withType:@"case-study"];
        //white paper
    }else if([localData objectForKey:@"white-paper"]){
        //set when the white paper content type was last updated
        [lastUpdated setObject:[localData objectForKey:@"last-updated"] forKey:@"white-paper"];
        //break out the data in files to be save to disk
        [self breakoutDocumentData:[localData objectForKey:@"white-paper"] withType:@"white-paper"];
        //product spec
    }else if([localData objectForKey:@"product-spec"]){
        //set when the product spec content type was last updated
        [lastUpdated setObject:[localData objectForKey:@"last-updated"] forKey:@"product-spec"];
        //break out the data in files to be save to disk
        [self breakoutDocumentData:[localData objectForKey:@"product-spec"] withType:@"product-spec"];
        //product
    }else if([localData objectForKey:@"product"]){
        //set when the product content type was last updated
        [lastUpdated setObject:[localData objectForKey:@"last-updated"] forKey:@"product"];
        //break out the product data to be saved to memory
        [self breakoutProductData:[localData objectForKey:@"product"]];
        //videos
    }else if([localData objectForKey:@"video"]){
        
    }
    
    completeFlag(YES);
}

-(void)breakoutProductData:(NSArray* )products
{
    for(NSDictionary *dict in products){
        Product *p = [[Product alloc] init];
        
        p.title = [dict objectForKey:@"title"];
        NSString *keyProduct = [dict objectForKey:@"key"];
        p.key = keyProduct;
        p.description = [dict objectForKey:@"product-description"];
        p.productSpec = [dict objectForKey:@"product-spec"];
        p.whitePaper = [dict objectForKey:@"white-papers"];
        p.caseStudy = [dict objectForKey:@"case-studies"];
        
        NSDictionary *show = [dict objectForKey:@"show-all"];
        for(id key in show){
            NSString *value = [show objectForKey:key];
            NSMutableArray *s = [showAll objectForKey:value];
            //make sure the key is not already in the array
            if(![s containsObject:keyProduct]){
                [s addObject:keyProduct];
            }
        }
        
        NSDictionary *what = [dict objectForKey:@"what-do-you-want-to-print"];
        for(id key in what){
            NSString *value = [what objectForKey:key];
            NSMutableArray *a = [whatDoYouWantToPrint objectForKey:value];
            //make sure the key is not already in the array
            if(![a containsObject:keyProduct]){
                [a addObject:keyProduct];
            }
        }
        [productData setObject:p  forKey:keyProduct];
    }
}

-(void)breakoutDocumentData:(NSArray *)documents withType:(NSString *)type
{
    for(NSDictionary *dict in documents){
        Document *d = [[Document alloc] init];
        
        NSString *key = [dict objectForKey:@"key"];
        NSString *filename = [NSString stringWithFormat:@"%@.html", key];
        d.key = key;
        d.title = [dict objectForKey:@"title"];
        d.type = type;
        d.data = filename;
        
        //make sure there is something here to load into the image
        if([dict objectForKey:@"image"] != nil){
            d.image = [dict objectForKey:@"image"];
        }else{
            d.image = @"";
        }
        
        //make sure there is something here to load into the description
        if([dict objectForKey:@"description"] != nil){
            d.description = [dict objectForKey:@"description"];
        }else{
            d.description = @"";
        }
        
        NSData *data = [[dict objectForKey:@"document-data"] dataUsingEncoding:NSUTF8StringEncoding];
        //save the html file and save the object
        [self saveHTMLFile:data andFileName:filename complete:^(BOOL completeFlag){
            [documentData setObject:d forKey:key];
        }];
    }
}

-(void)wipeOutAllModelDataForUpdate
{
    
    [documentData removeAllObjects];
    [productData removeAllObjects];
    for(id key in whatDoYouWantToPrint){
        NSMutableArray * a = [whatDoYouWantToPrint objectForKey:key];
        [a removeAllObjects];
    }
    
    for(id key in showAll){
        NSMutableArray * a = [showAll objectForKey:key];
        [a removeAllObjects];
    }
}

/*----------------------------------------------*
 Functionas that handle interaction with documents saved to the application
 -(void)saveHTMLFile:(NSData *)data andFileName:(NSString *)filename complete:(completeBlock)completeFlag
 -(NSData *)getFileData:(NSString *)fileName complete:(completeBlock)completeFlag
 -(BOOL)fileExists:(NSString *)filename
 *---------------------------------------------*/

//function that saves a file and returns a response of YES or NO if the action was performed
-(void)saveHTMLFile:(NSData *)data andFileName:(NSString *)filename complete:(completeBlock)completeFlag
{
    //NSLog(@"Filename %@", filename );
    @autoreleasepool {
        if (data != nil)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString* path = [documentsDirectory stringByAppendingPathComponent:filename];
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if([html writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil]){
                //NSLog(@"SAVED FILE SUCCESSFULLY %@", filename);
                completeFlag(YES);
            }else{
                //NSLog(@"ERROR SAVING FILE %@", filename);
                completeFlag(NO);
            }
        }
    }
}


//function the retrieves the nsdata based upon file name
-(NSData *)getFileData:(NSString *)fileName complete:(completeBlock)completeFlag
{
    NSError *err = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&err];
    //NSLog(@"Filename %@ amd path %@", fileName, path );
    if(data != nil && [data length] > 0){
        completeFlag(YES);
        return data;
    }else{
        completeFlag(NO);
        NSLog(@"Error retrieving the file from disk %@", err);
        return data;
    }
    
}

-(NSData *)getHTMLFile:(NSString *)filename complete:(completeBlock)completeFlag
{
    NSError *err = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:filename];
    //get the html data from disk
    NSData *htmlData = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&err];
    //if we actually get data
    if(htmlData != nil && [htmlData length] > 0){
        //Pass this data to a string with UTF8 encoding
        NSString *decodedString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
        //decode the base 64 encryption
        NSData *html = [[NSData alloc]initWithBase64EncodedString:decodedString options:NSDataBase64DecodingIgnoreUnknownCharacters];
        completeFlag(YES);
        return html;
    }else{
        completeFlag(NO);
        NSLog(@"Error retrieving the file from disk %@", err);
        return htmlData;
    }
    
}

//function that checks if a file exists
-(BOOL)fileExists:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:path]){
        return YES;
    }else{
        return NO;
    }
    
}

@end
