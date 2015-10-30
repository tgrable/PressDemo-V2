//
//  CanonModel.m
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "CanonModel.h"
#import "SBJson.h"
#import "SDWebImageManager.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"
#import <CoreText/CTStringAttributes.h>

//this is a local macro that sets up a class wide logging scheme
#define ALog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

@implementation CanonModel
@synthesize orange, blue, green, dullBlack, lightGray, red, yellow, pink, purple, gray, testingString, animationRun;
@synthesize localProds, currentFilter, filteredProducts, selectedSeries, tracker, selectedMill, selectedPartner;
@synthesize initialBannerDictionary, selectedSoftware;
- (id)init
{
    self = [super init];
    
    if (self != nil){

        selectedSeries = [[ProductSeries alloc] init];
        selectedMill = [[Mill alloc] init];
        selectedPartner = [[Partner alloc] init];
        selectedSoftware = [[Software alloc] init];
        
        self.hostReachability = [Reachability reachabilityWithHostname:@"www.apple.com"];
        [self.hostReachability startNotifier];
        
        lastUpdated = [[NSMutableDictionary alloc] init];
        documentData = [[NSMutableDictionary alloc] init];
        productData = [[NSMutableDictionary alloc] init];
        productSeriesData = [[NSMutableDictionary alloc] init];
        videoData = [[NSMutableDictionary alloc] init];
        downloadedImages = [NSMutableArray array];
        millData = [[NSMutableDictionary alloc] init];
        paperData = [[NSMutableDictionary alloc] init];
        softwareData = [[NSMutableDictionary alloc] init];
        initialBannerDictionary = [[NSMutableDictionary alloc] init];
        initialFilesToDownload = [NSMutableArray array];
        initialPartnerData = [NSMutableArray array];
        initialSetOfMills = [NSMutableArray array];
        initialSetOfPaper = [NSMutableArray array];
        initialSolutionData = [NSMutableArray array];
        initialSofwareData = [NSMutableArray array];
        initialBannerData = [NSMutableArray array];
        searchableMillData = [NSMutableArray array];
        searchablePaperDataObjects = [NSMutableArray array];
        searchDataArray = [NSMutableArray array];
        
        //initial setup of products in the first view
        localProds = [NSMutableArray array];
        //a changing set of products for the filtered view
        filteredProducts = [NSMutableArray array];
        
        currentFilter = @"";
        
        //Full on UIImages to be referenced in the ViewController by Key
        whatDoYouWantToPrint = [[NSMutableDictionary alloc] init];
        [whatDoYouWantToPrint setObject:[UIImage imageNamed:@"home-nav-books.png"] forKey:@"books"];
        [whatDoYouWantToPrint setObject:[UIImage imageNamed:@"home-nav-statements.png"] forKey:@"statements"];
        [whatDoYouWantToPrint setObject:[UIImage imageNamed:@"home-nav-brochures.png"] forKey:@"brochures-&-collateral"];
        [whatDoYouWantToPrint setObject:[UIImage imageNamed:@"home-nav-dm.png"] forKey:@"direct-mail"];
        [whatDoYouWantToPrint setObject:[UIImage imageNamed:@"home-nav-catalogs.png"] forKey:@"catalogs"];
        [whatDoYouWantToPrint setObject:[UIImage imageNamed:@"home-nav-manuals.png"] forKey:@"manuals"];
        [whatDoYouWantToPrint setObject:[UIImage imageNamed:@"home-nav-specialty.png"] forKey:@"specialty"];
        
        //Full on UIImages to be referenced in the ViewController by Key
        showAll = [[NSMutableDictionary alloc] init];
        [showAll setObject:[UIImage imageNamed:@"home-nav-color.png"] forKey:@"color"];
        [showAll setObject:[UIImage imageNamed:@"home-nav-mono.png"] forKey:@"monochrome"];
        [showAll setObject:[UIImage imageNamed:@"home-nav-continuous.png"] forKey:@"continuous-feed"];
        [showAll setObject:[UIImage imageNamed:@"home-nav-cutsheet.png"] forKey:@"cutsheet"];
        [showAll setObject:[UIImage imageNamed:@"home-nav-software.png"] forKey:@"software"];
        [showAll setObject:[UIImage imageNamed:@"home-nav-media.png"] forKey:@"media"];
        
        
        //Full on UIImages to be referenced in the ViewController by Key
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
        
        //Full on UIImages to be referenced in the ViewController by Key
        seriesBanners = [[NSMutableDictionary alloc] init];
        [seriesBanners setObject:[UIImage imageNamed:@"hdr-short-jetstreamdual.png"] forKey:@"oce-jetstream-dual-series--series"];
        [seriesBanners setObject:[UIImage imageNamed:@"hdr-short-CS3000.png"] forKey:@"oce-colorstream-3000-series--series"];
        [seriesBanners setObject:[UIImage imageNamed:@"hdr-short-jetstreamcompact.png"] forKey:@"oce-jetstream-compact-series--series"];
        [seriesBanners setObject:[UIImage imageNamed:@"hdr-short-imagepress.png"] forKey:@"canon-imagepress-jet-series--series"];
        [seriesBanners setObject:[UIImage imageNamed:@"hdr-short-VP6000.png"] forKey:@"oce-varioprint-6000+-series--series"];
        [seriesBanners setObject:[UIImage imageNamed:@"hdr-short-prisma.png"] forKey:@"prisma-series--series"];
        
        red = [UIColor colorWithRed:207.0f/255.0f green:10.0f/255.0f blue:44.0f/255.0f alpha:1.0];
        green = [UIColor colorWithRed:119.0f/255.0f green:188.0f/255.0f blue:31.0f/255.0f alpha:1.0];
        purple = [UIColor colorWithRed:170.0f/255.0f green:25.0f/255.0f blue:141.0f/255.0f alpha:1.0];
        pink = [UIColor colorWithRed:234.0f/255.0f green:29.0f/255.0f blue:118.0f/255.0f alpha:1.0];
        dullBlack = [UIColor colorWithRed:85.0f/255.0f green:85.0f/255.0f blue:85.0f/255.0f alpha:1.0];
        orange = [UIColor colorWithRed:255.0f/255.0f green:103.0f/255.0f blue:27.0f/255.0f alpha:1.0];
        yellow = [UIColor colorWithRed:255.0f/255.0f green:198.0f/255.0f blue:39.0f/255.0f alpha:1.0];
        lightGray = [UIColor colorWithRed:202.0f/255.0f green:200.0f/255.0f blue:200.0f/255.0f alpha:1.0];
        blue = [UIColor colorWithRed:1.0f/255.0f green:120.0f/255.0f blue:180.0f/255.0f alpha:1.0];

        layoutSync = YES;
        animationRun = NO;
        needsUpdate = NO;
        imageCount = 0;
    }
    return self;
}

