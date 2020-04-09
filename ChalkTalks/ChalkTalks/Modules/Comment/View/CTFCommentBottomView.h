//
//  CTFCommentBottomView.h
//  ChalkTalks
//
//  Created by vision on 2019/12/24.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CommentBottomHanleBlock)(NSInteger index);

@interface CTFCommentBottomView : UIView

@property (nonatomic, copy ) NSString *content;
@property (nonatomic, copy ) CommentBottomHanleBlock  handleBlock;

@end

