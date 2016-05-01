//
//  UserManager.h
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

@interface UserManager : NSObject

@property (strong, nonatomic) NSArray *banks;

- (void)save;

@end
