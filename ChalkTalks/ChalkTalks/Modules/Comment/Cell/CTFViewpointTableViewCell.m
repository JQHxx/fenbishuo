//
//  CTFViewpointTableViewCell.m
//  ChalkTalks
//
//  Created by vision on 2020/2/20.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFViewpointTableViewCell.h"
#import "UIResponder+Event.h"
#import "CTFCommentView.h"
#import "NSString+Size.h"

@interface CTFViewpointTableViewCell ()

@property (nonatomic,strong) CTFCommentView  *commentView;
@property (nonatomic,strong) CTFCommentModel *commentModel;

@end

@implementation CTFViewpointTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.commentView];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    NSString *content = self.commentModel.isDeleted?@"该评论已删除":self.commentModel.content;
    CGFloat contentH = [content boundingRectWithSize:CGSizeMake(self.width-72, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:15]].height;
    self.commentView.frame = CGRectMake(0, 0, self.width, contentH+73);
}

#pragma mark -- Public Methods
#pragma mark 填充数据
- (void)fillCommentData:(CTFCommentModel *)model{
    self.commentModel = model;
    [self.commentView fillCommentData:self.commentModel];
}

#pragma mark 计算高度
+ (CGFloat)getCommentCellHeight:(CTFCommentModel *)model isSubComment:(BOOL)isSubComment{
    NSString *content = model.isDeleted?@"该评论已删除":model.content;
    CGFloat contentH = [content boundingRectWithSize:CGSizeMake(isSubComment?kScreen_Width-100:kScreen_Width-72, CGFLOAT_MAX) withTextFont:[UIFont regularFontWithSize:15]].height;
    return contentH + 73;
}

- (void)setLineLeft:(CGFloat)lineLeft{
    _lineLeft = lineLeft ;
    self.commentView.lineLeft = lineLeft;
}

#pragma mark -- Getters
#pragma mark 评论
- (CTFCommentView *)commentView{
    if (!_commentView) {
        _commentView = [[CTFCommentView alloc] init];
    }
    return _commentView;
}

- (CTFCommentModel *)commentModel{
    if (!_commentModel) {
        _commentModel = [[CTFCommentModel alloc] init];
    }
    return _commentModel;
}

@end
