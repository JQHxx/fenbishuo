//
//  CTFAnswerHandleView.m
//  ChalkTalks
//
//  Created by vision on 2020/2/27.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFAnswerHandleView.h"
#import "UIResponder+Event.h"
#import "MainPageViewModel.h"
#import "HWNavViewController.h"
#import "CTFReportTypeOptionVC.h"
#import "MainPageViewController.h"
#import "CTFShareManagerViewController.h"
#import <HWPanModal.h>
#import "CTFCommentListVC.h"
#import "MainTabListViewController.h"
#import "CTFCommonManager.h"

@import AudioToolbox;

@interface CTFAnswerHandleView ()

@property (nonatomic,strong) UIButton           *moreBtn;
@property (nonatomic,strong) UIButton           *commentBtn;
@property (nonatomic,strong) UILabel            *likeCountLab;               //靠谱数
@property (nonatomic,strong) UIButton           *likeBtn;                    //靠谱
@property (nonatomic,strong) UIButton           *unlikeBtn;                  //不靠谱
@property (nonatomic,strong) UILabel            *unlikeCountLab;             //不靠谱数
@property (nonatomic,strong) AnswerModel        *answerModel;
@property (nonatomic,strong) NSIndexPath        *myIndexPath;
@property (nonatomic,strong) MainPageViewModel  *mainAdapter;

@end

@implementation CTFAnswerHandleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark 填充数据
- (void)fillAnswerData:(AnswerModel *)answerModel indexPath:(NSIndexPath *)indexPath{
    self.answerModel = answerModel;
    self.myIndexPath = indexPath;
    [self.commentBtn setTitle:[AppUtils countToString:answerModel.commentCount] forState:UIControlStateNormal];
    [self updateLikeState];
}

#pragma mark -- Event response
#pragma mark 评论
- (void)commentPressedAction:(UIButton *)sender{
    if(![self.findViewController ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]){
        return;
    }
    [self routerEventWithName:kAnswerCommentEvent userInfo:@{kViewpointDataModelKey:self.answerModel,kCellIndexPathKey:self.myIndexPath}];
    
    if (![self.answerModel.status isEqualToString:@"normal"]) {
        [kKeyWindow makeToast:@"该回答尚在审核中"];
        return;
    }
    
    if (self.type == CTFAnswerHandleViewTypeTopicDetails) {
        [MobClick event:@"answerlist_listitemcomment"];
    }
    
    CTFCommentListVC *commentListVC = [[CTFCommentListVC alloc] init];
    commentListVC.answerId = self.answerModel.answerId;
    commentListVC.name = self.answerModel.author.name;
    commentListVC.dismissCallBack = ^(BOOL needReload, NSInteger commentCount) {
        if (needReload) {
            self.answerModel.commentCount = commentCount;
            [self routerEventWithName:kReloadAnswerCommentEvent userInfo:@{kViewpointDataModelKey:self.answerModel,kCellIndexPathKey:self.myIndexPath}];
        }
    };
    HWNavViewController *nav = [[HWNavViewController alloc] initWithRootViewController:commentListVC];
    nav.dismiss = ^(BOOL needReload, NSInteger commentCount) {
        if (needReload) {
            self.answerModel.commentCount = commentCount;
            [self routerEventWithName:kReloadAnswerCommentEvent userInfo:@{kViewpointDataModelKey:self.answerModel,kCellIndexPathKey:self.myIndexPath}];
        }
    };
    [self.findViewController presentPanModal:nav];
}

