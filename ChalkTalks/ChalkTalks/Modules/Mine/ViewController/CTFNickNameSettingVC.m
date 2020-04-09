//
//  CTFNickNameSettingVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/17.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFNickNameSettingVC.h"
#import "CTFMineViewModel.h"
#import "CTFMineViewModel.h"
#import "CTFWordLimit.h"
#import "CTFCommonManager.h"
#import <FBRetainCycleDetector.h>

@interface CTFNickNameSettingVC ()
@property (nonatomic, strong) UITextField *nickNameTextField;
@property (nonatomic, strong) CTFMineViewModel *adpater;
@end

@implementation CTFNickNameSettingVC


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.baseTitle = @"更改昵称";
    self.rigthTitleName = @"保存";
    
    self.adpater = [[CTFMineViewModel alloc] init];
    [self setupViewContent];
    
    /*
    FBRetainCycleDetector *detector = [FBRetainCycleDetector new];
    [detector addCandidate:self];
    NSSet *retainCycles = [detector findRetainCycles];
    NSLog(@"%@", retainCycles);
     */
}


- (void)setupViewContent {
    UIView *bgview = [[UIView alloc] init];
    bgview.layer.backgroundColor = [UIColor colorWithRed:248/255.0 green:248/255.0 blue:248/255.0 alpha:1.0].CGColor;
    [self.view addSubview:bgview];
    [bgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kNavBar_Height);
        make.left.mas_equalTo(self.view.mas_left);
        make.width.mas_equalTo(self.view.mas_width);
        make.height.mas_equalTo(60);
    }];
    
    self.nickNameTextField = [[UITextField alloc] init];
    self.nickNameTextField.placeholder = @"请输入昵称";
    [self.nickNameTextField addTarget:self action:@selector(nickNameTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    self.nickNameTextField.backgroundColor = UIColorFromHEX(0xF8F8F8);
    self.nickNameTextField.text = self.orignNickNameString;
    [bgview addSubview:self.nickNameTextField];
    [self.nickNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(bgview.mas_top);
        make.left.mas_equalTo(bgview.mas_left).offset(20);
        make.right.mas_equalTo(bgview.mas_right).offset(-20);;
        make.height.mas_equalTo(60);
    }];
}

- (void)rightNavigationItemAction{
    [self.nickNameTextField resignFirstResponder];
    //没有网络直接不进行任何操作
    if ([[CTFNetReachabilityManager sharedInstance] currentNetStatus] == AFNetworkReachabilityStatusNotReachable) {
        [self.view makeToast:@"请检查网络！"];
        return ;
    }
    
    if (self.nickNameTextField.text.length == 0) {
        [self.view makeToast:@"昵称不能设置为空及纯空格"];
        return ;
    }
    
    if ([self.nickNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0) {
        [self.view makeToast:@"昵称不能设置为空及纯空格"];
        return ;
    }
    
    if (![self ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    
    @weakify(self);
    [self.adpater svr_reviseMineUserMessageByHeadLine:nil name:self.nickNameTextField.text gender:nil avatarImageId:0 complete:^(BOOL isSuccess) {
        @strongify(self);
        if (isSuccess) {
            [CTFCommonManager sharedCTFCommonManager].userInfoLoad = YES;
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            /* 2.1.8 昵称、个性签名服务器加入了敏感词过滤，如果保存失败统一处理成Alert弹框 */
            //[self.view makeToast:self.adpater.errorString];
            [self nickNameSaveFailed];
        }
    }];
}

- (void)nickNameTextFieldChanged {    
    [CTFWordLimit computeWordCountWithTextField:self.nickNameTextField maxNumber:8];
}

- (void)dealloc{
    self.nickNameTextField = nil;
}

- (void)nickNameSaveFailed {
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
