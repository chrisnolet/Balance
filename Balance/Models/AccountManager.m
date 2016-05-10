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
#import "TransactionObject.h"
#import "NSDate+AddDays.h"
#import "NSDateFormatter+DateFormat.h"
#import "NSDictionary+StringValue.h"

@interface AccountManager ()

- (void)accountForAccessToken:(NSString *)accessToken
                    accountId:(NSString *)accountId
                   completion:(void (^)(AccountObject *account, NSArray *transactions, NSError *error))completion;

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
                         completion:^(AccountObject *account, NSArray *transactions, NSError *error) {

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
        NSMutableArray *accounts = [NSMutableArray arrayWithCapacity:[results[@"accounts"] count]];

        for (NSDictionary *dictionary in results[@"accounts"]) {
            [accounts addObject:[[AccountObject alloc] initWithDictionary:dictionary accessToken:accessToken]];
        }

        completion([accounts copy], error);
    }];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)accountForAccessToken:(NSString *)accessToken
                    accountId:(NSString *)accountId
                   completion:(void (^)(AccountObject *account, NSArray *transactions, NSError *error))completion
{
    // Filter transactions by account and date
    NSDate *startDate = [[NSDate date] dateByAddingDays:-kTransactionsNumberOfDays];

    NSDictionary *options = @{
        @"account": accountId,
        @"pending": @(YES),
        @"gte": [NSDateFormatter stringFromDate:startDate dateFormat:@"yyyy-MM-dd"]
    };

    // Get account and transaction details
    [[Adapter sharedInstance] postToEndpoint:@"connect/get"
                                  parameters:@{ @"access_token": accessToken, @"options": [options stringValue] }
                                  completion:^(NSDictionary *results, NSError *error) {

        // Retrieve the relevant account
        AccountObject *account;

        for (NSDictionary *dictionary in results[@"accounts"]) {
            if ([dictionary[@"_id"] isEqualToString:accountId]) {
                account = [[AccountObject alloc] initWithDictionary:dictionary accessToken:accessToken];
            }
        }

        // Populate transactions
        NSMutableArray *transactions = [NSMutableArray arrayWithCapacity:[results[@"transactions"] count]];

        for (NSDictionary *dictionary in results[@"transactions"]) {
            [transactions addObject:[[TransactionObject alloc] initWithDictionary:dictionary]];
        }

        completion(account, [transactions copy], error);
    }];
}

@end
