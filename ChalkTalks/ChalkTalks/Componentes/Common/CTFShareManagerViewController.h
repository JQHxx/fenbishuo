//
//  CTFShareManagerViewController.h
//  ChalkTalks
//
//  Created by vision on 2020/3/27.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CTFShareTypeDefault,    //默认
    CTFShareTypeQuestionOthers,   //举报话题
    CTFShareTypeQuestionMine,     //删除话题、修改话题
    CTFShareTypeAnswerOthers,     //举报回答、不感兴趣
    CTFShareTypeAnswerDelete,     //删除回答
    CTFShareTypeAnswerDeleteAndModify,   //删除回答、修改回答
    CTFShareTypeAnswerSucceed,  //回答完成后引导
} CTFShareType;

NS_ASSUME_NONNULL_BEGIN

typedef void(^CompleteBlock)(NSInteger tag);

@interface CTFShareManagerViewController : UIViewController

@property (nonatomic ,assign) CTFShareType   type;
@property (nonatomic ,strong) NSDictionary   *info;
@property (nonatomic, copy ) CompleteBlock   myBlock;

@end

NS_ASSUME_NONNULL_END
