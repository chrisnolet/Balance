//
//  AddAccountTableViewController.h
//  Balance
//
//  Created by Chris Nolet on 4/27/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "BankObject.h"

@interface AddAccountTableViewController : UITableViewController

@property (strong, nonatomic) BankObject *bank;
@property (strong, nonatomic) NSArray *accounts;

@end
