//
//  AppUtils.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppUtils : NSObject

+ (NSString *)getDocumentPath;
+ (NSString *)getCachePath;
+ (NSString *)currentUserCahcePath;//根据用户id生成对呀的文件夹
+ (void)deleteFileAtPath:(NSString *)filePath;

+ (NSString *)convertNSDateToYYYYMMDD:(NSDate *)date;
+ (NSString *)convertNSDateToYYYYMMDDHHMMSS:(NSDate *)date;
+ (NSString *)convertNSDateToChinaFormat:(NSDate *)date;
+ (NSDate *)convertYYYYMMDDHHMMSSToDate:(NSString *)datestr;
+ (NSString *)convertNSDateToHHMM:(NSDate *)date;

+ (NSString *)readCountUnitString:(NSInteger)count;
+ (NSString *)countToString:(NSInteger)count;
+ (NSString *)IDFA;

/// 拨打电话
+ (void)callPhoneWithNumber:(NSString *)telephoneNumber;


/// 把后台返回的图片url 转为九宫格显示的小图
/// @param ourl  原始url
+ (NSString *)imgUrlForGrid:(NSString *)ourl;

/// 把后台返回的图片url 转为九宫格 单图使用
/// @param ourl  原始url
+ (NSString *)imgUrlForGridSingle:(NSString *)ourl;

/// 把后台返回的图片url 转为带水印的原图
/// @param ourl  原始url
+ (NSString *)imgUrlForBrowse:(NSString *)ourl;

/// 把后台返回的图片url 转为视频封面图
/// @param ourl  原始url
+ (NSString *)imgUrlForVideoCover:(NSString *)ourl;

/// 把后台返回的图片url 转用户头像小图
/// @param ourl  原始url
+ (NSString *)imgUrlForAvater:(NSString *)ourl;

/// 把后台返回的图片url 转用户头像大图
/// @param ourl  原始url
+ (NSString *)imgUrlForBigAvater:(NSString *)ourl;

@end
