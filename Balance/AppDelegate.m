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
    // Initialize Plaid
    [Plaid sharedInstance].publicKey = kPlaidPublicKey;

    // Set up API adapter
    [Adapter sharedInstance].baseURL = kPlaidBaseURL;

    [Adapter sharedInstance].defaultParameters = @{
        @"client_id": kPlaidClientId,
        @"secret": kPlaidSecret
    };

    return YES;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

@end
