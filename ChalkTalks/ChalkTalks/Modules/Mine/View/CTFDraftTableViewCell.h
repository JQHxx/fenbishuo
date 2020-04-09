//
//  CTFDraftTableViewCell.h
//  ChalkTalks
//
//  Created by vision on 2020/3/5.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTBaseCard.h"

@class CTDraftAnswer;

NS_ASSUME_NONNULL_BEGIN

@interface CTFDraftTableViewCell :CTBaseCard

@property(nonatomic, copy) void (^ _Nonnull didDeleteDraftAnswer)(CTDraftAnswer *model);
@property(nonatomic, copy) void (^ _Nonnull didSelectedDraftAnswer)(CTDraftAnswer *model);

@end

NS_ASSUME_NONNULL_END
