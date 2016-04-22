//
//  UIButton+ActivityIndicatorView.m
//  Balance
//
//  Created by Chris Nolet on 4/2/15.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "UIButton+ActivityIndicatorView.h"
#import <objc/runtime.h>

static void *ActivityIndicatorViewKey = &ActivityIndicatorViewKey;

@implementation UIButton (ActivityIndicatorView)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)startAnimating
{
    // Add activity indicator to button
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc]
                                                      initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.center = self.titleLabel.center;
    [activityIndicatorView startAnimating];

    [self addSubview:activityIndicatorView];

    // Disable button and hide text
    [self setTitle:@"" forState:UIControlStateDisabled];
    self.enabled = NO;

    // Save reference to the activity indicator
    objc_setAssociatedObject(self, ActivityIndicatorViewKey, activityIndicatorView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopAnimating
{
    // Remove activity indicator
    UIActivityIndicatorView *activityIndicatorView = objc_getAssociatedObject(self, ActivityIndicatorViewKey);

    [activityIndicatorView removeFromSuperview];

    // Re-enable button and show text
    self.enabled = YES;
}

@end
