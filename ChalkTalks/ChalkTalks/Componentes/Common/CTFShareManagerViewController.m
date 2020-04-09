//
//  CTFShareManagerViewController.m
//  ChalkTalks
//
//  Created by vision on 2020/3/27.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFShareManagerViewController.h"
#import <HWPanModal.h>
#import <UMShare/UMShare.h>
#import <UMAnalytics/MobClick.h>
#import "UIImage+Size.h"

@interface CTFShareManagerViewController ()<HWPanModalPresentable>

@property (nonatomic,strong) NSMutableArray *platFormTypes;
@property (nonatomic,strong) NSMutableArray *btnTitles;
@property (nonatomic,strong) NSMutableArray *btnImages;
@property (nonatomic,assign) CGFloat  viewHeight;

@end

@implementation CTFShareManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self parserShareInfo];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self hw_panModalTransitionTo:PresentationStateLong animated:NO];
}

#pragma mark -- HWPanModalPresentable
#pragma 是否显示drag指示view
- (BOOL)showDragIndicator {
    return NO;
}

#pragma mark
- (PanModalHeight)longFormHeight{
    return PanModalHeightMake(PanModalHeightTypeContent,self.viewHeight);
}

#pragma mark 是否需要使拖拽手势生效
- (BOOL)shouldRespondToPanModalGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {
    return NO;
}

#pragma mark -- Event response
#pragma mark 分享
-(void)shareAction:(UIButton *)sender{
    UMSocialPlatformType type = [self.platFormTypes[sender.tag] integerValue];
    if (type == UMSocialPlatformType_UserDefine_Begin+1) { //删除或举报
        if (self.type == CTFShareTypeAnswerOthers) {
            [MobClick event:@"answerlist_more_report"];
        }
        kSelfWeak;
        [self dismissViewControllerAnimated:YES completion:^{
            weakSelf.myBlock(0);
        }];
        
    } else if (type == UMSocialPlatformType_UserDefine_Begin+2){ //不感兴趣或修改
        kSelfWeak;
        [self dismissViewControllerAnimated:YES completion:^{
            weakSelf.myBlock(1);
        }];
    } else { //分享
        if (type == UMSocialPlatformType_WechatSession) {
            [MobClick event:@"answerlist_more_shareweixin"];
        } else if (type == UMSocialPlatformType_WechatTimeLine){
            [MobClick event:@"answerlist_more_sharepengyouquan"];
        }
        
        //创建分享消息对象
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        //创建网页内容对象
        id image = self.info[@"image"];
        if (kIsEmptyObject(image)) {
            image = ImageNamed(@"share_icon_logo");
        }
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:self.info[@"title"] descr:self.info[@"desc"] thumImage:image];
        //设置网页地址
        NSString *baseurl = [[CTENVConfig share] h5BaseUrl];
        NSString *shareUrl = [NSString stringWithFormat:@"%@%@",baseurl,self.info[@"url"]];
        ZLLog(@"shareurl:%@",shareUrl);
        shareObject.webpageUrl = shareUrl;
    
        //分享消息对象设置分享内容对象
        messageObject.shareObject = shareObject;
        //调用分享接口
        [[UMSocialManager defaultManager] shareToPlatform:type messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
            if (error) {
                ZLLog(@"************Share fail with error %@*********",error);
            } else {
                ZLLog(@"分享成功");
                //分享成功
                [self uploadShareEvent];
            }
       }];
       [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark 取消
- (void)cancelAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -- Private methods
#pragma mark 上报分享资源
- (void)uploadShareEvent {
    NSString *resourceType = [self.info safe_stringForKey:@"resourceType"];
    NSInteger resourceId = [self.info safe_integerForKey:@"resourceId"];
    
    CTRequest *request = [CTFMineApi uploadShareEventWithResourceType:resourceType resourceId:resourceId];
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
        
    }];
}

