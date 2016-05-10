//
//  AccountManager.m
//  Balance
//
//  Created by Chris Nolet on 4/27/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import <Realm/Realm.h>
#import "AccountManager.h"
#import "Adapter.h"
#import "AccountObject.h"

@interface AccountManager ()

- (void)accountForAccessToken:(NSString *)accessToken
                    accountId:(NSString *)accountId
                   completion:(void (^)(AccountObject *account, NSError *error))completion;

@end

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
- (void)updateAccounts
{
    RLMRealm *realm = [RLMRealm defaultRealm];
    RLMResults *accounts = [AccountObject allObjects];

    [realm beginWriteTransaction];

    // Create a dispatch group
    dispatch_group_t group = dispatch_group_create();

    // Update each account asyncronously
    for (AccountObject *account in accounts) {
        dispatch_group_enter(group);

        [self accountForAccessToken:account.accessToken
                          accountId:account.accountId
                         completion:^(AccountObject *account, NSError *error) {

            // Update the account
            [realm addOrUpdateObject:account];

            dispatch_group_leave(group);
        }];
    }

    // Close out the transaction
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [realm commitWriteTransaction];
    });
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

        completion([accounts copy], error);
    }];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)accountForAccessToken:(NSString *)accessToken
                    accountId:(NSString *)accountId
                   completion:(void (^)(AccountObject *account, NSError *error))completion
{
    [self accountsForAccessToken:accessToken completion:^(NSArray *accounts, NSError *error) {

        // Find and return the relevant account
        for (AccountObject *account in accounts) {
            if ([account.accountId isEqualToString:accountId]) {
                return completion(account, error);
            }
        }

        // Otherwise return nil
        completion(nil, error);
    }];
}

@end
