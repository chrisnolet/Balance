//
//  HomeTableViewController.h
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "PLDLinkNavigationViewController.h"

@interface HomeTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *balanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *dateLabel;

@end
