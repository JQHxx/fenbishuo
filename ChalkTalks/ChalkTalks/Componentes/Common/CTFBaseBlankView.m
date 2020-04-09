//
//  CTFBaseBlankView.m
//  ChalkTalks
//
//  Created by vision on 2020/1/4.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFBaseBlankView.h"

@interface CTFBaseBlankView ()

@property (nonatomic, assign) CTFBlankType blankType;
@property (nonatomic, strong) UIImage *emptyImage;
@property (nonatomic, copy) NSString *emptyMessage;

@end

@implementation CTFBaseBlankView

- (instancetype)initWithFrame:(CGRect)frame blankType:(CTFBlankType)blankType imageOffY:(NSInteger)imageOffY {
    if (self = [super initWithFrame:frame]) {
        [self setBlankType:blankType];
        
        CGSize imageSize = self.emptyImage.size;
        
        self.myImgView = [[UIImageView alloc] initWithImage:self.emptyImage];
        [self addSubview:self.myImgView];
        [self.myImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset((kScreen_Width-imageSize.width)/2.f);
            make.size.mas_equalTo(CGSizeMake(imageSize.width, imageSize.height));
            make.top.mas_equalTo(self.mas_top).offset(imageOffY);
        }];
        
        self.tipslab = [[UILabel alloc] init];
        self.tipslab.text = self.emptyMessage;
        self.tipslab.font = [UIFont regularFontWithSize:15];
        self.tipslab.textColor = UIColorFromHEX(0x999999);
        self.tipslab.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.tipslab];
        [self.tipslab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).offset(10);
            make.top.mas_equalTo(self.myImgView.mas_bottom).offset(20);
            make.width.mas_equalTo(kScreen_Width-20);
        }];
    }
    return self;
}

#pragma mark  显示空白
- (void)setBlankType:(CTFBlankType)blankType {
    _blankType = blankType;
    if (self.blankType == CTFBlankType_ErrorNetwork) {
       self.emptyImage = ImageNamed(@"empty_NoNetwork_154x154");
       self.emptyMessage = @"网络出了一点小意外~";
        
    } else if (self.blankType == CTFBlankType_ErrorServer) {
       self.emptyImage = ImageNamed(@"empty_NoNetwork_154x154");
       self.emptyMessage = @"网络出了一点小意外~";
        
    }else if (self.blankType == CTFBlankType_ErrorNetwork_LitterIcon) {
       self.emptyImage = ImageNamed(@"empty_NoNetwork_120x120");
       self.emptyMessage = @"网络出了一点小意外~";
        
    } else if (self.blankType == CTFBlankType_ErrorServer_LitterIcon) {
       self.emptyImage = ImageNamed(@"empty_NoNetwork_120x120");
       self.emptyMessage = @"网络出了一点小意外~";
        
    } else if (self.blankType == CTFBlankTypeComment) {
        self.emptyImage = ImageNamed(@"empty_NoCommit_120x120");
        self.emptyMessage = @"还没有人来评论，快来抢沙发~";
        
    } else if (self.blankType == CTFBlankTypeHomepage) {
        self.emptyImage = ImageNamed(@"empty_NoAction_120x120");
        self.emptyMessage = @"还没有动态，赶快发一个话题体验一下吧";
        
    } else if (self.blankType == CTFBlankTypeOtherPage) {
        self.emptyImage = ImageNamed(@"empty_NoAction_120x120");
        self.emptyMessage = @"这人很不靠谱，啥也没留下";
        
    } else if (self.blankType == CTFBlankType_VoteList) {
        self.emptyImage = ImageNamed(@"empty_NoContent_160x160");
        self.emptyMessage = @"内容还在努力生产中~";
        
    } else if (self.blankType == CTFBlankType_SearchResult) {
        self.emptyImage = ImageNamed(@"empty_NoSearch_120x120");
        self.emptyMessage = @"还没有对应的内容~";
        
    } else if (self.blankType == CTFBlankType_DraftBox) {
        self.emptyImage = ImageNamed(@"empty_NoDraft_92x84");
        self.emptyMessage = @"暂时还没有草稿";
        
    } else if (self.blankType == CTFBlankType_FansForMe) {
       self.emptyImage = ImageNamed(@"empty_NoCare_120x120");
       self.emptyMessage = @"优秀如我，竟然还没有人关注";
        
    } else if (self.blankType == CTFBlankType_FansForOther) {
       self.emptyImage = ImageNamed(@"empty_NoCare_120x120");
       self.emptyMessage = @"点一下关注，找Ta不迷路";
        
    } else if (self.blankType == CTFBlankType_FollowForMe) {
       self.emptyImage = ImageNamed(@"empty_NoCare_120x120");
       self.emptyMessage = @"对Ta感兴趣，赶紧关注起来~";
        
    } else if (self.blankType == CTFBlankType_FollowForOther) {
       self.emptyImage = ImageNamed(@"empty_NoCare_120x120");
       self.emptyMessage = @"还没有值得让Ta回眸的人~";

    } else if (self.blankType == CTFBlankType_MineTopic) {
       self.emptyImage = ImageNamed(@"empty_NoAction_120x120");
       self.emptyMessage = @"你没点什么想知道的吗~";
        
    } else if (self.blankType == CTFBlankType_MineCareTopic) {
       self.emptyImage = ImageNamed(@"empty_NoAction_120x120");
       self.emptyMessage = @"你怎么什么都不关心吖~";
        
    } else if (self.blankType == CTFBlankType_MineViewPoint) {
       self.emptyImage = ImageNamed(@"empty_NoAction_120x120");
       self.emptyMessage = @"你还没有回答过任何问题~";
    }
}

@end
