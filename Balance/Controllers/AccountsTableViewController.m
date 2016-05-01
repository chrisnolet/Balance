//
//  AccountsTableViewController.m
//  Balance
//
//  Created by Chris Nolet on 4/23/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "AccountsTableViewController.h"
#import "AddAccountTableViewController.h"
#import "Adapter.h"
#import "BankObject.h"
#import "UIAlertView+Error.h"

@implementation AccountsTableViewController

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIViewController

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];
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
        addAccountTableViewController.bank = (BankObject *)sender;
    }
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
    return 1;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            static NSString *cellIdentifier = @"Cell";

            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
            cell.textLabel.text = @"Account";

            return cell;
        }

        default: {
            static NSString *cellIdentifier = @"AddCell";

            return [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        }
    }
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.section == 0);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
                                            forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // TODO(CN): Remove account
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

        // Show the Plaid Link view controller
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

        // Show list of bank accounts
        BankObject *bank = [[BankObject alloc] initWithAccessToken:results[@"access_token"]];

        [self dismissViewControllerAnimated:YES completion:^{
            [self performSegueWithIdentifier:@"AddAccountSegue" sender:bank];
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
#pragma mark - Private methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@end
