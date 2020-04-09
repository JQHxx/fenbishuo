//
//  CTFAudioCollectionViewCell.h
//  ChalkTalks
//
//  Created by vision on 2020/1/14.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTFAudioPlayView.h"
#import "AnswersModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFAudioCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) CTFAudioPlayView *playView;

+(NSString*)identifier;

-(void)displayCellWithModel:(AudioImageModel *)model;

@end

NS_ASSUME_NONNULL_END
