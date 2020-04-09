//
//  CTFFeedBackVC.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/18.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/* 产品逻辑记录：
 ||---反馈(push)
 ||---投诉(push)
 ||---举报(modal)
 ||------举报话题
 ||---------政治敏感、违法违规
 ||---------色情低俗、少儿不宜
 ||---------垃圾广告、售卖伪劣
 ||---------盗用广告、版权问题
 ||---------其他
 ||------举报回答
 ||---------政治敏感、违法违规
 ||---------色情低俗、少儿不宜
 ||---------垃圾广告、售卖伪劣
 ||---------盗用广告、版权问题
 ||---------其他
 ||------举报评论
 ||---------政治敏感、违法违规
 ||---------色情低俗、少儿不宜
 ||---------垃圾广告、售卖伪劣
 ||---------盗用广告、版权问题
 ||---------其他
 ||------举报回复
 ||---------政治敏感、违法违规
 ||---------色情低俗、少儿不宜
 ||---------垃圾广告、售卖伪劣
 ||---------盗用广告、版权问题
 ||---------其他
 */

typedef NS_ENUM(NSInteger, FeedBackType) {
    FeedBackType_FeedBack = 0,/* 反馈 */
    FeedBackType_Complain,    /* 投诉 */
    FeedBackType_Question,    /* 举报话题 */
    FeedBackType_Answer,      /* 举报回答 */
    FeedBackType_Comment,     /* 举报评论 */
    FeedBackType_Reply        /* 举报回复 */
};

typedef NS_ENUM(NSInteger, FeedBackContentType) {
    FeedBackContentType_Politics = 0,/* 政治敏感、违法违规 */
    FeedBackContentType_Sexy,        /* 色情低俗、少儿不宜 */
    FeedBackContentType_Garbage,     /* 垃圾广告、售卖伪劣 */
    FeedBackContentType_Copyright,   /* 盗用广告、版权问题 */
    FeedBackContentType_Other        /* 其他 */
};

/// 反馈
@interface CTFFeedBackVC : BaseViewController

- (instancetype)initWithFeedBackType:(FeedBackType)feedBackType
                 feedBackContentType:(FeedBackContentType)feedBackContentType
                      resourceTypeId:(NSInteger)resourceTypeId;

@end

NS_ASSUME_NONNULL_END
