//
//  LoginViewController.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginViewModel.h"
#import "UIColor+DefColors.h"
#import "UIImage+Ext.h"
#import "UILabel+LineSpace.h"
#import "UIView+Common.h"
#import "WXApi.h"
#import "PhoneLoginViewController.h"
#import <AVFoundation/AVFoundation.h>

#import "ChalkTalks-Swift.h"

CGFloat static const bgImgScale = 750.0/2604.0;

@interface LoginViewController () <UITextViewDelegate>
@property (nonatomic, strong) LoginViewModel *adapter;
@property (nonatomic, strong) UIButton *loginBtn;           //微信登录按钮
@property (nonatomic, strong) UIButton *userAgreementBtn;   //用户协议按钮
@property (nonatomic, strong) MBProgressHUD *loadingHUD;

@property (nonatomic, assign, readwrite) BOOL isContinueBindPhone;// 登录成功后是否需要继续进行绑定手机号

@property (nonatomic, strong) UIImageView *bgImg;       //
@property (nonatomic, strong) UIImageView *nextBgImg;   //
@property (nonatomic, assign) BOOL animateFailed;       //

@property (nonatomic, strong) AVPlayer *avPlayer;       //

@property (nonatomic, strong) UIViewController *myPresentingVC;

@end

@implementation LoginViewController

#pragma mark - 控制器生命周期
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenNavBar = YES;
    self.isContinueBindPhone = [self.schemaArgu[@"isContinueBindPhone"] boolValue];
    [self setupViewContent];
    self.adapter = [[LoginViewModel alloc] init];
    [self setupMonitor];
    self.myPresentingVC = self.presentingViewController;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self moveBgImgCheckInViewWillAppear];
}

#pragma mark - 监听事件
/* 监听微信登录授权失败的通知 */
- (void)setupMonitor {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxLoginErrorAction) name:kWechatLoginFailedNotification object:nil];
}

/* 微信登录授权失败响应事件 */
- (void)wxLoginErrorAction {
    [self.loadingHUD hideAnimated:YES];
    [self.view makeToast:@"微信登录失败"];
}

#pragma mark - UI
- (void)setupViewContent {
    // 背景墙（视频循环 或者 图片轮播）
    if (![self addLogonVideoBg]) {
        [self addBgimgs];
        UIView *hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Width/bgImgScale)];
        hudView.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.6);
        [self.view addSubview:hudView];
    }
    // 登录粉笔说体验更多功能-image
    UIImageView *img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"login_img_title_148x54"]];
    [self.view addSubview:img];
    [img mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(168);
        make.centerX.mas_equalTo(0);
        make.height.mas_equalTo(54);
        make.width.mas_equalTo(148);
    }];
    // 登录按钮
    [self.view addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom).mas_offset(-170);
        } else {
            make.bottom.mas_equalTo(-170);
        }
        make.height.mas_equalTo(46);
        make.left.mas_equalTo(73);
        make.right.mas_equalTo(-73);
    }];
    //
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"icon_nav_goBack_white_20x20"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(noLoginBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(52, 52));
        make.left.mas_equalTo(self.view.mas_left).offset(7);
        make.top.mas_equalTo(self.view.mas_top).offset(24);
    }];
    // 用户协议查看按钮
    [self.view addSubview:self.userAgreementBtn];
    [self.userAgreementBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom).mas_offset(-24);
        } else {
            make.bottom.mas_equalTo(-24);
        }
        make.centerX.mas_equalTo(0);
    }];
}

#pragma mark - 背景循环播放视频
- (BOOL)addLogonVideoBg {
    // 本地视频播放
    NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"loginVideo" ofType:@"mp4"];
    if (audioPath == nil) {
        return NO;
    } else {
        UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
        backgroundImageView.image = [UIImage imageNamed:@"loginVideoSnip"];
        [self.view addSubview:backgroundImageView];
        
        NSURL *url = [NSURL fileURLWithPath:audioPath];
        // 设置播放的项目
        AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:url];
        // 初始化player对象
        self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:item];
        // 设置播放页面
        AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
        // 设置播放页面的大小
        layer.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
        layer.backgroundColor = [UIColor clearColor].CGColor;
        // 设置播放窗口和当前视图之间的比例显示内容
        layer.videoGravity = AVLayerVideoGravityResize;
        // 添加播放视图到self.view
        [self.view.layer addSublayer:layer];
        // 视频播放
        [self.avPlayer play];
        // 添加播放完成通知
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(runLoopTheMovie:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.avPlayer.currentItem];
        return YES;
    }
}

/* 接收播放完成的通知 */
- (void)runLoopTheMovie:(NSNotification *)notification {
    AVPlayerItem *playerItem = notification.object;
    [playerItem seekToTime:kCMTimeZero];
    [self.avPlayer play];
}

#pragma mark - 处理背景移动图片

- (UIImageView *)bgImg {
    if (!_bgImg) {
        _bgImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginView_bg_img"]];
        _bgImg.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Width/bgImgScale);
        _bgImg.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _bgImg;
}

- (UIImageView *)nextBgImg {
    if (!_nextBgImg) {
        _nextBgImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"loginView_bg_img"]];
        _nextBgImg.frame = CGRectMake(0, kScreen_Width/bgImgScale, kScreen_Width, kScreen_Width/bgImgScale);
        _nextBgImg.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _nextBgImg;
}

- (void)addBgimgs {
    [self.view addSubview:self.bgImg];
    [self.view addSubview:self.nextBgImg];
    [self moveBgImg];
}

