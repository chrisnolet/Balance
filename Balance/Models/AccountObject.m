//
//  AccountObject.m
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "AccountObject.h"

@implementation AccountObject

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - RLMObject

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)primaryKey
{
    return @"accountId";
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
#pragma mark - Property methods

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
    NSNumber *balance = self.availableBalance ?: self.currentBalance;

    return [balance doubleValue];

    // TODO(CN): Consider subtracting pending charges from self.transactions
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)formattedBalance
{
    // Format the signed balance
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;

    return [numberFormatter stringFromNumber:@(self.signedBalance)];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)save
{
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    [realm addOrUpdateObject:self];
    [realm commitWriteTransaction];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)remove
{
    RLMRealm *realm = [RLMRealm defaultRealm];

    [realm beginWriteTransaction];
    [realm deleteObjects:self.transactions];
    [realm deleteObject:self];
    [realm commitWriteTransaction];
}

@end
