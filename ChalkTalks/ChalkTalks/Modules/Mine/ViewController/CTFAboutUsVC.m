//
//  CTFAboutUsVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/18.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFAboutUsVC.h"
#import "AppInfo.h"
#import "AppUtils.h"
#import "CTFFeedBackVC.h"

@interface CTFAboutUsVC ()

@end

@implementation CTFAboutUsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseNavView.backgroundColor = UIColorFromHEX(0xF1F1F1);
    self.baseTitle = @"关于我们";
    self.view.backgroundColor = UIColorFromHEX(0xF1F1F1);
    [self setupViewContent];
}

- (void)setupViewContent {
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_fenbishuo"]];
    [self.view addSubview:logoImageView];
    [logoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.top.mas_equalTo(kNavBar_Height+52);
        make.size.mas_equalTo(CGSizeMake(85, 85));
    }];
    
    UILabel *versionLabel = [[UILabel alloc] init];
    versionLabel.text = [NSString stringWithFormat:@"粉笔说版本 v%@",[AppInfo appVersion]];
    versionLabel.font = [UIFont systemFontOfSize:16];
    versionLabel.textColor = UIColorFromHEX(0x999999);
    [self.view addSubview:versionLabel];
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(logoImageView.mas_bottom).offset(30);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    
    UILabel *versionCheckLabel = [[UILabel alloc] init];
    versionCheckLabel.text = @"当前为最新版本";
    versionCheckLabel.font = [UIFont boldSystemFontOfSize:18];
    versionCheckLabel.textColor = UIColorFromHEX(0x333333);
    [self.view addSubview:versionCheckLabel];
    [versionCheckLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(versionLabel.mas_bottom).offset(9);
        make.centerX.mas_equalTo(self.view.mas_centerX);
    }];
    // 使用条款和隐私政策
    UIButton *agreementBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [agreementBtn addTarget:self action:@selector(agreementBtnAction) forControlEvents:UIControlEventTouchUpInside];
    agreementBtn.backgroundColor = UIColorFromHEX(0xFFFFFF);
    [agreementBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:UIColorFromHEX(0xFAFAFA) cornerRadius:0] forState:UIControlStateHighlighted];
    [self.view addSubview:agreementBtn];
    [agreementBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(versionCheckLabel.mas_bottom).offset(90);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 60));
        make.left.mas_equalTo(self.view.mas_left);
    }];
    
    UILabel *agreementLabel = [[UILabel alloc] init];
    agreementLabel.font = [UIFont systemFontOfSize:16];
    agreementLabel.textColor = UIColorFromHEX(0x666666);
    agreementLabel.text = @"使用条款和隐私政策";
    [agreementBtn addSubview:agreementLabel];
    [agreementLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(agreementBtn.mas_left).offset(17);
        make.centerY.mas_equalTo(agreementBtn.mas_centerY);
    }];
    
    UIImageView *turnRightImage1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_arrow_turnright_8x14"]];
    [agreementBtn addSubview:turnRightImage1];
    [turnRightImage1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(agreementBtn.mas_right).offset(-16);
        make.centerY.mas_equalTo(agreementBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(8, 14));
    }];
    // 投诉
    UIButton *complaintBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [complaintBtn addTarget:self action:@selector(complaintBtnAction) forControlEvents:UIControlEventTouchUpInside];
    complaintBtn.backgroundColor = UIColorFromHEX(0xFFFFFF);
    [complaintBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:UIColorFromHEX(0xFAFAFA) cornerRadius:0] forState:UIControlStateHighlighted];
    [self.view addSubview:complaintBtn];
    [complaintBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(agreementBtn.mas_bottom).offset(1);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 60));
        make.left.mas_equalTo(self.view.mas_left);
    }];
    
    UILabel *complaintLabel = [[UILabel alloc] init];
    complaintLabel.font = [UIFont systemFontOfSize:16];
    complaintLabel.textColor = UIColorFromHEX(0x666666);
    complaintLabel.text = @"投诉";
    [complaintBtn addSubview:complaintLabel];
    [complaintLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(complaintBtn.mas_left).offset(17);
        make.centerY.mas_equalTo(complaintBtn.mas_centerY);
    }];
    
    UIImageView *turnRightImage2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_arrow_turnright_8x14"]];
    [complaintBtn addSubview:turnRightImage2];
    [turnRightImage2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(complaintBtn.mas_right).offset(-16);
        make.centerY.mas_equalTo(complaintBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(8, 14));
    }];
    // 举报电话
    UIButton *telephoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [telephoneBtn addTarget:self action:@selector(telephoneBtnAction) forControlEvents:UIControlEventTouchUpInside];
    telephoneBtn.backgroundColor = UIColorFromHEX(0xFFFFFF);
    [telephoneBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:UIColorFromHEX(0xFAFAFA) cornerRadius:0] forState:UIControlStateHighlighted];
    [self.view addSubview:telephoneBtn];
    [telephoneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(complaintBtn.mas_bottom).offset(1);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 60));
        make.left.mas_equalTo(self.view.mas_left);
    }];
    
    UILabel *telephoneLabel = [[UILabel alloc] init];
    telephoneLabel.font = [UIFont systemFontOfSize:16];
    telephoneLabel.textColor = UIColorFromHEX(0x666666);
    telephoneLabel.text = @"不良内容举报电话";
    [telephoneBtn addSubview:telephoneLabel];
    [telephoneLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(telephoneBtn.mas_left).offset(17);
        make.top.mas_equalTo(telephoneBtn.mas_top).offset(13);
    }];
    
    UILabel *telephoneNumberLabel = [[UILabel alloc] init];
    telephoneNumberLabel.font = [UIFont systemFontOfSize:14];
    telephoneNumberLabel.textColor = UIColorFromHEX(0x999999);
    telephoneNumberLabel.text = @"0731-89707278";
    [telephoneBtn addSubview:telephoneNumberLabel];
    [telephoneNumberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(telephoneBtn.mas_left).offset(17);
        make.top.mas_equalTo(telephoneLabel.mas_bottom).offset(4);
    }];
    
    UIImageView *turnRightImage3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_arrow_turnright_8x14"]];
    [telephoneBtn addSubview:turnRightImage3];
    [turnRightImage3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(telephoneBtn.mas_right).offset(-16);
        make.centerY.mas_equalTo(telephoneBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(8, 14));
    }];
}