//##### Google Analytics ###################################################################

-(void)logData:(NSString *)category withAction:(NSString *)action withLabel:(NSString *)label
{
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category action:action label:label value:nil] build]];
}


- (NSString *)deviceInformation {
    
    static NSDictionary* deviceNamesByCode = nil;
    static NSString* deviceName = nil;
    
    if (deviceName) {
        return deviceName;
    }
    
    deviceNamesByCode = @{
                          @"i386"      :@"Simulator",
                          @"iPod1,1"   :@"iPod Touch",      // (Original)
                          @"iPod2,1"   :@"iPod Touch",      // (Second Generation)
                          @"iPod3,1"   :@"iPod Touch",      // (Third Generation)
                          @"iPod4,1"   :@"iPod Touch",      // (Fourth Generation)
                          @"iPhone1,1" :@"iPhone",          // (Original)
                          @"iPhone1,2" :@"iPhone",          // (3G)
                          @"iPhone2,1" :@"iPhone",          // (3GS)
                          @"iPad1,1"   :@"iPad",            // (Original)
                          @"iPad2,1"   :@"iPad 2",          //
                          @"iPad3,1"   :@"iPad",            // (3rd Generation)
                          @"iPhone3,1" :@"iPhone 4",        //
                          @"iPhone4,1" :@"iPhone 4S",       //
                          @"iPhone5,1" :@"iPhone 5",        // (model A1428, AT&T/Canada)
                          @"iPhone5,2" :@"iPhone 5",        // (model A1429, everything else)
                          @"iPad3,4"   :@"iPad",            // (4th Generation)
                          @"iPad2,5"   :@"iPad Mini",       // (Original)
                          @"iPhone5,3" :@"iPhone 5c",       // (model A1456, A1532 | GSM)
                          @"iPhone5,4" :@"iPhone 5c",       // (model A1507, A1516, A1526 (China), A1529 | Global)
                          @"iPhone6,1" :@"iPhone 5s",       // (model A1433, A1533 | GSM)
                          @"iPhone6,2" :@"iPhone 5s",       // (model A1457, A1518, A1528 (China), A1530 | Global)
                          @"iPad4,1"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Wifi
                          @"iPad4,2"   :@"iPad Air",        // 5th Generation iPad (iPad Air) - Cellular
                          @"iPad4,4"   :@"iPad Mini",       // (2nd Generation iPad Mini - Wifi)
                          @"iPad4,5"   :@"iPad Mini"        // (2nd Generation iPad Mini - Cellular)
                          };
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString* code = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    deviceName = [deviceNamesByCode objectForKey:code];
    
    if (!deviceName) {
        // Not found in database. At least guess main device type from string contents:
        
        if ([code rangeOfString:@"iPod"].location != NSNotFound) {
            deviceName = @"iPod Touch";
        } else if([code rangeOfString:@"iPad"].location != NSNotFound) {
            deviceName = @"iPad";
        } else if([code rangeOfString:@"iPhone"].location != NSNotFound){
            deviceName = @"iPhone";
        } else {
            deviceName = @"Simulator";
        }
    }
    
    return deviceName;
}

//This function breaks out the time stamps returned for each content type so that the application can recognize
//the need to flag an alert to the user that their is updated data available
//this function works by checking the incoming dates returned from the network stack to those saved to NSUserDefaults.
//if one of the dates is different, then we should flag to the user that an update is available
-(BOOL)breakoutUpdateData:(NSData *)data
{
    NSString *responseValue = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *localData = [(NSDictionary*)[responseValue JSONValue] objectForKey:@"last-update"];

    for(id key in localData){
        ALog(@"INCOMING DATE %@ and LOCAL DATE %@", [localData objectForKey:key], [[NSUserDefaults standardUserDefaults] objectForKey:key]);
        if(![[[NSUserDefaults standardUserDefaults] objectForKey:key] isEqualToString:[localData objectForKey:key]]){
            ALog(@"INCOMING DATES %@ and local dates %@", [localData objectForKey:key], [[NSUserDefaults standardUserDefaults] objectForKey:key]);
            return YES;
        }
    }
    return NO;
}


