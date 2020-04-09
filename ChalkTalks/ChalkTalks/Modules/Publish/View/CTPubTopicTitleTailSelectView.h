//
//  CTPubTopicTitleTailSelectView.h
//  ChalkTalks
//
//  Created by zingwin on 2020/1/13.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTFConfigsModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface CTPubTopicTitleTailSelectView : UIView
+ (void)showTopicTitleTailSelectView:(NSArray <CTFSuffixModel *> *)titleList
                            selSuffix:(CTFSuffixModel *)selSuffix
                        dismissBlock:(void (^) (void)) dismissBlock
                  didSelectedHandler:(void (^) (CTFSuffixModel *suffix)) didSelectedHandler;
@end

NS_ASSUME_NONNULL_END
