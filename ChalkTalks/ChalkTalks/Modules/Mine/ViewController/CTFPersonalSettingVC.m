//
//  CTFPersonalSettingVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/16.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFPersonalSettingVC.h"
#import "CTFMineViewModel.h"
#import "LoginViewModel.h"
#import "ChalkTalks-Swift.h"

#import <AliyunOSSiOS/OSSService.h>
#import "AliOSSTokenCache.h"
#import "CTFPublishTopicViewModel.h"
#import "CTFCommonManager.h"
#import "CTFImageUpload.h"
#import "CTFSignContentSettingVC.h"
#import "CTFNickNameSettingVC.h"

@interface CTFPersonalSettingVC () <CTFImageUploadDelegate>
@property (nonatomic, strong) UIControl *headSettingControl;
@property (nonatomic, strong) UIImageView *headImageView;

@property (nonatomic, strong) UIControl *nickNameSettingControl;
@property (nonatomic, strong) UILabel *nickNameLabel;

@property (nonatomic, strong) UIControl *signSettingControl;
@property (nonatomic, strong) UILabel *signLabel;

@property (nonatomic, strong) UIControl *sexSettingControl;
@property (nonatomic, strong) UIImageView *sexSignImageView;
@property (nonatomic, strong) UILabel *sexSignInfoLabel;

@property (nonatomic, strong) UIButton *womanSelectBtn;
@property (nonatomic, strong) UIButton *manSelectBtn;

@property (nonatomic, strong) UIButton *loginOutButton;

@property (nonatomic, strong) CTFMineViewModel *adpater;

@property (nonatomic, strong) LoginViewModel *loginVM;

@property (nonatomic, strong) CTFPublishTopicViewModel *publishTopicVM;

@property (nonatomic, strong) MBProgressHUD *loadingHUD;

@property (nonatomic, strong) UIImage *selectedImage;

@end

@implementation CTFPersonalSettingVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self downData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.baseTitle = @"资料编辑";
    [self setupData];
    [self setupViewContent];
}

//数据初始化
- (void)setupData {
    self.adpater = [[CTFMineViewModel alloc] init];
    self.loginVM = [[LoginViewModel alloc] init];
    self.publishTopicVM = [[CTFPublishTopicViewModel alloc] init];
}

//网路获取用户信息
- (void)downData {
    @weakify(self);
    [self.adpater svr_fetchMineUserMessage:^(BOOL isSuccess) {
        @strongify(self);
        [UserCache saveUserInfo:self.adpater.currentUserMessage];
        [self fillDataToView];
    }];
}

//界面刷新
- (void)fillDataToView {
    if (self.selectedImage) {
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:UserCache.getUserInfo.avatarUrl] placeholderImage:self.selectedImage];
    } else {
        [self.headImageView sd_setImageWithURL:[NSURL URLWithString:UserCache.getUserInfo.avatarUrl] placeholderImage:[UIImage imageNamed:@"placeholder_head_78x78"]];
    }
    
    self.nickNameLabel.text = UserCache.getUserInfo.name;
    
    self.signLabel.text = UserCache.getUserInfo.headline.length>0 ? UserCache.getUserInfo.headline : @"添加签名，让大家更好的认识你。";
    
    [self refresh_genderView:UserCache.getUserInfo.gender];
}

