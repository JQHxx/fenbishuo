//
//  PublishTopicViewController.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "PublishTopicViewController.h"
#import "CTFAddPhotosCollectionView.h"
#import "CTFPublishImageItemCCell.h"
#import "CTFPublishTopicViewModel.h"
#import "CTFWordLimit.h"
#import "CTPubTopicTitleTailSelectView.h"
#import <UITextView+Placeholder.h>
#import "CTFTopicPreviewView.h"
#import "NSString+Size.h"
#import "NSUserDefaultsInfos.h"
#import "CTFCommonManager.h"
#import "CTFConfigsModel.h"
#import "CTFLearningGuideView.h"

@interface PublishTopicViewController ()<UITextViewDelegate,UINavigationControllerDelegate,CTFAddPhotosCollectionViewDelegate,CTFTopicPreviewViewDelegate>{
    UIImageView              *poImageView;
    UILabel                  *navTitleLab;
    UIScrollView             *mainScrollView;
    UIView                   *mainContentView;
    UIView                   *titleContainView;
    UIImageView              *titleQuotationImaegView;
    UITextView               *topicTextView;
    UILabel                  *titleCountLabel;
    UILabel                  *titleTipsLabel;
    UILabel                  *immediatelyTitleLabel;
    UILabel                  *dotLine; //虚线
    UIButton                 *titleTailButton;
    UIView                   *lineView;
    UILabel                  *descTipsLabel;
    UIView                   *descContainView;
    UIImageView              *descQuotationImaegView;
    UITextView               *topicDescTextView;
    CTFAddPhotosCollectionView   *imgsCollectionView;
    UIButton                 *bottomPublishButton;
}

@property (nonatomic,strong) CTFPublishTopicViewModel  *adpater;
@property (nonatomic,strong) NSArray<CTFSuffixModel *> *titleTailList;
@property (nonatomic,strong) CTFSuffixModel            *currentSuffix;
@property (nonatomic,strong) CTFTopicPreviewView       *previewView; // 预览

@property (nonatomic, strong) CTFLearningGuideView *learningGuideView;// 学习引导view

@end

@implementation PublishTopicViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.isHiddenBackBtn = YES;
    self.rightImageName = @"nav_close";
    
    self.adpater = [[CTFPublishTopicViewModel alloc] init];
    self.currentSuffix = [[CTFSuffixModel alloc] init];
    
    [self setupUI];
    [self setupUILayout];
    
    if ([self.questionsModel.type isEqualToString:@"demand"]) {
        [self loadTopicDemandSuffixTitles];
    }
    
    [self configObserver];
    [topicTextView becomeFirstResponder];
}

