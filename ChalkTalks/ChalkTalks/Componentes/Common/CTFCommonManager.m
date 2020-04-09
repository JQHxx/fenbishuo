//
//  CTFCommonManager.m
//  ChalkTalks
//
//  Created by vision on 2019/12/26.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFCommonManager.h"
#import "CTRequest.h"

@implementation CTFCommonManager

singleton_implementation(CTFCommonManager)

-(void)setUserInfoLoad:(BOOL)userInfoLoad{
    if (userInfoLoad) {
        self.homePageLoad = YES;
    }
}

#pragma mark 数目转换
+(NSString *)numberTransforByCount:(NSInteger)count{
    NSString *transforString = @"";
    if (count < 999) {
        transforString = [NSString stringWithFormat:@"%ld", count];
        return transforString;
    }else {
        CGFloat floatNumber = count / 1000.f;
        if (count % 1000 < 100) {
            transforString = [NSString stringWithFormat:@"%0.0lfK", floatNumber];
        }else {
            transforString = [NSString stringWithFormat:@"%0.1lfK", floatNumber];
        }
        return transforString;
    }
}

#pragma mark 设置话题标题
+ (NSMutableAttributedString *)setTopicTitleWithType:(NSString *)type shortTitle:(NSString *)shortTitle suffix:(NSString *)suffix {
    NSMutableAttributedString *attrbuteStr ;
    if ([type isEqualToString:@"demand"]) { //提要求
        NSString *titleStr = [NSString stringWithFormat:@"%@%@",shortTitle,suffix];
        attrbuteStr = [[NSMutableAttributedString alloc] initWithString:titleStr];
        [attrbuteStr addAttribute:NSForegroundColorAttributeName value:[UIColor ctMainColor] range:NSMakeRange(shortTitle.length, suffix.length)];
    } else { //求推荐
        NSString *titleStr = [NSString stringWithFormat:@"求推荐%@",shortTitle];
        attrbuteStr = [[NSMutableAttributedString alloc] initWithString:titleStr];
        [attrbuteStr addAttribute:NSForegroundColorAttributeName value:[UIColor ctRecommendColor] range:NSMakeRange(0, 3)];
    }
    return attrbuteStr;
}

#pragma mark  草稿箱数据转换成回答模型
- (AnswerModel *)transformAnswerForDraftAnswer:(CTDraftAnswer *)draftModel {
    AnswerModel *answerModel = [[AnswerModel alloc] init];
    answerModel.draftId = draftModel.draftId;
    QuestionModel *question = [[QuestionModel alloc] init];
    question.questionId = draftModel.questionId;
    question.title = draftModel.questionTitle;
    answerModel.question = question;
    answerModel.content = draftModel.content;
    answerModel.createdAt = draftModel.updateAt;
    if (draftModel.type == DraftAnswerTypePhoto) {
        answerModel.type = @"images";
        if (draftModel.items.count>0) {
            NSMutableArray *tempArr = [[NSMutableArray alloc] init];
            for (CTDraftAnswerItem *item in draftModel.items) {
                ImageItemModel *imageItem = [[ImageItemModel alloc] init];
                imageItem.image = [[CTDrafts share] imageWithPath:item.imagePath];
                imageItem.isLocal = YES;
                imageItem.imgId = [item.imageId integerValue];
                [tempArr addObject:imageItem];
            }
            answerModel.images = tempArr;
        }
    } else if (draftModel.type == DraftAnswerTypeVideo) {
        answerModel.type = @"video";
        answerModel.videoPath = draftModel.videoPath;
        answerModel.videoCoverPath = draftModel.videoCoverPath;
        answerModel.videoCoverIndex = draftModel.videoCoverIndex;
    } else if (draftModel.type == DraftAnswerTypePhotoWithAudio) {
        answerModel.type = @"audioImage";
    }
    return answerModel;
}

@end
