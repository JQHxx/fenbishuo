//
//  CTFCommentView.m
//  ChalkTalks
//
//  Created by vision on 2020/2/20.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFCommentView.h"
#import "CTFCommonManager.h"
#import "NSString+Size.h"
#import "UIResponder+Event.h"
#import "NSURL+Ext.h"

@interface CTFCommentView ()
    
@property (nonatomic,strong) UIImageView     *headImgView;
@property (nonatomic,strong) UILabel         *nameLabel;
@property (nonatomic,strong) UIImageView     *arrowImgView;
@property (nonatomic,strong) UILabel         *replyNameLabel; //被回复人
@property (nonatomic,strong) UIButton        *moretButton;
@property (nonatomic,strong) UILabel         *contentLabel;
@property (nonatomic,strong) UILabel         *timeLabel;
@property (nonatomic,strong) UIButton        *likeButton;
@property (nonatomic,strong) UILabel         *likeCountLabel;
@property (nonatomic,strong) UIButton        *handleBtn;
@property (nonatomic,strong) UIView          *lineView;

@property (nonatomic,strong) CTFCommentModel *commentModel;

@end

@implementation CTFCommentView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        
        [self addTapPressed:@selector(replyCommentAction) target:self];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.headImgView.frame = CGRectMake(16, 12, self.commentModel.avatarHeight, self.commentModel.avatarHeight);
    [self.headImgView setBorderWithCornerRadius:self.commentModel.avatarHeight/2.0 type:UIViewCornerTypeAll];
    self.moretButton.frame = CGRectMake(self.right-45, 8, 31, 32);
    CGFloat maxWidth = self.width-self.headImgView.right-self.moretButton.width-40;
    CGFloat nameWidth = [self.commentModel.author.name boundingRectWithSize:CGSizeMake(maxWidth, 22) withTextFont:self.nameLabel.font].width;
    self.nameLabel.frame = CGRectMake(self.headImgView.right+8, self.headImgView.top, nameWidth, 22);
    if (!kIsEmptyString(self.commentModel.replyToAuthor.name)) {
        self.arrowImgView.frame = CGRectMake(self.nameLabel.right+6, self.headImgView.top + 7, 7, 7);
        self.replyNameLabel.frame = CGRectMake(self.arrowImgView.right+6, self.headImgView.top, self.width-self.arrowImgView.right-self.moretButton.width-60, 22);
    } else {
        self.arrowImgView.frame = self.replyNameLabel.frame = CGRectZero;
    }
    
    NSString *content = self.commentModel.isDeleted?@"该评论已删除":self.commentModel.content;
    CGFloat contentH = [content boundingRectWithSize:CGSizeMake(self.width-self.nameLabel.left-16, CGFLOAT_MAX) withTextFont:self.contentLabel.font].height;
    self.contentLabel.frame = CGRectMake(self.nameLabel.left, self.nameLabel.bottom+2, self.width-self.nameLabel.left-16, contentH);
    self.timeLabel.frame = CGRectMake(self.nameLabel.left, self.contentLabel.bottom+8, 60, 17);
    self.likeButton.frame = CGRectMake(self.right-80, self.contentLabel.bottom+2, 65, 24);
    self.likeCountLabel.frame = CGRectMake(self.likeButton.left-85, self.contentLabel.bottom+4, 80, 20);
    self.lineView.frame = CGRectMake(self.lineLeft, self.timeLabel.bottom+11, self.width-self.lineLeft, 1);
}


#pragma mark -- Event response
#pragma mark 用户信息
- (void)userInfoPressedAction{
    [self routerEventWithName:kViewpointUserInfoEvent userInfo:@{kCommentDataModelKey:self.commentModel,@"commentIn":@(YES)}];
}

#pragma mark 更多
-(void)moreAction:(UIButton *)sender{
    [self routerEventWithName:kCommentMoreHandleEvent userInfo:@{kCommentDataModelKey:self.commentModel}];
}

#pragma mark 设置是否靠谱
-(void)setLikeAction:(UIButton *)sender{
    NSInteger likeCount = self.commentModel.voteupCount;
    NSString *state = self.commentModel.attitude;
    if ([state isEqualToString:@"like"]) {
        state = @"neutral";
        likeCount --;
    } else {
        state = @"like";
        likeCount ++;
    }
    self.commentModel.attitude = state;
    self.commentModel.voteupCount = likeCount;
    [self updateLikeUI];
    
    [self routerEventWithName:kCommentReliableEvent userInfo:@{kCommentDataModelKey:self.commentModel}];
}

#pragma mark 回复评论
- (void)replyCommentAction{
    if (self.commentModel.isDeleted) return;
    [self routerEventWithName:kCommentReplyEvent userInfo:@{kCommentDataModelKey:self.commentModel}];
}

