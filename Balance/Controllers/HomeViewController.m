//
//  HomeViewController.m
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import <Realm/Realm.h>
#import "HomeViewController.h"
#import "AccountObject.h"
#import "TransactionObject.h"

@interface HomeViewController ()

@property (strong, nonatomic) RLMResults<AccountObject *> *accounts;
@property (strong, nonatomic) RLMResults<TransactionObject *> *transactions;
@property (strong, nonatomic) RLMNotificationToken *notificationToken;

- (void)applicationDidBecomeActive:(NSNotification *)notification;
- (void)refresh;

@end

@implementation HomeViewController

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Refresh when re-opened
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    // Set up Realm queries
    self.accounts = [AccountObject allObjects];
    self.transactions = [TransactionObject allObjects];

    // Sort transactions by date
    [self.transactions sortedResultsUsingProperty:NSStringFromSelector(@selector(date)) ascending:NO];

    // Update unified balance when new accounts are added
    RLMRealm *realm = [RLMRealm defaultRealm];
    typeof(self) __weak weakSelf = self;

    self.notificationToken = [realm addNotificationBlock:^(NSString *notification, RLMRealm *realm) {
        [weakSelf refresh];
    }];

    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.transactions count];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = @"Transaction";

    return cell;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self.tableView reloadData];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)refresh
{
    // Calculate the total balance
    double unifiedBalance = 0.0;

    for (AccountObject *account in self.accounts) {
        unifiedBalance += [account signedBalance];
    }

    // Format the result
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
    numberFormatter.maximumFractionDigits = 0;

    self.balanceLabel.text = [numberFormatter stringFromNumber:@(unifiedBalance)];

    // Reload transactions
    [self.tableView reloadData];
}

@end
