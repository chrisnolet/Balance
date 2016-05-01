//
//  BankObject.h
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

@interface BankObject : NSObject

@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSArray *accounts;

- (instancetype)initWithAccessToken:(NSString *)accessToken;

@end