//界面搭建
- (void)setupViewContent {
    //头像
    self.headSettingControl = [[UIControl alloc] init];
    self.headSettingControl.backgroundColor = [UIColor whiteColor];
    [self.headSettingControl addTarget:self action:@selector(headSettingControlAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.headSettingControl];
    [self.headSettingControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kNavBar_Height);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
        make.height.mas_equalTo(83);
    }];
    
    UILabel *headTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 30, 34, 22)];
    headTitleLabel.text = @"头像";
    headTitleLabel.font = [UIFont systemFontOfSize:16];
    headTitleLabel.textColor = UIColorFromHEX(0x333333);
    [self.headSettingControl addSubview:headTitleLabel];
    
    self.headImageView = [[UIImageView alloc] init];
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:UserCache.getUserInfo.avatarUrl] placeholderImage:[UIImage imageNamed:@"placeholder_head_78x78"]];
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = 33;
    [self.headSettingControl addSubview:self.headImageView];
    [self.headImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.headSettingControl.mas_right).offset(-37);
        make.size.mas_equalTo(CGSizeMake(69, 69));
        make.centerY.mas_equalTo(self.headSettingControl.mas_centerY);
    }];
    
    UIImageView *toDetailImageView0 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_back_turnRight_10_14"]];
    [self.headSettingControl addSubview:toDetailImageView0];
    [toDetailImageView0 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.headSettingControl.mas_right).offset(-17);
        make.size.mas_equalTo(CGSizeMake(10, 14));
        make.centerY.mas_equalTo(self.headSettingControl.mas_centerY);
    }];
    
    UIView *lineView1 = [[UIView alloc] init];
    lineView1.backgroundColor = UIColorFromHEXWithAlpha(0xEEEEEE, 0.49);
    [self.headSettingControl addSubview:lineView1];
    [lineView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headSettingControl.mas_left);
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(self.headSettingControl.mas_width);
        make.bottom.mas_equalTo(self.headSettingControl.mas_bottom);
    }];
    
    //昵称
    self.nickNameSettingControl = [[UIControl alloc] init];
    self.nickNameSettingControl.backgroundColor = [UIColor whiteColor];
    [self.nickNameSettingControl addTarget:self action:@selector(nickNameSettingControlAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nickNameSettingControl];
    [self.nickNameSettingControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headSettingControl.mas_bottom).offset(0);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
        make.height.mas_equalTo(64);
    }];
    
    UILabel *nickNameTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 22, 34, 22)];
    nickNameTitleLabel.text = @"昵称";
    nickNameTitleLabel.font = [UIFont systemFontOfSize:16];
    nickNameTitleLabel.textColor = UIColorFromHEX(0x333333);
    [self.nickNameSettingControl addSubview:nickNameTitleLabel];
    
    self.nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, kScreen_Width - 100, 22)];
    self.nickNameLabel.text = UserCache.getUserInfo.name;
    self.nickNameLabel.textAlignment = NSTextAlignmentRight;
    self.nickNameLabel.font = [UIFont systemFontOfSize:16];
    self.nickNameLabel.textColor = UIColorFromHEX(0x999999);
    [self.nickNameSettingControl addSubview:self.nickNameLabel];
    
    UIImageView *toDetailImageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_back_turnRight_10_14"]];
    [self.nickNameSettingControl addSubview:toDetailImageView2];
    [toDetailImageView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.nickNameSettingControl.mas_right).offset(-17);
        make.size.mas_equalTo(CGSizeMake(10, 14));
        make.centerY.mas_equalTo(self.nickNameSettingControl.mas_centerY);
    }];
    
    UIView *lineView2 = [[UIView alloc] init];
    lineView2.backgroundColor = UIColorFromHEXWithAlpha(0xEEEEEE, 0.49);
    [self.nickNameSettingControl addSubview:lineView2];
    [lineView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.nickNameSettingControl.mas_left);
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(self.nickNameSettingControl.mas_width);
        make.bottom.mas_equalTo(self.nickNameSettingControl.mas_bottom);
    }];

    //签名
    self.signSettingControl = [[UIControl alloc] init];
    self.signSettingControl.backgroundColor = [UIColor whiteColor];
    [self.signSettingControl addTarget:self action:@selector(signSettingControlAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.signSettingControl];
    [self.signSettingControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.nickNameSettingControl.mas_bottom).offset(0);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
        make.height.mas_equalTo(64);
    }];
    
    UILabel *signTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 22, 34, 22)];
    signTitleLabel.text = @"签名";
    signTitleLabel.font = [UIFont systemFontOfSize:16];
    signTitleLabel.textColor = UIColorFromHEX(0x333333);
    [self.signSettingControl addSubview:signTitleLabel];
    
    self.signLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 20, kScreen_Width - 100, 22)];
    self.signLabel.text = UserCache.getUserInfo.headline;
    self.signLabel.font = [UIFont systemFontOfSize:16];
    self.signLabel.textColor = UIColorFromHEX(0x999999);
    self.signLabel.textAlignment = NSTextAlignmentRight;
    [self.signSettingControl addSubview:self.signLabel];
    
    UIImageView *toDetailImageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_back_turnRight_10_14"]];
    [self.signSettingControl addSubview:toDetailImageView3];
    [toDetailImageView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.signSettingControl.mas_right).offset(-17);
        make.size.mas_equalTo(CGSizeMake(10, 14));
        make.centerY.mas_equalTo(self.signSettingControl.mas_centerY);
    }];
    
    UIView *lineView3 = [[UIView alloc] init];
    lineView3.backgroundColor = UIColorFromHEXWithAlpha(0xEEEEEE, 0.49);
    [self.signSettingControl addSubview:lineView3];
    [lineView3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.signSettingControl.mas_left);
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(self.signSettingControl.mas_width);
        make.bottom.mas_equalTo(self.signSettingControl.mas_bottom);
    }];
    
    //性别
    self.sexSettingControl = [[UIControl alloc] init];
    self.sexSettingControl.backgroundColor = [UIColor whiteColor];
    [self.sexSettingControl addTarget:self action:@selector(alertSexSettingView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sexSettingControl];
    [self.sexSettingControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.signSettingControl.mas_bottom).offset(0);
        make.left.mas_equalTo(self.view.mas_left).offset(0);
        make.right.mas_equalTo(self.view.mas_right).offset(0);
        make.height.mas_equalTo(64);
    }];
    
    UILabel *sexTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 22, 34, 22)];
    sexTitleLabel.text = @"性别";
    sexTitleLabel.font = [UIFont systemFontOfSize:16];
    sexTitleLabel.textColor = UIColorFromHEX(0x333333);
    [self.sexSettingControl addSubview:sexTitleLabel];
    
    self.sexSignImageView = [[UIImageView alloc] init];
    [self.sexSettingControl addSubview:self.sexSignImageView];
    [self.sexSignImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.sexSettingControl.mas_right).offset(-71);
        make.size.mas_equalTo(CGSizeMake(26, 26));
        make.centerY.mas_equalTo(self.sexSettingControl.mas_centerY);
    }];
    
    self.sexSignInfoLabel = [[UILabel alloc] init];
    self.sexSignInfoLabel.font = [UIFont systemFontOfSize:16];
    [self.sexSignInfoLabel setTextColor:UIColorFromHEX(0x999999)];
    [self.sexSettingControl addSubview:self.sexSignInfoLabel];
    [self.sexSignInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.sexSettingControl.mas_centerY);
        make.left.mas_equalTo(self.sexSignImageView.mas_right).offset(10);
    }];
    
    [self refresh_genderView:UserCache.getUserInfo.gender];
    
    UIImageView *toDetailImageView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_back_turnRight_10_14"]];
    [self.sexSettingControl addSubview:toDetailImageView4];
    [toDetailImageView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.sexSettingControl.mas_right).offset(-17);
        make.size.mas_equalTo(CGSizeMake(10, 14));
        make.centerY.mas_equalTo(self.sexSettingControl.mas_centerY);
    }];
    
    UIView *lineView4 = [[UIView alloc] init];
    lineView4.backgroundColor = UIColorFromHEXWithAlpha(0xEEEEEE, 0.49);
    [self.sexSettingControl addSubview:lineView4];
    [lineView4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sexSettingControl.mas_left);
        make.height.mas_equalTo(1);
        make.width.mas_equalTo(self.sexSettingControl.mas_width);
        make.bottom.mas_equalTo(self.sexSettingControl.mas_bottom);
    }];
    
    self.loginOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginOutButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [self.loginOutButton setTitleColor:UIColorFromHEX(0xFF5757) forState:UIControlStateNormal];
    self.loginOutButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.loginOutButton.layer.borderColor = UIColorFromHEX(0xEEEEEE).CGColor;
    self.loginOutButton.layer.cornerRadius = 25;
    self.loginOutButton.layer.borderWidth = 1;
    [self.loginOutButton addTarget:self action:@selector(loginOutButtonAvtion) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginOutButton];
    [self.loginOutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(273, 50));
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-112);
    }];
}

