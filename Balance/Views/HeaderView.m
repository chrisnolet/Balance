//
//  HeaderView.m
//  Balance
//
//  Created by Chris Nolet on 5/12/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "HeaderView.h"

@implementation HeaderView

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (instancetype)viewWithDefaultNib
{
    return [[[UINib nibWithNibName:@"HeaderView" bundle:nil] instantiateWithOwner:self options:nil] firstObject];
}

@end
