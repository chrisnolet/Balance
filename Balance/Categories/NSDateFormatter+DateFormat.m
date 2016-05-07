//
//  NSDateFormatter+DateFormat.m
//  Balance
//
//  Created by Chris Nolet on 6/2/15.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "NSDateFormatter+DateFormat.h"

@implementation NSDateFormatter (DateFormat)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Class methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSString *)stringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;

    return [dateFormatter stringFromDate:date];
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate *)dateFromString:(NSString *)string dateFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = dateFormat;

    return [dateFormatter dateFromString:string];
}

@end
