//
//  CTFCommentTableViewCell.m
//  ChalkTalks
//
//  Created by vision on 2020/2/21.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFCommentTableViewCell.h"
#import "CTFCommentsTableView.h"
#import "CTFCommentView.h"
#import "UIResponder+Event.h"
#import "NSString+Size.h"

@interface CTFCommentTableViewCell ()<CTFCommentsTableViewDelegate>

@property (nonatomic,strong) CTFCommentView        *mainCommentView;
@property (nonatomic,strong) CTFCommentsTableView  *subCommentView;
@property (nonatomic,strong) UIView                *lineView;
@property (nonatomic,strong) CTFCommentModel       *commentModel;

@end

@implementation CTFCommentTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.mainCommentView];
        [self.contentView addSubview:self.subCommentView];
        [self.contentView addSubview:self.lineView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    NSString *content = self.commentModel.isDeleted?@"该评论已删除":self.commentModel.content;
    CGFloat contentH = [content boundingRectWithSize:CGSizeMake(kScreen_Width-72, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:15]].height;
    self.mainCommentView.frame = CGRectMake(0, 0, kScreen_Width, contentH+73);
    
    if (self.commentModel.childComments.count>0) {
        CGFloat childCommentH = 0;
        if (self.commentModel.isExpanded) { //子评论展开
            for (CTFCommentModel *model in self.commentModel.childComments) {
                NSString *tempContent = model.isDeleted?@"该评论已删除":model.content;
                CGFloat tempH = [tempContent boundingRectWithSize:CGSizeMake(kScreen_Width-100, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:15]].height;
                childCommentH += tempH+73;
            }
        } else {
            NSInteger tempCount = 0;
            for (CTFCommentModel *model in self.commentModel.childComments) {
                if (model.isLocal) {
                    tempCount ++ ;
                }
            }
            NSInteger tempCount1 = self.commentModel.childComments.count - tempCount;
            NSInteger totalCount = tempCount1 > 2 ? (2 + tempCount):(tempCount1 + tempCount);
            for (NSInteger i=0; i< totalCount; i++) {
                CTFCommentModel *model = [self.commentModel.childComments safe_objectAtIndex:i];
                NSString *tempContent = model.isDeleted?@"该评论已删除":model.content;
                CGFloat tempH = [tempContent boundingRectWithSize:CGSizeMake(kScreen_Width-100, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:15]].height;
                childCommentH += tempH+73;
            }
            
            if (self.commentModel.childCommentsCount - tempCount > 2) {
                childCommentH += 44;
            }
        }
        self.subCommentView.frame = CGRectMake(40, self.mainCommentView.bottom, kScreen_Width-40, childCommentH);
        self.lineView.frame = CGRectMake(0, self.subCommentView.bottom-1, kScreen_Width, 1);
    } else {
        self.subCommentView.frame = CGRectZero;
        self.lineView.frame = CGRectZero;
    }
}

#pragma mark -- Public Methods
#pragma mark 填充数据
- (void)fillCommentData:(CTFCommentModel *)model answerId:(NSInteger)answerId commentCount:(NSInteger)commentCount{
    self.commentModel = model;
    self.commentModel.avatarHeight = 33;
    [self.mainCommentView fillCommentData:self.commentModel] ;
    if (self.commentModel.childComments.count>0) {
        for (CTFCommentModel *model in self.commentModel.childComments) {
            model.avatarHeight = 20;
        }
        self.mainCommentView.lineLeft = 60;
        self.subCommentView.commentModel = self.commentModel;
        self.subCommentView.lineLeft = 44;
        self.subCommentView.answerId = answerId;
        self.subCommentView.commentCount = commentCount;
    } else {
        self.mainCommentView.lineLeft = 0;
        self.subCommentView.commentModel = [[CTFCommentModel alloc] init];
        self.subCommentView.lineLeft = 0;
    }
}

#pragma mark 计算高度
+ (CGFloat)getCommentCellHeight:(CTFCommentModel *)model{
    NSString *content = model.isDeleted?@"该评论已删除":model.content;
    CGFloat contentH = [content boundingRectWithSize:CGSizeMake(kScreen_Width-72, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:15]].height;
    CGFloat childCommentH = 0;
    if (model.childComments.count>0) {
        if (model.isExpanded) { //子评论展开
            for (CTFCommentModel *aModel in model.childComments) {
                NSString *tempContent = aModel.isDeleted?@"该评论已删除":aModel.content;
                CGFloat tempH = [tempContent boundingRectWithSize:CGSizeMake(kScreen_Width-100, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:15]].height;
                childCommentH += tempH+73;
            }
        } else {
            NSInteger tempCount = 0;
            for (CTFCommentModel *aModel in model.childComments) {
                if (aModel.isLocal) {
                    tempCount ++ ;
                }
            }
            NSInteger tempCount1 = model.childComments.count - tempCount;
            NSInteger totalCount = tempCount1 > 2 ? (2 + tempCount):(tempCount1 + tempCount);
            for (NSInteger i=0; i<totalCount; i++) {
                CTFCommentModel *aModel = [model.childComments safe_objectAtIndex:i];
                NSString *tempContent = aModel.isDeleted?@"该评论已删除":aModel.content;
                CGFloat tempH = [tempContent boundingRectWithSize:CGSizeMake(kScreen_Width-100, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:15]].height;
                childCommentH += tempH+73;
            }
            
            if (model.childCommentsCount - tempCount > 2) {
                childCommentH += 44;
            }
        }
    }
    return contentH + 73 + childCommentH;
}

#pragma mark CTFCommentsTableViewDelegate
#pragma mark 展开
- (void)commentsTableViewSetCellExpand {
    self.commentModel.isExpanded = YES;
    [self.subCommentView reloadData];
    [self setNeedsLayout];
    self.setCellExpandBlock();
}

#pragma mark -- Getters
#pragma mark 主评论
- (CTFCommentView *)mainCommentView{
    if (!_mainCommentView) {
        _mainCommentView = [[CTFCommentView alloc] init];
    }
    return _mainCommentView;
}

#pragma mark 子评论
- (CTFCommentsTableView *)subCommentView{
    if (!_subCommentView) {
        _subCommentView = [[CTFCommentsTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _subCommentView.isSubComment = YES;
        _subCommentView.viewDelegate = self;
    }
    return _subCommentView;
}

#pragma mark 横线
- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor ctColorEE];
    }
    return _lineView;
}

- (CTFCommentModel *)commentModel{
    if (!_commentModel) {
        _commentModel = [[CTFCommentModel alloc] init];
    }
    return _commentModel;
}

@end
