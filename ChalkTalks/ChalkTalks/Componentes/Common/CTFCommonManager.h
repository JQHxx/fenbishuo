//
//  CTFCommonManager.h
//  ChalkTalks
//
//  Created by vision on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"


NS_ASSUME_NONNULL_BEGIN

@interface CTFCommonManager : NSObject

singleton_interface(CTFCommonManager)

@property (nonatomic,assign) BOOL  homeFeedsLoad;
@property (nonatomic,assign) BOOL  userInfoLoad;
@property (nonatomic,assign) BOOL  homePageLoad;
@property (nonatomic,assign) BOOL  topicReLoad;
@property (nonatomic, copy ) NSArray  *questionTitleSuffix; //话题后缀
@property (nonatomic,assign) BOOL  needVideoStop;


/*
 * 数量转化 （如1k 1.3k）
 * @param count 数量
 */
+ (NSString *)numberTransforByCount:(NSInteger)count;

/*
* 设置话题标题
* @param type 话题类型
* @param shortTitle 话题短标题
* @param suffix 前后缀
*/
+ (NSMutableAttributedString *)setTopicTitleWithType:(NSString *)type
                                         shortTitle:(NSString *)shortTitle
                                             suffix:(NSString *)suffix;


/*
 * 草稿箱数据转换成回答模型
 * @param draftModel 草稿箱数据
 *
 */
- (AnswerModel *)transformAnswerForDraftAnswer:(CTDraftAnswer *)draftModel;

@end

NS_ASSUME_NONNULL_END
