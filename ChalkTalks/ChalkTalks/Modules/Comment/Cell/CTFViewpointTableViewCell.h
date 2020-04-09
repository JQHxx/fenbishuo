//
//  CTFViewpointTableViewCell.h
//  ChalkTalks
//
//  Created by vision on 2020/2/20.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTFCommentModel.h"

@interface CTFViewpointTableViewCell : UITableViewCell

@property (nonatomic,assign) CGFloat lineLeft;

- (void)fillCommentData:(CTFCommentModel *)model ;

+ (CGFloat)getCommentCellHeight:(CTFCommentModel *)model isSubComment:(BOOL)isSubComment;


@end
