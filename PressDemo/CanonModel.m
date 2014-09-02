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
#import <SDWebImage/SDWebImageManager.h>

@implementation CanonModel
@synthesize orange, blue, green, dullBlack, lightGray, red, yellow, pink, purple, gray, testingString, ui;
@synthesize localProds, currentFilter, filteredProducts, selectedSeries;
- (id)init
{
    self = [super init];
    
    if (self != nil){
        ui = [[UIModel alloc] init];
        
        //manager = [SDWebImageManager sharedManager];
        selectedSeries = [[ProductSeries alloc] init];
        
        self.hostReachability = [Reachability reachabilityWithHostname:@"www.apple.com"];
        [self.hostReachability startNotifier];
        
        lastUpdated = [[NSMutableDictionary alloc] init];
        documentData = [[NSMutableDictionary alloc] init];
        productData = [[NSMutableDictionary alloc] init];
        productSeriesData = [[NSMutableDictionary alloc] init];
        videoData = [[NSMutableDictionary alloc] init];
        downloadedImages = [NSMutableArray array];
        
        //initial setup of products in the first view
        localProds = [NSMutableArray array];
        //a changing set of products for the filtered view
        filteredProducts = [NSMutableArray array];
        
        currentFilter = @"";
        
        whatDoYouWantToPrint = [[NSMutableDictionary alloc] init];
        [whatDoYouWantToPrint setObject:[UIImage imageNamed:@"home-nav-books.png"] forKey:@"books"];
        [whatDoYouWantToPrint setObject:[UIImage imageNamed:@"home-nav-brochures.png"] forKey:@"brochures-&-collateral"];
        [whatDoYouWantToPrint setObject:[UIImage imageNamed:@"home-nav-catalogs.png"] forKey:@"catalogs"];
        [whatDoYouWantToPrint setObject:[UIImage imageNamed:@"home-nav-dm.png"] forKey:@"direct-mail"];
        [whatDoYouWantToPrint setObject:[UIImage imageNamed:@"home-nav-healthcare.png"] forKey:@"healthcare-eobs"];
        [whatDoYouWantToPrint setObject:[UIImage imageNamed:@"home-nav-manuals.png"] forKey:@"manuals"];
        [whatDoYouWantToPrint setObject:[UIImage imageNamed:@"home-nav-specialty.png"] forKey:@"specialty"];
        [whatDoYouWantToPrint setObject:[UIImage imageNamed:@"home-nav-statements.png"] forKey:@"statements"];
        
        showAll = [[NSMutableDictionary alloc] init];
        [showAll setObject:[UIImage imageNamed:@"home-nav-color.png"] forKey:@"color"];
        [showAll setObject:[UIImage imageNamed:@"home-nav-continuous.png"] forKey:@"continuous-feed"];
        [showAll setObject:[UIImage imageNamed:@"home-nav-cutsheet.png"] forKey:@"cutsheet"];
        [showAll setObject:[UIImage imageNamed:@"home-nav-mono.png"] forKey:@"monochrome"];
        [showAll setObject:[UIImage imageNamed:@"home-nav-workflow.png"] forKey:@"workflow"];
        
        topBanners = [[NSMutableDictionary alloc] init];
        [topBanners setObject:[UIImage imageNamed:@"header-books.png"] forKey:@"books"];
        [topBanners setObject:[UIImage imageNamed:@"header-brochure.png"] forKey:@"brochures-&-collateral"];
        [topBanners setObject:[UIImage imageNamed:@"header-catalogs.png"] forKey:@"catalogs"];
        [topBanners setObject:[UIImage imageNamed:@"header-dm.png"] forKey:@"direct-mail"];
        [topBanners setObject:[UIImage imageNamed:@"header-healthcare.png"] forKey:@"healthcare-eobs"];
        [topBanners setObject:[UIImage imageNamed:@"header-manuals.png"] forKey:@"manuals"];
        [topBanners setObject:[UIImage imageNamed:@"header-specialty.png"] forKey:@"specialty"];
        [topBanners setObject:[UIImage imageNamed:@"header-statements.png"] forKey:@"statements"];
        [topBanners setObject:[UIImage imageNamed:@"header-color.png"] forKey:@"color"];
        [topBanners setObject:[UIImage imageNamed:@"header-continuousfeed.png"] forKey:@"continuous-feed"];
        [topBanners setObject:[UIImage imageNamed:@"header-cutsheet.png"] forKey:@"cutsheet"];
        [topBanners setObject:[UIImage imageNamed:@"header-monochrome.png"] forKey:@"monochrome"];
        [topBanners setObject:[UIImage imageNamed:@"header-workflow.png"] forKey:@"workflow"];

        
        /*
        whatDoYouWantToPrint = [[NSMutableDictionary alloc] init];
        [whatDoYouWantToPrint setObject:@"/home-nav-books@2x.png" forKey:@"books"];
        [whatDoYouWantToPrint setObject:@"/home-nav-brochures@2x.png" forKey:@"brochures-&-collateral"];
        [whatDoYouWantToPrint setObject:@"/home-nav-catalogs@2x.png" forKey:@"catalogs"];
        [whatDoYouWantToPrint setObject:@"/home-nav-dm@2x.png" forKey:@"direct-mail"];
        [whatDoYouWantToPrint setObject:@"/home-nav-healthcare@2x.png" forKey:@"healthcare-eobs"];
        [whatDoYouWantToPrint setObject:@"/home-nav-manuals@2x.png" forKey:@"manuals"];
        [whatDoYouWantToPrint setObject:@"/home-nav-specialty@2x.png" forKey:@"specialty"];
        [whatDoYouWantToPrint setObject:@"/home-nav-statements@2x.png" forKey:@"statements"];
        
        showAll = [[NSMutableDictionary alloc] init];
        [showAll setObject:@"/home-nav-color@2x.png" forKey:@"color"];
        [showAll setObject:@"/home-nav-continuous@2x.png" forKey:@"continuous-feed"];
        [showAll setObject:@"/home-nav-cutsheet@2x.png" forKey:@"cutsheet"];
        [showAll setObject:@"/home-nav-mono@2x.png" forKey:@"monochrome"];
        [showAll setObject:@"/home-nav-workflow@2x.png" forKey:@"workflow"];
        
        topBanners = [[NSMutableDictionary alloc] init];
        [topBanners setObject:@"/header-books@2x.png" forKey:@"books"];
        [topBanners setObject:@"/header-brochure@2x.png" forKey:@"brochures-&-collateral"];
        [topBanners setObject:@"/header-catalogs@2x.png" forKey:@"catalogs"];
        [topBanners setObject:@"/header-dm@2x.png" forKey:@"direct-mail"];
        [topBanners setObject:@"/header-healthcare@2x.png" forKey:@"healthcare-eobs"];
        [topBanners setObject:@"/header-manuals@2x.png" forKey:@"manuals"];
        [topBanners setObject:@"/header-specialty@2x.png" forKey:@"specialty"];
        [topBanners setObject:@"/header-statements@2x.png" forKey:@"statements"];
        [topBanners setObject:@"/header-color@2x.png" forKey:@"color"];
        [topBanners setObject:@"/header-continuousfeed@2x.png" forKey:@"continuous-feed"];
        [topBanners setObject:@"/header-cutsheet@2x.png" forKey:@"cutsheet"];
        [topBanners setObject:@"/header-monochrome@2x.png" forKey:@"monochrome"];
        [topBanners setObject:@"/header-workflow@2x.png" forKey:@"workflow"];
        */
         
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
        
        /*
        seriesBanners = [[NSMutableDictionary alloc] init];
        [seriesBanners setObject:@"/hdr-short-jetstreamdual@2x.png" forKey:@"jet-stream-dual-series"];
        [seriesBanners setObject:@"/hdr-short-CS3000@2x.png" forKey:@"color-stream-3000-series"];
        [seriesBanners setObject:@"/hdr-short-jetstreamcompact@2x.png" forKey:@"jet-stream-compact-series"];
        [seriesBanners setObject:@"/hdr-short-imagepress@2x.png" forKey:@"image-press-series"];
        [seriesBanners setObject:@"/hdr-short-VP6000@2x.png" forKey:@"vario-print-6000-series"];
        [seriesBanners setObject:@"/hdr-short-prisma@2x.png" forKey:@"prisma-series"];
         */
        
        seriesBanners = [[NSMutableDictionary alloc] init];
        [seriesBanners setObject:[UIImage imageNamed:@"hdr-short-jetstreamdual.png"] forKey:@"jet-stream-dual-series"];
        [seriesBanners setObject:[UIImage imageNamed:@"hdr-short-CS3000.png"] forKey:@"color-stream-3000-series"];
        [seriesBanners setObject:[UIImage imageNamed:@"hdr-short-jetstreamcompact.png"] forKey:@"jet-stream-compact-series"];
        [seriesBanners setObject:[UIImage imageNamed:@"hdr-short-imagepress.png"] forKey:@"image-press-series"];
        [seriesBanners setObject:[UIImage imageNamed:@"hdr-short-VP6000.png"] forKey:@"vario-print-6000-series"];
        [seriesBanners setObject:[UIImage imageNamed:@"hdr-short-prisma.png"] forKey:@"prisma-series"];
        
        red = [UIColor colorWithRed:207.0f/255.0f green:10.0f/255.0f blue:44.0f/255.0f alpha:1.0];
        green = [UIColor colorWithRed:119.0f/255.0f green:188.0f/255.0f blue:31.0f/255.0f alpha:1.0];
        purple = [UIColor colorWithRed:170.0f/255.0f green:25.0f/255.0f blue:141.0f/255.0f alpha:1.0];
        pink = [UIColor colorWithRed:234.0f/255.0f green:29.0f/255.0f blue:118.0f/255.0f alpha:1.0];
        dullBlack = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0];
        orange = [UIColor colorWithRed:255.0f/255.0f green:103.0f/255.0f blue:27.0f/255.0f alpha:1.0];
        yellow = [UIColor colorWithRed:255.0f/255.0f green:198.0f/255.0f blue:39.0f/255.0f alpha:1.0];
        lightGray = [UIColor colorWithRed:202.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0];
        blue = [UIColor colorWithRed:1.0f/255.0f green:120.0f/255.0f blue:180.0f/255.0f alpha:1.0];

        
        reachable = YES;
        layoutSync = YES;
        needsUpdate = NO;
    }
    return self;
}

