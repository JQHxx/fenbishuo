//
//  CTFMoreHandleView.h
//  ChalkTalks
//
//  Created by vision on 2020/2/22.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTFCommentModel.h"

typedef void(^HandleBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface CTFMoreHandleView : UIView

+(void)showMoreHandleViewWithFrame:(CGRect)frame isAuthor:(BOOL )isAuthor isReply:(BOOL)isReply handle:(HandleBlock)handle;

@end

NS_ASSUME_NONNULL_END
