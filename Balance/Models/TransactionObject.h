//
//  TransactionObject.h
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import <Realm/Realm.h>

@interface TransactionObject : RLMObject

@property (strong, nonatomic) NSString *transactionId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *amount;
@property (strong, nonatomic) NSDate *date;

@end

RLM_ARRAY_TYPE(TransactionObject)
