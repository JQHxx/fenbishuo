//
//  CTFNewCareEventView.h
//  ChalkTalks
//
//  Created by vision on 2020/1/17.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTFQuestionsModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFNewCareEventView : UIView

@property (nonatomic,assign) BOOL btnDisabled;

-(void)fillCareEventWithModel:(CTFQuestionsModel *)model indexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
