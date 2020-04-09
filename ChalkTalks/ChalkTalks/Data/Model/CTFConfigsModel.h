//
//  CTFConfigsModel.h
//  ChalkTalks
//
//  Created by vision on 2020/2/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFGuideVideoModel : NSObject

@property (nonatomic,assign) NSInteger  duration;
@property (nonatomic, copy ) NSString   *url;
@property (nonatomic, copy ) NSString   *videoPath;
@property (nonatomic,strong) UIImage    *videoCoverImage;

@end

@interface CTFSuffixModel : NSObject

@property (nonatomic,assign) NSInteger suffixId;
@property (nonatomic, copy ) NSString  *idString;
@property (nonatomic, copy ) NSString  *suffix;
@property (nonatomic,assign) BOOL      isSelected;

@end

@interface CTFConfigsModel : BaseModel

@property (nonatomic , copy ) NSString  *appTrendingSearchWord; //app热搜词
@property (nonatomic , copy ) NSString  *questionGuide;  //onceGuide：一次引导，onceClick：一次点击
@property (nonatomic , copy ) NSArray   <CTFSuffixModel *> *questionTitleSuffix;
@property (nonatomic ,strong) CTFGuideVideoModel  *questionGuideVideo;


@end

NS_ASSUME_NONNULL_END