//头像设置
- (void)headSettingControlAction {
    if (![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return;
    }
    [MobClick event:@"profile_img"];
    @weakify(self);
    CTImagePickerController *imgPicker =
    [[CTImagePickerController alloc] initWithSelectedCount:8
                                           didSelectImages:^(NSArray<UIImage *> * _Nonnull images) {
        @strongify(self);
        UIImage *image = images.firstObject;
        self.selectedImage = image;
        
        CTFImageUpload *imageUpload = [[CTFImageUpload alloc] initWithImage:image delegate:self];
        [imageUpload uploadImage];
        [self.loadingHUD showAnimated:YES];
    }];
    imgPicker.needShowPhotoEdit = YES;
    [self presentViewController:imgPicker animated:TRUE completion:nil];
}

//设置昵称
- (void)nickNameSettingControlAction {
    [MobClick event:@"profile_nickname"];
    CTFNickNameSettingVC *nickNameSettingVC = [[CTFNickNameSettingVC alloc] init];
    nickNameSettingVC.orignNickNameString = UserCache.getUserInfo.name;
    [self.navigationController pushViewController:nickNameSettingVC animated:YES];
}

//设置签名
- (void)signSettingControlAction {
    [MobClick event:@"profile_signature"];
    CTFSignContentSettingVC *signContentSettingVC = [[CTFSignContentSettingVC alloc] init];
    signContentSettingVC.orignSignContentString = UserCache.getUserInfo.headline;
    [self.navigationController pushViewController:signContentSettingVC animated:YES];
}

//退出登录
- (void)loginOutButtonAvtion {
    [MobClick event:@"profile_logout"];
    NSString *title = @"退出后，将无法收到消息推送，无法点赞和评论";
    NSString *message = @"";
    NSString *cancelButtonTitle = @"取消";
    NSString *otherButtonTitle = @"确认退出";

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

    }];
    
    @weakify(self);
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        @strongify(self);
        [self.loadingHUD showAnimated:YES];
        @weakify(self);
        [self.loginVM logout:^(BOOL isSuccess) {
            @strongify(self);
            [self.loadingHUD hideAnimated:YES];
            if (isSuccess) {
                [UserCache clearUserCache];
                [self.tabBarController setSelectedIndex:0];
                [self.navigationController popToRootViewControllerAnimated:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutedNotification object:nil];
                
                if (![[UIViewController getWindowsCurrentVC] ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Logined]) {
                    return;
                }
                
//                if (![UserCache isUserLogined]) {
//                    [ROUTER routeByCls:kLoginViewController param:@{@"isContinueBindPhone" : [NSNumber numberWithBool:NO]} animation:false presentWithNavBar:true];
//                    return;
//                }
            }else {
                [self.view makeToast:@"服务器忙，请稍后再试"];
            }
        }];
    }];
    
    [otherAction setValue:UIColorFromHEX(0x999999) forKey:@"titleTextColor"];
    [cancelAction setValue:UIColorFromHEX(0xFF6885) forKey:@"titleTextColor"];
    
    [alertController addAction:otherAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//选择性别
- (void)alertSexSettingView {
    [MobClick event:@"profile_gender"];
    NSString *title = @"";
    NSString *message = @"选择性别";
    NSString *manButtonTitle = @"男";
    NSString *womenButtonTitle = @"女";
    NSString *cancelButtonTitle = @"取消";

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *manButtonAction = [UIAlertAction actionWithTitle:manButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
            return;
        }
        if (![UserCache.getUserInfo.gender isEqualToString:@"male"]) {
            
            [self.sexSignImageView setImage:[UIImage imageNamed:@"icon_gender_male"]];
            [self.sexSignInfoLabel setText:@"男"];
            [self revise_gender:@"male"];
        }
    }];
    
    UIAlertAction *womenButtonAction = [UIAlertAction actionWithTitle:womenButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        if (![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
            return;
        }
        if (![UserCache.getUserInfo.gender isEqualToString:@"female"]) {
            [self.sexSignImageView setImage:[UIImage imageNamed:@"icon_gender_female"]];
            [self.sexSignInfoLabel setText:@"女"];
            [self revise_gender:@"female"];
        }
    }];
    
    UIAlertAction *cancelButtonAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    [alertController addAction:manButtonAction];
    [alertController addAction:womenButtonAction];
    [alertController addAction:cancelButtonAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

//设置性别的网络请求
- (void)revise_gender:(NSString *)gender {
    
    @weakify(self);
    [self.adpater svr_reviseMineUserMessageByHeadLine:nil name:nil gender:gender avatarImageId:0 complete:^(BOOL isSuccess) {
        @strongify(self);
        if (!isSuccess) {
            [self refresh_genderView:self.adpater.currentUserMessage.gender];
        } else {
            [CTFCommonManager sharedCTFCommonManager].userInfoLoad = YES;
            [self downData];
        }
    }];
}

- (void)refresh_genderView:(NSString *)gender {
    
    if ([gender isEqualToString:@"male"]) {
        
        [self.sexSignImageView setImage:[UIImage imageNamed:@"icon_gender_male"]];
        [self.sexSignInfoLabel setText:@"男"];
        
    } else if ([gender isEqualToString:@"female"]) {
        
        [self.sexSignImageView setImage:[UIImage imageNamed:@"icon_gender_female"]];
        [self.sexSignInfoLabel setText:@"女"];
        
    } else {
        [self.sexSignImageView setImage:[UIImage imageNamed:@""]];
        [self.sexSignInfoLabel setText:@""];
    }
}

#pragma mark - CTFImageUploadDelegate

//上传OSS过程中
- (void)uploadImageProgress:(UploadImageFileModel *)fileModel progress:(CGFloat)progress {
}

//Error != nil：图片检测失败 或者 上传OSS失败
//Error == nil：图片已经存在 或者 上传OSS成功
- (void)didFinishedUploadImage:(UploadImageFileModel *)fileModel error:(NSError * __nullable)error {
    
    if (error == nil) {
        if (![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
            [self.loadingHUD hideAnimated:YES];
            return;
        }
        @weakify(self);
        [self.adpater svr_reviseMineUserMessageByHeadLine:nil name:nil gender:nil avatarImageId:[fileModel.imageId integerValue] complete:^(BOOL isSuccess) {
            @strongify(self);
            [CTFCommonManager sharedCTFCommonManager].userInfoLoad = YES;
            [self.loadingHUD hideAnimated:YES];
            if (isSuccess) {
                [self downData];
            }else {
                [self.loadingHUD hideAnimated:YES];
                [self.view makeToast:self.adpater.errorString];
            }
        }];
    } else {
        [self.loadingHUD hideAnimated:YES];
    }
}

- (MBProgressHUD *)loadingHUD {
    if (!_loadingHUD) {
        _loadingHUD = [MBProgressHUD ctfShowLoading:self.view title:nil];
    }
    return _loadingHUD;
}

@end
