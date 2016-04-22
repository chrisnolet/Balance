//
//  NSDateFormatter+StringWithFormat.m
//  Balance
//
//  Created by Chris Nolet on 6/2/15.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "NSDateFormatter+StringWithFormat.h"

@implementation NSDateFormatter (StringWithFormat)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)stringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;

    return [dateFormatter stringFromDate:date];
}

@end
