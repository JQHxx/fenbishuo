//
//  CTFBlockButton+Event.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/13.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFBlockButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFBlockButton (Event)

//为按钮添加点击间隔 eventTimeInterval秒
@property (nonatomic, assign) NSTimeInterval eventTimeInterval;

@end

NS_ASSUME_NONNULL_END
