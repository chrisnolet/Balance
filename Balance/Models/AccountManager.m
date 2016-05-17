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
#import "TransactionObject.h"
#import "NSDate+AddDays.h"
#import "NSDateFormatter+DateFormat.h"
#import "NSDictionary+StringValue.h"

@interface AccountManager ()

- (void)accountsForAccessToken:(NSString *)accessToken completion:(void (^)(NSArray *accounts, NSError *error))completion;
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
- (void)addAccounts:(NSArray *)accounts
{
    // Save accounts
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    [realm addOrUpdateObjectsFromArray:accounts];
    [realm commitWriteTransaction];

    // Update transactions
    [self updateAccounts];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeAccount:(AccountObject *)account
{
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    [realm deleteObjects:account.transactions];
    [realm deleteObject:account];
    [realm commitWriteTransaction];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateAccounts
{
    RLMResults *accounts = [AccountObject allObjects];
    RLMResults *transactions = [TransactionObject allObjects];

    NSMutableArray *updates = [NSMutableArray array];

    // Create a dispatch group
    dispatch_group_t group = dispatch_group_create();

    // Fetch each account asyncronously
    for (AccountObject *account in accounts) {
        dispatch_group_enter(group);

        [self accountForAccessToken:account.accessToken
                          accountId:account.accountId
                         completion:^(AccountObject *account, NSError *error) {

            // Store the account and transaction details
            if (account) {
                [updates addObject:account];
            }

            dispatch_group_leave(group);
        }];
    }

    // Commit updates when all requests complete
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        RLMRealm *realm = [RLMRealm defaultRealm];

        [realm beginWriteTransaction];
        [realm deleteObjects:transactions];
        [realm addOrUpdateObjectsFromArray:updates];
        [realm commitWriteTransaction];
    });
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)accountsForPublicToken:(NSString *)publicToken completion:(void (^)(NSArray *accounts, NSError *error))completion
{
    // Exchange public token for access token
    [[Adapter sharedInstance] postToEndpoint:@"exchange_token"
                                  parameters:@{ @"public_token": publicToken }
                                  completion:^(NSDictionary *results, NSError *error) {
        if (error) {
            return completion(nil, error);
        }

        // Get associated accounts
        [[AccountManager sharedInstance] accountsForAccessToken:results[@"access_token"]
                                                     completion:^(NSArray *accounts, NSError *error) {
            completion(accounts, error);
        }];
    }];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)accountsForAccessToken:(NSString *)accessToken completion:(void (^)(NSArray *accounts, NSError *error))completion
{
    [[Adapter sharedInstance] postToEndpoint:@"balance"
                                  parameters:@{ @"access_token": accessToken }
                                  completion:^(NSDictionary *results, NSError *error) {

        // Populate accounts
        NSMutableArray *accounts = [NSMutableArray array];

        for (NSDictionary *dictionary in results[@"accounts"]) {
            [accounts addObject:[[AccountObject alloc] initWithDictionary:dictionary accessToken:accessToken]];
        }

        completion([accounts copy], error);
    }];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)accountForAccessToken:(NSString *)accessToken
                    accountId:(NSString *)accountId
                   completion:(void (^)(AccountObject *account, NSError *error))completion
{
    // Filter transactions by account and date
    NSDate *startDate = [[NSDate date] dateByAddingDays:-kTransactionsNumberOfDays];

    NSDictionary *options = @{
        @"account": accountId,
        @"pending": @(YES),
        @"gte": [NSDateFormatter stringFromDate:startDate dateFormat:@"yyyy-MM-dd"]
    };

    NSDictionary *parameters = @{
        @"access_token": accessToken,
        @"options": [options stringValue]
    };

    // Get account and transaction details
    [[Adapter sharedInstance] postToEndpoint:@"connect/get"
                                  parameters:parameters
                                  completion:^(NSDictionary *results, NSError *error) {

        // Find the relevant account
        AccountObject *account;

        for (NSDictionary *dictionary in results[@"accounts"]) {
            if ([dictionary[@"_id"] isEqualToString:accountId]) {
                account = [[AccountObject alloc] initWithDictionary:dictionary accessToken:accessToken];
            }
        }

        // Add transactions
        for (NSDictionary *dictionary in results[@"transactions"]) {
            [account.transactions addObject:[[TransactionObject alloc] initWithDictionary:dictionary]];
        }

        completion(account, error);
    }];
}

@end
