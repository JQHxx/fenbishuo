//
//  CTFCommentDetailsVC.h
//  ChalkTalks
//
//  Created by vision on 2020/2/21.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "BaseViewController.h"
#import "CTFCommentModel.h"

@interface CTFCommentDetailsVC : BaseViewController

@property (nonatomic,assign) NSInteger            answerId;
@property (nonatomic,assign) NSInteger            commentCount;
@property (nonatomic,strong) CTFCommentModel      *model;

@end

