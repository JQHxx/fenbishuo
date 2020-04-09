//
//  PhoneLoginViewController.m
//  ChalkTalks
//
//  Created by 何雨晴 on 2019/12/5.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "PhoneLoginViewController.h"
#import "UIColor+DefColors.h"
#import "UIImage+Ext.h"
#import "LoginViewModel.h"

#import "ChalkTalks-Swift.h"

CGFloat static const bgImgScale = 750.0/2604.0;

@interface PhoneLoginViewController () <UIGestureRecognizerDelegate, UITextFieldDelegate>

@property (nonatomic, assign) CTFFunctionType functionType;

@property (nonatomic, strong) UILabel *headerLabel;             /* 标题 */
@property (nonatomic, strong) CTFTextField *phoneTf;            /* 手机号输入框 */
@property (nonatomic, strong) CTFTextField *codeTf;             /* 验证码输入框 */
@property (nonatomic, strong) CTFBlockButton *countDownBtn;     /* 获取验证码按钮 */
@property (nonatomic, strong) CTFBlockButton *commitBtn;        /* 提交按钮 */
@property (nonatomic, strong) UIImageView *animalImageView;     /* 小动物图案 */

@property (nonatomic, strong) RACDisposable *disposable;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, strong) LoginViewModel *adapter;

@property (nonatomic, strong) UIImageView *bgImg;       //
@property (nonatomic, strong) UIImageView *nextBgImg;   //
@property (nonatomic, assign) BOOL animateFailed;       //

@property (nonatomic, strong) AVPlayer *avPlayer;       //

#pragma mark - CSS By CTFFunctionType
@property (nonatomic, assign) BOOL isDisplayBackgroundMedia;  // 是否展示背景媒体（视频循环或者图片滚动）
@property (nonatomic, assign) BOOL isDisplayAnimalImage;      // 是否展示小动物图片
@property (nonatomic, copy) NSString *hederLabelText;         // 标题名
@property (nonatomic, copy) NSString *commitText;             // 提交按钮名称
@property (nonatomic, strong) UIColor *headerLabelColor;      // 标题文字的颜色
@property (nonatomic, strong) UIColor *inputBgColor;          // 手机号输入框、验证码输入框颜色
@property (nonatomic, strong) UIColor *inputTextColor;        // 手机号、验证码文字颜色
@property (nonatomic, strong) UIColor *commitBtnBgNormalColor;      // 提交按钮的背景颜色（正常状态）
@property (nonatomic, strong) UIColor *commitBtnBgDisabledColor;    // 提交按钮的背景颜色（不可点击）
@property (nonatomic, strong) UIColor *commitBtnTextNormalColor;    // 提交按钮的文字颜色（正常状态）
@property (nonatomic, strong) UIColor *commitBtnTextDisabledColor;  // 提交按钮的文字颜色（不可点击）
@property (nonatomic, copy) NSString *navBackBtnImageName;          // 导航栏后退按钮的image

@property (nonatomic, strong) UIColor *countDownBtnTextNormalColor;// 获取验证码按钮文字颜色（正常状态）
@property (nonatomic, strong) UIColor *countDownBtnTextDisabledColor;// 获取验证码按钮文字颜色（正常状态）

@property (nonatomic, assign) CGFloat toastAlpha;//Toast的背景透明度


@end

@implementation PhoneLoginViewController

- (instancetype)initWithFunctionType:(CTFFunctionType)functionType {
    if (self = [super init]) {
        self.functionType = functionType;
    }
    return self;
}

