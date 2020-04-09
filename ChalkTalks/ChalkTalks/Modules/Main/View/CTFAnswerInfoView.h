//
//  CTFAnswerInfoView.h
//  ChalkTalks
//
//  Created by vision on 2020/2/27.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/* 例如用在首页的cell中的“头像+昵称+阅读量”的view */
@interface CTFAnswerInfoView : UIView

@property (nonatomic,assign) BOOL  clickDisable;

- (void)fillDataWithAuthor:(AuthorModel *)author viewCount:(NSInteger)viewCount;

@end

NS_ASSUME_NONNULL_END
