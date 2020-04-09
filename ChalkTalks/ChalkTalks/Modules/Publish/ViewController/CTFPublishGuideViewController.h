//
//  CTFPublishGuideViewController.h
//  ChalkTalks
//
//  Created by vision on 2020/3/21.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTFConfigsModel.h"

typedef void(^PublishGuideDismissBlock)(NSInteger viewTag);

NS_ASSUME_NONNULL_BEGIN

@interface CTFPublishGuideViewController : UIViewController

@property (nonatomic,strong) CTFGuideVideoModel *guideVideo;
@property (nonatomic, copy ) PublishGuideDismissBlock dismissBlock;


@end

NS_ASSUME_NONNULL_END
