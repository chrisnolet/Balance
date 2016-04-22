//
//  UIAlertView+Error.h
//  Balance
//
//  Created by Chris Nolet on 6/7/15.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (Error)

+ (UIAlertView *)alertViewWithError:(NSError *)error;
+ (UIAlertView *)alertViewWithErrorMessage:(NSString *)message;

@end
