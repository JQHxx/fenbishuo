//
//  CTFFeedBackVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/18.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFFeedBackVC.h"
#import <UITextView+Placeholder.h>
#import "CTFAddPhotosCollectionView.h"
#import "CTFPublishImageItemCCell.h"
#import "CTFFeedbackViewModel.h"
#import "UIView+Frame.h"
#import "CTFWordLimit.h"

@interface CTFFeedBackVC () <UITextViewDelegate, CTFAddPhotosCollectionViewDelegate> {
    UIScrollView                *rootScrollView;
    UITextView                  *myTextView;
    UILabel                     *textLab;   //字数限制
    UILabel                     *titleLabel;
    CTFAddPhotosCollectionView  *imgsCollectionView;
}

@property (nonatomic, strong) CTFFeedbackViewModel     *myViewModel;

@property (nonatomic, assign) FeedBackType feedBackType;
@property (nonatomic, copy) NSString *reportType_name;
@property (nonatomic, assign) FeedBackContentType feedBackContentType;
@property (nonatomic, copy) NSString *feedBackContentType_name;
@property (nonatomic, assign) NSInteger resourceTypeId;

@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UIButton *commitBtn;

@end

@implementation CTFFeedBackVC

- (instancetype)initWithFeedBackType:(FeedBackType)feedBackType
                 feedBackContentType:(FeedBackContentType)feedBackContentType
                      resourceTypeId:(NSInteger)resourceTypeId {
    if (self = [super init]) {
        self.feedBackType = feedBackType;
        self.feedBackContentType = feedBackContentType;
        self.resourceTypeId = resourceTypeId;
        [self setHidesBottomBarWhenPushed:YES];
        //
        if (feedBackType == FeedBackType_Question) {
            self.reportType_name = @"question";
        } else if (feedBackType == FeedBackType_Answer) {
            self.reportType_name = @"answer";
        } else if (feedBackType == FeedBackType_Comment) {
            self.reportType_name = @"comment";
        } else if (feedBackType == FeedBackType_Reply) {
            self.reportType_name = @"comment";
        }
        
        // 导航栏title设置
        if (feedBackType == FeedBackType_FeedBack) {
            self.feedBackContentType_name = @"向我们反馈";
        } else if (feedBackType == FeedBackType_Complain) {
            self.feedBackContentType_name = @"投诉";
        } else {
            if (feedBackContentType == FeedBackContentType_Politics) {
                self.feedBackContentType_name = @"举报-政治敏感、违法违规";
            } else if (feedBackContentType == FeedBackContentType_Sexy) {
                self.feedBackContentType_name = @"举报-色情低俗、少儿不宜";
            } else if (feedBackContentType == FeedBackContentType_Garbage) {
                self.feedBackContentType_name = @"举报-垃圾广告、售卖伪劣";
            } else if (feedBackContentType == FeedBackContentType_Copyright) {
                self.feedBackContentType_name = @"举报-盗用作品、版权问题";
            } else if (feedBackContentType == FeedBackContentType_Other) {
                self.feedBackContentType_name = @"举报-其他";
            }
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = self.feedBackContentType_name;
    self.myViewModel = [[CTFFeedbackViewModel alloc] init];
    [self setFeedbackContentView];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [CTFWordLimit computeWordCountWithTextView:myTextView maxNumber:500];
    /* 2.1.7 如果是举报（话题、回答、评论、回复），由于已经选择了举报内容的类型，因此没有填写其他内容也可以提交 */
    if (self.feedBackType == FeedBackType_Question || self.feedBackType ==FeedBackType_Answer || self.feedBackType == FeedBackType_Comment || self.feedBackType ==FeedBackType_Reply) {
        self.commitBtn.enabled = YES;
    } else {
        /* 2.1.8 如果是反馈和投诉，描述问题（大于一个字）和上传图片（大于一张），二选一就可以提交 */
        if (textView.text.length > 0 || [imgsCollectionView uploadedImageIds].count > 0) {
            self.commitBtn.enabled = YES;
        } else {
            self.commitBtn.enabled = NO;
        }
    }
    textLab.text = [NSString stringWithFormat:@"%ld/500",textView.text.length];
}

#pragma mark -- Event response
#pragma mark 提交
- (void)commitBtnAction {
    // 去掉前后空格
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    // 问题描述
    NSString *contentDesc = myTextView.text;
    contentDesc = [contentDesc stringByTrimmingCharactersInSet:set];
    
    // 联系邮箱
    NSString *emailDesc = self.emailTextField.text;
    emailDesc = [emailDesc stringByTrimmingCharactersInSet:set];
    
    if (![imgsCollectionView uploadAllSucceed]) {
        [self.view makeToast:@"图片还未全部上传"];
        return;
    }
    
    if (contentDesc.length > 500) {
        [self.view makeToast:@"反馈内容不能超过500字"];
        return;
    }
    
    /* 2.1.7 如果是举报（话题、回答、评论、回复），由于已经选择了举报内容的类型，因此没有填写其他内容也可以提交 */
    if (self.feedBackType == FeedBackType_Question || self.feedBackType ==FeedBackType_Answer || self.feedBackType == FeedBackType_Comment || self.feedBackType ==FeedBackType_Reply) {
    } else {
        /* 2.1.8 如果是反馈和投诉，描述问题（大于一个字）和上传图片（大于一张），二选一就可以提交 */
        if (contentDesc.length > 0 || [imgsCollectionView uploadedImageIds].count > 0) {
        } else {
            [self.view makeToast:@"反馈内容不能为空"];
            return;
        }
    }
    
    NSArray *imgIds = [imgsCollectionView uploadedImageIds];
    MBProgressHUD *hub = [MBProgressHUD ctfShowLoading:self.view title:@"提交中..."];
    if (self.feedBackType == FeedBackType_FeedBack) {
        @weakify(self);
        [self.myViewModel createFeedbackWithContent:contentDesc imageIds:imgIds email:emailDesc complete:^(BOOL isSuccess) {
            @strongify(self);
            [hub hideAnimated:NO];
            if(isSuccess){
                [kKeyWindow makeToast:@"反馈提交成功" duration:1.5 position:CSToastPositionBottom];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self.view makeToast:self.myViewModel.errorString];
            }
        }];
    } else if (self.feedBackType == FeedBackType_Complain) {
        @weakify(self);
        [self.myViewModel createComplainWithContent:contentDesc imageIds:imgIds email:emailDesc complete:^(BOOL isSuccess) {
            @strongify(self);
            [hub hideAnimated:NO];
            if(isSuccess){
                [kKeyWindow makeToast:@"投诉提交成功" duration:1.5 position:CSToastPositionBottom];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [self.view makeToast:self.myViewModel.errorString];
            }
        }];
    } else {
        @weakify(self);
        [self.myViewModel createReportsWithResourceId:self.resourceTypeId resourceType:self.reportType_name feedbackTitle:self.feedBackContentType_name Content:contentDesc imageIds:imgIds email:emailDesc complete:^(BOOL isSuccess) {
            @strongify(self);
            [hub hideAnimated:NO];
            if (isSuccess) {
                [kKeyWindow makeToast:@"举报成功" duration:1.5 position:CSToastPositionBottom];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self.view makeToast:self.myViewModel.errorString];
            }
        }];
    }
}

