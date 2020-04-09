//
//  CTFCommentView.h
//  ChalkTalks
//
//  Created by vision on 2020/2/20.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTFCommentModel.h"

@interface CTFCommentView : UIView

@property (nonatomic,assign) CGFloat lineLeft;

- (void)fillCommentData:(CTFCommentModel *)commentModel;

@end
