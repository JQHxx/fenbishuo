//
//  NSObject+Permission.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/6.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Permission)

/// 类别  判断是否有相册访问权限
/// @param completeBlock cb
+ (void)haveAlbumAccess:(void(^)(BOOL isAuth))completeBlock;


/// NSObject 判断是否有相机访问权限
/// @param completeBlock cb
+ (void)haveCameraAccess:(void(^)(BOOL isAuth))completeBlock;

@end

NS_ASSUME_NONNULL_END
