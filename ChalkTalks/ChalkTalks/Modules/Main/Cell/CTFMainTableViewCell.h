//
//  CTFMainTableViewCell.h
//  ChalkTalks
//
//  Created by vision on 2020/1/7.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTBaseCard.h"

NS_ASSUME_NONNULL_BEGIN

@class CTFMainTableViewCell;
@protocol CTFMainTableViewCellDelegate <NSObject>

-(void)mainTableViewCell:(CTFMainTableViewCell *)cell avcellPlayVideoAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CTFMainTableViewCell : CTBaseCard

-(void)setDelegate:(id<CTFMainTableViewCellDelegate>)delegate withIndexPath:(NSIndexPath *)indexPath;

-(void)showLoadingFailView;

//停止播放音频
- (void)stopAuido;


@end

NS_ASSUME_NONNULL_END
