//
//  UIAlertView+Error.m
//  Balance
//
//  Created by Chris Nolet on 6/7/15.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "UIAlertView+Error.h"

@implementation UIAlertView (Error)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIAlertView *)alertViewWithError:(NSError *)error
{
    return [self alertViewWithErrorMessage:[error localizedDescription]];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (UIAlertView *)alertViewWithErrorMessage:(NSString *)message
{
    NSArray *messages = @[ message ?: @"An error occured.", @"Please try again later." ];

    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:[messages componentsJoinedByString:@" "]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];

    return alertView;
}

@end