// TO DO:跳转到使用条约内容界面
- (void)agreementBtnAction {
    [ROUTER routeByCls:@"CTFUserAgreementVC"];
}

// TO DO:跳转到投诉界面
- (void)complaintBtnAction {
    CTFFeedBackVC *feedBackVC = [[CTFFeedBackVC alloc] initWithFeedBackType:FeedBackType_Complain feedBackContentType:-1 resourceTypeId:0];
    [self.navigationController pushViewController:feedBackVC animated:YES];
}

// TO DO:准备拨打投诉电话
- (void)telephoneBtnAction {
    [self telephoneActionAlertSheetView];
}

// 拨打电话SheetView
- (void)telephoneActionAlertSheetView {
    NSString *buttonTitle = @"呼叫（0731089707278）";
    NSString *cancelButtonTitle = @"取消";

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *buttonAction = [UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        // TO DO:拨打电话
        [AppUtils callPhoneWithNumber:@"0731089707278"];
    }];
    
    UIAlertAction *cancelButtonAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    [buttonAction setValue:UIColorFromHEX(0x0091FF) forKey:@"titleTextColor"];
    [cancelButtonAction setValue:UIColorFromHEX(0x999999) forKey:@"titleTextColor"];
    
    [alertController addAction:buttonAction];
    [alertController addAction:cancelButtonAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
