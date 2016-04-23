//
//  AccountObject.h
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

@interface AccountObject : NSObject

@property (strong, nonatomic) NSString *accountId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *number;
@property (nonatomic, assign) double balance;
@property (strong, nonatomic) NSArray *transactions;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
