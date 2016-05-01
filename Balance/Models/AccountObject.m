//
//  AccountObject.m
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "AccountObject.h"
#import "Adapter.h"

@implementation AccountObject

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - RLMObject

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)primaryKey
{
    return NSStringFromSelector(@selector(accountId));
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)accountsForAccessToken:(NSString *)accessToken completion:(void (^)(NSArray *accounts, NSError *error))completion
{
    [[Adapter sharedInstance] postToEndpoint:@"balance"
                                  parameters:@{ @"access_token": accessToken }
                                  completion:^(NSDictionary *results, NSError *error) {

        // Populate accounts
        NSMutableArray *accounts = [NSMutableArray array];

        for (NSDictionary *account in results[@"accounts"]) {
            [accounts addObject:[[AccountObject alloc] initWithDictionary:account accessToken:accessToken]];
        }

        completion(accounts, error);
    }];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithDictionary:(NSDictionary *)dictionary accessToken:(NSString *)accessToken
{
    self = [super init];

    if (self) {
        self.accessToken = accessToken;
        self.accountId = dictionary[@"_id"];
        self.name = dictionary[@"meta"][@"name"];
        self.number = dictionary[@"meta"][@"number"];
        self.type = dictionary[@"type"];
        self.availableBalance = dictionary[@"balance"][@"available"];
        self.currentBalance = dictionary[@"balance"][@"current"];
    }

    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (double)signedBalance
{
    // Return a negative balance for credit accounts
    if ([self.type isEqualToString:@"credit"] ||
        [self.type isEqualToString:@"loan"] ||
        [self.type isEqualToString:@"mortgage"]) {

        return -[self.currentBalance doubleValue];
    }

    // Return a positive balance for checking and savings accounts
    NSString *balance = self.availableBalance ?: self.currentBalance;

    return [balance doubleValue];

    // TODO(CN): Consider subtracting pending charges from self.transactions
}

@end
