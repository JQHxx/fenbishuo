//
//  CTFAnswerDetailCell.h
//  ChalkTalks
//
//  Created by vision on 2020/1/9.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTBaseCard.h"

@class CTFAnswerDetailCell;
@protocol CTFAnswerDetailCellDelegate <NSObject>

//播放视频
-(void)answerDetailCell:(CTFAnswerDetailCell *)answerDetailCell playTheVideoAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CTFAnswerDetailCell : CTBaseCard

- (void)setDelegate:(id<CTFAnswerDetailCellDelegate>)delegate withIndexPath:(NSIndexPath *)indexPath;

-(void)stopAuido;

@end