//This is the function that is hit the when the network stack is downloading content data.NSUTF8StringEncoding
//The data that hits here is checked to determine which content type it falls into, and then it is sent to a parsing function to break the data into objects.
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
        
        //software
    }else if([localData objectForKey:@"software"]){
       
        //set when the software content type was last updated
        [lastUpdated setObject:[localData objectForKey:@"last-updated"] forKey:@"software"];
        //break out the data in files to be save to disk
        [self breakoutSoftwareData:[localData objectForKey:@"software"]];
        
        //mill
    }else if([localData objectForKey:@"mill"]){
 
        //set when the mill content type was last updated
        [lastUpdated setObject:[localData objectForKey:@"last-updated"] forKey:@"mill"];
        //break out the data in files to be save to disk
        [self breakoutMillData:[localData objectForKey:@"mill"]];
        
        //paper
    }else if([localData objectForKey:@"paper"]){
    
        //set when the paper content type was last updated
        [lastUpdated setObject:[localData objectForKey:@"last-updated"] forKey:@"paper"];
        //break out the data in files to be save to disk
        [self breakoutPaperData:[localData objectForKey:@"paper"]];
        
        //datasheet
    }else if([localData objectForKey:@"datasheet"]){
       
        //set when the datasheet content type was last updated
        [lastUpdated setObject:[localData objectForKey:@"last-updated"] forKey:@"datasheet"];
        //break out the data in files to be save to disk
        [self breakoutDocumentData:[localData objectForKey:@"datasheet"] withType:@"datasheet"];
        
        //brochure
    }else if([localData objectForKey:@"brochure"]){
    
        //set when the brochure content type was last updated
        [lastUpdated setObject:[localData objectForKey:@"last-updated"] forKey:@"brochure"];
        //break out the data in files to be save to disk
        [self breakoutDocumentData:[localData objectForKey:@"brochure"] withType:@"brochure"];
        
        //partner
    }else if([localData objectForKey:@"partner"]){
    
        //set when the brochure content type was last updated
        [lastUpdated setObject:[localData objectForKey:@"last-updated"] forKey:@"partner"];
        //break out the data in files to be save to disk
        [self breakoutPartnerData:[localData objectForKey:@"partner"]];
        
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
        
        //solution
    }else if([localData objectForKey:@"solution"]){
        //set when the video content type was last updated
        [lastUpdated setObject:[localData objectForKey:@"last-updated"] forKey:@"solution"];
        //break out the product data to be saved to memory
        [self breakoutSolutionData:[localData objectForKey:@"solution"]];
        
    }else if([localData objectForKey:@"banner"]){
        //set when the video content type was last updated
        [lastUpdated setObject:[localData objectForKey:@"last-updated"] forKey:@"banner"];
        //break out the product data to be saved to memory
        [self breakoutBannerData:[localData objectForKey:@"banner"]];
    }
   
    completeFlag(YES);
}

//function that creates solution objects out of an array of dictionaries
-(void)breakoutSolutionData:(NSArray* )solution
{
    for(NSDictionary *dict in solution){
        Solution *s = [[Solution alloc] init];
        
        s.title = [dict objectForKey:@"title"];
        
        NSString *keySolution = [dict objectForKey:@"key"];
        s.key = keySolution;
        s.description = [dict objectForKey:@"description"];
        
        [initialSolutionData addObject:s];
    
    }
}

//function that creates solution objects out of an array of dictionaries
-(void)breakoutBannerData:(NSArray* )banner
{
    for(NSDictionary *dict in banner){
        Banner *b = [[Banner alloc] init];
        
        b.title = [dict objectForKey:@"title"];
        
        NSString *keyBanner = [dict objectForKey:@"key"];
        b.key = keyBanner;
        b.banners = [dict objectForKey:@"banners"];
        b.product_series_reference = [dict objectForKey:@"product_series_reference"];
        
        //make sure and add the banners to the downloadImages array
        for(NSString *urlString in b.banners){
            ALog(@"HERE IS THE BANNER URL %@", urlString);
            [downloadedImages addObject:urlString];
        }
        
        [initialBannerData addObject:b];
        
    }
}

//function that creates product objects out of an array of dictionaries
-(void)breakoutProductData:(NSArray* )products
{
    
    for(NSDictionary *dict in products){

        Product *p = [[Product alloc] init];
        
        p.title = [dict objectForKey:@"title"];
        
        NSString *keyProduct = [dict objectForKey:@"key"];
        p.key = keyProduct;
        p.series = [self cleanseStringName:[dict objectForKey:@"series"]];
        
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
        
        p.series_title = [dict objectForKey:@"series_title"];
        p.short_series_description = [dict objectForKey:@"product-series-description"];
        
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:p];
        [productData setObject:encodedObject  forKey:keyProduct];
    }
}

