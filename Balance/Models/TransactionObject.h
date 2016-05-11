//
//  TransactionObject.h
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import <Realm/Realm.h>

RLM_ARRAY_TYPE(TransactionObject)

@interface TransactionObject : RLMObject

@property (strong, nonatomic) NSString *transactionId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSNumber<RLMDouble> *amount;
@property (strong, nonatomic) NSNumber<RLMBool> *pending;

@property (nonatomic, readonly) double signedAmount;
@property (nonatomic, readonly) NSString *formattedAmount;

+ (RLMResults *)allObjectsByDate;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
