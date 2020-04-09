//
//  CTMacro.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#ifndef CTMacro_h
#define CTMacro_h

#define kScreen_Height   ([UIScreen mainScreen].bounds.size.height)
#define kScreen_Width    ([UIScreen mainScreen].bounds.size.width)
#define KScreen_Scale    ([UIScreen mainScreen].scale)
#define kStatusBar_Height ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define kNavBar_Height ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 88 : 64)
#define kTabBar_Height ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 83 : 49)
#define kSafeAreaInsetBottom ([[UIApplication sharedApplication] statusBarFrame].size.height > 20 ? 34 : 0)

//RGB color macro with alpha
#define UIColorFromHEX(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 blue:((float)(rgbValue & 0xFF)) / 255.0 alpha:1.0]
#define UIColorFromHEXWithAlpha(rgbValue, a) [UIColor           \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0    \
blue:((float)(rgbValue & 0xFF)) / 255.0             \
alpha:a]

#define kDEFAULTNOTIFICATION [NSNotificationCenter defaultCenter]
#define kSHAREDAPPLICATION [UIApplication sharedApplication]
#define kAPPDELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)
#define ImageNamed(fp) [UIImage imageNamed:fp]
#define kSystemFont(f) [UIFont systemFontOfSize:f]

// keyWindow
#define kKeyWindow     [UIApplication sharedApplication].keyWindow

#define isiPad [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad

#define HUD_MESSAGE_SHOWTIME 1.6f

#define VIEW_SHOW_ANIMATE_TIME 0.4f

#define kDefaultNavigationBarHeight 64 //navigation bar高度

#define kStandardUserDefaults [NSUserDefaults standardUserDefaults]

#ifdef DEBUG
#define ZLLog(formatString,...)  fprintf(stderr,"%s:%d\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:formatString, ##__VA_ARGS__] UTF8String]);

#else
# define ZLLog(...);
#endif

#define LogError(x) [CTLogger errorWithLog:x]

/*****************数据类型判断*******************/
//字符串为空判断
#define kIsEmptyString(s)       (s == nil || [s isKindOfClass:[NSNull class]] || ([s isKindOfClass:[NSString class]] && s.length == 0))
//对象为空判断
#define kIsEmptyObject(obj)     (obj == nil || [obj isKindOfClass:[NSNull class]])
//数组类型判断
#define kIsArray(objArray)      (objArray != nil && [objArray isKindOfClass:[NSArray class]])

#define kSelfWeak     __weak typeof(self) weakSelf = self


#define kAvailableiOS11 @available(iOS 11.0, *)
#define kAvailableiOS13 @available(iOS 13.0, *)


#endif /* CTMacro_h */
