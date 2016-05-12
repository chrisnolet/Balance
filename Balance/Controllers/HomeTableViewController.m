//
//  HomeTableViewController.m
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import <Realm/Realm.h>
#import "HomeTableViewController.h"
#import "AccountManager.h"
#import "AccountObject.h"
#import "TransactionObject.h"
#import "NSDateFormatter+DateFormat.h"

@interface HomeTableViewController ()

@property (strong, nonatomic) RLMResults<AccountObject *> *accounts;
@property (strong, nonatomic) RLMResults<TransactionObject *> *transactions;
@property (strong, nonatomic) RLMNotificationToken *notificationToken;
@property (strong, nonatomic) UIView *headerView;

- (void)applicationDidBecomeActive:(NSNotification *)notification;
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
    [self refreshUserInterface];

    // Refresh when accounts are updated
    typeof(self) __weak weakSelf = self;

    self.notificationToken = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString *notification, RLMRealm *realm) {
        [weakSelf refreshUserInterface];
    }];

    // Update accounts
    [[AccountManager sharedInstance] updateAccounts];

    // Update when re-opened
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    // Add header view
    self.headerView = [[[UINib nibWithNibName:@"HeaderView" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
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
    cell.textLabel.textColor = [transaction.pending boolValue] ? [UIColor darkGrayColor] : [UIColor darkTextColor];
    cell.detailTextLabel.text = transaction.formattedAmount;

    return cell;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIScrollViewDelegate

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Pin the header view to the top of the table view
    CGFloat offset = MIN(self.tableView.contentOffset.y, -self.tableView.contentInset.top);

    self.headerView.transform = CGAffineTransformMakeTranslation(0, offset);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Property methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setHeaderView:(UIView *)headerView
{
    [_headerView removeFromSuperview];

    _headerView = headerView;

    // Fill the table view width
    CGRect frame = CGRectMake(0, 0, self.tableView.frame.size.width, headerView.frame.size.height);

    headerView.frame = frame;

    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:frame];
    self.tableView.tableHeaderView.userInteractionEnabled = NO;

    [self.tableView addSubview:headerView];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
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

    self.balanceLabel.text = [numberFormatter stringFromNumber:@(totalBalance)];

    // Display the date
    self.dateLabel.text = [NSDateFormatter stringFromDate:[NSDate date] dateFormat:@"EEEE, MMMM d"];

    // Reload transactions
    [self.tableView reloadData];
}

@end
