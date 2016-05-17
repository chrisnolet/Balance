//
//  AddAccountTableViewController.h
//  Balance
//
//  Created by Chris Nolet on 4/27/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

@interface AddAccountTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIBarButtonItem *doneBarButtonItem;

@property (strong, nonatomic) NSArray *accounts;

- (IBAction)cancelBarButtonItemPressed:(id)sender;

@end