//function that creates product series objects out of an array of dictionaries
-(void)breakoutProductSeriesData:(NSArray *)series
{
    
    for(NSDictionary *dict in series){
        ProductSeries *ps = [[ProductSeries alloc] init];
        
        ps.title = [self cleanseStringName:[dict objectForKey:@"title"]];
        NSString *keyProduct = [self cleanseStringName:[dict objectForKey:@"key"]];
        ps.key = keyProduct;

        
        //add the description in order to the description dictionary on the object
        NSArray *desc = [dict objectForKey:@"description"];
        int i = 0;
        for(NSDictionary *d in desc){
            [ps.description setObject:d forKey:[NSString stringWithFormat:@"%d", i]];
            i++;
        }
        
        ps.product_spec = [dict objectForKey:@"product_spec"];
        
        //case study keys
        ps.case_studies = [dict objectForKey:@"case_studies"];
        
        //white paper keys
        ps.white_papers = [dict objectForKey:@"white_papers"];
    
        //video keys
        ps.videos = [dict objectForKey:@"videos"];
    
        //product keys
        ps.products = [dict objectForKey:@"products"];
        
        //solutions keys
        ps.solutions = [dict objectForKey:@"solutions"];
        
     
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:ps];
        [productSeriesData setObject:encodedObject forKey:keyProduct];
    }
}

//function that creates video objects out of an array of dictionaries
-(void)breakoutVideoData:(NSArray *)videos
{
    
    for(NSDictionary *dict in videos){
        Video *v = [[Video alloc] init];
        
        v.title = [dict objectForKey:@"title"];
        NSString *keyProduct = [dict objectForKey:@"key"];
        v.key = keyProduct;
        
        //add the video image overylay to the array to cache the images upfront
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
        
        //make sure we have a url value before we create a video out of it
        if(![v.rawVideo isEqualToString:@""]){

            NSMutableDictionary *thread = [[NSMutableDictionary alloc] init];
            [thread setValue:v.rawVideo forKey:@"URL"];
            [thread setValue:[v.rawVideo lastPathComponent] forKey:@"name"];
            [initialFilesToDownload addObject:thread];
        }
        
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:v];
        [videoData setObject:encodedObject forKey:keyProduct];
    }
}

//function that creates document objects out of an array of dictionaries
//the document objects include case studies, white papers, and specs
-(void)breakoutDocumentData:(NSArray *)documents withType:(NSString *)type
{
    
    for(NSDictionary *dict in documents){
        Document *d = [[Document alloc] init];
        
        NSString *key = [dict objectForKey:@"key"];
        //NSString *filename = [NSString stringWithFormat:@"%@.html", key];
        d.key = key;
        d.title = [dict objectForKey:@"title"];
        d.type = type;
        d.data = [dict objectForKey:@"document-data"];
        
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
        
        //make sure we have a url value before we create a video out of it
        if(![d.data isEqualToString:@""]){
            NSMutableDictionary *thread = [[NSMutableDictionary alloc] init];
            [thread setValue:d.data forKey:@"URL"];
            [thread setValue:[d.data lastPathComponent] forKey:@"name"];
            [initialFilesToDownload addObject:thread];
        }
        
        //encoded object
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:d];
        [documentData setObject:encodedObject forKey:key];
        
    }
}

//function that breaks out all of the paper data and saves it as a model object
-(void)breakoutPaperData:(NSArray *)papers
{
    for(NSDictionary *dict in papers){
        
        Paper *p = [[Paper alloc] init];
        
        NSString *key = [dict objectForKey:@"key"];
        p.key = key;
        p.title = [dict objectForKey:@"title"];
        p.mill = [dict objectForKey:@"mill"];
        
        NSString *name = [p.mill stringByReplacingOccurrencesOfString:@"--mill" withString:@""];
        name = [name capitalizedString];
        name = [name stringByReplacingOccurrencesOfString:@"-" withString:@" "];
        p.mill_name = name;
        
        p.basis_weight = [dict objectForKey:@"basis_weight"];
        p.brightness = [dict objectForKey:@"brightness"];
        p.coating = [dict objectForKey:@"coating"];
        
        p.category = [dict objectForKey:@"category"];
        p.dye_pigment = [dict objectForKey:@"dye_pigment"];
        p.region = [dict objectForKey:@"region"];
        p.micr_capable = [dict objectForKey:@"micr_capable"];
        p.price_range = [dict objectForKey:@"price_range"];
        p.opacity_range = [dict objectForKey:@"opacity_range"];
        
        p.recycled_percentage = [dict objectForKey:@"recycled_percentage"];
        p.type_one = [dict objectForKey:@"type_one"];
        p.type_two = [dict objectForKey:@"type_two"];
        
        p.color_capability = [dict objectForKey:@"color_capability"];
        p.weights_available = [dict objectForKey:@"weights_available"];
        p.boost_sample = [dict objectForKey:@"boost_sample"];
        p.house_paper = [dict objectForKey:@"house_paper"];
        
        //add to the inital set of papers so they do not have to be queries later
        //this is a band-aid until we can implement a RDMS
        [initialSetOfPaper addObject:p];
        
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:p];
        [paperData setObject:encodedObject forKey:key];
    }
}

