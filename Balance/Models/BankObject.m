//
//  BankObject.m
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "BankObject.h"
#import "UIAlertView+Error.h"

@implementation BankObject

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithAccessToken:(NSString *)accessToken
{
    self = [super init];

    if (self) {
        self.accessToken = accessToken;
    }

    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)update
{
    // Generate POST request
    NSURL *url = [NSURL URLWithString:@"https://tartan.plaid.com/balance"];

    NSDictionary *parameters = @{
        @"client_id": kPlaidClientId,
        @"secret": kPlaidSecret,
        @"access_token": self.accessToken
    };

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:10];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];

    // Perform API call
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        // Return to main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSLog(@"%@", results);

            if (error) {
                return [[UIAlertView alertViewWithError:error] show];
            }
        });
    }] resume];
}

@end