-(BOOL)breakoutUpdateData:(NSData *)data
{
    NSString *responseValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *localData = [(NSDictionary*)[responseValue JSONValue] objectForKey:@"last-update"];

    for(id key in localData){
        NSLog(@"INCOMING DATE %@ and LOCAL DATE %@", [localData objectForKey:key], [[NSUserDefaults standardUserDefaults] objectForKey:key]);
        if(![[[NSUserDefaults standardUserDefaults] objectForKey:key] isEqualToString:[localData objectForKey:key]]){
            NSLog(@"INCOMING DATES %@ and local dates %@", [localData objectForKey:key], [[NSUserDefaults standardUserDefaults] objectForKey:key]);
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
        //set when the video content type was last updated
        [lastUpdated setObject:[localData objectForKey:@"last-updated"] forKey:@"video"];
        //break out the product data to be saved to memory
        [self breakoutVideoData:[localData objectForKey:@"video"]];
        
        //product series
    }else if([localData objectForKey:@"product-series"]){
        //set when the video content type was last updated
        [lastUpdated setObject:[localData objectForKey:@"last-updated"] forKey:@"product-series"];
        //break out the product data to be saved to memory
        [self breakoutProductSeriesData:[localData objectForKey:@"product-series"]];
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
        p.series = [dict objectForKey:@"series"];
        
        if([dict objectForKey:@"product-description"] != nil){
          p.description = [dict objectForKey:@"product-description"];
        }else{
          p.description = @"";
        }
        p.images = [[dict objectForKey:@"images"] mutableCopy];
        
        for(id key in p.images){
            [downloadedImages addObject:[p.images objectForKey:key]];
        }
        
        p.showAll = [dict objectForKey:@"show-all"];
            
        p.whatDoYouWantToPrint = [dict objectForKey:@"what-do-you-want-to-print"];
       
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:p];
        [productData setObject:encodedObject  forKey:keyProduct];
        
    }
}

