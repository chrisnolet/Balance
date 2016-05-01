//
//  Adapter.m
//  Balance
//
//  Created by Chris Nolet on 4/22/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "Adapter.h"

@interface Adapter ()

- (NSString *)queryWithParameters:(NSDictionary *)parameters;

@end

@implementation Adapter

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype)sharedInstance
{
    static id sharedInstance;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });

    return sharedInstance;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)postToEndpoint:(NSString *)endpoint
            parameters:(NSDictionary *)parameters
            completion:(void (^)(NSDictionary *results, NSError *error))completion
{
    // Mix-in default parameters
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:self.defaultParameters];
    [mutableParameters addEntriesFromDictionary:parameters];

    // Create query string
    NSString *query = [self queryWithParameters:mutableParameters];

    // Generate POST request
    NSURL *URL = [NSURL URLWithString:endpoint relativeToURL:[NSURL URLWithString:self.baseURL]];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:self.timeoutInterval];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [query dataUsingEncoding:NSUTF8StringEncoding];

    // Perform API call
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        // Parse the response
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

        // Return to main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@", results);

            completion(results, error);
        });
    }] resume];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)queryWithParameters:(NSDictionary *)parameters
{
    // Create query string from parameters
    NSMutableArray *pairs = [NSMutableArray arrayWithCapacity:[parameters count]];

    NSMutableCharacterSet *characterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [characterSet removeCharactersInString:@"&+=?"];

    for (NSString *key in parameters) {
        NSString *encodedKey = [key stringByAddingPercentEncodingWithAllowedCharacters:characterSet];
        NSString *encodedValue = [parameters[key] stringByAddingPercentEncodingWithAllowedCharacters:characterSet];

        [pairs addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
    }

    return [pairs componentsJoinedByString:@"&"];
}

@end
