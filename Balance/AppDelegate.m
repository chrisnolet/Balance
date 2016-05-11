//
//  AppDelegate.m
//  Balance
//
//  Created by Chris Nolet on 4/21/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import <Plaid.h>
#import "AppDelegate.h"
#import "Adapter.h"

@implementation AppDelegate

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - UIApplicationDelegate

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Set up API adapter
    [Adapter sharedInstance].baseURL = kPlaidBaseURL;

    [Adapter sharedInstance].defaultParameters = @{
        @"client_id": kPlaidClientId,
        @"secret": kPlaidSecret
    };

    // Initialize Plaid
    [Plaid sharedInstance].publicKey = kPlaidPublicKey;

    // Remove shadow under navigation bar
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [UINavigationBar appearance].shadowImage = [[UIImage alloc] init];

    return YES;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

@end