- (void)setupCSSByFunctionType:(CTFFunctionType)functionType {
    if (functionType == CTFFunctionType_Bind) {/* 绑定界面：白色背景 */
        self.isDisplayBackgroundMedia = NO;
        self.isDisplayAnimalImage = YES;
        self.hederLabelText = @"手机号绑定";
        
        self.headerLabelColor = UIColorFromHEX(0x333333);
        self.inputBgColor = UIColorFromHEXWithAlpha(0xF8F8F8, 1);
        self.inputTextColor = UIColorFromHEX(0x333333);
        
        // 提交按钮
        self.commitText = @"确认绑定";
        self.commitBtnBgNormalColor = UIColorFromHEXWithAlpha(0xFF6885, 1);
        self.commitBtnBgDisabledColor = UIColorFromHEXWithAlpha(0xFF6885, 0.5);
        self.commitBtnTextNormalColor = UIColorFromHEXWithAlpha(0xFFFFFF, 1);
        self.commitBtnTextDisabledColor = UIColorFromHEXWithAlpha(0xFFFFFF, 1);
        self.navBackBtnImageName = @"icon_nav_goBack_20x20";
        
        // 获取验证码按钮的文字
        self.countDownBtnTextNormalColor = UIColorFromHEX(0x333333);
        self.countDownBtnTextDisabledColor = UIColorFromHEX(0xCCCCCC);
        
        //
        self.toastAlpha = 1.f;
        
        
    } else {/* 登录界面：视频循环播放或者图片轮播 */
        self.isDisplayBackgroundMedia = YES;
        self.isDisplayAnimalImage = NO;
        self.hederLabelText = @"手机号登录";
        
        self.headerLabelColor = UIColorFromHEX(0xFFFFFF);
        self.inputBgColor = UIColorFromHEXWithAlpha(0xF8F8F8, 0.5);
        self.inputTextColor = UIColorFromHEX(0xFFFFFF);
        
        // 提交按钮
        self.commitText = @"确认登录";
        self.commitBtnBgNormalColor = UIColorFromHEXWithAlpha(0xFF6885, 0.5);
        self.commitBtnBgDisabledColor = UIColorFromHEXWithAlpha(0xFF6885, 0.4);
        self.commitBtnTextNormalColor = UIColorFromHEXWithAlpha(0xFFFFFF, 1);
        self.commitBtnTextDisabledColor = UIColorFromHEXWithAlpha(0xFFFFFF, 0.4);
        self.navBackBtnImageName = @"icon_nav_goBack_white_20x20";
        
        // 获取验证码按钮的文字
        self.countDownBtnTextNormalColor = UIColorFromHEX(0xFFFFFF);
        self.countDownBtnTextDisabledColor = UIColorFromHEX(0xCCCCCC);
        
        //
        self.toastAlpha = 0.5f;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self.phoneTf becomeFirstResponder];
    [self moveBgImgCheckInViewWillAppear];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self moveBgImgCheckInViewWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.phoneTf resignFirstResponder];
    [self.codeTf resignFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.layer.masksToBounds = YES;
    self.view.backgroundColor = UIColor.whiteColor;
    self.isHiddenNavBar = YES;
    self.adapter = [[LoginViewModel alloc]init];
    [self setupCSSByFunctionType:self.functionType];
    [self setupViewContent];
    if ([CTFSystemCache query_inputedPhoneNumber].length > 0) {
        self.phoneTf.text = [CTFSystemCache query_inputedPhoneNumber];
    }
    if (kAPPDELEGATE.countDownTime > 0) {
         [self countAction];/* 继续倒计时 */
    }
}