//function that breaks out all of the mill data and saves it as a model object
-(void)breakoutMillData:(NSArray *)mills
{
    
    for(NSDictionary *dict in mills){
        
        Mill *m = [[Mill alloc] init];
        
        NSString *key = [dict objectForKey:@"key"];
        m.key = key;
        m.title = [dict objectForKey:@"title"];
        m.logo = [dict objectForKey:@"logo"];
        
        //add the logo to cache it during the initial downloading sequence
        if(![m.logo isEqualToString:@""]){
            [downloadedImages addObject:m.logo];
        }
        
        m.banners = [dict objectForKey:@"banners"];
        //make sure and add the banners to the downloadImages array
        for(NSString *urlString in m.banners){
            [downloadedImages addObject:urlString];
        }
        
        m.description = [dict objectForKey:@"description"];
        m.website = [dict objectForKey:@"website"];
        m.phone = [dict objectForKey:@"phone"];
        m.address = [dict objectForKey:@"address"];
        m.videos = [dict objectForKey:@"videos"];
        m.papers = [dict objectForKey:@"papers"];
        
        //add to the inital set of mills so they do not have to be queries later
        //this is a band-aid until we can implement a RDMS
        [initialSetOfMills addObject:m];
        
        NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:m];
        [millData setObject:encodedObject forKey:key];
    }
}

//function that breaks out all of the software data and saves it as a model object
-(void)breakoutSoftwareData:(NSArray *)software
{
    
    for(NSDictionary *dict in software){
        
        Software *s = [[Software alloc] init];
        NSString *key = [dict objectForKey:@"key"];
        s.key = key;
        s.title = [dict objectForKey:@"title"];
        s.logo = [dict objectForKey:@"logo"];
        
        //add the logo to cache it during the initial downloading sequence
        if(![s.logo isEqualToString:@""]){
            [downloadedImages addObject:s.logo];
        }
        s.short_desc = [dict objectForKey:@"short_desc"];
        s.banners = [dict objectForKey:@"banners"];
        //make sure and add the banners to the downloadImages array
        for(NSString *urlString in s.banners){
            [downloadedImages addObject:urlString];
        }
        
        s.description = [dict objectForKey:@"description"];
        NSArray *overviewObjects = [dict objectForKey:@"overview"];
        int i = 0;
        for(NSDictionary *d in overviewObjects){
            [s.overview setObject:d forKey:[NSString stringWithFormat:@"%d", i]];
            i++;
        }
        
        
        s.datasheets = [dict objectForKey:@"datasheets"];
        s.white_papers = [dict objectForKey:@"white_papers"];
        s.case_studies = [dict objectForKey:@"case_studies"];
        s.brochures = [dict objectForKey:@"brochures"];
        s.videos = [dict objectForKey:@"videos"];
   
        
        ALog(@"DICTIONARY %@", s.case_studies);
        ALog(@"DICTIONARY %@", s.white_papers);
        [initialSofwareData addObject:s];
    }
}

//function that breaks out all of the partner data and saves it as a model object
-(void)breakoutPartnerData:(NSArray *)partners
{
    
    for(NSDictionary *dict in partners){
        
        Partner *p = [[Partner alloc] init];
        NSString *key = [dict objectForKey:@"key"];
        p.key = key;
        p.logo = [dict objectForKey:@"logo"];
        
        //add the logo to cache it during the initial downloading sequence
        if(![p.logo isEqualToString:@""]){
            [downloadedImages addObject:p.logo];
        }
        
        p.title = [dict objectForKey:@"title"];
        p.banners = [dict objectForKey:@"banners"];
        //make sure and add the banners to the downloadImages array
        for(NSString *urlString in p.banners){
            [downloadedImages addObject:urlString];
        }
        
        p.description = [dict objectForKey:@"description"];
        p.website = [dict objectForKey:@"website"];
        p.white_papers = [dict objectForKey:@"white_paper"];
        p.case_studies = [dict objectForKey:@"case_study"];
        p.videos = [dict objectForKey:@"videos"];
        p.solutions = [dict objectForKey:@"solutions"];
        p.premier_partner = [[dict objectForKey:@"premier_partner"] boolValue];
        
        [initialPartnerData addObject:p];
    }
}


//this function removes all NSUserDefaults for data to be updated
//this function is called when an update routine needs to run
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
    
    [productData removeAllObjects];
    [productSeriesData removeAllObjects];
    [videoData removeAllObjects];
    [documentData removeAllObjects];
    [softwareData removeAllObjects];
    [paperData removeAllObjects];
    [millData removeAllObjects];
    [initialSetOfMills removeAllObjects];
    [initialSetOfPaper removeAllObjects];
    [initialSofwareData removeAllObjects];
    [initialSolutionData removeAllObjects];
    [initialPartnerData removeAllObjects];
    [initialBannerData removeAllObjects];
    
    if([self deleteFile:@"initialPapers"]){
        ALog(@"Deleted Papers");
        if([self deleteFile:@"initialSolutions"]){
            ALog(@"Deleted Solutions");
            if([self deleteFile:@"initialPartners"]){
                ALog(@"Deleted Partners");
                if([self deleteFile:@"initialSoftware"]){
                    ALog(@"Deleted Software");
                    if([self deleteFile:@"initialMills"]){
                        ALog(@"Deleted Mills");
                        if([self deleteFile:@"initialBanners"]){
                            ALog(@"Deleted Banners");
                        }
                    }
                }
            }
        }
    }
    
}

