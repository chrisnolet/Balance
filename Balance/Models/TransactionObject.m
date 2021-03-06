//
//  TransactionObject.m
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "TransactionObject.h"
#import "NSDateFormatter+DateFormat.h"

@implementation TransactionObject

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - RLMObject

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)primaryKey
{
    return @"transactionId";
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (RLMResults *)allObjectsByDate
{
    RLMResults *results = [[self allObjects] sortedResultsUsingDescriptors:@[
        [RLMSortDescriptor sortDescriptorWithProperty:@"pending" ascending:NO],
        [RLMSortDescriptor sortDescriptorWithProperty:@"date" ascending:NO],
        [RLMSortDescriptor sortDescriptorWithProperty:@"accountId" ascending:YES]
    ]];

    return results;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];

    if (self) {
        self.transactionId = dictionary[@"_id"];
        self.accountId = dictionary[@"_account"];
        self.name = dictionary[@"name"];
        self.amount = dictionary[@"amount"];
        self.pending = dictionary[@"pending"];
        self.date = [NSDateFormatter dateFromString:dictionary[@"date"] dateFormat:@"yyyy-MM-dd"];
    }

    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Property methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)formattedName
{
    // Display generic titles for unnamed transactions
    if ([self.name length] <= 1) {
        return @"Transaction";
    }

    // Normalize uppercase names
    if ([[self.name uppercaseString] isEqualToString:self.name] && [self.name length] >= 3) {
        return [self.name capitalizedString];
    }

    return self.name;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (double)signedAmount
{
    // Return negative amounts for outgoing amounts
    return -[self.amount doubleValue];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)formattedAmount
{
    // Format the transaction amount
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;

    return [numberFormatter stringFromNumber:@(self.signedAmount)];
}

@end
