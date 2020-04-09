//
//  CTFMyAnswerCell.h
//  ChalkTalks
//
//  Created by vision on 2020/1/2.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTBaseCard.h"
#import "AnswersModel.h"

NS_ASSUME_NONNULL_BEGIN

@class CTFMyAnswerCell;
@protocol CTFMyAnswerCellDelegate <NSObject>

-(void)myAnswerCell:(CTFMyAnswerCell *)cell avcellPlayVideoAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CTFMyAnswerCell : CTBaseCard

- (void)setDelegate:(id<CTFMyAnswerCellDelegate>)delegate withIndexPath:(NSIndexPath *)indexPath;

-(void)showLoadingFailView;

-(void)stopAuido;

@end

NS_ASSUME_NONNULL_END
