//
//  CTFVoteListCell.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/1/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTBaseCard.h"
@class CTFVoteListCell;

NS_ASSUME_NONNULL_BEGIN

@protocol CTFVoteListCellDelegate <NSObject>
- (void)tableViewCell:(CTFVoteListCell *)cell touchedSkipQuestionDetailId:(NSInteger)questionId;
@end

@interface CTFVoteListCell : CTBaseCard

@property (nonatomic, weak) id<CTFVoteListCellDelegate> delegate;

- (void)fillContentWithData:(CTFQuestionsModel *)questionsModel indexNum:(NSInteger)indexNum sortType:(NSString *)sort;


@end

NS_ASSUME_NONNULL_END