#pragma mark -- Private methods
#pragma mark 是否靠谱
-(void)updateLikeUI{
    self.likeButton.selected = [self.commentModel.attitude isEqualToString:@"like"];
    if ([self.commentModel.attitude isEqualToString:@"like"]) { //靠谱
        self.likeButton.backgroundColor = UIColorFromHEX(0xFF2C45);
        [self.likeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.likeCountLabel.textColor = UIColorFromHEX(0xFF2C45);
    } else {
        self.likeButton.backgroundColor = [UIColor ctColorEE];
        [self.likeButton setTitleColor:[UIColor ctColor66] forState:UIControlStateNormal];
        self.likeCountLabel.textColor = [UIColor ctColor66];
    }
    self.likeCountLabel.text = [CTFCommonManager numberTransforByCount:self.commentModel.voteupCount];
}

#pragma mark 初始化界面
-(void)setupUI{
    [self addSubview:self.headImgView];
    [self addSubview:self.moretButton];
    [self addSubview:self.nameLabel];
    [self addSubview:self.arrowImgView];
    [self addSubview:self.replyNameLabel];
    self.arrowImgView.hidden = self.replyNameLabel.hidden = YES;
    [self addSubview:self.contentLabel];
    [self addSubview:self.timeLabel];
    [self addSubview:self.likeCountLabel];
    [self addSubview:self.likeButton];
    [self addSubview:self.lineView];
}

#pragma mark -- Setters
#pragma mark 填充数据
- (void)fillCommentData:(CTFCommentModel *)commentModel{
    self.commentModel = commentModel;
    
    [self.headImgView sd_setImageWithURL:[NSURL safe_URLWithString:commentModel.author.avatarUrl] placeholderImage:ImageNamed(@"placeholder_head_78x78")];
    
    self.nameLabel.text = self.commentModel.author.name;
    if (!kIsEmptyString(self.commentModel.replyToAuthor.name)) {
        self.arrowImgView.hidden = self.replyNameLabel.hidden = NO;
        self.replyNameLabel.text = self.commentModel.replyToAuthor.name;
    } else {
        self.arrowImgView.hidden = self.replyNameLabel.hidden = YES;
    }
    //内容
    if (self.commentModel.isDeleted) {
        self.moretButton.hidden = self.likeButton.hidden = self.likeCountLabel.hidden = YES;
        self.contentLabel.text = @"该评论已删除";
        self.contentLabel.textColor = [UIColor ctColorBB];
        self.contentLabel.userInteractionEnabled = self.likeButton.userInteractionEnabled = self.moretButton.userInteractionEnabled = NO;
    }else{
        self.moretButton.hidden = self.likeButton.hidden = self.likeCountLabel.hidden = NO;
        self.contentLabel.text = self.commentModel.content;
        self.contentLabel.textColor = [UIColor ctColor66];
        self.contentLabel.userInteractionEnabled = self.likeButton.userInteractionEnabled = self.moretButton.userInteractionEnabled = YES;
    }
    //时间
    self.timeLabel.text = [CTDateUtils formatTimeAgoWithTimestamp:self.commentModel.createdAt];
    
    //是否靠谱
    [self updateLikeUI];
    [self setNeedsLayout];
}

- (void)setLineLeft:(CGFloat)lineLeft{
    _lineLeft = lineLeft;
    self.lineView.frame = CGRectMake(self.lineLeft, self.timeLabel.bottom+11, self.width-self.lineLeft, 1);
}

#pragma mark -- Getters
#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] init];
        [_headImgView addTapPressed:@selector(userInfoPressedAction) target:self];
    }
    return _headImgView;
}

#pragma mark 用户名
-(UILabel *)nameLabel{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont mediumFontWithSize:16];
        _nameLabel.textColor = [UIColor ctColor33];
    }
    return _nameLabel;
}

#pragma mark 箭头
-(UIImageView *)arrowImgView{
    if (!_arrowImgView) {
        _arrowImgView = [[UIImageView alloc] init];
        _arrowImgView.image = ImageNamed(@"comment_icon_reply");
    }
    return _arrowImgView;
}

#pragma mark 被回复人
-(UILabel *)replyNameLabel{
    if (!_replyNameLabel) {
        _replyNameLabel = [[UILabel alloc] init];
        _replyNameLabel.font = [UIFont mediumFontWithSize:16];
        _replyNameLabel.textColor = [UIColor ctColor33];
    }
    return _replyNameLabel;
}

#pragma mark 更多（举报或删除）
-(UIButton *)moretButton{
    if (!_moretButton) {
        _moretButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreen_Width-45, 14, 31, 32)];
        [_moretButton setImage:ImageNamed(@"comment_icon_more") forState:UIControlStateNormal];
        [_moretButton addTarget:self action:@selector(moreAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moretButton;
}

#pragma mark 评论内容
-(UILabel *)contentLabel{
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [UIFont regularFontWithSize:15];
        _contentLabel.textColor = [UIColor ctColor33];
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

#pragma mark 时间
-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont mediumFontWithSize:11];
        _timeLabel.textColor = [UIColor ctColorCC];
    }
    return _timeLabel;
}

#pragma mark 更多（举报或删除）
-(UIButton *)likeButton{
    if (!_likeButton) {
        _likeButton = [[UIButton alloc] initWithFrame:CGRectZero];
        _likeButton.backgroundColor = [UIColor ctColorEE];
        [_likeButton setImage:ImageNamed(@"tool_like_flag") forState:UIControlStateNormal];
        [_likeButton setTitle:@"靠谱" forState:UIControlStateNormal];
        [_likeButton setTitleColor:[UIColor ctColor66] forState:UIControlStateNormal];
        _likeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        _likeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        _likeButton.titleLabel.font = [UIFont mediumFontWithSize:12];
        [_likeButton doBorderWidth:0 color:nil cornerRadius:12];
        [_likeButton addTarget:self action:@selector(setLikeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeButton;
}

#pragma mark 靠谱数
-(UILabel *)likeCountLabel{
    if (!_likeCountLabel) {
        _likeCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _likeCountLabel.font = [UIFont regularFontWithSize:12];
        _likeCountLabel.textColor = [UIColor ctColor99];
        _likeCountLabel.textAlignment = NSTextAlignmentRight;
    }
    return _likeCountLabel;
}

#pragma mark 线条
-(UIView *)lineView{
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