-(void)breakoutProductSeriesData:(NSArray *)series
{
    
    for(NSDictionary *dict in series){
        ProductSeries *ps = [[ProductSeries alloc] init];
        
        ps.title = [dict objectForKey:@"title"];
        NSString *keyProduct = [dict objectForKey:@"key"];
        ps.key = keyProduct;
        
        //add the description in order to the description dictionary on the object
        NSArray *desc = [dict objectForKey:@"description"];
        int i = 0;
        for(NSDictionary *d in desc){
            [ps.description setObject:d forKey:[NSString stringWithFormat:@"%d", i]];
            i++;
        }
        
        //product spec key
        ps.product_spec = [dict objectForKey:@"product_spec"];
        //case study keys
        ps.case_studies = [dict objectForKey:@"case_studies"];
        //white paper keys
        ps.white_papers = [dict objectForKey:@"white_papers"];
        //video keys
        ps.videos = [dict objectForKey:@"videos"];
        //product keys
        ps.products = [dict objectForKey:@"products"];
        
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:ps];
        [productSeriesData setObject:encodedObject forKey:keyProduct];
    }
}

-(void)breakoutVideoData:(NSArray *)videos
{
    
    for(NSDictionary *dict in videos){
        Video *v = [[Video alloc] init];
        
        v.title = [dict objectForKey:@"title"];
        NSString *keyProduct = [dict objectForKey:@"key"];
        v.key = keyProduct;
        if([dict objectForKey:@"image"] != nil){
          v.image = [dict objectForKey:@"image"];
         [downloadedImages addObject:v.image];
        }else{
          v.image = @"";
        }
        
        //raw video url
        v.rawVideo = [dict objectForKey:@"raw-video"];
        
        if([dict objectForKey:@"video-description"] != nil){
            v.description = [dict objectForKey:@"video-description"];
        }else{
            v.description = @"";
        }
        v.streamingURL = [dict objectForKey:@"streaming-url"];
        
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:v];
        [videoData setObject:encodedObject forKey:keyProduct];
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
            [downloadedImages addObject:d.image];
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
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:d];
        //save the html file and save the object
        [self saveHTMLFile:data andFileName:filename complete:^(BOOL completeFlag){
            [documentData setObject:encodedObject forKey:key];
        }];
    }
}

