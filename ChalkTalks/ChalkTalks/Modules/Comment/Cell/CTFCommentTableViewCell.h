//
//  CTFCommentTableViewCell.h
//  ChalkTalks
//
//  Created by vision on 2020/2/21.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTFCommentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFCommentTableViewCell : UITableViewCell

@property(nonatomic, copy) void (^ _Nonnull setCellExpandBlock)(void);

- (void)fillCommentData:(CTFCommentModel *)model
               answerId:(NSInteger )answerId
           commentCount:(NSInteger)commentCount;

+ (CGFloat)getCommentCellHeight:(CTFCommentModel *)model;

@end

NS_ASSUME_NONNULL_END
