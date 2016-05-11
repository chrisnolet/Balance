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
    RLMResults *results = [self allObjects];

    return [results sortedResultsUsingProperty:@"date" ascending:NO];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];

    if (self) {
        self.transactionId = dictionary[@"_id"];
        self.name = dictionary[@"name"];
        self.amount = dictionary[@"amount"];
        self.date = [NSDateFormatter dateFromString:dictionary[@"date"] dateFormat:@"yyyy-MM-dd"];
    }

    return self;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Property methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)formattedAmount
{
    // Format the transaction amount
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    numberFormatter.minimumFractionDigits = 2;
    numberFormatter.maximumFractionDigits = 2;
    numberFormatter.alwaysShowsDecimalSeparator = YES;

    return [numberFormatter stringFromNumber:self.amount];
}

@end