//this function is run after the network routine finishes running the initial download or after an update
//the reason this is done is it saves on memory and redundant saved object attached to the model
-(void)wipeOutAllModelData
{
    //this routine adds the last updated dictionary to a NSUserDefault dictionary for the data to be persistant
    
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
    
    //wipe out all of the saved data in the models dictionaries
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:products];
    [self saveFile:data andFileName:@"product-data" complete:^(BOOL completeFlag){
        [productData removeAllObjects];
        [productSeriesData removeAllObjects];
        [videoData removeAllObjects];
        [documentData removeAllObjects];
        [softwareData removeAllObjects];
        [paperData removeAllObjects];
        [millData removeAllObjects];
        [initialSetOfMills removeAllObjects];
        [initialSetOfPaper removeAllObjects];
        [initialSofwareData removeAllObjects];
        [initialSolutionData removeAllObjects];
        [initialPartnerData removeAllObjects];
        [initialBannerData removeAllObjects];
        [lastUpdated removeAllObjects];
        
    }];

}


//This function saves all the objects saved temporarily in the model to disk
//So basically all of the objects are serialized and saved in dictionaries/arrays now they are wrote to the device by the object key.
//The object key is sort of like the object ID or row ID.
-(void)saveAllDataToDisk:(completeBlock)completeFlagArgument
{
    dispatch_queue_t backgroundQueue = dispatch_queue_create("canon.dev.com", 0);
    dispatch_async(backgroundQueue, ^{
        //save all product data
        __block int c1 = 0;
        for(id key in productData){
            
            [self saveFile:[productData objectForKey:key] andFileName:key complete:^(BOOL completeFlag){
                c1++;
                
                if(c1 == [productData count]){
                    __block int c2 = 0;
                    //save all product series data
                    for(id key in productSeriesData){
                        
                        [self saveFile:[productSeriesData objectForKey:key] andFileName:key complete:^(BOOL completeFlag){
                            c2++;
                            if(c2 == [productSeriesData count]){
                                __block int c3 = 0;
                                //save all video data
                                for(id key in videoData){
 
                                    [self saveFile:[videoData objectForKey:key] andFileName:key complete:^(BOOL completeFlag){
                                        c3++;
                                        if(c3 == [videoData count]){
                                            __block int c4 = 0;
                                            //save all document data
                                            for(id key in documentData){
  
                                                [self saveFile:[documentData objectForKey:key] andFileName:key complete:^(BOOL completeFlag){
                                                    c4++;
                                                    if(c4 == [documentData count]){
                     
                                                        //save inital dataset of software as object
                                                        NSData *encodedSoftware = [NSKeyedArchiver archivedDataWithRootObject:initialSofwareData];
                                                        
                                                        //save inital dataset of mills as object
                                                        NSData *encodedMills = [NSKeyedArchiver archivedDataWithRootObject:initialSetOfMills];
                                                        //save inital dataset of papers as object
                                                        NSData *encodedPapers = [NSKeyedArchiver archivedDataWithRootObject:initialSetOfPaper];
                                                        //save the initial dataset of solutions
                                                        NSData *encodedSolutions = [NSKeyedArchiver archivedDataWithRootObject:initialSolutionData];
                                                        NSData *encodedBanners = [NSKeyedArchiver archivedDataWithRootObject:initialBannerData];
                                                        
                                                        //save the initial dataset of partners
                                                        NSData *encodedPartners = [NSKeyedArchiver archivedDataWithRootObject:initialPartnerData];
                                                        [self saveFile:encodedMills andFileName:@"initialMills" complete:^(BOOL completeFlag){
                                                            [self saveFile:encodedPapers andFileName:@"initialPapers" complete:^(BOOL completeFlag){
                                                                [self saveFile:encodedSolutions andFileName:@"initialSolutions" complete:^(BOOL completeFlag){
                                                                    [self saveFile:encodedPartners andFileName:@"initialPartners" complete:^(BOOL completeFlag){
                                                                        [self saveFile:encodedSoftware andFileName:@"initialSoftware" complete:^(BOOL completeFlag){
                                                                            [self saveFile:encodedBanners andFileName:@"initialBanners" complete:^(BOOL completeFlag){
                                                                                if(completeFlag){
                                                                                    completeFlagArgument(YES);
                                                                                }else{
                                                                                    completeFlagArgument(NO);
                                                                                }
                                                                            }];
                                                                        }];
                                                                    }];
                                                                }];
                                                            }];
                                            
                                                        }];
                                                        
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
    });
}



//this sorts the data that is going into the table
-(void)sortInitialPaperDataAlpha:(NSString *)key complete:(completeBlock)completeFlag
{
    NSData *paperEncodedData = [self getFileData:@"initialPapers" complete:^(BOOL completeFlag){}];
    initialSetOfPaper = [NSKeyedUnarchiver unarchiveObjectWithData:paperEncodedData];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:key ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    initialSetOfPaper = [[initialSetOfPaper sortedArrayUsingDescriptors:sortDescriptors] mutableCopy];
    
    completeFlag(YES);
}

-(void)searchInitialPaperData:(NSMutableDictionary *)searchTerms complete:(completeBlock)completeFlag
{
    ALog(@"########### Before Filter Count %lu", (unsigned long)[searchablePaperDataObjects count]);
    NSMutableArray *predicateArray = [NSMutableArray array];
    for (id key in searchTerms) {
        if (![[searchTerms objectForKey:key] isEqualToString:@"- NONE -"]) {
            NSPredicate *p = [NSPredicate predicateWithFormat:@"%K == %@", key, [searchTerms objectForKey:key]];
            [predicateArray addObject:p];
        }
    }
    
    if ([predicateArray count] > 0) {
        NSPredicate *masterPred = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];
        ALog(@"master pred %@", masterPred);
   
        NSArray *newFilteredArray = [searchablePaperDataObjects filteredArrayUsingPredicate:masterPred];
        ALog(@"########### After Filter Count %lu", (unsigned long)[newFilteredArray count]);
        [searchablePaperDataObjects removeAllObjects];
        searchablePaperDataObjects = [newFilteredArray mutableCopy];
        
        completeFlag(YES);
    } else {
        completeFlag(YES);
    }
}

-(void)buildSearchableDataSource:(NSMutableArray *)incomingPaperData sourceFlag:(BOOL)flag complete:(completeBlock)completeFlag
{
    // Large Data Source
    // Mill Name      =   0
    // Media Name     =   1
    // Basis Weight   =   2
    // Brightness     =   3
    // Coating        =   4
    // Color          =   5
    // Capability     =   6
    // Inkset         =   7
    
    // Clear out the array
    [searchableMillData removeAllObjects];
    NSMutableArray *tempData = [NSMutableArray array];
    NSMutableArray *noDups = [NSMutableArray array];
    // build large data source
    if (flag) {
        // Load the array with a new array object
        for (int i = 0; i < 8; i++) {
            NSMutableArray *newArray = [NSMutableArray array];
            [tempData addObject:newArray];
        }

        int i = 0;
        for (Paper *p in incomingPaperData) {
            if (p != nil) {

                // Mill Name
                if (p.mill_name != nil){
                  [[tempData objectAtIndex:0] addObject:p.mill_name];
                }
                // Media Name
                if (p.title != nil) {
                    [[tempData objectAtIndex:1] addObject:p.title];
                }
                // Basis Weight
                if ([p.basis_weight count] > 0) {
                    for(NSString *weight in p.basis_weight) {
                       [[tempData objectAtIndex:2] addObject:weight];
                    }
                }
                // Brightness
                if (p.brightness != nil) {
                    [[tempData objectAtIndex:3] addObject:p.brightness];
                }
                // Coating
                if (p.coating != nil) {
                    [[tempData objectAtIndex:4] addObject:p.coating];
                }
                // Coating
                if (p.color_capability != nil) {
                    [[tempData objectAtIndex:5] addObject:p.color_capability];
                }
                // Capability
                if (p.category != nil) {
                    [[tempData objectAtIndex:6] addObject:p.category];
                }
                // Inkset
                if (p.dye_pigment != nil && ![p.dye_pigment isEqualToString:@""]) {
                    [[tempData objectAtIndex:7] addObject:p.dye_pigment];
                }
            }
            i++;
            if (i == [incomingPaperData count]){
                // Reduce Duplicated
                for (NSMutableArray *a in tempData) {
                    NSMutableArray *noDuplicates = [[[NSSet setWithArray: a] allObjects] mutableCopy];
                    [noDups addObject:noDuplicates];
                }
            }
        }
        
        searchableMillData = [noDups mutableCopy];
        
        // Insert None at the all of these options
        for (NSMutableArray *array in searchableMillData) {
            [array insertObject:@"- NONE -" atIndex:0];
        }
        completeFlag(YES);
        
    // build small data source
    } else {
        completeFlag(YES);
    }
}

//This function takes a CDN Hyperlink and chops it up to extract the video file name
//This function will be in flux as we transition asset providers and move away from Media Valet
-(NSString *)getVideoFileName:(NSString *)url
{
    if([url length] > 0){
        NSArray *chopped = [url componentsSeparatedByString:@"//"];
        if([chopped count] > 0){
            NSArray *choppedSecond = [[chopped objectAtIndex:1] componentsSeparatedByString:@"/"];
            if([choppedSecond objectAtIndex:2] != nil){
                return [choppedSecond objectAtIndex:2];
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

//function that gets the width of the field based upon the size of the text and the font of the text
- (CGFloat)widthOfString:(NSString *)string withStringSize:(float)size andFontKey:(NSString *)key
{
    UIFont *font = [UIFont fontWithName:key size:size];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}


-(UIImage *)getImageWithName:(NSString *)filename
{
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    @autoreleasepool {
      return [UIImage imageWithContentsOfFile:path];
    }
}

-(NSString *)addAccentToOCEString:(NSString *)string
{
    //"®"
    NSString *accent = [string stringByReplacingOccurrencesOfString:@"Oce" withString:@"Océ"];
    
    //here we are accounting for a "one off request"
    if([string isEqualToString:@"Canon imagePRESS C800C700 Series"]){
        accent = @"Canon imPRESS C800/C700";
    }
    
    return accent;

}


/*----------------------------------------------*
 Functionas that handle interaction with documents saved to the application
 -(void)saveHTMLFile:(NSData *)data andFileName:(NSString *)filename complete:(completeBlock)completeFlag
 -(NSData *)getFileData:(NSString *)fileName complete:(completeBlock)completeFlag
 -(BOOL)fileExists:(NSString *)filename
 *---------------------------------------------*/

//saves a file by the file name locally to the device
-(void)saveFile:(NSData *)data andFileName:(NSString *)filename complete:(completeBlock)completeFlag
{
    filename = [self cleanseStringName:filename];
    @autoreleasepool {
        if (data != nil)
        {
           
            //NSError *error;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString* path = [documentsDirectory stringByAppendingPathComponent:filename];

            if([data writeToFile:path atomically:YES]){
                ALog(@"Model SAVED FILE SUCCESSFULLY %@", path);
                completeFlag(YES);
            }else{
                ALog(@"ERROR SAVING FILE %@", path);
                completeFlag(NO);
            }
            
        }
    }

}

//function that saves a file and returns a response of YES or NO if the action was performed
//It should be noted that this function is save an HTML file and UTF8StringEncodes the data to be saved as HTML
-(void)saveHTMLFile:(NSData *)data andFileName:(NSString *)filename complete:(completeBlock)completeFlag
{
    filename = [self cleanseStringName:filename];
    @autoreleasepool {
        if (data != nil)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString* path = [documentsDirectory stringByAppendingPathComponent:filename];
            NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if([html writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil]){
                //ALog(@"SAVED HTML FILE SUCCESSFULLY %@", path);
                completeFlag(YES);
            }else{
                ALog(@"ERROR SAVING FILE %@", path);
                completeFlag(NO);
            }
        }
    }
}

//When all downloads are completed and it is time to display the view to the user, we need some data to get started with.
//This function allows us to display an initial set of data to the user
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

        ALog(@"Error retrieving the file from disk %@", err);
        return nil;
    }
}

-(NSMutableDictionary *)getInitialBannerData
{
    NSMutableDictionary *bannerData = [[NSMutableDictionary alloc] init];
    NSData *localBannerData = [self getFileData:@"initialBanners" complete:^(BOOL completeFlag){}];
    
    
    NSMutableArray *bannerArray = [NSKeyedUnarchiver unarchiveObjectWithData:localBannerData];
    for(Banner *b in bannerArray){
        [bannerData setObject:b forKey:b.key];
    }
    return bannerData;
}

//function the retrieves the nsdata based upon file name
-(NSData *)getFileData:(NSString *)fileName complete:(completeBlock)completeFlag
{

    fileName = [self cleanseStringName:fileName];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:fileName];
    NSError *err = nil;
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&err];

    if(data != nil && [data length] > 0){
        //ALog("Filename %@", fileName);
        //ALog("Data length %d", [data length]);
        completeFlag(YES);
        return data;
    }else{
        completeFlag(NO);
        ALog(@"Error retrieving the file from disk %@", err);
        return data;
    }
    
}

//function that gets an HTML file based upon name
//this function is function when it comes time to display documents in the prodoct series view
-(NSData *)getHTMLFile:(NSString *)filename complete:(completeBlock)completeFlag
{
    filename = [self cleanseStringName:filename];
   
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:filename];
    NSError *err = nil;
    //get the html data from disk
    NSData * htmlData = [NSData dataWithContentsOfFile:path options:NSDataReadingUncached error:&err];
    
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
        ALog(@"Error retrieving the file from disk %@", err);
        return htmlData;
    }
    
}

//function that checks if a file exists
-(BOOL)fileExists:(NSString *)filename
{
    filename = [self cleanseStringName:filename];
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

//function that checks if a file exists
-(BOOL)deleteFile:(NSString *)filename
{
    filename = [self cleanseStringName:filename];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSError *error;
    
    return [fileManager removeItemAtPath:path error:&error];

}


/**
 * Attempt to load the correct URL for the correct device
 **/
-(NSURL *)getProperURL:(NSString *)url
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
        ([UIScreen mainScreen].scale == 2.0)) {
        // Retina display
        
        if ([url rangeOfString:@"@2x"].location != NSNotFound) {
            //the url contains @2x, return it
            return [NSURL URLWithString:url];
        }

    } else {
        // non-Retina display
        if ([url rangeOfString:@"@2x"].location == NSNotFound) {
            url = [url stringByReplacingOccurrencesOfString:@"@2x" withString:@""];
        }
        
        if([[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:url]]){
            ALog(@"Non retina asset found in the cache");
            return [NSURL URLWithString:url];
        }
    }
    return nil;
}

//function that returns the file path based upon a filename
//this function is used a lot for videos that were just downloaded to the device
-(NSString *)returnFilePath:(NSString *)name
{
    name = [self cleanseStringName:name];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent:name];
    return path;
}

//this function checks to see if a video exists
-(BOOL)videoExists:(NSString *)videoURL
{
    videoURL = [self cleanseStringName:videoURL];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:videoURL]){
        return YES;
    }else{
        return NO;
    }
}

//this function cleans up a string so that nothing is saved with a strange character
-(NSString *)cleanseStringName:(NSString *)filename
{
    
    filename = [filename stringByReplacingOccurrencesOfString:@"/" withString:@""];
    filename = [filename stringByReplacingOccurrencesOfString:@"," withString:@""];
    filename = [filename stringByReplacingOccurrencesOfString:@":" withString:@""];
    filename = [filename stringByReplacingOccurrencesOfString:@"é" withString:@"e"];
    return [filename stringByReplacingOccurrencesOfString:@"\u00e9" withString:@"e"];
}

-(NSMutableArray *)cleanArray:(NSMutableArray *)array
{
    NSMutableArray *arr = [NSMutableArray array];
    for(NSString *str in array){
        NSString *s = str;
        s = [self cleanseStringName:s];
        [arr addObject:s];
    }
    return arr;
    
}

@end
