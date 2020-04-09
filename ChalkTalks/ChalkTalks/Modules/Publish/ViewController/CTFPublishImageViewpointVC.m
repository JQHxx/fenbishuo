//
//  CTFPublishImageViewpointVC.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/12.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFPublishImageViewpointVC.h"
#import "CTFAddPhotosCollectionView.h"
#import "CTFPublishImageItemCCell.h"
#import "CTFPublishImageViewpointViewModel.h"
#import "CTFWordLimit.h"
#import <UITextView+Placeholder.h>
#import "CTFPublishTopicViewModel.h"
#import "CTFCommonManager.h"

@interface CTFPublishImageViewpointVC ()<CTFAddPhotosCollectionViewDelegate,UITextViewDelegate>{
    UIView                     *navLineView;
    UIScrollView               *mainScrollView;
    UIView                     *mainContentView;
    UILabel                    *topicLabel;
    UIView                     *lineView;
    UITextView                 *topicDescTextView;
    CTFAddPhotosCollectionView *imgsCollectionView;
    NSString                   *quesionTitle;
}

@property(nonatomic, strong) CTFPublishImageViewpointViewModel *adpater;
@property(nonatomic,  copy ) NSString    *type;  // publish 发布，modify 修改，draft 草稿
@property(nonatomic, strong) AnswerModel *answerModel;
@property (nonatomic,assign) BOOL    editing;

@end

@implementation CTFPublishImageViewpointVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.baseTitle = @"我来回答";
    self.rigthTitleName = @"发布";
    self.rightBtn.enabled = NO;
    
    [self setupUI];
    [self setupUILayout];
    [self handlerInpickedImage];
    [self parseAnswerImagesInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - UITextViewDelegate
-(void)textViewDidChange:(UITextView *)textView{
    self.editing = YES;
    if (textView == topicDescTextView){
         [CTFWordLimit computeWordCountWithTextView:textView maxNumber:20000];
    }
    [self uploadPublishButton];
}

#pragma mark CTFAddPhotosCollectionViewDelegate
-(void)addPhotosCollectionView:(CTFAddPhotosCollectionView *)collectionView didUploadState:(PhotoUploadState)state{
    self.editing = YES;
    [topicDescTextView resignFirstResponder];
    if (state == PhotoUploadStateUploaded) {
        [self uploadPublishButton];
    }
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
}

#pragma mark - Action
#pragma mark 发布
-(void)rightNavigationItemAction{
    [MobClick event:@"answer_textsubmit"];
    NSString *desc = topicDescTextView.text;
//    NSCharacterSet  *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
//    desc = [desc stringByTrimmingCharactersInSet:set];
    
    if(desc.length > 20000){
         [self.view makeToast:@"回答不能超过20000字"];
        return;
    }
    if(![imgsCollectionView uploadAllSucceed]){
         [self.view makeToast:@"图片还未全部上传"];
        return;
    }
    
    NSArray *arr = [imgsCollectionView uploadedImageIds];
    MBProgressHUD *hub= [MBProgressHUD ctfShowLoading:self.view title:self.answerModel&&self.answerModel.answerId>0 ? @"修改中..." : @"发布中..."];
    @weakify(self);
    @weakify(hub);
    [self.adpater publishAnswer:desc oldAnswerModel:self.answerModel imageIds:arr complete:^(BOOL isSuccess) {
        @strongify(self);
        @strongify(hub);
        [hub hideAnimated:YES];
        if(isSuccess){
            NSInteger answerId = [self.adpater currentAnswerId];
            NSDictionary *userinfo = @{@"answerId": @(answerId)};
            [[NSNotificationCenter defaultCenter] postNotificationName:kPublishAnswerSuccessNotification object:nil userInfo:userinfo];
            if (self.draftModel != nil) {
                [[CTDrafts share] removeDraftWithId:self.draftModel.draftId];
            }
            [self dismissViewControllerAnimated:YES completion:^{
                [kKeyWindow makeToast:self.answerModel&&self.answerModel.answerId>0 ? @"修改成功" : @"发布成功"];
            }];
        }else{
            if(self.adpater.serverErrorCode == 4020 || self.adpater.serverErrorCode == 4002){
                [self cannotPublishTwoAnswerWithMsg:self.adpater.errorString];
            }else{
                [kKeyWindow makeToast:self.adpater.errorString];
            }
        }
    }];
}

#pragma mark 返回
-(void)leftNavigationItemAction{
    if (self.draftModel != nil && !self.editing) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    if(kIsEmptyString(topicDescTextView.text) && [[imgsCollectionView adpater] uploadImageArr].count == 0){
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"是否退出编辑？" preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self);
    UIAlertAction* exitAction = [UIAlertAction actionWithTitle:@"保存并退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        @strongify(self);
        [MobClick event:@"answer_exitedit"];
        BOOL isChanging = self.answerModel != nil && self.answerModel.answerId>0;
        if (!isChanging) {
            [self storeToDraft];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [exitAction setValue:[UIColor ctColor99] forKey:@"titleTextColor"];
    
    UIAlertAction* goonAction = [UIAlertAction actionWithTitle:@"继续编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
           [MobClick event:@"answer_canclexit"];
    }];
    [goonAction setValue:UIColorFromHEX(0xFF6885) forKey:@"titleTextColor"];

    [alert addAction:exitAction];
    [alert addAction:goonAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -- Private methods
#pragma mark 解析数据
- (void)parseAnswerImagesInfo {
    NSInteger quesionId;
    if (self.draftModel != nil) {
        quesionId = self.draftModel.questionId;
        quesionTitle = self.draftModel.questionTitle;
        self.answerModel = [[ CTFCommonManager sharedCTFCommonManager] transformAnswerForDraftAnswer:self.draftModel];
    } else {
        quesionId = [self.schemaArgu safe_integerForKey:@"questionId"];
        quesionTitle = [self.schemaArgu safe_stringForKey:@"quesionTitle"];
        self.answerModel = (AnswerModel *)[self.schemaArgu safe_objectForKey:@"answerModel"];
    }
    self.adpater = [[CTFPublishImageViewpointViewModel alloc] initWithQuesionId:quesionId];
    
    topicLabel.text = quesionTitle;
    if (self.answerModel != nil) {
        topicDescTextView.text = _answerModel.content;
        [imgsCollectionView addImageItems:_answerModel.images];
        [self.rightBtn setEnabled:YES];
    }
    [topicDescTextView becomeFirstResponder];
}

#pragma mark 已发布过回答提示
-(void)cannotPublishTwoAnswerWithMsg:(NSString *)message{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self);
    UIAlertAction* exitAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:exitAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark 添加图片
-(void)handlerInpickedImage{
    [imgsCollectionView addPickedPhotos:self.pickImages];
}

#pragma mark 更新提交按钮状态
-(void)uploadPublishButton{
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *content = [topicDescTextView.text stringByTrimmingCharactersInSet:set];
    if(content.length > 0 || [imgsCollectionView uploadedImageIds].count>0){
        [self.rightBtn setEnabled:YES];
    }else{
        [self.rightBtn setEnabled:NO];
    }
}

#pragma mark 保存草稿
- (void)storeToDraft {
    CTFPublishTopicViewModel *model = [imgsCollectionView adpater];
    [[CTDrafts share] addDraftWithQuestionId:self.adpater.quesionId
                               questionTitle:quesionTitle
                                     content:topicDescTextView.text
                                      images:model.uploadImageArr];
}

#pragma mark 界面初始化
-(void)setupUI{
    navLineView = [[UIView alloc] init];
    navLineView.backgroundColor = [UIColor ctColorEE];
    [self.view addSubview:navLineView];
    
    mainScrollView = [[UIScrollView alloc] init];
    mainScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [mainScrollView setShowsVerticalScrollIndicator:NO];
    mainScrollView.alwaysBounceVertical = YES;
    [self.view addSubview:mainScrollView];
    
    mainContentView = [[UIView alloc] init];
    [mainScrollView addSubview:mainContentView];
    
    topicLabel = [[UILabel alloc] init];
    topicLabel.font = [UIFont regularFontWithSize:18];
    topicLabel.textColor = [UIColor ctColor33];
    [mainContentView addSubview:topicLabel];
    
    lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor ctColorEE];
    [mainContentView addSubview:lineView];
    
    topicDescTextView = [[UITextView alloc] init];
    topicDescTextView.font = [UIFont regularFontWithSize:16];
    topicDescTextView.textColor = [UIColor ctColor66];
    topicDescTextView.placeholder = @"写回答....";
    topicDescTextView.placeholderColor = [UIColor ctColorBB];
    topicDescTextView.delegate = self;
    [mainContentView addSubview:topicDescTextView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    imgsCollectionView = [[CTFAddPhotosCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    imgsCollectionView.backgroundColor = [UIColor whiteColor];
    imgsCollectionView.viewDelegate = self;
    [mainContentView addSubview:imgsCollectionView];
}

-(void)setupUILayout{
    [navLineView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.mas_equalTo(kNavBar_Height);
         make.left.right.equalTo(self.view);
        make.height.mas_equalTo(0.5f);
    }];
    
    [mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(navLineView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(kScreen_Height-kNavBar_Height);
    }];
    
    [mainContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(mainScrollView);
        make.width.height.equalTo(mainScrollView);
    }];
    
    [topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMarginLeft);
        make.top.mas_equalTo(kMarginTop);
        make.right.mas_equalTo(-kMarginRight);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(mainContentView);
        make.top.equalTo(topicLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(14);
    }];
    
    [topicDescTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMarginLeft);
        make.top.equalTo(lineView.mas_bottom).offset(10);
        make.right.mas_equalTo(-kMarginRight);
        make.height.mas_equalTo(kResetDimension(170));
    }];
    
    [imgsCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMarginLeft);
        make.top.equalTo(topicDescTextView.mas_bottom).offset(10);
        make.right.mas_equalTo(-kMarginRight);
        make.height.mas_equalTo(3*([CTFPublishImageItemCCell itemSize].height+kMutiImagesSpace));
    }];
}
@end