#pragma mark - UITextViewDelegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if([text isEqualToString:@" "] && textView.text.length <= 0){
        //首字不可以是空格
        return NO;
    }
    
    if(textView == topicTextView){
        if([text isEqualToString:@"\n"]){
            [self.view endEditing:YES];
            //话题标题不可以\n
            return NO;
        }
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView{
    if(textView == topicTextView){
        NSString *lang = [textView.textInputMode primaryLanguage];
        if ([lang isEqualToString:@"zh-Hans"]) {
            UITextRange *selectedRange = [textView markedTextRange];
            UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
            if (position==nil) {
                //苹果输入拼音高亮部分
                textView.text = [self removeNewline:textView.text];
                [self configObserver];
            }
        }else{
            [self configObserver];
        }
        [CTFWordLimit computeWordCountWithTextView:textView maxNumber:15];
    } else if(textView == topicDescTextView){
        [CTFWordLimit computeWordCountWithTextView:textView maxNumber:1000];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (textView == topicTextView) {
        [self addsubviewTitleTailLearningGuide];
    }
}

#pragma mark CTFAddPhotosCollectionViewDelegate
-(void)addPhotosCollectionView:(CTFAddPhotosCollectionView *)collectionView didUploadState:(PhotoUploadState)state{
    [self.view endEditing:YES];
    [self configObserver];
    [self.view setNeedsUpdateConstraints];
    [self.view updateConstraintsIfNeeded];
}

#pragma mark CTFTopicPreviewViewDelegate
#pragma mark 返回修改
- (void)topicPreviewViewDidBackAction{
    [self.previewView removeFromSuperview];
    self.previewView = nil;
}

#pragma mark 确认发布
- (void)topicPreviewViewSubmitTopic{
    NSArray *imageIds = [imgsCollectionView uploadedImageIds];
    MBProgressHUD *hub = [MBProgressHUD ctfShowLoading:kKeyWindow title:@"发布中..."];
    @weakify(self);
    if (self.questionsModel.questionId>0) { //修改话题
        [self.adpater modifyTopicWithId:self.questionsModel.questionId type:self.questionsModel.type title:self.questionsModel.title suffix:self.questionsModel.titleSuffixId content:self.questionsModel.content imageIds:imageIds complete:^(BOOL isSuccess) {
            @strongify(self);
            [hub hideAnimated:NO];
            [self.previewView removeFromSuperview];
            self.previewView = nil;
            if (isSuccess) {
                [CTFCommonManager sharedCTFCommonManager].topicReLoad = YES;
                [self dismissViewControllerAnimated:NO completion:^{
                    [kKeyWindow makeToast:@"发布成功"];
                }];
            } else {
                [self.view makeToast:self.adpater.errorString];
            }
        }];
    } else { //发布话题
        [self.adpater createTopicWithType:self.questionsModel.type title:self.questionsModel.title suffix:self.questionsModel.titleSuffixId content:self.questionsModel.content imageIds:imageIds complete:^(BOOL isSuccess) {
            @strongify(self);
            [hub hideAnimated:NO];
            [self.previewView removeFromSuperview];
            self.previewView = nil;
            if (isSuccess) {
                [self dismissViewControllerAnimated:NO completion:^{
                    NSString *sid = [NSString stringWithFormat:@"%@?questionId=%zd&showAll=1&showInvitedUserDisplay=%d", kCTFTopicDetailsVC, [self.adpater currentPublishTopicId], 1];
                    APPROUTE(sid);
                }];
            } else {
                [self.view makeToast:self.adpater.errorString];
            }
        }];
    }
}

#pragma mark -- Event response
#pragma mark 选择后缀
-(void)topicTailTap{
    titleTailButton.selected = YES;
    [self.view endEditing:YES];
    @weakify(self);
    [CTPubTopicTitleTailSelectView showTopicTitleTailSelectView:self.titleTailList selSuffix:self.currentSuffix dismissBlock:^{
        @strongify(self);
        self->titleTailButton.selected = NO;
    } didSelectedHandler:^(CTFSuffixModel * suffix) {
        @strongify(self);
        self->titleTailButton.selected = NO;
        self.currentSuffix = suffix;
        for (CTFSuffixModel *model in self.titleTailList) {
            if (model.suffixId == self.currentSuffix.suffixId) {
                model.isSelected = YES;
            } else {
                model.isSelected = NO;
            }
        }
        [self->titleTailButton setTitle:self.currentSuffix.suffix forState:UIControlStateNormal];
        [self->titleTailButton ctfLayoutButtonWithEdgeInsetsStyle:CTFButtonEdgeInsetsType_ImageRight imageTitleSpace:3];
    }];
}

#pragma mark 返回
-(void)rightNavigationItemAction{
    if(topicTextView.text.length <= 0 && topicDescTextView.text.length <= 0 && [imgsCollectionView uploadedImageIds].count <= 0){
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:@"现在退出，内容将全部丢失，是否继续？" preferredStyle:UIAlertControllerStyleAlert];
    @weakify(self);
    UIAlertAction* exitAction = [UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {
        @strongify(self);
        [MobClick event:@"add_exitexit"];
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [exitAction setValue:[UIColor ctColor99] forKey:@"titleTextColor"];
    
    UIAlertAction* goonAction = [UIAlertAction actionWithTitle:@"继续编辑" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [MobClick event:@"add_exitcancel"];
    }];
    [goonAction setValue:UIColorFromHEX(0xFF6885) forKey:@"titleTextColor"];

    [alert addAction:exitAction];
    [alert addAction:goonAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark 发布
-(void)publishTopicTap{
    [MobClick event:@"add_submit"];
    
    if(![imgsCollectionView uploadAllSucceed]){
        [self.view makeToast:@"图片还未全部上传"];
        return;
    }
    
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    self.questionsModel.title = [topicTextView.text stringByTrimmingCharactersInSet:set];
    self.questionsModel.suffix = [self.questionsModel.type isEqualToString:@"recommend"]?@"求推荐":self.currentSuffix.suffix;
    self.questionsModel.titleSuffixId = self.currentSuffix.suffixId;
    self.questionsModel.content = [topicDescTextView.text stringByTrimmingCharactersInSet:set];
    self.questionsModel.images = [imgsCollectionView topicUploadedImages];
    self.questionsModel.attitude = @"like";
    [kKeyWindow addSubview:self.previewView];
    [self.previewView fillTopicData:self.questionsModel];
}

#pragma mark -- Private methods
#pragma mark 清除空格
-(NSString *)removeNewline:(NSString *)str{
    NSString *temp = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    temp = [temp stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return temp;
}

#pragma mark - RX Observer
-(void)configObserver{
    NSString *topicStr = topicTextView.text;
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    topicStr = [topicStr stringByTrimmingCharactersInSet:set];
    if (!kIsEmptyString(topicStr)) {
        bottomPublishButton.enabled = YES;
        titleTipsLabel.text = @"标题";
        [titleTipsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(titleContainView.mas_bottom).offset(20);
        }];
        [immediatelyTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(titleTipsLabel.mas_bottom).offset(20);
        }];
    } else {
        bottomPublishButton.enabled = NO;
        titleTipsLabel.text = @"";
        [titleTipsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(titleContainView.mas_bottom);
        }];
        [immediatelyTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(titleTipsLabel.mas_bottom);
        }];
    }
    
    if(topicStr.length > 15){
        immediatelyTitleLabel.text = [topicStr substringToIndex:15];
    } else {
        immediatelyTitleLabel.text = topicStr;
    }
    titleCountLabel.text = [NSString stringWithFormat:@"%zd/15",immediatelyTitleLabel.text.length];
    [self->titleTailButton setHidden:topicStr.length <= 0];
    if (!kIsEmptyString(immediatelyTitleLabel.text)) {
        CGFloat topicWidth = [immediatelyTitleLabel.text boundingRectWithSize:CGSizeMake(kScreen_Width, immediatelyTitleLabel.height) withTextFont:immediatelyTitleLabel.font].width;
        CGRect dotLineFrame = dotLine.frame;
        dotLineFrame.size.width = topicWidth;
        dotLineFrame.size.height = 2;
        dotLine.frame = dotLineFrame;
        [self drawDashLine:dotLine lineLength:3 lineSpacing:2 lineColor:[UIColor ctColorEE]];
    }
    [dotLine setHidden:kIsEmptyString(topicStr)];
}

#pragma mark 画虚线
- (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor{
    //删除子layer
    NSArray<CALayer *> *subLayers = lineView.layer.sublayers;
    NSArray<CALayer *> *removedLayers = [subLayers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject isKindOfClass:[CAShapeLayer class]];
    }]];
    [removedLayers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
    //开始绘制
   CAShapeLayer *shapeLayer = [CAShapeLayer layer];
   [shapeLayer setBounds:lineView.bounds];
   [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame)/2.0, CGRectGetHeight(lineView.frame))];
   [shapeLayer setFillColor:[UIColor clearColor].CGColor];
   //  设置虚线颜色为blackColor
   [shapeLayer setStrokeColor:lineColor.CGColor];
   //  设置虚线宽度
   [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
   [shapeLayer setLineJoin:kCALineJoinRound];
   //  设置线宽，线间距
   [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
   //  设置路径
   CGMutablePathRef path = CGPathCreateMutable();
   CGPathMoveToPoint(path, NULL, 0, 0);
   CGPathAddLineToPoint(path, NULL, CGRectGetWidth(lineView.frame), 0);
   [shapeLayer setPath:path];
   CGPathRelease(path);
   //  把绘制好的虚线添加上来
   [lineView.layer addSublayer:shapeLayer];
}

#pragma mark 获取话题后缀
- (void)loadTopicDemandSuffixTitles {
    NSArray *titles = [CTFCommonManager sharedCTFCommonManager].questionTitleSuffix;
    if (titles.count > 0) {
        for (CTFSuffixModel *model in titles) {
            model.isSelected = NO;
        }
        self.titleTailList = titles;
        [self parseCurrentTitleSuffix];
    } else {
        MBProgressHUD *hub = [MBProgressHUD ctfShowLoading:kKeyWindow title:@"发布中..."];
        [self.adpater loadTopicSuffixTitlesComplete:^(BOOL isSuccess) {
            [hub hideAnimated:YES];
            if (isSuccess) {
                [CTFCommonManager sharedCTFCommonManager].questionTitleSuffix = [self.adpater allSuffixTitles];
                self.titleTailList = [self.adpater allSuffixTitles];
                [self parseCurrentTitleSuffix];
            } else {
                [self.view makeToast:self.adpater.errorString];
            }
        }];
    }
}

#pragma mark 解析话题后缀
- (void)parseCurrentTitleSuffix {
    if (self.questionsModel.titleSuffixId > 0) {
        for (CTFSuffixModel * model in self.titleTailList) {
            if (model.suffixId == self.questionsModel.titleSuffixId) {
                model.isSelected = YES;
                self.currentSuffix = model;
            } else {
                model.isSelected = NO;
            }
        }
        if (self.currentSuffix.suffixId == 0) {
            self.currentSuffix.suffix = self.questionsModel.suffix;
        }
    } else {
        self.currentSuffix = [self.titleTailList safe_objectAtIndex:0];
        self.currentSuffix.isSelected = YES;
    }
    [titleTailButton setTitle:self.currentSuffix.suffix forState:UIControlStateNormal];
    [titleTailButton ctfLayoutButtonWithEdgeInsetsStyle:CTFButtonEdgeInsetsType_ImageRight imageTitleSpace:3];
}

#pragma mark 界面初始化
-(void)setupUI{
    mainScrollView = [[UIScrollView alloc] init];
    mainScrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [mainScrollView setShowsVerticalScrollIndicator:NO];
    mainScrollView.alwaysBounceVertical = YES;
    [self.view addSubview:mainScrollView];
           
    mainContentView = [[UIView alloc] init];
    [mainScrollView addSubview:mainContentView];
    
    poImageView = [[UIImageView alloc] init];
    poImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:poImageView];
    
    navTitleLab = [[UILabel alloc] init];
    navTitleLab.textColor=[UIColor ctColor9B];
    navTitleLab.font=[UIFont mediumFontWithSize:18];
    [self.view addSubview:navTitleLab];
    
    if ([self.questionsModel.type isEqualToString:@"recommend"]) {
        poImageView.image = ImageNamed(@"publish_topic_recommend");
        navTitleLab.text = @"你的避雷指南";
    } else {
        poImageView.image = ImageNamed(@"publish_topic_demand");
        navTitleLab.text = @"大家帮你来评测！";
    }
            
    titleContainView = [[UIView alloc] init];
    titleContainView.backgroundColor = UIColorFromHEX(0xF6F7F9);
    titleContainView.clipsToBounds = YES;
    titleContainView.layer.cornerRadius = 6;
    [mainContentView addSubview:titleContainView];
    
    titleQuotationImaegView = [[UIImageView alloc] init];
    titleQuotationImaegView.image = ImageNamed(@"quotation_left");
    [mainContentView addSubview:titleQuotationImaegView];
    
    topicTextView = [[UITextView alloc] init];
    topicTextView.font = [UIFont regularFontWithSize:14];
    topicTextView.textColor = [UIColor ctColor33];
    topicTextView.placeholder = [self.questionsModel.type isEqualToString:@"recommend"]?@"(必填)输入你想让大家推荐的东西...":@"(必填)输入你想评测的一样东西...";
    topicTextView.placeholderColor = [UIColor ctColorBB];
    topicTextView.delegate = self;
    topicTextView.returnKeyType = UIReturnKeyContinue;
    topicTextView.scrollEnabled = NO;
    topicTextView.backgroundColor = [UIColor clearColor];
    topicTextView.text = kIsEmptyString(self.questionsModel.shortTitle)?@"":self.questionsModel.shortTitle;
    [titleContainView addSubview:topicTextView];
    
    titleCountLabel = [[UILabel alloc] init];
    titleCountLabel.font = [UIFont regularFontWithSize:10];
    titleCountLabel.textColor = [UIColor ctColorCC];
    titleCountLabel.text = @"0/15";
    titleCountLabel.textAlignment = NSTextAlignmentRight;
    [titleContainView addSubview:titleCountLabel];
    
    titleTipsLabel = [[UILabel alloc] init];
    titleTipsLabel.font = [UIFont systemFontOfSize:14];
    titleTipsLabel.textColor = [UIColor ctColor33];
    [mainContentView addSubview:titleTipsLabel];
    
    immediatelyTitleLabel = [[UILabel alloc] init];
    immediatelyTitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    immediatelyTitleLabel.textColor = [UIColor ctColor33];
    immediatelyTitleLabel.text = kIsEmptyString(self.questionsModel.shortTitle)?@"":self.questionsModel.shortTitle;
    [mainContentView addSubview:immediatelyTitleLabel];
    
    //虚线
    dotLine = [[UILabel alloc] init];
    [mainContentView addSubview:dotLine];
        
    titleTailButton = [[UIButton alloc] init];
    [titleTailButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    titleTailButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    if ([self.questionsModel.type isEqualToString:@"recommend"]) {
        [titleTailButton setTitleColor:[UIColor ctRecommendColor] forState:UIControlStateNormal];
        [titleTailButton setTitle:@"求推荐" forState:UIControlStateNormal];
        titleTailButton.userInteractionEnabled = NO;
    } else {
        [titleTailButton setTitleColor:[UIColor ctMainColor] forState:UIControlStateNormal];
        [titleTailButton addTarget:self action:@selector(topicTailTap) forControlEvents:UIControlEventTouchUpInside];
        [titleTailButton setImage:ImageNamed(@"publish_arrow_down") forState:UIControlStateNormal];
        [titleTailButton setImage:ImageNamed(@"publish_arrow_up") forState:UIControlStateSelected];
        [titleTailButton ctfLayoutButtonWithEdgeInsetsStyle:CTFButtonEdgeInsetsType_ImageRight imageTitleSpace:3];
        titleTailButton.userInteractionEnabled = YES;
    }
    [mainContentView addSubview:titleTailButton];

    descTipsLabel = [[UILabel alloc] init];
    descTipsLabel.font = [UIFont systemFontOfSize:14];
    descTipsLabel.text = @"补充说明：";
    descTipsLabel.textColor = [UIColor ctColor33];
    [mainContentView addSubview:descTipsLabel];
    
    descContainView = [[UIView alloc] init];
    descContainView.backgroundColor =  UIColorFromHEX(0xF6F7F9);
    descContainView.clipsToBounds = YES;
    descContainView.layer.cornerRadius = 6;
    [mainContentView addSubview:descContainView];
    
    descQuotationImaegView = [[UIImageView alloc] init];
    descQuotationImaegView.image = ImageNamed(@"quotation_right");
    [mainContentView addSubview:descQuotationImaegView];
    
    topicDescTextView = [[UITextView alloc] init];
    topicDescTextView.font = [UIFont regularFontWithSize:14];
    topicDescTextView.textColor = [UIColor ctColor33];
    topicDescTextView.placeholder = @"(选填)填写补充说明，可以更快获得解答";
    topicDescTextView.placeholderColor = [UIColor ctColorBB];
    topicDescTextView.delegate = self;
    topicDescTextView.backgroundColor = [UIColor clearColor];
    topicDescTextView.text = kIsEmptyString(self.questionsModel.content)?@"":self.questionsModel.content;
    [descContainView addSubview:topicDescTextView];
   
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    imgsCollectionView = [[CTFAddPhotosCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    imgsCollectionView.viewDelegate = self;
    imgsCollectionView.autoZoom = YES;
    imgsCollectionView.backgroundColor = UIColorFromHEX(0xF6F7F9);
    [descContainView addSubview:imgsCollectionView];
    if (self.questionsModel.images.count>0) {
        [imgsCollectionView addImageItems:self.questionsModel.images];
    }
    
    bottomPublishButton = [[UIButton alloc] init];
    [bottomPublishButton addTarget:self action:@selector(publishTopicTap) forControlEvents:UIControlEventTouchUpInside];
    [bottomPublishButton setTitle:@"预览并发布" forState:UIControlStateNormal];
    [bottomPublishButton setTitleColor:UIColorFromHEX(0xFFFFFF) forState:UIControlStateNormal];
    [bottomPublishButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    if ([self.questionsModel.type isEqualToString:@"recommend"]) {
        [bottomPublishButton setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:UIColorFromHEX(0xFFC028) cornerRadius:4] forState:UIControlStateNormal];
        [bottomPublishButton setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:UIColorFromHEX(0xFFD268) cornerRadius:4] forState:UIControlStateHighlighted];
    } else {
        [bottomPublishButton setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:UIColorFromHEX(0xFF6885) cornerRadius:4] forState:UIControlStateNormal];
        [bottomPublishButton setBackgroundImage:[UIImage ctRoundRectImageWithFillColor:UIColorFromHEX(0xFF95A9) cornerRadius:4] forState:UIControlStateHighlighted];
    }
    [self.view addSubview:bottomPublishButton];
}

-(void)setupUILayout{
    [poImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMarginLeft);
        make.top.mas_equalTo(self.view.mas_top).offset(kStatusBar_Height+7);
        make.height.mas_equalTo(30);
    }];
    
    [navTitleLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(poImageView.mas_right).offset(5);
        make.height.mas_equalTo(20);
        make.bottom.mas_equalTo(poImageView.mas_bottom).offset(-2);
    }];
    
   [mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.top.mas_equalTo(kNavBar_Height);
       make.left.right.equalTo(self.view);
       make.height.mas_equalTo(kScreen_Height-kNavBar_Height-55);
   }];
  
   [mainContentView mas_makeConstraints:^(MASConstraintMaker *make) {
       make.edges.equalTo(mainScrollView);
       make.width.equalTo(mainScrollView);
   }];
    
    [titleContainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMarginLeft);
        make.right.mas_equalTo(-kMarginRight);
        make.top.mas_equalTo(32);
        make.height.mas_equalTo(58);
    }];
    
                               
    [titleQuotationImaegView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(32, 21));
        make.left.equalTo(titleContainView.mas_left).offset(15);
        make.bottom.equalTo(titleContainView.mas_top).offset(10);
    }];
        
    [topicTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(13, 10, 13, 10));
    }];
    
    [titleCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(titleContainView.mas_right).offset(-6);
        make.bottom.equalTo(titleContainView.mas_bottom).offset(-6);
    }];
    
    //标题
    [titleTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMarginLeft);
        make.top.equalTo(titleContainView.mas_bottom);
    }];
    
    if ([self.questionsModel.type isEqualToString:@"recommend"]) {
        [titleTailButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(26);
            make.top.equalTo(titleTipsLabel.mas_bottom);
        }];
        
        [immediatelyTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(titleTailButton.mas_right).offset(3);
            make.centerY.equalTo(titleTailButton.mas_centerY);
        }];
        
    } else {
        [immediatelyTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(26);
            make.top.equalTo(titleTipsLabel.mas_bottom);
        }];
        
        [titleTailButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(immediatelyTitleLabel.mas_right).offset(3);
            make.centerY.equalTo(immediatelyTitleLabel.mas_centerY);
        }];
    }
    
    [dotLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(immediatelyTitleLabel);
        make.top.mas_equalTo(immediatelyTitleLabel.mas_bottom);
        make.height.mas_equalTo(2);
    }];
    
    //补充说明
    [descTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMarginLeft);
        make.top.equalTo(immediatelyTitleLabel.mas_bottom).offset(20);
    }];
    
    [descContainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMarginLeft);
        make.right.mas_equalTo(-kMarginRight);
        make.top.equalTo(descTipsLabel.mas_bottom).offset(10);
        make.bottom.equalTo(mainContentView.mas_bottom).offset(-10-[AppMargin notchScreenBottom]);
    }];
    
    [descQuotationImaegView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(32, 21));
        make.right.equalTo(descContainView.mas_right).offset(-15);
        make.bottom.equalTo(descContainView.mas_top).offset(10);
    }];
    
    [topicDescTextView mas_makeConstraints:^(MASConstraintMaker *make) {
          make.left.equalTo(descContainView.mas_left).offset(8);
          make.right.equalTo(descContainView.mas_right).offset(-8);
          make.top.equalTo(descContainView.mas_top).offset(15);
          make.height.mas_equalTo(94);
    }];
    
    NSInteger count = 1;
    if (self.questionsModel.images.count > 0) {
        if (self.questionsModel.images.count == 9) {
            count = 3;
        }else{
            count = 1+self.questionsModel.images.count/3;
        }
    }
    [imgsCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(descContainView.mas_left).offset(10);
        make.right.equalTo(descContainView.mas_right).offset(-10);
        make.top.equalTo(topicDescTextView.mas_bottom).offset(10);
        make.height.mas_equalTo(([CTFPublishImageItemCCell itemSizeWidthPading:10].height*count+kMutiImagesSpace));
        make.bottom.equalTo(descContainView.mas_bottom).offset(-10);
    }];
    
    [bottomPublishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.right.mas_equalTo(-16);
        make.height.mas_equalTo(48);
        make.bottom.mas_equalTo(self.view.mas_bottom).offset(-(kStatusBar_Height>20?20:10));
    }];
}

