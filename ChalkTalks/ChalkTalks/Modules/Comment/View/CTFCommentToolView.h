//
//  CTFCommentToolView.h
//  ChalkTalks
//
//  Created by vision on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CTFInputToolViewTypeComment,
    CTFInputToolViewTypeAudioImage,
} CTFInputToolViewType;

typedef void(^SubmitCommentBlock)(NSString *content);
typedef void(^DismissBlock)(NSString *content);

@interface CTFCommentToolView : UIView


///显示评论输入框
///@param frame    输入框大小
///@param type      输入类型
///@param isAuthor  是否作者
///@param authorName  被评论人姓名
///@param content  评论内容
///@param submitBlock  提交回调
///@param dismissBlock 关闭回调
+ (void)showCommentInputViewWithFrame:(CGRect)frame
                                 type:(CTFInputToolViewType)type
                             isAuthor:(BOOL)isAuthor
                                 name:(NSString *)authorName
                              content:(NSString *)content
                               submit:(SubmitCommentBlock)submitBlock
                              dismiss:(DismissBlock)dismissBlock;

@end

