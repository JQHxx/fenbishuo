//
//  CTFCommentsTableView.h
//  ChalkTalks
//
//  Created by vision on 2020/2/21.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTFCommentModel.h"

@protocol CTFCommentsTableViewDelegate <NSObject>

//展开
- (void)commentsTableViewSetCellExpand;

@end

@interface CTFCommentsTableView : UITableView

@property (nonatomic, weak ) id<CTFCommentsTableViewDelegate>viewDelegate;
@property (nonatomic,assign) BOOL isSubComment;
@property (nonatomic,assign) NSInteger answerId;
@property (nonatomic,assign) CGFloat lineLeft;
@property (nonatomic,assign) CGFloat commentCount;
@property (nonatomic,strong) CTFCommentModel  *commentModel;

@end

