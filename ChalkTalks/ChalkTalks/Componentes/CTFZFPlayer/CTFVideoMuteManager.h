//
//  CTFVideoMuteManager.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/16.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 在列表状态，声音控制

@interface CTFVideoMuteManager : NSObject
+ (instancetype)sharedInstance;


/// YES: 静音  NO: 开启声音
-(BOOL)getAudoMuteInFeed;
-(void)setAudoMuteInFeed:(BOOL)isMute;
@end

NS_ASSUME_NONNULL_END