-(void)wipeOutAllModelDataForUpdate
{
    
    //here I remove the last updated user defaults
    //i do not remove the saved nsdata to disk because it will be overwritten when updated
    NSUserDefaults * defs = [NSUserDefaults standardUserDefaults];
    NSDictionary * dict = [defs dictionaryRepresentation];
    for (id key in dict) {
        [defs removeObjectForKey:key];
    }
    [defs synchronize];
    
}

-(void)wipeOutAllModelData
{
    for(id key in lastUpdated){
        NSString *date = [lastUpdated objectForKey:key];
        [[NSUserDefaults standardUserDefaults] setObject:date forKey:key];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    //this builds an easily recognizable set of products to initially start off with
    NSMutableArray *products = [NSMutableArray array];
    for(id key in productData){
        NSData *obj = [productData objectForKey:key];
        Product *p = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
        [products addObject:p.key];
    }
    
    NSLog(@"Last updated %@", lastUpdated);
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:products];
    [self saveFile:data andFileName:@"product-data" complete:^(BOOL completeFlag){
        [productData removeAllObjects];
        [productSeriesData removeAllObjects];
        [videoData removeAllObjects];
        [documentData removeAllObjects];
        [lastUpdated removeAllObjects];
    }];
}


/*
-(void)downloadAllImagesAndSaveThem:(completeBlock)completeFlagFirstParent
{
    __block NSMutableDictionary *images = [[NSMutableDictionary alloc] init];
    __block int count = [downloadedImages count], i = 0;
    for(NSString *url in downloadedImages){
        __block NSString *u = [url stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
        NSLog(@"URL %@", u);
        [manager downloadWithURL:[NSURL URLWithString:u] options:0
         progress:^(NSUInteger receivedSize, long long expectedSize){
            // progression tracking code
             
         }completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished){
             NSLog(@"Images %@", image);
            [images setObject:image forKey:u];
             i++;
             if(i == count){
                 NSLog(@"Sending images to save");
                [self saveAllImagesToDisk:images complete:^(BOOL completeFlagParent){
                    NSLog(@"Complete, returning!!");
                     completeFlagFirstParent(YES);
                }];
             }
        }];
    }
    

}

-(void)saveAllImagesToDisk:(NSMutableDictionary *)images complete:(completeBlock)completeFlagParent
{
    NSLog(@"Images %@", images);
    
    __block int count = (int)[images count], i =0;
    for(id key in images){
        NSLog(@"Image be saved %@",[images objectForKey:key] );
        [self saveFile:UIImagePNGRepresentation([images objectForKey:key]) andFileName:key complete:^(BOOL completeFlag){
            i++;
            if(count == i){
                [images removeAllObjects];
                manager = nil;
                [downloadedImages removeAllObjects];
                completeFlagParent(YES);
            }
        }];
    }
}*/

