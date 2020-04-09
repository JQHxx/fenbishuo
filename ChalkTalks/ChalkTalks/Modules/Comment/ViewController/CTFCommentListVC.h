//
//  CTFCommentListVC.h
//  ChalkTalks
//
//  Created by vision on 2020/3/24.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^CommentDismissCallBack)(BOOL needReload, NSInteger commentCount);

NS_ASSUME_NONNULL_BEGIN

@interface CTFCommentListVC : BaseViewController

@property (nonatomic,assign) NSInteger    answerId;
@property (nonatomic, copy ) NSString     *name;
@property (nonatomic, copy ) CommentDismissCallBack dismissCallBack;


@end

NS_ASSUME_NONNULL_END
