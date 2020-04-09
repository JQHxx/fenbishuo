//
//  CTFVideoGuideVIew.h
//  ChalkTalks
//
//  Created by vision on 2020/3/24.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTFConfigsModel.h"

typedef void(^CloseActionBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface CTFVideoGuideView : UIView

@property (nonatomic ,copy ) CloseActionBlock closeBlock;
@property (nonatomic ,strong) CTFGuideVideoModel *videoModel;

@end

NS_ASSUME_NONNULL_END