- (void)dealloc {
    [self.disposable dispose];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViewContent {
    // 背景墙（视频循环 或者 图片轮播）
    if (self.isDisplayBackgroundMedia) {
        if (![self addLogonVideoBg]) {
            [self addBgimgs];
            UIView *hudView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Width/bgImgScale)];
            hudView.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.6);
            [self.view addSubview:hudView];
        }
    }
    if (self.isDisplayAnimalImage) {
        [self.view addSubview:self.animalImageView];
        [self.animalImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.view.mas_right);
            make.size.mas_equalTo(CGSizeMake(91, 154));
            make.top.mas_equalTo(self.view.mas_top).offset(54);
        }];
    }
    //
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:self.navBackBtnImageName] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(leftNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(52, 52));
        make.left.mas_equalTo(self.view.mas_left).offset(7);
        make.top.mas_equalTo(self.view.mas_top).offset(24);
    }];
    //
    [self.view addSubview:self.headerLabel];
    [self.headerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kNavBar_Height+75);
        make.left.mas_equalTo(self.view.mas_left).offset(28);
    }];
    //
    UIView *lineView = [[UIView alloc]init];
    lineView.backgroundColor = self.inputBgColor;
    lineView.layer.cornerRadius = 23;
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerLabel.mas_bottom).offset(44);
        make.left.mas_equalTo(self.view.mas_left).offset(28);
        make.right.mas_equalTo(self.view.mas_right).offset(-28);
        make.height.mas_equalTo(46);
    }];
    //
    [lineView addSubview:self.phoneTf];
    [self.phoneTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(lineView.mas_centerY);
        make.left.mas_equalTo(lineView.mas_left).offset(20);
        make.right.mas_equalTo(lineView.mas_right).offset(-20);
    }];
    //
    UIView *lineView2 = [[UIView alloc]init];
    lineView2.backgroundColor = self.inputBgColor;
    lineView2.layer.cornerRadius = 23;
    [self.view addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineView.mas_bottom).offset(10);
        make.left.mas_equalTo(self.view.mas_left).offset(28);
        make.right.mas_equalTo(self.view.mas_right).offset(-28);
        make.height.mas_equalTo(46);
    }];
    //
    [lineView2 addSubview:self.countDownBtn];
    [self.countDownBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(lineView2.mas_centerY);
        make.right.mas_equalTo(lineView2.mas_right).offset(-15);
        make.width.mas_equalTo(80);
    }];
    //
    [lineView2 addSubview:self.codeTf];
    [self.codeTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(lineView2.mas_centerY);
        make.left.mas_equalTo(lineView2.mas_left).offset(20);
    }];
    //
    UIView *gapLineView = [[UIView alloc] init];
    gapLineView.backgroundColor = UIColorFromHEX(0xCCCCCC);
    [lineView2 addSubview:gapLineView];
    [gapLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(2, 16));
        make.right.mas_equalTo(self.countDownBtn.mas_left).offset(-15);
        make.centerY.mas_equalTo(lineView2.mas_centerY);
    }];
    //
    [self.view addSubview:self.commitBtn];
    [self.commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(lineView2.mas_bottom).offset(20);
        make.left.mas_equalTo(self.view.mas_left).offset(28);
        make.right.mas_equalTo(self.view.mas_right).offset(-28);
        make.height.mas_equalTo(46);
    }];

    [self addBottomText];
}

/* 用户协议的查看按钮 */
- (void)addBottomText {
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:@"登录表明已阅读并同意《粉笔说使用条款和隐私政策》"attributes: @{NSFontAttributeName: [UIFont systemFontOfSize:12],NSForegroundColorAttributeName: UIColorFromHEX(0x999999)}];
    [attString addAttributes:@{NSForegroundColorAttributeName: UIColorFromHEX(0x999999)} range:NSMakeRange(0, 10)];
    [attString addAttributes:@{NSForegroundColorAttributeName: UIColorFromHEX(0xFF6885)} range:NSMakeRange(10, 14)];
    [btn setAttributedTitle:attString forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showUserAgreementAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-24);
        } else {
            make.bottom.mas_equalTo(-24);
        }
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
}

/* 跳转到用户协议界面 */
- (void)showUserAgreementAction {
    [ROUTER routeByCls:@"CTFUserAgreementVC"];
}

#pragma mark - business

/* 手机号输入框的响应事件 */
- (void)phoneTfValueChangeAction {
    
    [CTFWordLimit computeWordCountWithTextField:self.phoneTf maxNumber:11];
    
    // 获取验证码按钮
    if (self.phoneTf.text.length == 11 && self.time == 0) {
        [self.countDownBtn setEnabled:YES];
    }else {
        [self.countDownBtn setEnabled:NO];
    }
    // 提交按钮
    if (self.phoneTf.text.length == 11 && self.codeTf.text.length == 4) {
        [self.commitBtn setEnabled:YES];
    }else {
        [self.commitBtn setEnabled:NO];
    }
}

/* 验证码输入框的响应事件 */
- (void)codeTfValueChangeAction {
    
    [CTFWordLimit computeWordCountWithTextField:self.codeTf maxNumber:4];
    // 提交按钮
    if (self.codeTf.text.length == 4 && self.phoneTf.text.length == 11) {
        [self.commitBtn setEnabled:YES];
        [self.codeTf resignFirstResponder];
        [self commitBtnAction];/* 当验证码输完第四位时，直接触发提交操作 */
    }else {
        [self.commitBtn setEnabled:NO];
    }
}

