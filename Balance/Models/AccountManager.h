//
//  AccountManager.h
//  Balance
//
//  Created by Chris Nolet on 4/27/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "AccountObject.h"

@interface AccountManager : NSObject

+ (instancetype)sharedInstance;

- (void)addAccounts:(NSArray *)accounts;
- (void)removeAccount:(AccountObject *)account;
- (void)updateAccounts;
- (void)accountsForPublicToken:(NSString *)publicToken completion:(void (^)(NSArray *accounts, NSError *error))completion;

@end