#pragma mark 更多
- (void)morePressed{
    if (![self.findViewController ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    [self routerEventWithName:kAnswerMoreEvent userInfo:@{kViewpointDataModelKey:self.answerModel,kCellIndexPathKey:self.myIndexPath}];
    if (self.type == CTFAnswerHandleViewTypeHome) { //首页
        [MobClick event:@"home_feeds_itemmore"];
    } else if (self.type == CTFAnswerHandleViewTypeTopicDetails) { //话题详情
        [MobClick event:@"answerlist_listitemmore"];
    } else if (self.type == CTFAnswerHandleViewTypeHomepage) { //个人主页
        [MobClick event:@"homepage_listitemmore"];
    }
    NSString *desc = [NSString stringWithFormat:@"“%@”的回答很不错哦",self.answerModel.author.name];
    //分享图片
    id shareImage = nil;
    if ([self.answerModel.type isEqualToString:@"images"]) {
        if (self.answerModel.images.count>0) {
            ImageItemModel *item = [self.answerModel.images objectAtIndex:0];
            shareImage = [AppUtils imgUrlForGrid:item.url];
        } else {
            shareImage = ImageNamed(@"share_icon_logo");
        }
    } else if([self.answerModel.type isEqualToString:@"video"]) {
        if (!kIsEmptyString(self.answerModel.video.coverUrl)) {
            shareImage = self.answerModel.video.coverUrl;
        } else {
            shareImage = ImageNamed(@"share_icon_logo");
        }
    } else if ([self.answerModel.type isEqualToString:@"audioImage"]) {
        if (self.answerModel.audioImage.count>0) {
            AudioImageModel *item = [self.answerModel.audioImage objectAtIndex:0];
            shareImage = item.url;
        } else {
            shareImage = ImageNamed(@"share_icon_logo");
        }
    } else {
        shareImage = ImageNamed(@"share_icon_logo");
    }
    NSString *shareUrl = [NSString stringWithFormat:kAnswerDetailsUrl,self.answerModel.idString,self.answerModel.question.idString];
    NSDictionary *info = @{@"title":self.answerModel.question.title,@"desc":desc,@"image":shareImage,@"url":shareUrl,@"status":self.answerModel.status,@"resourceType":@"answer",@"resourceId":@(self.answerModel.answerId)};
    CTFShareType type;
    if (self.answerModel.isAuthor) {
        if ([self.answerModel.type isEqualToString:@"images"]) { //图文回答
            type = CTFShareTypeAnswerDeleteAndModify;
        } else {
            type = CTFShareTypeAnswerDelete;
        }
    } else {
        type = CTFShareTypeAnswerOthers;
    }
    
    CTFShareManagerViewController *shareVC = [[CTFShareManagerViewController alloc] init];
    shareVC.info = info;
    shareVC.type = type;
    kSelfWeak;
    shareVC.myBlock = ^(NSInteger tag) {
        if (weakSelf.answerModel.isAuthor) {
            if (tag==0) { //删除回答
                [weakSelf deleteCurrentAnswer];
            } else { //修改回答
                [CTPublishSelectViewController changeAnswer:self.answerModel];
            }
        } else {
            if (tag==0) { //举报回答
                [weakSelf reportCurrentAnswer];
            } else { //不感兴趣
                [weakSelf routerEventWithName:kAnswerNotInterestedEvent userInfo:@{kViewpointDataModelKey: weakSelf.answerModel,kCellIndexPathKey:weakSelf.myIndexPath}];
            }
        }
    };
    [self.findViewController presentPanModal:shareVC];
}

#pragma mark 靠谱或不靠谱
-(void)setLikeAction:(UIButton *)sender{
    if (![self.findViewController ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Logined]) {
        return;
    }
    if (![self.answerModel.status isEqualToString:@"normal"]) {
        [kKeyWindow makeToast:@"该回答尚在审核中"];
        return;
    }
    
    if (sender.tag==0) { //靠谱
        BOOL needShowAnimate = NO;
        if ([self.answerModel.attitude isEqualToString:@"neutral"]) {
           self.answerModel.voteupCount++;
           self.answerModel.attitude = @"like";
            needShowAnimate = YES;
        } else {
            if ([self.answerModel.attitude isEqualToString:@"like"]) {
                //之前是赞再点赞，取消赞
                self.answerModel.voteupCount--;
                if(self.answerModel.voteupCount < 0) self.answerModel.voteupCount = 0;
                self.answerModel.attitude = @"neutral";
            } else {
                //之前是猜再点赞，取消菜，加上赞
                self.answerModel.votedownCount--;
                if(self.answerModel.votedownCount < 0) self.answerModel.votedownCount = 0;
                self.answerModel.voteupCount++;
                self.answerModel.attitude = @"like";
                needShowAnimate = YES;
            }
        }
        if (needShowAnimate) {
            AudioServicesPlaySystemSound(1520);
        }
    } else {
        if ([self.answerModel.attitude isEqualToString:@"neutral"]) {
           self.answerModel.votedownCount++;
           self.answerModel.attitude = @"unlike";
            AudioServicesPlaySystemSound(1520);
        } else {
            if ([self.answerModel.attitude isEqualToString:@"unlike"]) {
                //之前是踩再点踩，取消踩
                self.answerModel.votedownCount--;
                if (self.answerModel.votedownCount < 0) self.answerModel.votedownCount = 0;
                self.answerModel.attitude = @"neutral";
            } else {
                //之前是赞再踩，取消赞，加上踩
                self.answerModel.voteupCount--;
                if(self.answerModel.voteupCount < 0) self.answerModel.voteupCount = 0;
                self.answerModel.votedownCount++;
                self.answerModel.attitude = @"unlike";
                AudioServicesPlaySystemSound(1520);
            }
        }
    }
    [self updateLikeState];
    
    //设置靠谱
    [self.mainAdapter votersToAnswer:self.answerModel.answerId attitude:self.answerModel.attitude complete:^(BOOL isSuccess) {
        if (self.type == CTFAnswerHandleViewTypeHome && isSuccess) {
            MainTabListViewController *vc = (MainTabListViewController *)self.findViewController;
            [vc removeMainPageLearningView];
        }
    }];
}

#pragma mark -- Private methods
#pragma mark 删除回答
- (void)deleteCurrentAnswer {
    MBProgressHUD *hud = [MBProgressHUD ctfShowLoading:self.findViewController.view title:nil];
    @weakify(self);
    [self.mainAdapter deleteMyViewpoint:self.answerModel.answerId complete:^(BOOL isSuccess) {
        [hud hideAnimated:YES];
        @strongify(self);
        if (isSuccess) {
            [kKeyWindow makeToast:@"删除成功"];
            [self routerEventWithName:kAnswerDeleteEvent userInfo:@{kViewpointDataModelKey: self.answerModel,kCellIndexPathKey:self.myIndexPath}];
        } else {
            [kKeyWindow makeToast:self.mainAdapter.errorString];
        }
    }];
}

#pragma mark 举报回答
- (void)reportCurrentAnswer {
    [self routerEventWithName:kAnswerReportEvent userInfo:@{kViewpointDataModelKey: self.answerModel,kCellIndexPathKey:self.myIndexPath}];
    CTFReportTypeOptionVC *reportTypeOptionVC = [[CTFReportTypeOptionVC alloc] initWithFeedBackType:FeedBackType_Answer resourceTypeId:self.answerModel.answerId];
    reportTypeOptionVC.dismissBlock = ^{
        [self routerEventWithName:kAnswerReportDismissEvent userInfo:@{kViewpointDataModelKey: self.answerModel,kCellIndexPathKey:self.myIndexPath}];
    };
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:reportTypeOptionVC];
    nav.modalPresentationStyle = UIModalPresentationCustom;
    [self.findViewController presentViewController:nav animated:YES completion:nil];
}

#pragma mark 更新状态
-(void)updateLikeState{
    self.unlikeCountLab.text = [AppUtils countToString:self.answerModel.votedownCount];
    self.likeCountLab.text = [AppUtils countToString:self.answerModel.voteupCount];
    if ([self.answerModel.attitude isEqualToString:@"like"]) {
        [self.likeBtn setSelected:YES];
        [self.likeCountLab setHighlighted:YES];
        [self.unlikeBtn setSelected:NO];
        [self.unlikeCountLab setHighlighted:NO];
    } else if([self.answerModel.attitude isEqualToString:@"unlike"]) {
        [self.likeBtn setSelected:NO];
        [self.likeCountLab setHighlighted:NO];
        [self.unlikeBtn setSelected:YES];
        [self.unlikeCountLab setHighlighted:YES];
    } else {
        [self.likeBtn setSelected:NO];
        [self.likeCountLab setHighlighted:NO];
        [self.unlikeBtn setSelected:NO];
        [self.unlikeCountLab setHighlighted:NO];
    }
}

#pragma mark 初始化
- (void)setupUI {
    [self addSubview:self.moreBtn];
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kMarginLeft);
        make.centerY.equalTo(self.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self addSubview:self.commentBtn];
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.moreBtn.mas_right).offset(30);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self addSubview:self.unlikeCountLab];
    [self.unlikeCountLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-kMarginRight);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self addSubview:self.unlikeBtn];
    [self.unlikeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
          make.right.equalTo(self.unlikeCountLab.mas_left).offset(-2); //-40
          make.centerY.mas_equalTo(self.mas_centerY);
          make.height.mas_equalTo(28);
          make.width.mas_equalTo(76);
    }];
    
    [self addSubview:self.likeBtn];
    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.unlikeBtn.mas_left);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.height.mas_equalTo(28);
        make.width.mas_equalTo(76); 
    }];
    
    [self addSubview:self.likeCountLab];
    [self.likeCountLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.likeBtn.mas_left).offset(-2);
        make.centerY.equalTo(self.mas_centerY);
    }];
}

