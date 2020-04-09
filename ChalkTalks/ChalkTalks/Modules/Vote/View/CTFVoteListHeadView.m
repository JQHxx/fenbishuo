//
//  CTFVoteListHeadView.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/1/11.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFVoteListHeadView.h"
#import "CTFVoteListVC.h"
#import "LMJVerticalScrollText.h"

@interface CTFVoteListHeadView () <LMJVerticalScrollTextDelegate>
@property (nonatomic, strong) UILabel *topicAccountLabel;//话题数目

@property (nonatomic, strong) UILabel *loadingLable;
@property (nonatomic, strong) LMJVerticalScrollText *verticalScrollText;

@property (nonatomic, strong) UIView *btnBgView;
@property (nonatomic, strong) UIButton *defaultBtn;
@property (nonatomic, strong) UIButton *lastBtn;

@property (nonatomic, copy) NSArray<CTFCarouselsModel*> *wheelArray;
@property (nonatomic, assign) NSInteger account;
@property (nonatomic, copy) NSString *sort;

@end

@implementation CTFVoteListHeadView

- (instancetype)initWithFrame:(CGRect)frame account:(NSInteger)account sortType:(NSString *)sort {
    if (self = [super initWithFrame:frame]) {
        self.account = account;
        self.sort = sort;
        [self setupViewContent];
    }
    return self;
}

- (void)updateDataByAccount:(NSInteger)account sortType:(NSString *)sort {
    self.account = account;
    self.sort = sort;
    self.topicAccountLabel.text = [NSString stringWithFormat:@"话题 %ld", self.account];
    if ([self.sort isEqualToString:@"last"]) {
        [self.defaultBtn setSelected:NO];
        [self.lastBtn setSelected:YES];
    }else {
        [self.defaultBtn setSelected:YES];
        [self.lastBtn setSelected:NO];
    }
    [self updataButtonBackgroundColor];
}

- (instancetype)initWithFrame:(CGRect)frame wheelData:(NSArray<CTFCarouselsModel*> *)wheelArray sortType:(NSString *)sort {
    if (self = [super initWithFrame:frame]) {
        self.wheelArray = wheelArray;
        self.sort = sort;
        [self setupViewContent];
    }
    return self;
}

- (LMJVerticalScrollText *)verticalScrollText {
    if (!_verticalScrollText) {
        _verticalScrollText = [[LMJVerticalScrollText alloc] initWithFrame:CGRectMake(16, 9, self.frame.size.width - 16 - 101, 20)];
        _verticalScrollText.delegate = self;
        _verticalScrollText.textStayTime = 2;
        _verticalScrollText.scrollAnimationTime = 1;
        _verticalScrollText.backgroundColor = UIColorFromHEX(0xFFFFFF);
        _verticalScrollText.textColor = UIColorFromHEX(0x666666);
        _verticalScrollText.textFont = [UIFont boldSystemFontOfSize:12];
        _verticalScrollText.textAlignment = NSTextAlignmentLeft;
        _verticalScrollText.touchEnable = YES;
        _verticalScrollText.layer.cornerRadius = 3;
        [self addSubview:_verticalScrollText];
    }
    return _verticalScrollText;
}

- (void)updateDataByWheelData:(NSArray<CTFCarouselsModel*> *)wheelArray sortType:(NSString *)sort {
    self.wheelArray = wheelArray;
    self.sort = sort;
    @weakify(self);
    [self handledCarouslesMessageComplete:^(NSArray *carouselsArray) {
        @strongify(self);
        [self.loadingLable removeFromSuperview];
        self.verticalScrollText.textDataArr = carouselsArray;
        [self.verticalScrollText startScrollBottomToTopWithNoSpace];
    }];
    if ([self.sort isEqualToString:@"last"]) {
        [self.defaultBtn setSelected:NO];
        [self.lastBtn setSelected:YES];
    }else {
        [self.defaultBtn setSelected:YES];
        [self.lastBtn setSelected:NO];
    }
    [self updataButtonBackgroundColor];
}

- (void)setupViewContent {
    
    self.backgroundColor = UIColorFromHEX(0xFFFFFF);
    
    if (self.wheelArray) {
        
        self.loadingLable = [[UILabel alloc] init];
        [self addSubview:self.loadingLable];
        [self.loadingLable mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(16);
            make.right.mas_equalTo(self.mas_right).offset(-101);
            make.top.mas_equalTo(self.mas_top).offset(9);
            make.height.mas_equalTo(20);
        }];
        
    } else {
        
        self.topicAccountLabel = [[UILabel alloc] init];
        self.topicAccountLabel.text = [NSString stringWithFormat:@"话题 %ld", self.account];
        self.topicAccountLabel.textColor = UIColorFromHEX(0xC2C2C2);
        self.topicAccountLabel.font = [UIFont systemFontOfSize:14];
        // backdoor
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(backdoorAction:)];
        longPress.minimumPressDuration = 3;
        [self.topicAccountLabel addGestureRecognizer:longPress];
        [self.topicAccountLabel setUserInteractionEnabled:YES];
        
        [self addSubview:self.topicAccountLabel];
        [self.topicAccountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.mas_centerY);
            make.left.mas_equalTo(self.mas_left).offset(16);
        }];
    }
    //
    self.btnBgView = [[UIView alloc] init];
    self.btnBgView.backgroundColor = UIColorFromHEX(0xFFFFFF);
    [self addSubview:self.btnBgView];
    [self.btnBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(78, 28));
        make.right.mas_equalTo(self.mas_right).offset(-19);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    //
    self.defaultBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.defaultBtn setTitle:@"最热" forState:UIControlStateNormal];
    [self.defaultBtn setTitleColor:UIColorFromHEX(0x666666) forState:UIControlStateNormal];
    [self.defaultBtn setTitleColor:UIColorFromHEX(0xFFFFFF) forState:UIControlStateSelected];
    [self.defaultBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.defaultBtn setAdjustsImageWhenHighlighted:NO];
    self.defaultBtn.layer.cornerRadius = 12;
    [self.defaultBtn addTarget:self action:@selector(defaultBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnBgView addSubview:self.defaultBtn];
    [self.defaultBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.btnBgView.mas_centerY);
        make.right.mas_equalTo(self.btnBgView.mas_right).offset(-2);
        make.size.mas_equalTo(CGSizeMake(36, 24));
    }];
    //
    self.lastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.lastBtn setTitle:@"最新" forState:UIControlStateNormal];
    [self.lastBtn setTitleColor:UIColorFromHEX(0x666666) forState:UIControlStateNormal];
    [self.lastBtn setTitleColor:UIColorFromHEX(0xFFFFFF) forState:UIControlStateSelected];
    [self.lastBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.lastBtn setAdjustsImageWhenHighlighted:NO];
    self.lastBtn.layer.cornerRadius = 12;
    [self.lastBtn addTarget:self action:@selector(lastBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnBgView addSubview:self.lastBtn];
    [self.lastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.btnBgView.mas_centerY);
        make.left.mas_equalTo(self.btnBgView.mas_left).offset(2);
        make.size.mas_equalTo(CGSizeMake(36, 24));
    }];
    
    [self setupSkeletonable];
}

