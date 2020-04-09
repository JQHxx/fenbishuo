//
//  CTFAnswerDetailUserInfoView.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIResponder+Event.h"
#import <Masonry/Masonry.h>
#import "NSURL+Ext.h"
#import "UIImageView+CTWebImage.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFAnswerDetailUserInfoView : UIView

-(void)fillContentWithData:(AnswerModel*)model indexPath:(NSIndexPath*)indexPath;

@end

NS_ASSUME_NONNULL_END
