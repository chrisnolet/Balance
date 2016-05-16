//
//  AccountsTableViewController.m
//  Balance
//
//  Created by Chris Nolet on 4/23/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import <Realm/Realm.h>
#import "AccountsTableViewController.h"
#import "AddAccountTableViewController.h"
#import "AccountManager.h"
#import "AccountObject.h"
#import "UIAlertView+Error.h"

@interface AccountsTableViewController ()

@property (strong, nonatomic) RLMResults<AccountObject *> *accounts;
@property (strong, nonatomic) RLMNotificationToken *notificationToken;

- (NSString *)formattedBalance;

@end

@implementation AccountsTableViewController

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Load accounts
    self.accounts = [AccountObject allObjects];

    // Refresh when accounts are updated
    typeof(self) __weak weakSelf = self;

    self.notificationToken = [[RLMRealm defaultRealm] addNotificationBlock:^(NSString *notification, RLMRealm *realm) {
        [weakSelf.tableView reloadData];
    }];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"AddAccountSegue"]) {
        AddAccountTableViewController *addAccountTableViewController = segue.destinationViewController;
        addAccountTableViewController.accounts = (NSArray *)sender;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc
{
    [self.notificationToken stop];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {

        // Account
        case 0:
            return [self.accounts count];

        // Add account
        default:
            return 1;
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {

        // Account
        case 0: {
            static NSString *cellIdentifier = @"Cell";

            AccountObject *account = self.accounts[indexPath.row];

            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = account.name;
            cell.detailTextLabel.text = account.formattedBalance;

            return cell;
        }

        // Add account
        default: {
            static NSString *cellIdentifier = @"AddCell";

            return [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    switch (section) {

        // Account
        case 0: {
            if ([self.accounts count] == 0) {
                return nil;
            }

            return [NSString stringWithFormat:@"Total: %@", [self formattedBalance]];
        }

        // Add account
        default: {
            return @"Made with <3 by Chris Nolet © 2016";
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Swipe to delete accounts
    return (indexPath.section == 0);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove the account
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AccountObject *account = self.accounts[indexPath.row];

        [account remove];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDelegate

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    // Add account
    if (indexPath.section == 1) {

        // Show the bank selection controller
        PLDLinkBankSelectionViewController *plaidBankSelectionViewController = [[PLDLinkBankSelectionViewController alloc]
                                                                                initWithProduct:PlaidProductConnect];
        plaidBankSelectionViewController.title = @"Select Your Bank";
        plaidBankSelectionViewController.view.backgroundColor = self.view.backgroundColor;
        plaidBankSelectionViewController.navigationItem.rightBarButtonItem = nil;
        plaidBankSelectionViewController.delegate = self;

        [self.navigationController pushViewController:plaidBankSelectionViewController animated:YES];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;

    footer.textLabel.textAlignment = (section == 0) ? NSTextAlignmentRight : NSTextAlignmentCenter;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PLDLinkBankSelectionViewControllerDelegate

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)bankSelectionViewController:(PLDLinkBankSelectionViewController *)viewController
           didFinishWithInstitution:(PLDInstitution *)institution
{
    PLDLinkBankMFAContainerViewController *plaidBankMFAContainerViewController = [[PLDLinkBankMFAContainerViewController alloc]
                                                                                  initWithInstitution:institution
                                                                                  product:PlaidProductConnect];

    [self.navigationController pushViewController:plaidBankMFAContainerViewController animated:YES];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)bankSelectionViewControllerDidFinishWithBankNotListed:(PLDLinkBankSelectionViewController *)viewController
{
    [self.navigationController popToViewController:self animated:YES];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)bankSelectionViewControllerCancelled:(PLDLinkBankSelectionViewController *)viewController
{
    [self.navigationController popToViewController:self animated:YES];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PLDLinkBankMFAContainerViewControllerDelegate

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)mfaContainerViewController:(PLDLinkBankMFAContainerViewController *)viewController
       didFinishWithAuthentication:(PLDAuthentication *)authentication
{
    // Authenticate and fetch accounts
    [[AccountManager sharedInstance] accountsForPublicToken:authentication.accessToken
                                                 completion:^(NSArray *accounts, NSError *error) {
        if (error) {
            [self dismissViewControllerAnimated:YES completion:nil];

            return [[UIAlertView alertViewWithError:error] show];
        }

        // Show list of bank accounts
        [self performSegueWithIdentifier:@"AddAccountSegue" sender:accounts];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)unwindFromAddAccountSegue:(UIStoryboardSegue *)unwindSegue
{
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)formattedBalance
{
    // Calculate the total balance
    double totalBalance = 0;

    for (AccountObject *account in self.accounts) {
        totalBalance += account.signedBalance;
    }

    // Format the result
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = NSNumberFormatterCurrencyStyle;

    return [numberFormatter stringFromNumber:@(totalBalance)];
}

@end
