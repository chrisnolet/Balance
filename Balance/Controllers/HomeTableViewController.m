//
//  HomeTableViewController.m
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import <Realm/Realm.h>
#import "HomeTableViewController.h"
#import "HeaderView.h"
#import "AccountManager.h"
#import "AccountObject.h"
#import "TransactionObject.h"
#import "NSDateFormatter+DateFormat.h"

@interface HomeTableViewController ()

@property (strong, nonatomic) RLMResults<AccountObject *> *accounts;
@property (strong, nonatomic) RLMResults<TransactionObject *> *transactions;
@property (strong, nonatomic) RLMNotificationToken *notificationToken;
@property (strong, nonatomic) HeaderView *headerView;

- (void)applicationDidBecomeActive:(NSNotification *)notification;
- (void)updateAccounts;
- (void)refreshUserInterface;

@end

@implementation HomeTableViewController

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Load accounts and transactions
    self.accounts = [AccountObject allObjects];
    self.transactions = [TransactionObject allObjectsByDate];

    // Set up user interface
    self.headerView = [HeaderView viewWithDefaultNib];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self refreshUserInterface];

    // Refresh when accounts are updated
    typeof(self) __weak weakSelf = self;

    self.notificationToken = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString *notification, RLMRealm *realm) {
        [weakSelf refreshUserInterface];
    }];

    // Update accounts
    [self updateAccounts];

    // Update when re-opened
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
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
    [self.notificationToken stop];

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

    TransactionObject *transaction = self.transactions[indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = transaction.formattedName;
    cell.textLabel.textColor = [transaction.pending boolValue] ? [UIColor grayColor] : [UIColor darkTextColor];
    cell.detailTextLabel.text = transaction.formattedAmount;

    return cell;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIScrollViewDelegate

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Pin the header view to the top of the table view
    CGFloat offset = self.tableView.contentOffset.y;

    self.headerView.frame = CGRectMake(0, offset, self.tableView.frame.size.width, MAX(-offset, 0));
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Property methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHeaderView:(HeaderView *)headerView
{
    [_headerView removeFromSuperview];

    _headerView = headerView;

    // Fill the table view width
    headerView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, headerView.frame.size.height);

    self.tableView.contentInset = UIEdgeInsetsMake(headerView.frame.size.height, 0, 0, 0);
    self.tableView.contentOffset = CGPointMake(0, -headerView.frame.size.height);

    [self.tableView addSubview:headerView];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self updateAccounts];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)updateAccounts
{
    self.headerView.balanceView.alpha = 0.5f;

    [[AccountManager sharedInstance] updateAccounts];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)refreshUserInterface
{
    // Calculate the total balance
    double totalBalance = 0.0;

    for (AccountObject *account in self.accounts) {
        totalBalance += account.signedBalance;
    }

    // Format the result
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
    numberFormatter.maximumFractionDigits = 0;

    self.headerView.balanceLabel.text = [numberFormatter stringFromNumber:@(totalBalance)];
    self.headerView.balanceView.alpha = 1.0f;

    // Display the date
    self.headerView.dateLabel.text = [NSDateFormatter stringFromDate:[NSDate date] dateFormat:@"EEEE, MMMM d"];

    // Reload transactions
    [self.tableView reloadData];
}

@end