/* 告诉代理指定的textField已经开始编辑 */
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    if (textField == self.phoneTf) {
        // 获取验证码按钮
        if (self.phoneTf.text.length == 11 && self.time == 0) {
            [self.countDownBtn setEnabled:YES];
        } else {
            [self.countDownBtn setEnabled:NO];
        }
    }
    
    if (textField == self.codeTf) {
        // 当开始编辑验证码时，小动物闭眼
        self.animalImageView.image = [UIImage imageNamed:@"icon_loginAnimal2_91x154"];
    }
}

/* 告诉代理指定的textField已经开始编辑 */
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.codeTf) {
        // 当结束编辑验证码时，小动物睁眼
        self.animalImageView.image = [UIImage imageNamed:@"icon_loginAnimal1_91x154"];
    }
}

/* 告诉代理方法指定的text应不应该改变。textfiled会在用户输入内容改变的情况下调用 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (textField == self.phoneTf) {
        return [self checkNumInputShouldNumber:string];
    }else if (textField == self.codeTf) {
        return [self checkNumInputShouldNumber:string];
    }else {
        return YES;
    }
}

/* 进入倒计时 */
- (void)countAction {
    
    self.time = kAPPDELEGATE.countDownTime;
    self.countDownBtn.enabled = NO;
    [self.countDownBtn setTitle:[NSString stringWithFormat:@"%lds",self.time] forState:UIControlStateDisabled];
    @weakify(self);
    self.disposable = [[RACSignal interval:1.0 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
        @strongify(self);
        self.time--;
        NSString *text = (self.time > 0) ? [NSString stringWithFormat:@"%lds",self.time] : @"重新获取";
        if (self.time > 0) {
            self.countDownBtn.enabled = NO;
            [self.countDownBtn setTitle:text forState:UIControlStateDisabled];
        } else {
            [self.countDownBtn setTitle:text forState:UIControlStateNormal];
            [self.countDownBtn setTitle:[NSString stringWithFormat:@"重新获取"] forState:UIControlStateDisabled];
            //关掉信号
            [self.disposable dispose];
            if (self.phoneTf.text.length == 11) {
                self.countDownBtn.enabled = YES;
            }
        }
    }];
}

/* 网络请求-获取验证码 */
- (void)countDownBtnAction {
    
    self.codeTf.text = @"";
    
    if (self.phoneTf.text.length < 11 || ![[self.phoneTf.text substringToIndex:1] isEqualToString:@"1"]) {
        [self.view makeToast:@"请输入正确的手机号" duration:2.0 position:CSToastPositionCenter backgroundAlpha:self.toastAlpha];
        return;
    }
    
    [CTFSystemCache revise_inputedPhoneNumber:self.phoneTf.text];
    
    self.countDownBtn.enabled = NO;
    
    if (self.functionType == CTFFunctionType_Bind) {
        [MobClick event:@"login_wechat_getcode"];
    } else {
        [MobClick event:@"login_phone_getcode"];
    }
    
    NSString *getCodeType = self.functionType == CTFFunctionType_Bind ? @"bind" : @"login";
    
    @weakify(self)
    [self.adapter getCode:self.phoneTf.text type:getCodeType complete:^(NSString *code, NSInteger leftTime, NSError *error) {
        
        @strongify(self)
        if (error) { //失败
            if (error.code == 40030) {//验证码获取次数过于频繁，请1小时之后再试
                [self.view makeToast:[error.userInfo safe_stringForKey:NSLocalizedDescriptionKey] duration:2.0 position:CSToastPositionCenter backgroundAlpha:self.toastAlpha];
                self.countDownBtn.enabled = YES;
            } else if (error.code == 40031) {//该手机号今日验证码发送次数已达上限，请24小时之后再试
                [self.view makeToast: [error.userInfo safe_stringForKey:NSLocalizedDescriptionKey] duration:2.0 position:CSToastPositionCenter backgroundAlpha:self.toastAlpha];
                self.countDownBtn.enabled = YES;
            } else if (error.code == 4018) {//该手机号已被拉黑，请更换其他手机号
                [self.view makeToast:[error.userInfo safe_stringForKey:NSLocalizedDescriptionKey] duration:2.0 position:CSToastPositionCenter backgroundAlpha:self.toastAlpha];
                self.countDownBtn.enabled = YES;
            } else {
                [self.view makeToast:[error.userInfo safe_stringForKey:NSLocalizedDescriptionKey] duration:2.0 position:CSToastPositionCenter  backgroundAlpha:self.toastAlpha];
                self.countDownBtn.enabled = YES;
            }
        } else { //成功
            if (![[CTENVConfig share] isProdEnv]) {
                [self.view makeToast:code duration:2.0 position:CSToastPositionCenter backgroundAlpha:self.toastAlpha];
            }
            if (leftTime > 0) {/* 防止后端未正确放回leftTime，导致按钮不能点击 */
                kAPPDELEGATE.countDownTime = leftTime;
                [self countAction];
            } else {
                self.countDownBtn.enabled = YES;
            }
        }
    }];
}

