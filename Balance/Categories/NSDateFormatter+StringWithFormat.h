//
//  NSDateFormatter+StringWithFormat.h
//  Balance
//
//  Created by Chris Nolet on 6/2/15.
//  Copyright © 2016 Relaunch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSDateFormatter (StringWithFormat)

+ (NSString *)stringFromDate:(NSDate *)date dateFormat:(NSString *)dateFormat;

@end
