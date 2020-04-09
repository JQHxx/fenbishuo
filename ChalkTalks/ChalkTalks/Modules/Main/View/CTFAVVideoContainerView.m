//
//  CTFAVVideoContainerView.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/30.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFAVVideoContainerView.h"
#import "CTFStatusErrorView.h"
#import "NSURL+Ext.h"

@interface CTFAVVideoContainerView (){
    UIImageView              *videoCoverView;
    UIButton                 *playButton;
    UILabel                  *durationLabel;
    CTFStatusErrorView       *videoStatusErrorView;
    CTFAVVideoInterruptView  *interruptTipsView;
    AnswerModel *curModel;
}

@end

@implementation CTFAVVideoContainerView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        self.clipsToBounds = YES;
        self.layer.cornerRadius = kCornerRadius;
        self.userInteractionEnabled = YES;
        [self setupUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    videoCoverView.frame = self.bounds;
    playButton.frame = CGRectMake((CGRectGetWidth(videoCoverView.frame)-64)/2.0, (CGRectGetHeight(videoCoverView.frame)-64)/2.0f, 64, 64);
    durationLabel.frame = CGRectMake(videoCoverView.width-50-10, videoCoverView.height-30, 50, 20);
    interruptTipsView.frame = videoCoverView.frame;
    videoStatusErrorView.frame = self.bounds;
}

#pragma mark - publish
-(void)fillContentWithData:(AnswerModel*)model{
    curModel = model;

    if ([model.status isEqualToString:@"normal"] && !kIsEmptyString(model.video.url) && model.video.width > 0 && model.video.height > 0) {
        self.tag = 1000;
        playButton.hidden = videoCoverView.hidden = durationLabel.hidden = NO;
        videoStatusErrorView.hidden = YES;
        [videoCoverView sd_setImageWithURL:[NSURL safe_URLWithString: model.video.coverUrl] placeholderImage:[UIImage ctPlaceholderImage]];
        BOOL isLarge = [AppMargin isLargeScaleIsWidth:model.video.width height:model.video.height rotation:model.video.rotation];
        if (isLarge) {
            videoCoverView.contentMode = UIViewContentModeScaleAspectFit;
            videoCoverView.backgroundColor = [UIColor blackColor];
        } else {
            videoCoverView.contentMode = UIViewContentModeScaleAspectFill;
            videoCoverView.backgroundColor = [UIColor ctColorEE];
        }
        durationLabel.text = [ZFUtilities convertTimeSecond: model.video.duration/1000/1000];
    } else {
        NSString *originUrl =  [[CTVideoCache share] getVideoWithQuestionId:model.question.questionId];
        if ([model.status isEqualToString:@"init"] && model.isAuthor && !kIsEmptyString(originUrl)) {
            self.tag = 1000;
            playButton.hidden = videoCoverView.hidden = durationLabel.hidden = NO;
            videoStatusErrorView.hidden = YES; 
            videoCoverView.contentMode = UIViewContentModeScaleAspectFit;
            videoCoverView.image = [[CTVideoCache share] getVideoCoverWithQuestionId:model.question.questionId];
            videoCoverView.backgroundColor = [UIColor blackColor];
            durationLabel.text = [ZFUtilities convertTimeSecond: model.video.duration/1000/1000];
        } else {
            self.tag = 0;
            playButton.hidden = videoCoverView.hidden = durationLabel.hidden = YES;
            videoStatusErrorView.hidden = NO;
            [videoStatusErrorView fillErrorViewWithCoverImage:model.video.coverUrl status:model.status];
        }
    }
    [interruptTipsView showViewByType:VideoInterrupted_No];
}

-(void)showInterruptTipsView:(VideoInterrupted)type{
    [interruptTipsView showViewByType:type];
    playButton.hidden = type == VideoInterrupted_Cellular;
}

-(void)hideInterruptTipsView{
    [interruptTipsView showViewByType:VideoInterrupted_No];
}

#pragma mark - Action
-(void)playBtnClick:(id)sender{
    if(self.playVideo){
        self.playVideo();
    }
}

#pragma mark - UI
-(void)setupUI{
    videoCoverView = [[UIImageView alloc] init];
    videoCoverView.contentMode = UIViewContentModeScaleAspectFill;
    videoCoverView.userInteractionEnabled = YES;
    [self addSubview:videoCoverView];
    
    playButton = [[UIButton alloc] init];
    [playButton setImage:[UIImage imageNamed:@"video_player_play"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [videoCoverView addSubview:playButton];
    
    durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(videoCoverView.frame.size.width-50-10, videoCoverView.frame.size.height-30, 50, 20)];
    durationLabel.font= [UIFont monospacedDigitSystemFontOfSize:12 weight:(UIFontWeightRegular)];
    durationLabel.textColor = [UIColor whiteColor];
    durationLabel.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.4);
    durationLabel.layer.cornerRadius = 10;
    durationLabel.clipsToBounds = YES;
    durationLabel.textAlignment = NSTextAlignmentCenter;
    [videoCoverView addSubview:durationLabel];
    
    videoStatusErrorView = [[CTFStatusErrorView alloc] init];
    [self addSubview:videoStatusErrorView];
    videoStatusErrorView.hidden = YES;
    
    interruptTipsView = [[CTFAVVideoInterruptView alloc] init];
    @weakify(self);
    [interruptTipsView setPlayVideo:^{
        @strongify(self);
        [self playBtnClick:nil];
    }];
    [interruptTipsView setHidden:YES];
    [videoCoverView addSubview:interruptTipsView];
}
@end
