//
//  CTFBaseBlankView.h
//  ChalkTalks
//
//  Created by vision on 2020/1/4.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewModel.h"
#import "UIView+Frame.h"

typedef enum : NSUInteger {
    
    CTFBlankType_ErrorNetwork,                 //网络错误
    CTFBlankType_ErrorServer,                  //服务器错误
    CTFBlankType_ErrorNetwork_LitterIcon,      //网络错误(小图)
    CTFBlankType_ErrorServer_LitterIcon,       //服务器错误（小图）
    
    CTFBlankTypeComment,            //评论
    CTFBlankTypeHomepage,           //个人主页
    CTFBlankTypeOtherPage,          //他人主页
    CTFBlankType_VoteList,          //投票列表
    CTFBlankType_SearchResult,      //搜索结果
    CTFBlankType_DraftBox,          //草稿箱
    CTFBlankType_FansForMe,         //粉丝列表（对自己）
    CTFBlankType_FansForOther,      //粉丝列表（对他人）
    CTFBlankType_FollowForMe,       //关注列表（对自己）
    CTFBlankType_FollowForOther,    //关注列表（对他人）
    CTFBlankType_MineTopic,         //我想知道
    CTFBlankType_MineCareTopic,     //我关心的
    CTFBlankType_MineViewPoint      //我的回答
    
    
} CTFBlankType;

NS_ASSUME_NONNULL_BEGIN

@interface CTFBaseBlankView : UIView

- (instancetype)initWithFrame:(CGRect)frame blankType:(CTFBlankType)blankType imageOffY:(NSInteger)imageOffY;

@property (nonatomic, strong) UIImageView    *myImgView;
@property (nonatomic, strong) UILabel        *tipslab;

@end

NS_ASSUME_NONNULL_END
