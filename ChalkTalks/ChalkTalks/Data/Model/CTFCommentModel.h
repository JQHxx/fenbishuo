//
//  CTFCommentModel.h
//  ChalkTalks
//
//  Created by vision on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface CTFCommentModel : BaseModel

@property (nonatomic , assign) NSInteger     commentId;
@property (nonatomic , copy )  NSString      *content;
@property (nonatomic , assign) NSInteger     voteupCount;
@property (nonatomic , copy )  NSString      *attitude;
@property (nonatomic , strong) Author        *author;
@property (nonatomic , assign) long          createdAt;
@property (nonatomic , assign) BOOL          isAuthor;
@property (nonatomic , assign) BOOL          showMore;
@property (nonatomic , assign) BOOL          isDeleted;
@property (nonatomic , assign) NSInteger     childCommentsCount;  //子评论的总数
@property (nonatomic ,  copy ) NSArray<CTFCommentModel *> *childComments;   //最新 不超过4 个的子评论
@property (nonatomic , strong) Author        *replyToAuthor;
@property (nonatomic , assign) BOOL          isExpanded;  //是否展开
@property (nonatomic , assign) CGFloat       avatarHeight;
@property (nonatomic , assign) BOOL          isReply;  //是否回复
@property (nonatomic , assign) BOOL          isLocal; 

@end

NS_ASSUME_NONNULL_END
