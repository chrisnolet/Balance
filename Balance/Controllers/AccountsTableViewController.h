//
//  AccountsTableViewController.h
//  Balance
//
//  Created by Chris Nolet on 4/23/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "PLDLinkNavigationViewController.h"

@interface AccountsTableViewController : UITableViewController <PLDLinkNavigationControllerDelegate>

- (IBAction)unwindFromAddAccountSegue:(UIStoryboardSegue *)unwindSegue;

@end
