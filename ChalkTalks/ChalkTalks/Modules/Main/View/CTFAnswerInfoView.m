//
//  CTFAnswerInfoView.m
//  ChalkTalks
//
//  Created by vision on 2020/2/27.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFAnswerInfoView.h"
#import "NSURL+Ext.h"

@interface CTFAnswerInfoView ()

@property (nonatomic,strong) UIImageView          *headImgView;  //头像
@property (nonatomic,strong) UILabel              *nameLab;  //昵称
@property (nonatomic,strong) UIButton             *viewCountBtn;   //阅读量
@property (nonatomic,strong) AuthorModel          *author;

@end

@implementation CTFAnswerInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor ctColorF8];
        
        [self setupUI];
    }
    return self;
}

#pragma mark 填充数据
- (void)fillDataWithAuthor:(AuthorModel *)author viewCount:(NSInteger)viewCount {
    self.author = author;
    [self.headImgView sd_setImageWithURL:[NSURL safe_URLWithString:author.avatarUrl] placeholderImage:ImageNamed(@"placeholder_head_78x78")];
    NSString *nameStr = [NSString stringWithFormat:@"%@ 回答了该话题",author.name];
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:nameStr];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:[UIColor ctColor33] range:NSMakeRange(0, author.name.length)];
    self.nameLab.attributedText = attributeStr;
    [self.viewCountBtn setTitle:[NSString stringWithFormat:@"%@人阅读",[AppUtils countToString:viewCount]] forState:UIControlStateNormal];
}

#pragma mark -- Event response
#pragma mark 用户信息
- (void)userPressedAction {
    if (self.clickDisable) return;
    [ROUTER routeByCls:kCTFHomePageVC withParam:@{@"userId": @(self.author.authorId)}];
}

#pragma mark -- Private methods
#pragma mark 初始化
- (void)setupUI {
    [self addSubview:self.headImgView];
    [self.headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.size.mas_equalTo(CGSizeMake(14, 14));
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    [self addSubview:self.nameLab];
    [self.nameLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headImgView.mas_right).offset(2);
        make.centerY.mas_equalTo(self.headImgView.mas_centerY);
    }];
    
    [self addSubview:self.viewCountBtn];
    [self.viewCountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-11);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
}

- (void)setClickDisable:(BOOL)clickDisable{
    _clickDisable = clickDisable;
}

#pragma mark -- Getters
#pragma mark 头像
-(UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] init];
        _headImgView.layer.cornerRadius = 7;
        _headImgView.layer.borderColor = [UIColor ctColorEE].CGColor;
        _headImgView.layer.borderWidth = 1;
        _headImgView.clipsToBounds = YES;
        [_headImgView addTapPressed:@selector(userPressedAction) target:self];
    }
    return _headImgView;
}

#pragma mark 昵称
-(UILabel *)nameLab{
    if (!_nameLab) {
        _nameLab = [[UILabel alloc] init];
        _nameLab.font = [UIFont regularFontWithSize:11];
        _nameLab.textColor = [UIColor ctColor99];
        [_nameLab addTapPressed:@selector(userPressedAction) target:self];
    }
    return _nameLab;
}

#pragma mark 阅读量
- (UIButton *)viewCountBtn {
    if (!_viewCountBtn) {
        _viewCountBtn = [[UIButton alloc] init];
        [_viewCountBtn setImage:ImageNamed(@"topic_read_count") forState:UIControlStateNormal];
        [_viewCountBtn setTitleColor:[UIColor ctColor99] forState:UIControlStateNormal];
        _viewCountBtn.titleLabel.font = [UIFont regularFontWithSize:11];
        _viewCountBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    }
    return _viewCountBtn;
}

@end