/* 网路请求-登录 */
- (void)loginRequest {
    [self.view endEditing:YES];
    @weakify(self)
    [self.adapter phoneLoginAndRegister:self.phoneTf.text code:self.codeTf.text complete:^(BOOL isSuccess) {
        @strongify(self)
        if (isSuccess) {
            [UserCache uploadUserDeviceInfoWithAppLaunching:NO]; //上传设备信息
            [self dismissViewControllerAnimated:true completion:nil];
        } else {
            ZLLog(@"%@",self.adapter.errorString);
            if (self.adapter.serverErrorCode == 42207) {//验证码不正确
                /*[self.view makeToast:self.adapter.errorString duration:2.0 position:CSToastPositionCenter backgroundAlpha:self.toastAlpha];*/
                [self.view makeToast:@"请输入正确的验证码" duration:2.0 position:CSToastPositionCenter backgroundAlpha:self.toastAlpha];
            } else if (self.adapter.serverErrorCode == 42203) {//验证码已过期，请重新获取
                [self.view makeToast:self.adapter.errorString duration:2.0 position:CSToastPositionCenter backgroundAlpha:self.toastAlpha];
            } else {
                [self.view makeToast:self.adapter.errorString duration:2.0 position:CSToastPositionCenter backgroundAlpha:self.toastAlpha];
                /* 其中包括：
                 //验证码获取次数过于频繁，请1小时之后再试
                 self.adapter.serverErrorCode == 40030
                 
                 //该手机号今日验证码发送次数已达上限，请24小时之后再试
                 self.adapter.serverErrorCode == 40031
                 
                 //验证码输入次数过多，请1小时候后再试
                 self.adapter.serverErrorCode == 42208
                 */
            }
        }
    }];
}

/* 网路请求-绑定手机号 */
- (void)bindPhoneRequest {
    [self.view endEditing:YES];
    @weakify(self)
    [self.adapter bindPhone:self.phoneTf.text code:self.codeTf.text complete:^(BOOL isSuccess) {
        @strongify(self)
        if(isSuccess){
            [self dismissViewControllerAnimated:true completion:nil];
        } else {
            ZLLog(@"%@",self.adapter.errorString);
            if (self.adapter.serverErrorCode == 42207) {//验证码不正确
                /*[self.view makeToast:self.adapter.errorString duration:2.0 position:CSToastPositionCenter backgroundAlpha:self.toastAlpha];*/
                [self.view makeToast:@"请输入正确的验证码" duration:2.0 position:CSToastPositionCenter backgroundAlpha:self.toastAlpha];
            } else if (self.adapter.serverErrorCode == 42203) {//验证码已过期，请重新获取
                [self.view makeToast:self.adapter.errorString duration:2.0 position:CSToastPositionCenter backgroundAlpha:self.toastAlpha];
            }else{
                [self.view makeToast:self.adapter.errorString duration:2.0 position:CSToastPositionCenter backgroundAlpha:self.toastAlpha];
                /* 其中包括：
                 //验证码获取次数过于频繁，请1小时之后再试
                 self.adapter.serverErrorCode == 42230
                 
                 //该手机号今日验证码发送次数已达上限，请24小时之后再试
                 self.adapter.serverErrorCode == 42231
                 
                 //验证码输入次数过多，请1小时候后再试
                 self.adapter.serverErrorCode == 42208
                 */
            }
        }
    }];
}

/* 导航栏返回按钮响应事件 */
- (void)leftNavigationItemAction {
    @weakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        @strongify(self);
        [self.phoneTf resignFirstResponder];
        [self.codeTf resignFirstResponder];
    }];
}