#pragma mark -- Getters
#pragma mark 更多
- (UIButton *)moreBtn {
    if (!_moreBtn) {
        _moreBtn = [[UIButton alloc] init];
        [_moreBtn setImage:ImageNamed(@"answer_icon_share") forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(morePressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

#pragma mark 评论
- (UIButton *)commentBtn{
    if (!_commentBtn) {
        _commentBtn = [[UIButton alloc] init];
        [_commentBtn setImage:ImageNamed(@"tool_comment_nor") forState:UIControlStateNormal];
        [_commentBtn setTitleColor:[UIColor ctColor66] forState:UIControlStateNormal];
        _commentBtn.titleLabel.font = [UIFont regularFontWithSize:14];
        _commentBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 0);
        [_commentBtn addTarget:self action:@selector(commentPressedAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentBtn;
}

#pragma mark 靠谱数
-(UILabel *)likeCountLab{
    if (!_likeCountLab) {
        _likeCountLab = [[UILabel alloc] init];
        _likeCountLab.textAlignment = NSTextAlignmentRight;
        _likeCountLab.font = [UIFont regularFontWithSize:14];
        _likeCountLab.textColor = [UIColor ctColor66];
        _likeCountLab.highlightedTextColor = UIColorFromHEX(0xF9384A);
    }
    return _likeCountLab;
}

#pragma mark 靠谱
-(UIButton *)likeBtn{
    if (!_likeBtn) {
        _likeBtn = [[UIButton alloc] init];
        [_likeBtn setBackgroundImage:ImageNamed(@"tool_likebg_nor") forState:UIControlStateNormal];
         [_likeBtn setBackgroundImage:ImageNamed(@"tool_likebg_sel") forState:UIControlStateSelected];
        [_likeBtn setImage:ImageNamed(@"tool_like_flag") forState:UIControlStateNormal];
        [_likeBtn setImage:ImageNamed(@"tool_like_flag") forState:UIControlStateSelected];
        [_likeBtn setTitleColor:[UIColor ctColor4C]  forState:UIControlStateNormal];
        [_likeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        _likeBtn.titleLabel.font = [UIFont mediumFontWithSize:12];
        [_likeBtn setTitle:@"靠谱" forState:UIControlStateNormal];
        _likeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        _likeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        _likeBtn.tag = 0;
        [_likeBtn addTarget:self action:@selector(setLikeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _likeBtn;
}

#pragma mark 不靠谱
-(UIButton *)unlikeBtn{
    if (!_unlikeBtn) {
        _unlikeBtn = [[UIButton alloc] init];
        [_unlikeBtn setBackgroundImage:ImageNamed(@"tool_unlikebg_nor") forState:UIControlStateNormal];
        [_unlikeBtn setBackgroundImage:ImageNamed(@"tool_unlikebg_sel") forState:UIControlStateSelected];
        [_unlikeBtn setImage:ImageNamed(@"tool_unlike_flag") forState:UIControlStateNormal];
        [_unlikeBtn setImage:ImageNamed(@"tool_unlike_flag") forState:UIControlStateSelected];
        [_unlikeBtn setTitleColor:[UIColor ctColor4C] forState:UIControlStateNormal];
        [_unlikeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_unlikeBtn setTitle:@"不靠谱" forState:UIControlStateNormal];
        _unlikeBtn.titleLabel.font = [UIFont mediumFontWithSize:12];
        _unlikeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, _unlikeBtn.titleLabel.intrinsicContentSize.width, 0, -_unlikeBtn.titleLabel.intrinsicContentSize.width);
        _unlikeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -_unlikeBtn.imageView.intrinsicContentSize.width-4, 0, _unlikeBtn.imageView.intrinsicContentSize.width+5);
        _unlikeBtn.tag = 1;
        [_unlikeBtn addTarget:self action:@selector(setLikeAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _unlikeBtn;
}

#pragma mark 不靠谱数
-(UILabel *)unlikeCountLab{
    if (!_unlikeCountLab) {
        _unlikeCountLab = [[UILabel alloc] init];
        _unlikeCountLab.font = [UIFont regularFontWithSize:14];
        _unlikeCountLab.textColor = [UIColor ctColor66];
        _unlikeCountLab.highlightedTextColor = [UIColor ctColor4C];
        _unlikeCountLab.textAlignment = NSTextAlignmentRight;
    }
    return _unlikeCountLab;
}

- (MainPageViewModel *)mainAdapter{
    if (!_mainAdapter) {
        _mainAdapter = [[MainPageViewModel alloc] init];
    }
    return _mainAdapter;
}

@end