#pragma mark -- Getters
#pragma mark 预览
- (CTFTopicPreviewView *)previewView{
    if (!_previewView) {
        _previewView = [[CTFTopicPreviewView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _previewView.delegate = self;
    }
    return _previewView;
}

#pragma mark -  提个要求的后缀切换学习引导
- (void)addsubviewTitleTailLearningGuide {
    
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *topicText = [topicTextView.text stringByTrimmingCharactersInSet:set];
    
    if (![CTFSystemCache query_showedLearningGuideForFunctionView:CTFLearningGuideViewType_Public] && self.learningGuideView == nil && topicText.length > 0 && ![self.questionsModel.type isEqualToString:@"recommend"]) {
        
        [self handleApplicationDidEnterBackground];
        
        [self.view layoutIfNeeded];
        CGRect hollowRect = [mainContentView convertRect:titleTailButton.frame toView:mainContentView];
        
        CGFloat imageRect_x = CGRectGetMidX(hollowRect) - 147/2.f + 15.5;
        if (imageRect_x < 48) {
            imageRect_x = 48;
        }
        if (imageRect_x + 147 + 16 > kScreen_Width) {
            imageRect_x = kScreen_Width - 147 - 16;
        }
        CGFloat imageRect_y = hollowRect.origin.y-57-6;
        CGRect imageRect = CGRectMake(imageRect_x, imageRect_y, 147, 57);
        
        CGRect frame = CGRectZero;
        if ([[UIApplication sharedApplication] statusBarFrame].size.height > 20) {
            frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height-20);
        } else {
            frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
        }
        
        @weakify(self);
        CTFLearningGuideView *learningGuideView = [[CTFLearningGuideView alloc] initWithFrame:frame alpha:0.f hollowFrame:hollowRect hollowCornerRadius:0 imageName:@"icon_publish_learningGuide_147x57" imageFrame:imageRect clickSelfBlcok:^{
            @strongify(self);
            [self removeTitleTailLearningGuide];
        }];
        self.learningGuideView = learningGuideView;
        [mainContentView addSubview:learningGuideView];
    }
}

- (void)removeTitleTailLearningGuide {
    [self.learningGuideView removeFromSuperview];
    self.learningGuideView = nil;
    [CTFSystemCache revise_showedLearningGuide:YES ForFunctionView:CTFLearningGuideViewType_Public];
}

//
- (void)handleApplicationDidEnterBackground {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeTitleTailLearningGuide) name:kApplicationWillTerminateNotification object:nil];
}

@end