/* 是否是0~9的数字检测 */
- (BOOL)checkNumInputShouldNumber:(NSString *)str {
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

#pragma mark - 懒加载

/* 标题Label */
- (UILabel *)headerLabel {
    if (!_headerLabel) {
        _headerLabel = [[UILabel alloc] init];
        _headerLabel.text = self.hederLabelText;
        _headerLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightSemibold];
        _headerLabel.textColor = self.headerLabelColor;
    }
    return _headerLabel;
}

/* 小动物图案 */
- (UIImageView *)animalImageView {
    if (!_animalImageView) {
        _animalImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_loginAnimal1_91x154"]];
    }
    return _animalImageView;
}

/* 手机号码输入框 */
- (UITextField *)phoneTf {
    if (!_phoneTf) {
        _phoneTf = [[CTFTextField alloc]init];
        _phoneTf.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        [_phoneTf addTarget:self action:@selector(phoneTfValueChangeAction) forControlEvents:UIControlEventEditingChanged];
        _phoneTf.textColor = self.inputTextColor;
        _phoneTf.delegate = self;
        NSMutableDictionary *attDic = [@{NSForegroundColorAttributeName:UIColorFromHEX(0xCCCCCC), NSFontAttributeName:[UIFont systemFontOfSize:17]} mutableCopy];
        NSMutableAttributedString *attPlace = [[NSMutableAttributedString alloc] initWithString:@"请输入手机号" attributes:attDic];
        _phoneTf.attributedPlaceholder = attPlace;
        _phoneTf.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _phoneTf;
}

/* 验证码输入框 */
- (UITextField *)codeTf {
    if (!_codeTf) {
        _codeTf = [[CTFTextField alloc]init];
        _codeTf.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        _codeTf.textColor = self.inputTextColor;
        _codeTf.delegate = self;
        [_codeTf addTarget:self action:@selector(codeTfValueChangeAction) forControlEvents:UIControlEventEditingChanged];
        NSMutableDictionary *attDic = [@{NSForegroundColorAttributeName:UIColorFromHEX(0xCCCCCC), NSFontAttributeName:[UIFont systemFontOfSize:17]} mutableCopy];
        NSMutableAttributedString *attPlace = [[NSMutableAttributedString alloc] initWithString:@"请输入验证码" attributes:attDic];
        _codeTf.attributedPlaceholder = attPlace;
        _codeTf.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _codeTf;
}

/* 获取验证码（倒计时）按钮 */
- (UIButton *)countDownBtn {
    if (!_countDownBtn) {
        _countDownBtn = [[CTFBlockButton alloc]init];
        [_countDownBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [_countDownBtn setTitleColor:self.countDownBtnTextNormalColor forState:UIControlStateNormal];
        [_countDownBtn setTitleColor:self.countDownBtnTextDisabledColor forState:UIControlStateDisabled];
        _countDownBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_countDownBtn setEventTimeInterval:3];
        [_countDownBtn addTarget:self action:@selector(countDownBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _countDownBtn;
}

/* 确认登录、绑定按钮 */
- (UIButton *)commitBtn {
    if (!_commitBtn) {
        _commitBtn = [[CTFBlockButton alloc]init];
        [_commitBtn setTitle:self.commitText forState:UIControlStateNormal];
        
        [_commitBtn setTitleColor:self.commitBtnTextNormalColor forState:UIControlStateNormal];
        [_commitBtn setTitleColor:self.commitBtnTextDisabledColor forState:UIControlStateDisabled];
        
        [_commitBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:self.commitBtnBgNormalColor cornerRadius:23] forState: UIControlStateNormal];
        [_commitBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:self.commitBtnBgDisabledColor cornerRadius:23] forState:UIControlStateDisabled];
        
        _commitBtn.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
        _commitBtn.enabled = false;
        [_commitBtn setEventTimeInterval:2];
        [_commitBtn addTarget:self action:@selector(commitBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commitBtn;
}

/* 提交按钮的点击事件 */
- (void)commitBtnAction {
    if (self.functionType == CTFFunctionType_Bind) {
        [self bindPhoneRequest];
    } else {
        [MobClick event:@""];
        [self loginRequest];
    }
}

/* 点击空白处收起键盘 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.phoneTf resignFirstResponder];
    [self.codeTf resignFirstResponder];
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

@end
