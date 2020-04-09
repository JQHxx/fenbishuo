//
//  CTFVideoGuideVIew.m
//  ChalkTalks
//
//  Created by vision on 2020/3/24.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFVideoGuideView.h"
#import "UIImage+Size.h"
#import "ZFUtilities.h"
#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "ZFPlayerControlView.h"
#import "CTFVideoMuteManager.h"
#import "NSURL+Ext.h"

@interface CTFVideoGuideView ()

@property (nonatomic,strong) UIImageView   *bgImgView;
@property (nonatomic,strong) UIButton      *closeBtn; //关闭
@property (nonatomic,strong) UIImageView   *headImgView;
@property (nonatomic,strong) UILabel       *nickLab;
@property (nonatomic,strong) UILabel       *descLab;    //描述
@property (nonatomic,strong) UIImageView   *coverImgView; //视频封面或占位图
@property (nonatomic,strong) UILabel       *secondsLab; //倒计时
@property (nonatomic,strong) UILabel       *tipsLab; //

@property (nonatomic,strong) ZFPlayerController  *player;
@property (nonatomic,strong) UserModel           *userInfo;

@end

@implementation CTFVideoGuideView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.userInfo = [UserCache getUserInfo];
        [self setupUI];
        [self setupAVVideoPlayer];
    }
    return self;
}

#pragma mark setui
- (void)setupUI{
    [self addSubview:self.bgImgView];
    [self.bgImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.right.mas_equalTo(self.bgImgView.mas_right).offset(-10);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self addSubview:self.nickLab];
    [self.nickLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.closeBtn.mas_bottom).offset(-10);
        make.centerX.mas_equalTo(self.bgImgView.mas_centerX).offset(12);
        make.height.mas_equalTo(18);
    }];
    
    [self addSubview:self.headImgView];
    [self.headImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nickLab.mas_top);
        make.right.mas_equalTo(self.nickLab.mas_left).offset(-6);
        make.size.mas_equalTo(CGSizeMake(18, 18));
    }];
    
    [self addSubview:self.descLab];
    [self.descLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headImgView.mas_bottom).offset(12);
        make.centerX.mas_equalTo(self.bgImgView.mas_centerX);
        make.height.mas_equalTo(22);
    }];
    
    [self addSubview:self.coverImgView];
    [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width-60, (kScreen_Width-60)*(9.0/16.0)));
        make.bottom.mas_equalTo(self.bgImgView.mas_bottom).offset(-14);
    }];
    
    [self addSubview:self.secondsLab];
    [self.secondsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.coverImgView.mas_top).offset(8);
        make.size.mas_equalTo(CGSizeMake(33, 16));
    }];
    
    [self addSubview:self.tipsLab];
    [self.tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.coverImgView.mas_centerX).offset(5);
        make.centerY.mas_equalTo(self.coverImgView.mas_centerY);
    }];
}

#pragma mark -- Event response
#pragma mark 关闭
- (void)closeCurrentViewAction:(UIButton *)sender {
    self.closeBlock();
}

#pragma mark -- Setters
- (void)setVideoModel:(CTFGuideVideoModel *)videoModel {
    _videoModel = videoModel;
    if (videoModel.videoPath) {
        if (videoModel.videoCoverImage) {
            self.coverImgView.image = videoModel.videoCoverImage;
        }
        self.player.currentPlayerManager.seekTime = 0;
        self.player.assetURL = [NSURL safe_URLWithString:videoModel.videoPath];
        self.secondsLab.hidden = NO;
        self.tipsLab.hidden = YES;
        self.secondsLab.text = [NSString stringWithFormat:@"%lds",videoModel.duration];
    } else {
        self.secondsLab.hidden = YES;
        self.tipsLab.hidden = NO;
        self.coverImgView.image = ImageNamed(@"publish_guide_video_placeholder");
    }
}

#pragma mark -- Getters
#pragma mark 虚线框
- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [[UIImageView alloc] initWithFrame:self.bounds];
        _bgImgView.image = ImageNamed(@"publish_guide_dashed_box");
    }
    return _bgImgView;
}

#pragma mark 关闭
- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setImage:ImageNamed(@"publish_guide_video_close") forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeCurrentViewAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

