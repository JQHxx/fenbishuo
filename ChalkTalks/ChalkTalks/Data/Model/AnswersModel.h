//
//  AnswersModel.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/6.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ImageItemModel :NSObject

@property (nonatomic , assign) NSInteger            imgId;
@property (nonatomic ,  copy ) NSString             *url;
@property (nonatomic , assign) NSInteger            size;
@property (nonatomic ,  copy ) NSString             *status;
@property (nonatomic , assign) CGFloat              width;
@property (nonatomic , assign) CGFloat              height;
@property (nonatomic ,  copy ) NSString             *objectKey;
@property (nonatomic ,  copy ) NSString             *imgHash;
@property (nonatomic , strong) UIImage              *image;
@property (nonatomic , assign) BOOL                 isLocal;

@end


@interface VideoItemModel :NSObject

@property (nonatomic , assign) NSInteger              videoId;
@property (nonatomic , copy) NSString              * status;
@property (nonatomic , copy) NSString              * videoHash;
@property (nonatomic , assign) CGFloat              height;
@property (nonatomic , copy) NSString              * encode;
@property (nonatomic , assign) CGFloat              width;
@property (nonatomic , assign) NSInteger              size;
@property (nonatomic , assign) NSInteger              duration;
@property (nonatomic , assign) NSInteger              rotation;
@property (nonatomic , copy) NSString              *coverUrl;
@property (nonatomic , copy) NSString              * url;

//local
@property(nonatomic,assign) CGFloat aleayPlayDuration;  //记录播放进度
@property(nonatomic,assign) BOOL isPlayComplete; //是否正常播放完成

@end

@interface AudioModel : NSObject

@property (nonatomic , assign) NSInteger            audioId;
@property (nonatomic , assign) NSInteger            idString;
@property (nonatomic ,  copy ) NSString             *url;
@property (nonatomic , assign) NSInteger            duration;
@property (nonatomic , assign) NSInteger            size;
@property (nonatomic ,  copy ) NSString             *status;

@end

@interface AudioImageModel : NSObject

@property (nonatomic , assign) NSInteger            audioId;
@property (nonatomic , assign) NSInteger            idString;
@property (nonatomic ,  copy ) NSString             *url;
@property (nonatomic , assign) NSInteger            size;
@property (nonatomic ,  copy ) NSString             *status;
@property (nonatomic , assign) CGFloat              width;
@property (nonatomic , assign) CGFloat              height;
@property (nonatomic ,  copy ) NSString             *audioHash;
@property (nonatomic , strong) NSDictionary         *audio;

@end


@interface AuthorModel :NSObject
@property (nonatomic , assign) NSInteger              authorId;
@property (nonatomic , copy) NSString              * avatarUrl;
@property (nonatomic , copy) NSString              * name;
@property (nonatomic , copy) NSString              * city;
@property (nonatomic , copy) NSString              * gender;
@property (nonatomic , copy) NSString              * headline;
@property (nonatomic ,assign) BOOL                isFollowing;
@end


@interface QuestionModel :NSObject

@property (nonatomic , assign) NSInteger           questionId;
@property (nonatomic ,  copy ) NSString            *title;
@property (nonatomic , assign) NSInteger           createdAt;
@property (nonatomic , assign) NSInteger           idString;
@property (nonatomic ,  copy ) NSString            *shortTitle; //标题
@property (nonatomic ,  copy ) NSString            *suffix; //前缀或后缀
@property (nonatomic ,  copy ) NSString            *type; //话题类型 recommend求推荐 demand提要求
@property (nonatomic , strong) NSDictionary        *author;

@end

@interface AnswerModel : BaseModel

@property (nonatomic , assign) NSInteger                   answerId;
@property (nonatomic , assign) NSInteger                   idString;
@property (nonatomic ,  copy ) NSString                    *content;
@property (nonatomic , assign) NSInteger                   createdAt;
@property (nonatomic , assign) NSInteger                   commentCount;
@property (nonatomic , assign) NSInteger                   voteupCount;
@property (nonatomic , assign) NSInteger                   votedownCount;
@property (nonatomic ,  copy ) NSString                    *attitude;
@property (nonatomic , strong) NSArray <ImageItemModel *>  *images;
@property (nonatomic , strong) VideoItemModel              *video;
@property (nonatomic , strong) NSArray <AudioImageModel *> *audioImage;
@property (nonatomic , strong) AuthorModel                 *author;
@property (nonatomic , strong) QuestionModel               *question;
@property (nonatomic , assign) BOOL                        isAuthor;
@property (nonatomic ,  copy ) NSString                    *type;  //images\video\audioImage
@property (nonatomic ,  copy ) NSString          *status;  //init:初始状态；reviewing:正在审核中;failed:转码失败;normal：正常状态 ；blocked:已拉黑 ;deleted:已删除；
@property (nonatomic , assign) NSInteger        viewCount; //阅读量

@property (nonatomic , assign) BOOL              hideTitle;
@property (nonatomic ,  copy ) NSString          *myTitle;
@property (nonatomic , assign) NSInteger         currentIndex;

//feed
@property (nonatomic , assign) NSInteger                   feedId;

//草稿箱相关
@property (nonatomic , assign) NSInteger         draftId; //草稿箱id
@property (nonatomic ,  copy ) NSString          *videoPath; //视频路径
@property (nonatomic ,  copy ) NSString          *videoCoverPath; //视频封面路径
@property (nonatomic , assign) NSInteger         videoCoverIndex; //视频封面序号


@end

NS_ASSUME_NONNULL_END
