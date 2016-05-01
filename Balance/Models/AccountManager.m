//
//  AccountManager.m
//  Balance
//
//  Created by Chris Nolet on 4/27/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "AccountManager.h"
#import "Adapter.h"
#import "AccountObject.h"

@implementation AccountManager

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
- (void)accountsForAccessTokens:(NSArray *)accessTokens
                     accountIds:(NSArray *)accountIds
                     completion:(void (^)(NSArray *accounts, NSError *error))completion
{

}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)accountsForAccessToken:(NSString *)accessToken completion:(void (^)(NSArray *accounts, NSError *error))completion
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

@end
