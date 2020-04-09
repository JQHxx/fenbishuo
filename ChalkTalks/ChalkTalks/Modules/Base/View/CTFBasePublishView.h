//
//  CTFBasePublishView.h
//  ChalkTalks
//
//  Created by vision on 2020/2/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^PubulishClickBlock)(NSInteger tag);

@interface CTFBasePublishView : UIView

@property (nonatomic , copy ) PubulishClickBlock clickBlock;

- (instancetype)initWithFrame:(CGRect)frame desc:(NSString *)desc image:(NSString *)image;


@end

NS_ASSUME_NONNULL_END