- (void)setupSkeletonable {
    
    self.topicAccountLabel.text = @"                        ";
    self.loadingLable.text = @"                        ";
    
    [self ctf_skeletonable:YES];
    [self.topicAccountLabel ctf_skeletonable:YES];
    [self.loadingLable ctf_skeletonable:YES];
    [self.btnBgView ctf_skeletonable:YES];
    [self.defaultBtn ctf_skeletonable:YES];
    [self.lastBtn ctf_skeletonable:YES];
}

- (void)backdoorAction:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [CTBackdoorViewController showBackdoor];
    }
}

- (void)updataButtonBackgroundColor {
    if (self.defaultBtn.selected) {
        self.defaultBtn.backgroundColor = UIColorFromHEX(0xFF6885);
        self.lastBtn.backgroundColor = UIColorFromHEX(0xFFFFFF);
    } else {
        self.defaultBtn.backgroundColor = UIColorFromHEX(0xFFFFFF);
        self.lastBtn.backgroundColor = UIColorFromHEX(0xFF6885);
    }
    self.btnBgView.layer.cornerRadius = 14;
    self.btnBgView.layer.borderWidth = 1;
    self.btnBgView.layer.borderColor = UIColorFromHEX(0xFF6885).CGColor;
}

- (void)defaultBtnAction:(UIButton *)btn {
    
    CTFVoteListVC *voteListVC = (CTFVoteListVC *)self.findViewController;
    voteListVC.sortType = @"default";
    @weakify(self);
    [voteListVC beginTableViewRefreshWithMJHeadLoading:YES complete:^(BOOL isSuccess) {
        @strongify(self);
        if (isSuccess) {
            [self.defaultBtn setSelected:YES];
            [self.lastBtn setSelected:NO];
            [self updataButtonBackgroundColor];
            [voteListVC.adpater local_updateVoteListSortType:@"default" toCategoryId:voteListVC.categoryId];
        }
    }];
}

- (void)lastBtnAction:(UIButton *)btn {
    CTFVoteListVC *voteListVC = (CTFVoteListVC *)self.findViewController;
    voteListVC.sortType = @"last";
    @weakify(self);
    [voteListVC beginTableViewRefreshWithMJHeadLoading:YES complete:^(BOOL isSuccess) {
        @strongify(self);
        if (isSuccess) {
            [self.defaultBtn setSelected:NO];
            [self.lastBtn setSelected:YES];
            [self updataButtonBackgroundColor];
            [voteListVC.adpater local_updateVoteListSortType:@"last" toCategoryId:voteListVC.categoryId];
        }
    }];
}

- (void)handledCarouslesMessageComplete:(void(^)(NSArray *carouselsArray))completeBlock {
    
    NSMutableArray *carouselsArray = [NSMutableArray array];
    
    for (int i = 0; i < self.wheelArray.count; i++) {
        
        CTFCarouselsModel *carousele = [self.wheelArray objectAtIndex:i];
        
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:carousele.actors.avatarUrl] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                
                NSString *contentText = [NSString stringWithFormat:@" %@%@",carousele.actors.name, carousele.text];
                NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:contentText];
                
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                textAttachment.image = error ? [[UIImage imageNamed:@"placeholder_head_78x78"] circleImage] : [image circleImage];
                textAttachment.bounds = CGRectMake(0, -4, 15, 15);
                
                NSAttributedString *attachmentAttrStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                
                [attrStr insertAttributedString:attachmentAttrStr atIndex:0];
                
                [carouselsArray addObject:attrStr];
                
                if (carouselsArray.count == self.wheelArray.count) {
                    completeBlock(carouselsArray);
                }
        }];
    }
}

#pragma mark - LMJScrollTextView2 Delegate
- (void)verticalScrollText:(LMJVerticalScrollText *)scrollText currentTextIndex:(NSInteger)index{
//    NSLog(@"当前是信息%ld",index);
}
- (void)verticalScrollText:(LMJVerticalScrollText *)scrollText clickIndex:(NSInteger)index content:(NSString *)content{
//    NSLog(@"#####点击的是：第%ld条信息 内容：%@",index,content);
}

@end
