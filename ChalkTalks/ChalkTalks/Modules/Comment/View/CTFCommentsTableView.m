//
//  CTFCommentsTableView.m
//  ChalkTalks
//
//  Created by vision on 2020/2/21.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFCommentsTableView.h"
#import "CTFViewpointTableViewCell.h"
#import "UIResponder+Event.h"
#import "CTFCommentDetailsVC.h"

@interface CTFCommentsTableView ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSMutableArray *subCommentsArray;
@property (nonatomic,assign) NSInteger subCommentCount;
@property (nonatomic,assign) BOOL      isOpen;

@end

@implementation CTFCommentsTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    self = [super initWithFrame:frame style:style];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.delegate = self;
        self.dataSource = self;
        self.scrollEnabled = NO;
        self.showsVerticalScrollIndicator = NO;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableFooterView = [[UIView alloc] init];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.subCommentsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"CTFViewpointTableViewCell";
    CTFViewpointTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell = [[CTFViewpointTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.lineLeft = self.lineLeft;
    CTFCommentModel *model = self.subCommentsArray[indexPath.row];
    model.isReply = YES;
    [cell fillCommentData:model];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CTFCommentModel *model = self.subCommentsArray[indexPath.row];
    return [CTFViewpointTableViewCell getCommentCellHeight:model isSubComment:self.isSubComment];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (self.isSubComment&&self.subCommentsArray.count>0&&!self.isOpen&&self.subCommentCount>2) {
        NSInteger count = 0;
        for (NSInteger i = 0; i<self.subCommentsArray.count; i++) {
            CTFCommentModel *model = self.subCommentsArray[i];
            if (model.isLocal) {
                count ++;
            }
        }
        if (self.subCommentCount - count > 2 ) {
            UIView *aView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, 44)];
            aView.backgroundColor = [UIColor whiteColor];
            
            UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(44, 7, self.width-20, 30)];
            lab.font = [UIFont mediumFontWithSize:14];
            lab.textColor = [UIColor ctMainColor];
            lab.text = self.subCommentCount>4?[NSString stringWithFormat:@"查看全部%ld条回复",self.subCommentCount]:[NSString stringWithFormat:@"展开其他%ld条回复",self.subCommentCount - self.subCommentsArray.count];
            [lab addTapPressed:@selector(checkCommentDetailsAction) target:self];
            [aView addSubview:lab];
            
            return aView;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.isSubComment&&self.subCommentsArray.count>0&&!self.isOpen&&self.subCommentCount>2) {
        if (self.subCommentCount == self.subCommentsArray.count ) {
            return 0;
        } else {
            return 44;
        }
    } else {
        return 0;
    }
}

#pragma mark -- Event response
#pragma mark 查看详情
- (void)checkCommentDetailsAction{
    if (self.subCommentCount>4) {
        CTFCommentDetailsVC *commentVC = [[CTFCommentDetailsVC alloc] init];
        commentVC.model = self.commentModel;
        commentVC.answerId = self.answerId;
        commentVC.commentCount = self.commentCount;
        [self.findViewController.navigationController pushViewController:commentVC animated:YES];
    } else{
        if ([self.viewDelegate respondsToSelector:@selector(commentsTableViewSetCellExpand)]) {
            [self.viewDelegate commentsTableViewSetCellExpand];
        }
    }
}

#pragma mark -- Setters
#pragma mark 填充数据
- (void)setCommentModel:(CTFCommentModel *)commentModel{
    _commentModel = commentModel;
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    if (_commentModel.isExpanded) {
        [tempArr addObjectsFromArray:_commentModel.childComments];
    } else {
        if (self.isSubComment && _commentModel.childComments.count>2) {
            NSInteger count = 0;
            for (NSInteger i = 0; i<_commentModel.childComments.count; i++) {
                CTFCommentModel *model = _commentModel.childComments[i];
                if (model.isLocal) {
                    count ++;
                }
            }
            NSInteger tempCount = self.commentModel.childComments.count - count;
            NSInteger totalCount = tempCount > 2 ? (2 + count):(tempCount + count);
            for (NSInteger i = 0; i < totalCount; i++) {
                CTFCommentModel *model = _commentModel.childComments[i];
                [tempArr addObject:model];
            }
        } else {
            [tempArr addObjectsFromArray:_commentModel.childComments];
        }
    }
    
    self.subCommentsArray = tempArr;
    self.subCommentCount = _commentModel.childCommentsCount;
    self.isOpen = _commentModel.isExpanded;
    [self reloadData];
}

- (void)setIsSubComment:(BOOL)isSubComment{
    _isSubComment = isSubComment;
}

- (NSMutableArray<CTFCommentModel *> *)subCommentsArray {
    if (!_subCommentsArray) {
        _subCommentsArray = [[NSMutableArray alloc] init];
    }
    return _subCommentsArray;
}

@end