#pragma mark 头像
- (UIImageView *)headImgView {
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc] init];
        if (!kIsEmptyString(self.userInfo.avatarUrl)) {
            [_headImgView sd_setImageWithURL:[NSURL safe_URLWithString:self.userInfo.avatarUrl] placeholderImage:[UIImage imageNamed:@"placeholder_head_20x20"]];
        } else {
            [_headImgView setImage:[UIImage imageNamed:@"placeholder_head_20x20"]];
        }
        _headImgView.layer.cornerRadius = 9.0;
        _headImgView.clipsToBounds = YES;
    }
    return _headImgView;
}

#pragma mark 昵称
- (UILabel *)nickLab {
    if (!_nickLab) {
        _nickLab = [[UILabel alloc] init];
        _nickLab.font = [UIFont regularFontWithSize:12.f];
        _nickLab.textColor = UIColorFromHEX(0xD8D8D8);
        _nickLab.text = [NSString stringWithFormat:@"亲爱的%@，你已来到粉笔说 %ld 天  ",self.userInfo.name,self.userInfo.createdDays];

    }
    return _nickLab;
}

#pragma mark 描述
- (UILabel *)descLab {
    if (!_descLab) {
        _descLab = [[UILabel alloc] init];
        _descLab.font = [UIFont mediumFontWithSize:15.f];
        _descLab.textColor = [UIColor whiteColor];
        _descLab.textAlignment = NSTextAlignmentCenter;
        if (self.userInfo.questionCount > 0) {
            NSString *desc = [NSString stringWithFormat:@"发布了%ld个问题，收获了%ld个回答",self.userInfo.questionCount,self.userInfo.questionAnswerCount];
            _descLab.text = desc;
        } else {
            _descLab.text = @"你在粉笔说还未发布问题，赶紧来提问吧！";
        }
        
    }
    return _descLab;
}

#pragma mark 封面
- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [[UIImageView alloc] init];
        _coverImgView.layer.cornerRadius = 2.0;
        _coverImgView.clipsToBounds = YES;
        _coverImgView.backgroundColor = [UIColor ctColorEE];
        SDImageCache *cache =  [SDImageCache sharedImageCache];
        UIImage *memoryImage =  [cache imageFromMemoryCacheForKey:kPublishGuideVideoCoverKey];
        if (memoryImage) {
            self.coverImgView.image = memoryImage;
        } else {
            //再从磁盘中查找是否有图片
            UIImage *diskImage =  [cache imageFromDiskCacheForKey:kPublishGuideVideoCoverKey];
            if (diskImage) {
                self.coverImgView.image = memoryImage;
            }
        }
    }
    return _coverImgView;
}

#pragma mark 倒计时
- (UILabel *)secondsLab {
    if (!_secondsLab) {
        _secondsLab = [[UILabel alloc] init];
        _secondsLab.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.3);
        _secondsLab.textColor = [UIColor ctColorEE];
        _secondsLab.textAlignment = NSTextAlignmentCenter;
        _secondsLab.layer.cornerRadius = 8;
        _secondsLab.font = [UIFont regularFontWithSize:10.f];
        _secondsLab.clipsToBounds = YES;
    }
    return _secondsLab;
}

#pragma mark tips
- (UILabel *)tipsLab {
    if (!_tipsLab) {
        _tipsLab = [[UILabel alloc] init];
        _tipsLab.textColor = [UIColor whiteColor];
        _tipsLab.font = [UIFont regularFontWithSize:12];
        _tipsLab.text = @"点击下方按钮发布话题哦~";
    }
    return _tipsLab;
}

#pragma mark 播放器
-(void)setupAVVideoPlayer{
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    self.player = [ZFPlayerController playerWithPlayerManager:playerManager containerView:self.coverImgView];
    self.player.currentPlayerManager.muted = NO;
    self.player.WWANAutoPlay = YES;
    self.player.shouldAutoPlay = YES;
    self.player.exitFullScreenWhenStop = YES;
    self.player.allowOrentitaionRotation = NO;
    self.player.customAudioSession = YES;
    self.player.currentPlayerManager.bgColor = [UIColor clearColor];
    
    kSelfWeak;
    self.player.currentPlayerManager.playerDidToEnd = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset) {
        [weakSelf.player.currentPlayerManager replay];
    };
    
    self.player.currentPlayerManager.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        NSInteger playTime = (NSInteger)(duration - currentTime);
        weakSelf.secondsLab.text = [NSString stringWithFormat:@"%lds",playTime];
     };
}

@end




