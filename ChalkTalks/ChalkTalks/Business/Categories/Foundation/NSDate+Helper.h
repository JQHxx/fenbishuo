//
//  NSDate+Helper.h
//  StarryNight
//
//  Created by zingwin on 2017/3/17.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Helper)
+ (void)initializeStatics;

+ (NSCalendar *)sharedCalendar;
+ (NSDateFormatter *)sharedDateFormatter;
- (NSUInteger)daysAgo;
- (NSUInteger)daysAgoAgainstMidnight;
- (NSString *)stringDaysAgo;
- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag;
- (NSUInteger)weekday;
- (NSUInteger)weekNumber;
- (NSUInteger)hour;
- (NSUInteger)minute;
- (NSUInteger)second;
- (NSUInteger)day;
- (NSUInteger)month;
- (NSUInteger)year;
- (long int)utcTimeStamp; //full seconds since
+ (NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;
+ (NSString *)stringFromDate:(NSDate *)date withFormat:(NSString *)string;
+ (NSString *)stringFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed;
+ (NSString *)stringForDisplayFromDate:(NSDate *)date prefixed:(BOOL)prefixed alwaysDisplayTime:(BOOL)displayTime;
- (NSString *)string;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;
- (NSDate *)beginningOfWeek;
- (NSDate *)beginningOfDay;
- (NSDate *)endOfWeek;
+ (NSString *)dateFormatString;
+ (NSString *)timeFormatString;
+ (NSString *)timestampFormatString;
+ (NSString *)dbFormatString;

- (NSString*)chineseBabyAgeString;
- (NSInteger)getDifferenceByDate:(NSDate*)date;
@end