#pragma mark 解析数据
- (void)parserShareInfo{
    BOOL normal = [self.info[@"status"] isEqualToString:@"normal"];
    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_WechatSession]&&normal) {
        [self.platFormTypes addObjectsFromArray:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine)]];
        [self.btnTitles addObjectsFromArray:@[@"微信",@"朋友圈"]];
        [self.btnImages addObjectsFromArray:@[@"share_icon_wechat_session",@"share_icon_wechat_timeLine"]];
    }
    if ([[UMSocialManager defaultManager] isInstall:UMSocialPlatformType_QQ]&&normal) {
        [self.platFormTypes addObjectsFromArray:@[@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone)]];
        [self.btnTitles addObjectsFromArray:@[@"QQ好友",@"QQ空间"]];
        [self.btnImages addObjectsFromArray:@[@"share_icon_QQ",@"share_icon_Qzone"]];
    }
    
    if (self.type == CTFShareTypeQuestionOthers) { //举报话题
        [self.platFormTypes addObject:@(UMSocialPlatformType_UserDefine_Begin+1)];
        [self.btnTitles addObject:@"举报话题"];
        [self.btnImages addObject:@"share_icon_report"];
    } else if (self.type == CTFShareTypeQuestionMine) { //删除话题、修改话题
        [self.platFormTypes addObject:@(UMSocialPlatformType_UserDefine_Begin+1)];
        [self.btnTitles addObject:@"删除话题"];
        [self.btnImages addObject:@"share_icon_delete"];
        
        if (normal) {
            [self.platFormTypes addObject:@(UMSocialPlatformType_UserDefine_Begin+2)];
            [self.btnTitles addObject:@"修改话题"];
            [self.btnImages addObject:@"share_icon_edit"];
        }
    } else if(self.type == CTFShareTypeAnswerOthers){
       [self.platFormTypes addObject:@(UMSocialPlatformType_UserDefine_Begin+1)];
       [self.btnTitles addObject:@"举报回答"];
       [self.btnImages addObject:@"share_icon_report"];
        
       [self.platFormTypes addObject:@(UMSocialPlatformType_UserDefine_Begin+2)];
       [self.btnTitles addObject:@"不感兴趣"];
       [self.btnImages addObject:@"share_icon_unlike"];
    } else if(self.type == CTFShareTypeAnswerDelete){
        [self.platFormTypes addObject:@(UMSocialPlatformType_UserDefine_Begin+1)];
        [self.btnTitles addObject:@"删除回答"];
        [self.btnImages addObject:@"share_icon_delete"];
    } else if (self.type == CTFShareTypeAnswerDeleteAndModify){
        [self.platFormTypes addObject:@(UMSocialPlatformType_UserDefine_Begin+1)];
        [self.btnTitles addObject:@"删除回答"];
        [self.btnImages addObject:@"share_icon_delete"];
        
        if (normal) {
            [self.platFormTypes addObject:@(UMSocialPlatformType_UserDefine_Begin+2)];
            [self.btnTitles addObject:@"修改回答"];
            [self.btnImages addObject:@"share_icon_edit"];
        }
    }
    
    [self setupContentView];
}

#pragma mark 界面初始化
-(void)setupContentView{
    self.view.backgroundColor = UIColorFromHEX(0xF4F4F4);
    
    CGFloat topMargin = 0.0;
    if (self.type == CTFShareTypeAnswerSucceed) {
        UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake(10, 14, kScreen_Width-20, 20)];
        titleLab.font = [UIFont mediumFontWithSize:14.0f];
        titleLab.textColor = [UIColor ctColor33];
        titleLab.text = @"快邀请朋友围观，为你的回答增加人气";
        titleLab.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:titleLab];
        
        topMargin = titleLab.bottom;
    }
    
    CGFloat btnCap = (kScreen_Width-29*2-60*4)/3.0;
    for (NSInteger i=0; i<self.platFormTypes.count; i++) {
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(29+(i%4)*(60+btnCap), topMargin+ 15+(i/4)*100, 60, 90)];
        [btn setImage:[UIImage drawImageWithName:self.btnImages[i] size:CGSizeMake(60, 60)] forState:UIControlStateNormal];
        [btn setTitle:self.btnTitles[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor ctColor33] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont regularFontWithSize:13];
        CGFloat imageWith = btn.imageView.intrinsicContentSize.width;
        CGFloat imageHeight = btn.imageView.intrinsicContentSize.height;
        CGFloat labelWidth = btn.titleLabel.intrinsicContentSize.width;
        CGFloat labelHeight = btn.titleLabel.intrinsicContentSize.height;
        btn.imageEdgeInsets = UIEdgeInsetsMake(-labelHeight-5, -(btn.width-imageWith)/2.0, 0, -labelWidth);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWith, -imageHeight-10, 0);
        btn.tag = i;
        [btn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
    
    CGFloat btnBottomY = 15+((self.platFormTypes.count-1)/4)*100+100;
    
    //线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0,btnBottomY+10, kScreen_Width, 1)];
    line.backgroundColor = UIColorFromHEX(0xDDDDDD);
    [self.view addSubview:line];
    
    //取消
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, line.bottom, kScreen_Width,49)];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor ctColor33] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont regularFontWithSize:16];
    [cancelBtn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelBtn];
    
    self.viewHeight = cancelBtn.bottom;
    [self hw_panModalSetNeedsLayoutUpdate];
    
}

-(NSMutableArray *)platFormTypes{
    if (!_platFormTypes) {
        _platFormTypes = [[NSMutableArray alloc] init];
    }
    return _platFormTypes;
}

- (NSMutableArray *)btnTitles {
    if (!_btnTitles) {
        _btnTitles = [[NSMutableArray alloc] init];
    }
    return _btnTitles;
}

- (NSMutableArray *)btnImages {
    if (!_btnImages) {
        _btnImages = [[NSMutableArray alloc] init];
    }
    return _btnImages;
}

@end
