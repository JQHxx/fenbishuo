//
//  CTFPublishGuideView.h
//  ChalkTalks
//
//  Created by vision on 2020/2/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <HWPanModal.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PublishGuideCloseBlock)(void);
typedef void(^PublishTopicBlock)(void);

@interface CTFPublishGuideView : UIView

@property (nonatomic, copy ) PublishGuideCloseBlock closeBlock;
@property (nonatomic, copy ) PublishTopicBlock publishBlock;

@end

NS_ASSUME_NONNULL_END
