//
//  NSDate+DateByAddingDays.m
//  Balance
//
//  Created by Chris Nolet on 4/22/16.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import "NSDate+DateByAddingDays.h"

@implementation NSDate (DateByAddingDays)

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate *)dateByAddingDays:(NSInteger)days
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                   fromDate:[NSDate date]];
    dateComponents.day += days;

    return [calendar dateFromComponents:dateComponents];
}

@end
