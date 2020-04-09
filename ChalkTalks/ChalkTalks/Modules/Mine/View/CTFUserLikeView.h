//
//  CTFUserLikeView.h
//  ChalkTalks
//
//  Created by vision on 2019/12/31.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ViewDismissBlock)(void);

@interface CTFUserLikeView : UIView

+(void)showUserLikeViewWithFrame:(CGRect)frame isMine:(BOOL)isMine name:(NSString *)name like:(NSInteger)likeCount dismiss:(ViewDismissBlock)dismiss;

@end

NS_ASSUME_NONNULL_END
