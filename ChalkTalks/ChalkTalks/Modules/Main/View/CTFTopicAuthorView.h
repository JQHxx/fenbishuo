//
//  CTFTopicAuthorView.h
//  ChalkTalks
//
//  Created by vision on 2020/2/27.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnswersModel.h"

/* 例如用在首页的cell中的“提要求+by+”的view */
@interface CTFTopicAuthorView : UIView

@property (nonatomic, assign) BOOL showAvatar;

//填充数据
- (void)fillDataWithType:(NSString *)type author:(AuthorModel *)author;

@end

