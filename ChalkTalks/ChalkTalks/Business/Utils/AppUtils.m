//
//  AppUtils.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "AppUtils.h"
#import "UserCache.h"
#import "NSArray+Safety.h"

@implementation AppUtils

+ (NSString *)getFullPath:(NSString *)fileName {
    NSArray  *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentPaths objectAtIndex:0];
    return [documentDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)getDatabasePath {
    NSString *dbPath = @"";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    dbPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"ty.db"]];
    return dbPath;
}

+ (NSString *)getDocumentPath {
    static NSString *docPath = @"";
    if ([docPath length] <= 0) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        docPath = [[paths objectAtIndex:0] copy];
    }
    return docPath;
}

+ (NSString *)getCachePath {
    static NSString *cachePath = @"";
    if ([cachePath length] <= 0) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        cachePath = [[paths objectAtIndex:0] copy];
    }
    return cachePath;
}

+ (NSString *)currentUserCahcePath {
    NSString *doc = [[self class] getDocumentPath];
    NSString *uid = [UserCache getCurrentUserID];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [NSString stringWithFormat:@"%@/%@",doc, uid];
    if (![fm fileExistsAtPath:path]) {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}

+ (BOOL)isFileExists:(NSString *)file {
    NSFileManager *fm = [NSFileManager defaultManager];
    return [fm fileExistsAtPath:file];
}

+ (void)deleteFileAtPath:(NSString *)filePath {
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([[self class] isFileExists:filePath]) {
        [fm removeItemAtPath:filePath error:nil];
    }
}
#pragma mark - date
+ (NSString *)convertNSDateToHHMM:(NSDate *)date {
    if (!date) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    
    // change from NSString to NSDate
    [dateFormatter setDateFormat:@"HH:mm"];//yyyy-MM-dd HH:mm:ss
    NSString *retString = [NSString stringWithString:[dateFormatter stringFromDate:date]];
    return retString;
}

+ (NSString *)convertNSDateToYYYYMMDD:(NSDate *)date {
    if (!date) {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    
    // change from NSString to NSDate
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];//yyyy-MM-dd HH:mm:ss
    NSString *retString = [NSString stringWithString:[dateFormatter stringFromDate:date]];
    return retString;
}

+ (NSString *)convertNSDateToYYYYMMDDHHMMSS:(NSDate *)date {
    if (!date) {
        return nil;
    }
    //书的解压密码，必须使用东八区时间转化
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setLocale:[NSLocale systemLocale]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    //dateFormatter.timeZone = [NSTimeZone systemTimeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *retString = [NSString stringWithString:[dateFormatter stringFromDate:date]];
    return retString;
}

+ (NSDate *)convertYYYYMMDDHHMMSSToDate:(NSString *)datestr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale systemLocale]];
    
    // change from NSString to NSDate
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];//yyyy-MM-dd HH:mm:ss
    return  [dateFormatter dateFromString:datestr];
}
+ (NSString *)convertNSDateToChinaFormat:(NSDate *)date {
    NSString *dateString = [AppUtils convertNSDateToYYYYMMDD:date];
    NSArray *date_str1 = [dateString componentsSeparatedByString:@" "];
    NSArray *date_str2 = [(NSString *)[date_str1 safe_objectAtIndex:0] componentsSeparatedByString:@"-"];
    NSString *retString = [NSString stringWithFormat:@"%@年%@月%@日", [date_str2 safe_objectAtIndex:0], [date_str2 safe_objectAtIndex:1], [date_str2 safe_objectAtIndex:2]];
    return retString;
}

+ (NSString *)readCountUnitString:(NSInteger)count {
    if (count<=10000) {
        return [NSString stringWithFormat:@"%zd", count];
    } else if (count<=99999999) {
        return [NSString stringWithFormat:@"%.1f万", count/10000.0f];
    } else {
        return [NSString stringWithFormat:@"%.1f亿", count/100000000.0f];
    }
}

+ (NSString *)countToString:(NSInteger)count {
    if(count < 0) {
        return @"0";
    } else if (count <= 999) {
        return [NSString stringWithFormat:@"%zd", count];
    } else {
        double kk = count / 1000.0;
        return [NSString stringWithFormat:@"%.1fk", kk];
    }
}

+ (NSString *)IDFA {
//    if([[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]){
//        NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//        return idfa;
//    }
    return nil;
}

// 拨打电话
+ (void)callPhoneWithNumber:(NSString *)telephoneNumber {
    if (telephoneNumber.length == 0) {
        return;
    }
    NSString *callPhone = [NSString stringWithFormat:@"telprompt://%@", telephoneNumber];
    /// 大于等于10.0系统使用此openURL方法
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:callPhone] options:@{} completionHandler:nil];
}

+ (NSString *)imgUrlForGrid:(NSString *)ourl {
    if (ourl) {
        return [NSString stringWithFormat:@"%@/s", ourl];
    }
    return nil;
}

+ (NSString *)imgUrlForGridSingle:(NSString *)ourl {
    if (ourl) {
        return [NSString stringWithFormat:@"%@/w400", ourl];
    }
    return nil;
}

+ (NSString *)imgUrlForBrowse:(NSString *)ourl {
    if (ourl) {
          return [NSString stringWithFormat:@"%@/r", ourl];
      }
      return nil;
}

+ (NSString *)imgUrlForVideoCover:(NSString *)ourl {
    if (ourl) {
          return [NSString stringWithFormat:@"%@/l", ourl];
      }
      return nil;
}

+ (NSString *)imgUrlForAvater:(NSString *)ourl {
    if (ourl) {
        return [NSString stringWithFormat:@"%@/m", ourl];
    }
    return nil;
}
+ (NSString *)imgUrlForBigAvater:(NSString *)ourl {
    if (ourl) {
        return [NSString stringWithFormat:@"%@/b", ourl];
    }
    return nil;
}

@end
