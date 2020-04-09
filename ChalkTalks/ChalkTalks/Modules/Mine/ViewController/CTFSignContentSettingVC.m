//
//  CTFSignContentSettingVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/17.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFSignContentSettingVC.h"
#import "CTFWordLimit.h"
#import "NSObject+Routes.h"
#import "NSDictionary+Safety.h"
#import "CTFMineViewModel.h"
#import "CTFCommonManager.h"
#import <UITextView+Placeholder.h>
#import "CTFTextView.h"

@interface CTFSignContentSettingVC () <UITextViewDelegate>
@property (nonatomic, strong) CTFTextView *signContentTextField;
@property (nonatomic, strong) UILabel *reminderLabel;
@property (nonatomic, strong) CTFMineViewModel *adpater;

@end

@implementation CTFSignContentSettingVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.baseTitle = @"更改签名";
    self.rigthTitleName = @"保存";
    
    self.adpater = [[CTFMineViewModel alloc] init];
    [self setupViewContent];
    [self textViewDidChange:self.signContentTextField];
}

- (void)setupViewContent {
    UIView *bgview = [[UIView alloc] init];
    bgview.layer.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0].CGColor;
    [self.view addSubview:bgview];
    [bgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kNavBar_Height);
        make.left.mas_equalTo(self.view.mas_left);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(102);
    }];
    
    self.signContentTextField = [[CTFTextView alloc] init];
    self.signContentTextField.forbidMenuView = YES;
    self.signContentTextField.placeholder = @"请输入签名";
    self.signContentTextField.placeholderColor = UIColorFromHEX(0xCCCCCC);
    self.signContentTextField.text = self.orignSignContentString;
    self.signContentTextField.backgroundColor = UIColorFromHEX(0xF8F8F8);
    self.signContentTextField.delegate = self;
    self.signContentTextField.font = [UIFont systemFontOfSize:16];
    self.signContentTextField.textColor = UIColorFromHEX(0x333333);
    self.signContentTextField.returnKeyType = UIReturnKeyDone;
    [bgview addSubview:self.signContentTextField];
    [self.signContentTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgview.mas_top).offset(12);
        make.left.mas_equalTo(bgview.mas_left).offset(8);
        make.right.mas_equalTo(bgview.mas_right).offset(-8);
    }];
    
    self.reminderLabel = [[UILabel alloc] init];
    self.reminderLabel.font = [UIFont systemFontOfSize:12];
    self.reminderLabel.textColor = UIColorFromHEX(0xCCCCCC);
    [bgview addSubview:self.reminderLabel];
    [self.reminderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.signContentTextField.mas_bottom).offset(12);
        make.right.mas_equalTo(bgview.mas_right).offset(-12);
        make.bottom.mas_equalTo(bgview.mas_bottom).offset(-12);
    }];
}

- (void)rightNavigationItemAction{
    [self.signContentTextField resignFirstResponder];
    //没有网络直接不进行任何操作
    if ([[CTFNetReachabilityManager sharedInstance] currentNetStatus] == AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:@"请检查网络"];
        return ;
    }
    
    if (![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }

    @weakify(self);
    [self.adpater svr_reviseMineUserMessageByHeadLine:self.signContentTextField.text name:nil gender:nil avatarImageId:0 complete:^(BOOL isSuccess) {
        @strongify(self);
        if (isSuccess) {
            [CTFCommonManager sharedCTFCommonManager].userInfoLoad = YES;
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            /* 2.1.8 昵称、个性签名服务器加入了敏感词过滤，如果保存失败统一处理成Alert弹框 */
            //[self.view makeToast:self.adpater.errorString];
            [self signContentSaveFailed];
        }
    }];
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView == self.signContentTextField) {
        //个性签名，25字
        [CTFWordLimit computeWordCountWithTextView:textView warningLabel:self.reminderLabel maxNumber:25];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self rightNavigationItemAction];
        return NO;
    }
    return YES;
}

- (void)signContentSaveFailed {
    NSString *title = @"操作不成功\n请修改或稍后再试";
    NSString *message = @"";
    NSString *cancelButtonTitle = @"确定";

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {

    }];

    [cancelAction setValue:UIColorFromHEX(0x999999) forKey:@"titleTextColor"];
    
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
