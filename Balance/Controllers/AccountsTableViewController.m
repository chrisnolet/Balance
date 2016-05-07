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
#import "Adapter.h"
#import "AccountManager.h"
#import "AccountObject.h"
#import "UIAlertView+Error.h"

@interface AccountsTableViewController ()

@property (strong, nonatomic) RLMResults<AccountObject *> *accounts;
@property (strong, nonatomic) RLMNotificationToken *notificationToken;

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
        case 0:
            return nil;

        // Add account
        default:
            return @"Made with <3 by Chris Nolet © 2016";
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

        // Show the bank selection modal
        PLDLinkNavigationViewController *plaidLink = [[PLDLinkNavigationViewController alloc]
                                                      initWithEnvironment:PlaidEnvironmentTartan
                                                      product:PlaidProductConnect];

        plaidLink.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        plaidLink.linkDelegate = self;

        [self presentViewController:plaidLink animated:YES completion:nil];
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - PLDLinkNavigationControllerDelegate

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)linkNavigationContoller:(PLDLinkNavigationViewController *)navigationController
       didFinishWithAccessToken:(NSString *)publicToken
{
    // Exchange public token for access token
    [[Adapter sharedInstance] postToEndpoint:@"exchange_token"
                                  parameters:@{ @"public_token": publicToken }
                                  completion:^(NSDictionary *results, NSError *error) {
        if (error) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [[UIAlertView alertViewWithError:error] show];

            return;
        }

        [[AccountManager sharedInstance] accountsForAccessToken:results[@"access_token"]
                                                     completion:^(NSArray *accounts, NSError *error) {
            if (error) {
                [self dismissViewControllerAnimated:YES completion:nil];
                [[UIAlertView alertViewWithError:error] show];

                return;
            }


            // Show list of bank accounts
            [self dismissViewControllerAnimated:YES completion:^{
                [self performSegueWithIdentifier:@"AddAccountSegue" sender:accounts];
            }];
        }];
    }];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)linkNavigationControllerDidFinishWithBankNotListed:(PLDLinkNavigationViewController *)navigationController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)linkNavigationControllerDidCancel:(PLDLinkNavigationViewController *)navigationController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (IBAction)unwindFromAddAccountSegue:(UIStoryboardSegue *)unwindSegue
{
}

@end
