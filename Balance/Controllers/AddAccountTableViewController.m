//
//  AddAccountTableViewController.m
//  Balance
//
//  Created by Chris Nolet on 4/27/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "AddAccountTableViewController.h"
#import "AccountManager.h"
#import "AccountObject.h"

@interface AddAccountTableViewController ()

@property (strong, nonatomic) NSMutableArray *selectedAccounts;

@end

@implementation AddAccountTableViewController

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    self.selectedAccounts = [[NSMutableArray alloc] init];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"UnwindFromAddAccountSegue"]) {

        // Re-order selected accounts
        NSMutableArray *orderedAccounts = [NSMutableArray arrayWithCapacity:[self.selectedAccounts count]];

        for (AccountObject *account in self.accounts) {
            if ([self.selectedAccounts containsObject:account]) {
                [orderedAccounts addObject:account];
            }
        }

        // Add the selected accounts
        [[AccountManager sharedInstance] addAccounts:orderedAccounts];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.accounts count];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";

    AccountObject *account = self.accounts[indexPath.row];

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = account.name;
    cell.detailTextLabel.text = account.formattedBalance;

    return cell;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Select Accounts";
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"Select accounts that you would like to include in your total balance.";
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // Add or remove selected account
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    AccountObject *account = self.accounts[indexPath.row];

    if ([self.selectedAccounts containsObject:account]) {
        [self.selectedAccounts removeObject:account];
        cell.accessoryType = UITableViewCellAccessoryNone;
    } else {
        [self.selectedAccounts addObject:account];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }

    // Enable done button with selection
    self.doneBarButtonItem.enabled = ([self.selectedAccounts count] > 0);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)cancelBarButtonItemPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