#pragma mark 界面搭建
-(void)setFeedbackContentView{
    rootScrollView = [[UIScrollView alloc] init];
    rootScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [rootScrollView setShowsVerticalScrollIndicator:NO];
    rootScrollView.alwaysBounceVertical = YES;
    [self.view addSubview:rootScrollView];
    [rootScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-48-20);
        } else {
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-48-20);
        }
        make.left.mas_equalTo(self.view.mas_left);
        make.top.mas_equalTo(self.baseNavView.mas_bottom);
        make.width.mas_equalTo(kScreen_Width);
    }];
    
    UIView *contentView = [[UIView alloc] init];
    [rootScrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(rootScrollView);
        make.width.mas_equalTo(rootScrollView.mas_width);
    }];
    #pragma mark - 描述问题
    NSString *mainTitle = @"描述问题";
    UILabel *mainTitleLabel = [[UILabel alloc] init];
    mainTitleLabel.text = mainTitle;
    mainTitleLabel.font = [UIFont boldSystemFontOfSize:15];
    mainTitleLabel.textColor = UIColorFromHEX(0x666666);
    [contentView addSubview:mainTitleLabel];
    [mainTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(contentView.mas_top).offset(kMarginTop);
        make.left.mas_equalTo(contentView.mas_left).offset(kMarginLeft);
    }];
    //
    UIView *myTextBgView = [[UIView alloc] init];
    myTextBgView.backgroundColor = UIColorFromHEX(0xF1F1F1);
    myTextBgView.layer.cornerRadius = 6;
    [contentView addSubview:myTextBgView];
    [myTextBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(mainTitleLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(contentView.mas_left).offset(kMarginLeft);
        make.width.mas_equalTo(kScreen_Width-2*kMarginLeft);
        make.height.mas_equalTo(160);
    }];
    
    //
    myTextView = [[UITextView alloc] init];
    myTextView.backgroundColor = UIColorFromHEX(0xF1F1F1);
    myTextView.font = [UIFont regularFontWithSize:15];
    myTextView.textColor = [UIColor ctColor66];
    /* 产品要求：只有是“向我们反馈”界面，才显示占位文字 */
    if (self.feedBackType == FeedBackType_FeedBack) {
        NSString *str = @"请写下你对“粉笔说”的意见与反馈，我们会关注并处理，感谢支持！";
        NSDictionary *attributeDict = @{NSFontAttributeName:[UIFont regularFontWithSize:15.0],NSForegroundColorAttributeName:[UIColor ctColor99]};
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:str];
        [attributeStr addAttributes:attributeDict range:NSMakeRange(0, str.length)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.lineSpacing = 0;
        [attributeStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, str.length)];
        myTextView.attributedPlaceholder = attributeStr;
    }
    myTextView.delegate = self;
    [myTextBgView addSubview:myTextView];
    [myTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(myTextBgView.mas_top).offset(10);
        make.left.mas_equalTo(myTextBgView.mas_left).offset(12);
        make.right.mas_equalTo(myTextBgView.mas_right).offset(-12);
        make.bottom.mas_equalTo(myTextBgView.mas_bottom).offset(-25);
    }];
    //
    textLab = [[UILabel alloc] init];
    textLab.backgroundColor = UIColorFromHEX(0xF1F1F1);
    textLab.font = [UIFont regularFontWithSize:12];
    textLab.textColor = [UIColor ctColor99];
    textLab.text = @"0/500";
    textLab.textAlignment = NSTextAlignmentRight;
    [myTextBgView addSubview:textLab];
    [textLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(myTextBgView.mas_right).offset(-12);
        make.height.mas_equalTo(25);
        make.bottom.mas_equalTo(myTextBgView.mas_bottom);
    }];
    #pragma mark - 邮箱
    NSString *emailTitle = @"邮箱";
    UILabel *emailTitleLabel = [[UILabel alloc] init];
    emailTitleLabel.textColor = UIColorFromHEX(0x666666);
    emailTitleLabel.font = [UIFont boldSystemFontOfSize:15];
    emailTitleLabel.text = emailTitle;
    [contentView addSubview:emailTitleLabel];
    [emailTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentView.mas_left).offset(kMarginLeft);
        make.top.mas_equalTo(myTextBgView.mas_bottom).offset(30);
        make.width.mas_equalTo(kScreen_Width-2*kMarginLeft);
        make.height.mas_equalTo(22);
    }];
    
    UILabel * emailTitleInfoLabel = [[UILabel alloc] init];
    emailTitleInfoLabel.textColor = UIColorFromHEX(0x999999);
    emailTitleInfoLabel.font = [UIFont regularFontWithSize:14];
    emailTitleInfoLabel.text = @"我们会尽快回复你，请记得查收邮件哦";
    [contentView addSubview:emailTitleInfoLabel];
    [emailTitleInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentView.mas_left).offset(kMarginLeft);
        make.top.mas_equalTo(emailTitleLabel.mas_bottom).offset(6);
        make.width.mas_equalTo(kScreen_Width-2*kMarginLeft);
        make.height.mas_equalTo(22);
    }];
    
    self.emailTextField = [[UITextField alloc] init];
    self.emailTextField.backgroundColor = UIColorFromHEX(0xF1F1F1);
    self.emailTextField.font = [UIFont systemFontOfSize:15];
    self.emailTextField.textColor = UIColorFromHEX(0x333333);
    self.emailTextField.layer.cornerRadius = 6;
    self.emailTextField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 46)];
    self.emailTextField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 46)];
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    self.emailTextField.rightViewMode = UITextFieldViewModeAlways;
    [contentView addSubview:self.emailTextField];
    [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentView.mas_left).offset(kMarginLeft);
        make.top.mas_equalTo(emailTitleInfoLabel.mas_bottom).offset(12);
        make.width.mas_equalTo(kScreen_Width-2*kMarginLeft);
        make.height.mas_equalTo(46);
    }];
    #pragma mark - 上传截图
    NSString *imageTitle = @"上传截图";
    UILabel *imageTitleLabel = [[UILabel alloc] init];
    imageTitleLabel.textColor = UIColorFromHEX(0x666666);
    imageTitleLabel.font = [UIFont boldSystemFontOfSize:15];
    imageTitleLabel.text = imageTitle;
    [contentView addSubview:imageTitleLabel];
    [imageTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentView.mas_left).offset(kMarginLeft);
        make.top.mas_equalTo(self.emailTextField.mas_bottom).offset(30);
        make.width.mas_equalTo(kScreen_Width-2*kMarginLeft);
        make.height.mas_equalTo(22);
    }];
    
    titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = UIColorFromHEX(0x999999);
    titleLabel.font = [UIFont regularFontWithSize:14];
    titleLabel.text = @"界面截图有助于我们更准确地理解你的问题";
    [contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentView.mas_left).offset(kMarginLeft);
        make.top.mas_equalTo(imageTitleLabel.mas_bottom).offset(6);
        make.width.mas_equalTo(kScreen_Width-2*kMarginLeft);
        make.height.mas_equalTo(22);
    }];
    //
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    imgsCollectionView = [[CTFAddPhotosCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    imgsCollectionView.showText = NO;
//    imgsCollectionView.nonFullScreen = self.nonFullScreen;
    imgsCollectionView.backgroundColor = [UIColor whiteColor];
    imgsCollectionView.viewDelegate = self;
    [contentView addSubview:imgsCollectionView];
    [imgsCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentView.mas_left).offset(kMarginLeft);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(10);
        make.width.mas_equalTo(kScreen_Width-2*kMarginLeft);
        make.height.mas_equalTo(3*([CTFPublishImageItemCCell itemSize].height+kMutiImagesSpace));
    }];
    
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(imgsCollectionView.mas_bottom);
    }];
    
    //
    self.commitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.commitBtn setTitle:@"提交" forState:UIControlStateNormal];
    [self.commitBtn setTitleColor:UIColorFromHEX(0xFFFFFF) forState:UIControlStateNormal];
    [self.commitBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self.commitBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:UIColorFromHEX(0xFF6885) cornerRadius:4] forState:UIControlStateNormal];
    [self.commitBtn setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:UIColorFromHEXWithAlpha(0xFF6885, 0.4) cornerRadius:4] forState:UIControlStateDisabled];
    self.commitBtn.layer.cornerRadius = 4;
    /* 2.1.7 如果是举报（话题、回答、评论、回复），由于已经选择了举报内容的类型，因此没有填写其他内容也可以提交 */
    if (self.feedBackType == FeedBackType_Question || self.feedBackType ==FeedBackType_Answer || self.feedBackType == FeedBackType_Comment || self.feedBackType ==FeedBackType_Reply) {
        self.commitBtn.enabled = YES;
    } else {
        self.commitBtn.enabled = NO;
    }
    [self.commitBtn addTarget:self action:@selector(commitBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.commitBtn];
    [self.commitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.bottom.mas_equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-5);
        } else {
            make.bottom.mas_equalTo(self.view.mas_bottom).offset(-5);
        }
        make.left.mas_equalTo(self.view.mas_left).offset(16);
        make.width.mas_equalTo(kScreen_Width-32);
        make.height.mas_equalTo(48);
    }];
}

#pragma mark - CTFAddPhotosCollectionViewDelegate 图片上传控件
- (void)addPhotosCollectionView:(CTFAddPhotosCollectionView *)collectionView didUploadState:(PhotoUploadState)state {
    [self textViewDidChange:myTextView];
}


@end
