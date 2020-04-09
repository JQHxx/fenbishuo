//
//  BaseViewController.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "BaseViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "CTFNetErrorView.h"

@interface BaseViewController () <UIGestureRecognizerDelegate> {
    UIButton      *backBtn;
    UILabel       *titleLabel;
}

@property (nonatomic, assign) ERRORTYPE errorType;
@property (nonatomic, strong) CTFNetErrorView *errorView;
@property (nonatomic, assign) CGRect errorViewFrame;

// 是否使用小尺寸的错误占位图（根据UI要求网络错误的占位图大小不统一）
@property (nonatomic, assign) BOOL isLittleIconModel_errorView;

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationController.interactivePopGestureRecognizer.enabled=YES;
    self.navigationController.interactivePopGestureRecognizer.delegate=(id)self;
    
    [self.navigationController setNavigationBarHidden:YES];
    self.fd_prefersNavigationBarHidden = YES;
    
    [self customNavBar];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:NSStringFromClass([self class])];
}

#pragma mark -- Event response
#pragma mark 左侧按钮事件
-(void)leftNavigationItemAction{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 右侧按钮事件
-(void)rightNavigationItemAction{
    
}

#pragma mark 刷新数据
-(void)baseRefreshData{
    
}

#pragma mark -- Public methods
#pragma mark 显示
-(void)showNetErrorViewWithType:(ERRORTYPE)type whetherLittleIconModel:(BOOL)isLittleIconModel frame:(CGRect)frame {
    self.errorType = type;
    self.isLittleIconModel_errorView = isLittleIconModel;
    self.errorViewFrame = frame;
    [self.view addSubview:self.errorView];
}

#pragma mark 隐藏
-(void)hideNetErrorView{
    if (self.errorView) {
        [self.errorView removeFromSuperview];
        self.errorView = nil;
    }
}

#pragma mark --Private Methods
#pragma mark 自定义导航栏
-(void)customNavBar{
    UIView *navView=[[UIView alloc] init];
    navView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navView];
    self.baseNavView = navView;
    [self.baseNavView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kStatusBar_Height);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(kNavBar_Height - kStatusBar_Height);
    }];
    
    backBtn=[[UIButton alloc] init];
    [backBtn setImage:ImageNamed(@"app_navback_btn") forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(0,-10.0, 0, 0)];
    [backBtn addTarget:self action:@selector(leftNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    [self.baseNavView addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5);
        make.centerY.mas_equalTo(self.baseNavView.centerY);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    titleLabel =[[UILabel alloc] init];
    titleLabel.textColor=[UIColor ctColor33];
    titleLabel.font=[UIFont mediumFontWithSize:18];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    [self.baseNavView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(60);
        make.centerY.mas_equalTo(self.baseNavView.centerY);
        make.right.mas_equalTo(-60);
        make.height.mas_equalTo(22);
    }];
    
    self.rightBtn=[[UIButton alloc] init];
    [self.rightBtn addTarget:self action:@selector(rightNavigationItemAction) forControlEvents:UIControlEventTouchUpInside];
    [self.baseNavView addSubview:self.rightBtn];
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-5);
        make.centerY.mas_equalTo(self.baseNavView.centerY);
        make.size.mas_equalTo(CGSizeMake(50, 40));
    }];
}

#pragma mark -- Setters
#pragma mark 设置是否隐藏导航栏
-(void)setIsHiddenNavBar:(BOOL)isHiddenNavBar{
    _isHiddenNavBar = isHiddenNavBar;
    self.baseNavView.hidden = isHiddenNavBar;
}

#pragma mark 设置是否隐藏返回按钮
-(void)setIsHiddenBackBtn:(BOOL)isHiddenBackBtn{
    _isHiddenBackBtn = isHiddenBackBtn;
    backBtn.hidden = isHiddenBackBtn;
}

#pragma makr 设置导航栏左侧按钮图片
-(void)setLeftImageName:(NSString *)leftImageName{
    _leftImageName=leftImageName;
    if (!kIsEmptyString(leftImageName)) {
        backBtn.hidden=NO;
        [backBtn setImage:ImageNamed(leftImageName) forState:UIControlStateNormal];
    }
}
#pragma mark 设置导航栏左侧按钮文字
- (void)setLeftTitleName:(NSString *)leftTitleName{
    _leftTitleName = leftTitleName;
    [backBtn setTitle:leftTitleName forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor ctColor33] forState:UIControlStateNormal];
    backBtn.titleLabel.font=[UIFont regularFontWithSize:16];
    backBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [backBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
}

#pragma mark 设置标题
-(void)setBaseTitle:(NSString *)baseTitle{
    _baseTitle=baseTitle;
    titleLabel.text=baseTitle;
}

#pragma mark 设置导航栏右侧按钮图片
-(void)setRightImageName:(NSString *)rightImageName{
    _rightImageName=rightImageName;
    if (!kIsEmptyString(rightImageName)) {
        [self.rightBtn setImage:ImageNamed(rightImageName) forState:UIControlStateNormal];
    }else{
        [self.rightBtn setImage:nil forState:UIControlStateNormal];
    }
}

#pragma mark 设置导航栏右侧按钮文字
-(void)setRigthTitleName:(NSString *)rigthTitleName{
    _rigthTitleName=rigthTitleName;
    self.rightBtn.enabled = !kIsEmptyString(rigthTitleName);
    
    [self.rightBtn setTitle:rigthTitleName forState:UIControlStateNormal];
    [self.rightBtn setTitleColor:[UIColor ctMainColor] forState:UIControlStateNormal];
    [self.rightBtn setTitleColor:UIColorFromHEXWithAlpha(0xFF6885, 0.4f) forState:UIControlStateDisabled];
    self.rightBtn.titleLabel.font = [UIFont regularFontWithSize:16];
    self.rightBtn.titleLabel.textAlignment=NSTextAlignmentCenter;
}

- (CTFNetErrorView *)errorView {
    if (!_errorView) {
        _errorView = [[CTFNetErrorView alloc] initWithFrame:self.errorViewFrame errorType:self.errorType whetherLittleIconModel:self.isLittleIconModel_errorView];
        [_errorView.refreshBtn addTarget:self action:@selector(baseRefreshData) forControlEvents:UIControlEventTouchUpInside];
    }
    return _errorView;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
