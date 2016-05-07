//
//  AccountManager.h
//  Balance
//
//  Created by Chris Nolet on 4/27/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

@interface AccountManager : NSObject

+ (instancetype)sharedInstance;

- (void)updateAccounts;
- (void)accountsForAccessToken:(NSString *)accessToken completion:(void (^)(NSArray *accounts, NSError *error))completion;

@end
