//
//  DownloadUrlOperation.m
//  PressDemo
//
//  Created by Matt Eaton on 5/21/14.
//  Copyright (c) 2014 Trekk. All rights reserved.
//

#import "DownloadUrlOperation.h"


@implementation DownloadUrlOperation
@synthesize error = error_, data = data_;
@synthesize connectionURL = connectionURL_;
#pragma mark -
#pragma mark Initialization & Memory Management


- (id)initWithURL:(NSURL *)url
{
    if( (self = [super init]) ) {
        connectionURL_ = [url copy];
    }
    return self;
}


- (void)dealloc
{
    if( connection_ ) {
        [connection_ cancel];
        connection_ = nil;
    }
    connectionURL_ = nil;
    data_ = nil;
    error_ = nil;
}

#pragma mark -
#pragma mark Start & Utility Methods

// This method is just for convenience. It cancels the URL connection if it
// still exists and finishes up the operation.
- (void)done
{
    if( connection_ ) {
        [connection_ cancel];
        connection_ = nil;
    }
    
    // Alert anyone that we are finished
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    executing_ = NO;
    finished_  = YES;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
    
}
-(void)canceled {
	// Code for being cancelled
    error_ = [[NSError alloc] initWithDomain:@"DownloadUrlOperation" code:123 userInfo:nil];
    
    [self done];
    
}
- (void)start
{
    // Ensure that this operation starts on the main thread
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
        return;
    }
    
    // Ensure that the operation should exute
    if( finished_ || [self isCancelled] ) { [self done]; return; }
    
    // From this point on, the operation is officially executing--remember, isExecuting
    // needs to be KVO compliant!
    [self willChangeValueForKey:@"isExecuting"];
    executing_ = YES;
    [self didChangeValueForKey:@"isExecuting"];
    // Create the NSURLConnection--this could have been done in init, but we delayed
    // until no in case the operation was never enqueued or was cancelled before starting
    NSURLRequest * req = [NSURLRequest requestWithURL:connectionURL_ cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:20.0];
    connection_ = [[NSURLConnection alloc]initWithRequest:req delegate:self];
    
}

#pragma mark -
#pragma mark Overrides

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return executing_;
}

- (BOOL)isFinished
{
    return finished_;
}

#pragma mark -
#pragma mark Delegate Methods for NSURLConnection

// The connection failed
- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
        NSString *errorMessage = [error localizedDescription];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error Occurred During Presentation Download"
                                                            message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        NSLog(@"Error Message %@", errorMessage); //For console output also
        return;
    }
	else {
		data_ = nil;
		[self done];
	}
}

// The connection received more data
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
        return;
    }
    [data_ appendData:data];
}

// Initial response
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
		return;
    }
    
    NSUInteger contentSize = 0;
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    
    
    NSInteger statusCode = [httpResponse statusCode];
    //if status code is successful
    if( statusCode == 200 ) {
        contentSize = (int)[httpResponse expectedContentLength] > 0 ? (int)[httpResponse expectedContentLength] : 0;
        //append data
        data_ = [[NSMutableData alloc] initWithCapacity:contentSize];
    } else {
        NSString* statusError  = [NSString stringWithFormat:NSLocalizedString(@"HTTP Error: %ld", nil), statusCode];
        NSDictionary* userInfo = [NSDictionary dictionaryWithObject:statusError forKey:NSLocalizedDescriptionKey];
        error_ = [[NSError alloc] initWithDomain:@"DownloadUrlOperation" code:statusCode userInfo:userInfo];
        [self done];
    }
    
}
//function that makes sure the connectin is finished
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Check if the operation has been cancelled
    if([self isCancelled]) {
        [self canceled];
		return;
    }
	else {
		[self done];
	}
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}


@end


