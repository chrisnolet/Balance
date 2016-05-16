//
//  AccountsTableViewController.h
//  Balance
//
//  Created by Chris Nolet on 4/23/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "PLDLinkBankSelectionViewController.h"
#import "PLDLinkBankMFAContainerViewController.h"
#import "PLDAuthentication.h"

@interface AccountsTableViewController : UITableViewController <PLDLinkBankSelectionViewControllerDelegate,
                                                                PLDLinkBankMFAContainerViewControllerDelegate>

- (IBAction)unwindFromAddAccountSegue:(UIStoryboardSegue *)unwindSegue;

@end
