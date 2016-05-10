//
//  NSDictionary+StringValue.m
//  Balance
//
//  Created by Chris Nolet on 5/8/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "NSDictionary+StringValue.h"

@implementation NSDictionary (StringValue)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString *)stringValue
{
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:0 error:nil];

    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
