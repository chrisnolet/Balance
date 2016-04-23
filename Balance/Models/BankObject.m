//
//  BankObject.m
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "BankObject.h"
#import "Adapter.h"
#import "AccountObject.h"

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
    // TODO(CN): Move API calls to class methods on the object-types that they create
    // For example: + (NSArray *)accountsForAccessToken:(NSString *)accessToken;

    // TODO(CN): Alternatively, create a SyncManager to manage Realm database store

    [[Adapter sharedInstance] postToEndpoint:@"balance"
                                  parameters:@{ @"access_token": self.accessToken }
                                  completion:^(NSDictionary *results, NSError *error) {

        // Populate accounts
        NSMutableArray *accounts = [NSMutableArray array];

        for (NSDictionary *account in results[@"accounts"]) {
            [accounts addObject:[[AccountObject alloc] initWithDictionary:account]];
        }

        self.accounts = [accounts copy];
    }];
}

@end
