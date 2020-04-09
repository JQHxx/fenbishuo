//
//  CTFMineOptionCell.h
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/3/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTBaseCard.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFMineOptionCell : CTBaseCard

- (void)fillDataWithTitleImageName:(NSString *)titleImage
                         titleName:(NSString *)titleName
                           message:(NSString *)message;

@end

NS_ASSUME_NONNULL_END
