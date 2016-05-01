//
//  AccountObject.h
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import <Realm/Realm.h>
#import "TransactionObject.h"

@interface AccountObject : RLMObject

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *accountId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *number;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *availableBalance;
@property (strong, nonatomic) NSString *currentBalance;
@property (strong, nonatomic) RLMArray<TransactionObject *><TransactionObject> *transactions;

+ (void)accountsForAccessToken:(NSString *)accessToken completion:(void (^)(NSArray *accounts, NSError *error))completion;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary accessToken:(NSString *)accessToken;
- (double)signedBalance;

@end
