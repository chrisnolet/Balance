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
@property (strong, nonatomic) NSNumber<RLMDouble> *availableBalance;
@property (strong, nonatomic) NSNumber<RLMDouble> *currentBalance;
@property (strong, nonatomic) RLMArray<TransactionObject *><TransactionObject> *transactions;

@property (nonatomic, readonly) double signedBalance;
@property (nonatomic, readonly) NSString *formattedBalance;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary accessToken:(NSString *)accessToken;
- (void)save;
- (void)remove;

@end
