//
//  HomeViewController.h
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "PLDLinkNavigationViewController.h"

@interface HomeViewController : UIViewController <UITableViewDataSource,
                                                  UITableViewDelegate,
                                                  PLDLinkNavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)addBarButtonItemPressed:(id)sender;

@end
