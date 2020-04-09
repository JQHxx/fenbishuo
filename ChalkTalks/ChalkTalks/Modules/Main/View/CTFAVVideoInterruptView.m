//
//  CTFVideoInterruptView.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/25.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFAVVideoInterruptView.h"


@interface CTFAVVideoInterruptView()

@end

@implementation CTFAVVideoInterruptView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
    }
    return self;
}

- (void)showViewByType:(VideoInterrupted)type{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self setHidden:(VideoInterrupted_No == type)];
    
    if(type == VideoInterrupted_Cellular){
        [self videoInterrupt_CellularView];
    }else if(type == VideoInterrupted_NetError){
        [self videoInterrupt_NetErrorView];
    }
}


/// 在4G下。用户点击继续播放
/// @param sender  sender
- (void)cellularNetPlay:(id)sender{
    [CTFCellularPlayerVideo sharedInstance].canPlayVideoViaWWAN = YES;
     [self showViewByType:VideoInterrupted_No];
    if(self.playVideo){
        self.playVideo();
    }
   
}

- (void)rePlayVideo:(id)sender{
       [self showViewByType:VideoInterrupted_No];
    if(self.playVideo){
        self.playVideo();
    }
 
}

- (void)netErrorReload:(id)sender{
    [self showViewByType:VideoInterrupted_No];
    if(self.playVideo){
        self.playVideo();
    }
}

- (UIView*)videoInterrupted_CompleteView{
    UIView *_videoInterrupted_CompleteView = [[UIView alloc] initWithFrame:self.bounds];
    _videoInterrupted_CompleteView.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.5);
    [self addSubview:_videoInterrupted_CompleteView];

    UIButton *rePlayButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [rePlayButton setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:[UIColor clearColor] borderColor:[UIColor whiteColor] borderWidth:1 cornerRadius:20] forState:UIControlStateNormal];
    [rePlayButton setImage:[[UIImage imageNamed:@"video_replay_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
    [rePlayButton setTitle:@" 重新播放" forState:UIControlStateNormal];
    rePlayButton.titleLabel.font = kSystemFont(14);
    [rePlayButton setHidden:YES];
    [rePlayButton addTarget:self action:@selector(rePlayVideo:) forControlEvents:UIControlEventTouchUpInside];
    [rePlayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_videoInterrupted_CompleteView addSubview:rePlayButton];
    
    [rePlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
       make.centerX.equalTo(_videoInterrupted_CompleteView.mas_centerX);
        make.centerY.equalTo(_videoInterrupted_CompleteView.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(100, 35));
    }];
    return _videoInterrupted_CompleteView;
}

- (UIView*)videoInterrupt_NetErrorView{
    UIView *_videoInterrupt_NetErrorView = [[UIView alloc] initWithFrame:self.bounds];
    _videoInterrupt_NetErrorView.backgroundColor = UIColorFromHEXWithAlpha(0x666666, 1);
    [self addSubview:_videoInterrupt_NetErrorView];
    
    UIImageView *centerImageView = [[UIImageView alloc] init];
    centerImageView.contentMode = UIViewContentModeScaleAspectFit;
    centerImageView.image = ImageNamed(@"video_loading_fail");
    [_videoInterrupt_NetErrorView addSubview:centerImageView];
    
    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.font = kSystemFont(12);
    tipsLabel.textColor = [UIColor whiteColor];
    tipsLabel.text = @"抱歉，加载失败";
    [_videoInterrupt_NetErrorView addSubview:tipsLabel];
    
    UIButton *rePlayButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [rePlayButton setTitle:@"重新加载" forState:UIControlStateNormal];
    rePlayButton.titleLabel.font = kSystemFont(14);

    [rePlayButton addTarget:self action:@selector(netErrorReload:) forControlEvents:UIControlEventTouchUpInside];
    [rePlayButton setTitleColor:UIColorFromHEX(0xFF6885) forState:UIControlStateNormal];
    [_videoInterrupt_NetErrorView addSubview:rePlayButton];
    
    [centerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.centerX.equalTo(_videoInterrupt_NetErrorView.mas_centerX);
        make.centerY.equalTo(_videoInterrupt_NetErrorView.mas_centerY).offset(-30);
    }];
    
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.centerX.equalTo(_videoInterrupt_NetErrorView.mas_centerX);
        make.top.equalTo(centerImageView.mas_bottom).offset(15);
    }];

     [rePlayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_videoInterrupt_NetErrorView.mas_centerX);
        make.top.equalTo(tipsLabel.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(100, 35));
     }];
    
    return _videoInterrupt_NetErrorView;
}


- (UIView*)videoInterrupt_CellularView{
    UIView *_videoInterrupt_CellularView = [[UIView alloc] initWithFrame:self.bounds];
    _videoInterrupt_CellularView.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.5);
    [self addSubview:_videoInterrupt_CellularView];

    UILabel *tipsLabel = [[UILabel alloc] init];
    tipsLabel.font = kSystemFont(12);
    tipsLabel.textColor = [UIColor whiteColor];
    tipsLabel.text = @"当前处于移动网络环境";
    [_videoInterrupt_CellularView addSubview:tipsLabel];
    
    UIButton *cellularNetConfirmButton = [UIButton buttonWithType:(UIButtonTypeSystem)];
    [cellularNetConfirmButton setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:[UIColor clearColor] borderColor:[UIColor whiteColor] borderWidth:1 cornerRadius:14] forState:UIControlStateNormal];
    [cellularNetConfirmButton setTitle:@"继续播放" forState:UIControlStateNormal];
    cellularNetConfirmButton.titleLabel.font = kSystemFont(14);
    [cellularNetConfirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cellularNetConfirmButton addTarget:self action:@selector(cellularNetPlay:) forControlEvents:UIControlEventTouchUpInside];
    [_videoInterrupt_CellularView addSubview:cellularNetConfirmButton];
    
    [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       make.centerX.equalTo(_videoInterrupt_CellularView.mas_centerX);
       make.centerY.equalTo(_videoInterrupt_CellularView.mas_centerY).offset(-20);
    }];
     
     [cellularNetConfirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(_videoInterrupt_CellularView.mas_centerX);
        make.top.equalTo(tipsLabel.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(111, 28));
     }];
    return _videoInterrupt_CellularView;
}
@end