- (void)moveBgImgCheckInViewWillAppear {
    if (self.animateFailed) {
        self.bgImg.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Width/bgImgScale);
        self.nextBgImg.frame = CGRectMake(0, kScreen_Width/bgImgScale, kScreen_Width, kScreen_Width/bgImgScale);
        [self moveBgImg];
        self.animateFailed = NO;
    }
}

- (void)moveBgImg {
    @weakify(self);
    [UIView animateWithDuration:25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        @strongify(self);
        [self.bgImg setY:-self.bgImg.frame.size.height];
        [self.nextBgImg setY:self.nextBgImg.frame.origin.y - self.bgImg.frame.size.height];
    } completion:^(BOOL finished) {
        @strongify(self);
        if (finished) {
            [self.bgImg setY:self.bgImg.frame.size.height];
            [self moveNextBgImg];
            self.animateFailed = NO;
        } else {
            self.animateFailed = YES;
        }
    }];
}

- (void)moveNextBgImg {
    @weakify(self);
    [UIView animateWithDuration:25 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        @strongify(self);
        [self.nextBgImg setY:-self.bgImg.frame.size.height];
        [self.bgImg setY:self.bgImg.frame.origin.y - self.bgImg.frame.size.height];
    } completion:^(BOOL finished) {
        @strongify(self);
        if (finished) {
            [self.nextBgImg setY:self.bgImg.frame.size.height];
            [self moveBgImg];
            self.animateFailed = NO;
        } else {
            self.animateFailed = YES;
        }
    }];
}

#pragma mark - 登录按钮
- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_loginBtn setTitle:@"微信登录" forState: UIControlStateNormal];
        [_loginBtn setTitleColor: UIColorFromHEX(0xFFFFFF) forState: UIControlStateNormal];
        [_loginBtn setImage:[UIImage imageNamed:@"login_btn_wechat_16x14"] forState:UIControlStateNormal];
        [_loginBtn ctfLayoutButtonWithEdgeInsetsStyle:CTFButtonEdgeInsetsType_ImageLeft imageTitleSpace:3];
        _loginBtn.layer.cornerRadius = 23;
        [_loginBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor: UIColorFromHEXWithAlpha(0xFF6885, 0.5) cornerRadius:23] forState: UIControlStateNormal];
        [_loginBtn addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _loginBtn;
}

#pragma mark 查看用户协议按钮
- (UIButton *)userAgreementBtn {
    if (!_userAgreementBtn) {
        _userAgreementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"登录表明已阅读并同意《粉笔说使用条款和隐私政策》"attributes: @{NSFontAttributeName: [UIFont systemFontOfSize:12],NSForegroundColorAttributeName: UIColorFromHEX(0x999999)}];
        [attString addAttributes:@{NSForegroundColorAttributeName: UIColorFromHEX(0x999999)} range:NSMakeRange(0, 10)];
        [attString addAttributes:@{NSForegroundColorAttributeName: UIColorFromHEX(0xFF6885)} range:NSMakeRange(10, 14)];
        [_userAgreementBtn setAttributedTitle:attString forState:UIControlStateNormal];
        [_userAgreementBtn addTarget:self action:@selector(userAgreementBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _userAgreementBtn;
}

#pragma mark HUD
- (MBProgressHUD *)loadingHUD {
    if (!_loadingHUD) {
        _loadingHUD = [MBProgressHUD ctfShowLoading:nil title:nil];
    }
    return _loadingHUD;
}

#pragma mark - 点击微信登录按钮
- (void)loginAction {
    if (![[CTENVConfig share] enablePhoneLogin] && [WXApi isWXAppInstalled]) {
        //没有网络直接不进行任何操作
        if ([[CTFNetReachabilityManager sharedInstance] currentNetStatus] == AFNetworkReachabilityStatusNotReachable) {
            [self.view makeToast:@"请检查网络！"];
            return;
        }
        [MobClick event:@"login_wechat"];
        @weakify(self);
        [self.adapter wechatAuthorizationLogin:^(BOOL isSuccess) {
            @strongify(self);
            [self.loadingHUD hideAnimated:YES];
            if (isSuccess) {
                [UserCache uploadUserDeviceInfoWithAppLaunching:NO]; //上传设备信息
                if (self.isContinueBindPhone && ([UserCache isUserLogined] == UserLoginStatus_UnBindPhone)) {
                    /* 登录完成需要继续绑定手机号 && 没有绑手机号 */
                    @weakify(self);
                    [self dismissViewControllerAnimated:YES completion:^{
                        @strongify(self);
                        [self.myPresentingVC ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded];
                    }];
                } else if (self.isContinueBindPhone && [UserCache isUserLogined] == UserLoginStatus_BindPhone) {
                    /* 登录完成需要继续绑定手机号 && 已经绑定手机号 */
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    /* 登录完成不需要继续绑定手机号 */
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            } else {
                ZLLog(@"%@",self.adapter.errorString);
            }
        }];
    } else {
        // 跳转到手机号码登录##只是为了测试强制使用手机号登录[[CTENVConfig share] enablePhoneLogin]
        PhoneLoginViewController *phoneLoginViewController = [[PhoneLoginViewController alloc] initWithFunctionType:CTFFunctionType_Login];
        [self presentViewController:phoneLoginViewController animated:YES completion:nil];
    }
}

#pragma mark 点击暂不登录按钮
- (void)noLoginBtnAction {
    [MobClick event:@"login_tourist"];
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

#pragma mark 跳转到用户协议界面
- (void)userAgreementBtnAction {
    [ROUTER routeByCls:@"CTFUserAgreementVC"];
}

@end
