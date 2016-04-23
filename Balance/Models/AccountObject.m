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
#pragma mark - NSObject

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];

    if (self) {
        NSString *balance = dictionary[@"balance"][@"available"] ?: dictionary[@"balance"][@"current"];

        self.accountId = dictionary[@"id"];
        self.name = dictionary[@"meta"][@"name"];
        self.number = dictionary[@"meta"][@"number"];
        self.balance = [balance doubleValue];
    }

    return self;
}

@end
