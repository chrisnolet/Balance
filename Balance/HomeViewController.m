//
//  HomeViewController.m
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "HomeViewController.h"
#import "Adapter.h"
#import "BankObject.h"

@interface HomeViewController ()

@property (strong, nonatomic) NSArray *items;

- (void)applicationDidBecomeActive:(NSNotification *)notification;

@end

@implementation HomeViewController

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Refresh when re-opened
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UITableViewDataSource

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
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
#pragma mark - PLDLinkNavigationControllerDelegate

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)linkNavigationContoller:(PLDLinkNavigationViewController *)navigationController
       didFinishWithAccessToken:(NSString *)publicToken
{
    [self dismissViewControllerAnimated:YES completion:nil];

    [[Adapter sharedInstance] postToEndpoint:@"exchange_token"
                                  parameters:@{ @"public_token": publicToken }
                                  completion:^(NSDictionary *results, NSError *error) {

        // Add new bank details
        //BankObject *bank = [[BankObject alloc] initWithAccessToken:accessToken];
        //[bank update];
    }];

    NSLog(@"Public Token: %@", publicToken);
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
- (IBAction)addBarButtonItemPressed:(id)sender
{
    // Show the Plaid Link modal
    PLDLinkNavigationViewController *plaidLink = [[PLDLinkNavigationViewController alloc]
                                                  initWithEnvironment:PlaidEnvironmentTartan
                                                  product:PlaidProductConnect];

    plaidLink.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    plaidLink.linkDelegate = self;

    [self presentViewController:plaidLink animated:YES completion:nil];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self.tableView reloadData];
}

@end