-(void)saveAllDataToDisk:(completeBlock)completeFlagArgument
{
    //save all product data
    __block int c1 = 0;
    for(id key in productData){
        NSLog(@"Product Key %@", key);
        [self saveFile:[productData objectForKey:key] andFileName:key complete:^(BOOL completeFlag){
            c1++;
            if(c1 == [productData count]){
                __block int c2 = 0;
                //save all product series data
                for(id key in productSeriesData){
                    NSLog(@"Product Series Key %@", key);
                    [self saveFile:[productSeriesData objectForKey:key] andFileName:key complete:^(BOOL completeFlag){
                        c2++;
                        if(c2 == [productSeriesData count]){
                            __block int c3 = 0;
                            //save all video data
                            for(id key in videoData){
                                NSLog(@"Video Key %@", key);
                                [self saveFile:[videoData objectForKey:key] andFileName:key complete:^(BOOL completeFlag){
                                    c3++;
                                    if(c3 == [videoData count]){
                                        __block int c4 = 0;
                                        //save all document data
                                        for(id key in documentData){
                                            NSLog(@"Document Key %@", key);
                                            [self saveFile:[documentData objectForKey:key] andFileName:key complete:^(BOOL completeFlag){
                                                c4++;
                                                if(c4 == [documentData count]){
                                                    completeFlagArgument(YES);
                                                }
                                            }];
                                        }

                                    }
                                }];
                            }
                        }
                    }];
                }
                
            }
        }];
    }
}

-(NSString *)getVideoFileName:(NSString *)url
{
    if([url length] > 0){
        NSArray *chopped = [url componentsSeparatedByString:@"//"];
        if([chopped count] > 0){
            NSArray *choppedSecond = [[chopped objectAtIndex:1] componentsSeparatedByString:@"/"];
            if([choppedSecond objectAtIndex:3] != nil){
                NSLog(@"Chopped %@", [choppedSecond objectAtIndex:3]);
                return [choppedSecond objectAtIndex:3];
            }else{
                return [choppedSecond objectAtIndex:2];
            }
        }else{
            return @"";
        }
    }else{
        return @"";
    }
}

/*----------------------------------------------*
 Functionas that handle interaction with documents saved to the application
 -(void)saveHTMLFile:(NSData *)data andFileName:(NSString *)filename complete:(completeBlock)completeFlag
 -(NSData *)getFileData:(NSString *)fileName complete:(completeBlock)completeFlag
 -(BOOL)fileExists:(NSString *)filename
 *---------------------------------------------*/

-(void)saveFile:(NSData *)data andFileName:(NSString *)filename complete:(completeBlock)completeFlag
{
    @autoreleasepool {
        if (data != nil)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString* path = [documentsDirectory stringByAppendingPathComponent:filename];
            
            if([data writeToFile:path atomically:YES]){
                NSLog(@"FULL PATH %@", path);
                NSLog(@"SAVED FILE SUCCESSFULLY %@", filename);
                completeFlag(YES);
            }else{
                completeFlag(NO);
            }
        }
    }

}

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
                NSLog(@"SAVED HTML FILE SUCCESSFULLY %@", filename);
                completeFlag(YES);
            }else{
                NSLog(@"ERROR SAVING FILE %@", filename);
                completeFlag(NO);
            }
        }
    }
}

-(NSMutableArray *)getInitialSetofPorducts
{
    NSError *err = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:@"product-data"];
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&err];
    
    //make sure we have returned data
    if(data != nil && [data length] > 0){
        //covert the nsdata to an array using our nscoder class
        NSMutableArray *prods =  [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSMutableArray *returnProds = [NSMutableArray array];
        //loop through that initial set of products
        for(NSString *key in prods){
            //get the data from the drive and convert it to an object to be added to the array to be returned
            NSData *obj = [self getFileData:key complete:^(BOOL completeFlag){}];
            Product *o = [NSKeyedUnarchiver unarchiveObjectWithData:obj];
            [returnProds addObject:o];
        }
        if([returnProds count] > 0){
            //if we have data, return the array
            return returnProds;
        }else{
            //otherwise return nil and I know to display an error message
            return nil;
        }
    }else{

        NSLog(@"Error retrieving the file from disk %@", err);
        return nil;
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

-(NSString *)returnFilePath:(NSString *)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:name];
    return path;
}

-(BOOL)videoExists:(NSString *)videoURL
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:videoURL]){
        return YES;
    }else{
        return NO;
    }
}

@end
