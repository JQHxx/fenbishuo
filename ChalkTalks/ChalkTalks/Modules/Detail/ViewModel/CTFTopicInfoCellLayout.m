//
//  CTFTopicInfoCellLayout.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFTopicInfoCellLayout.h"
#import "NSString+Size.h"
#import "UIFont+DefFonts.h"

@interface CTFTopicInfoCellLayout()
@property (nonatomic, assign) CGRect headerRect;
@property (nonatomic, assign) CGRect nickNameRect;
@property (nonatomic, assign) CGRect signRect;
@property (nonatomic, assign) CGRect timeRect;
@property (nonatomic, assign) CGRect typeRect;
@property (nonatomic, assign) CGRect topicContentRect;
@property (nonatomic, assign) CGRect topicSummaryRect; //2行
@property (nonatomic, assign) CGRect topicAllSummaryRect; //全部
@property (nonatomic, assign) CGRect showAllButtonRect; //显示 全部/收起
@property (nonatomic, assign) CGRect statusRect;
@property (nonatomic, assign) CGRect imgsRect;
@property (nonatomic, assign) CGFloat imgItemWidth;
@property (nonatomic, assign) CGFloat imgItemHeight;
@property (nonatomic, assign) CGRect attitudeRect;  //关心 踩
@property (nonatomic, assign) CGRect lineRect;

@property (nonatomic, assign) CGFloat height;  //没有展示全部备注的高度
@property (nonatomic, assign) CGFloat allHeight; //
@end

@implementation CTFTopicInfoCellLayout

- (instancetype)initWithData:(CTFQuestionsModel *)data{
    self = [super init];
    if (self) {
        self.model = data;
        
        CGFloat min_x = kMarginLeft;
        CGFloat min_y = 2;
        CGFloat min_h = 32;
        CGFloat min_view_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat min_w = min_view_w - 2*kMarginLeft;
        CGFloat gap = 10;
        self.headerRect = CGRectMake(min_x, min_y, min_h, min_h);
        
        min_x = CGRectGetMaxX(self.headerRect)+ 10;
        self.nickNameRect = CGRectMake(min_x, min_y, 120, 18);
        
        min_y = CGRectGetMaxY(self.nickNameRect);
        self.signRect = CGRectMake(min_x, min_y, min_view_w - 120 , 16);
        
        min_x = kMarginLeft;
        min_y = CGRectGetMaxY(self.headerRect) + 14;
        min_h = [data.title ctTextSizeWithFont:[UIFont mediumFontWithSize:20] numberOfLines:0 constrainedWidth:min_w].height;
        self.topicContentRect = CGRectMake(min_x, min_y, min_w, min_h);
        
        min_y = CGRectGetMaxY(self.topicContentRect) + 8;
        self.typeRect = CGRectMake(min_x, min_y, 54, 18);
        self.timeRect = CGRectMake(CGRectGetMaxX(self.typeRect) + 5, min_y,120, 18);
            
        //话题内容 全部
        if (!kIsEmptyString(data.content)) {
            min_y = CGRectGetMaxY(self.typeRect) + gap;
            min_h = [data.content ctTextSizeWithFont:[UIFont regularFontWithSize:16] numberOfLines:0 lineSpacing:4 constrainedWidth:min_w].height;
        }else{
            min_y = CGRectGetMaxY(self.typeRect);
            min_h = 0;
        }
        self.topicAllSummaryRect = CGRectMake(min_x, min_y, min_w, min_h);
            
        //话题内容 1行
        if (!kIsEmptyString(data.content)) {
            CGFloat height = [data.content ctTextSizeWithFont:[UIFont regularFontWithSize:16] numberOfLines:0 lineSpacing:4 constrainedWidth:min_w].height;
            if (height<20) {
                min_h = height;
            }else{
                min_h = [data.content ctTextSizeWithFont:[UIFont regularFontWithSize:16] numberOfLines:2 lineSpacing:4 constrainedWidth:min_w].height;
            }
        }else{
            min_h = 0;
        }
        self.topicSummaryRect = CGRectMake(min_x, min_y, min_w, min_h);
            
        if (data.images.count>0) {
            self.needShowAllBtn = YES;
        }else{
            self.needShowAllBtn = CGRectGetHeight(self.topicAllSummaryRect) > CGRectGetHeight(self.topicSummaryRect);
        }
        
        
        //imgs
        min_y = CGRectGetMaxY(self.topicAllSummaryRect);
        FeedImageSize imgsSize =  [AppMargin feedImageDimensions:data.images viewWidith:kScreen_Width-2*kMarginLeft];
        self.imgsRect = CGRectMake(min_x, min_y+gap, imgsSize.imgContainerWidth, imgsSize.imgContainerHeight);
        self.imgItemWidth = imgsSize.imgItemWidth;
        self.imgItemHeight = imgsSize.imgItemHeight;
        
        if (![data.status isEqualToString:@"normal"]) {
            if (data.images.count > 0) {
                self.statusRect = CGRectZero;
                min_y = CGRectGetMaxY(self.topicSummaryRect)+10;
            } else {
                min_y = CGRectGetMaxY(self.topicSummaryRect)+10;
                self.statusRect = CGRectMake(kMarginLeft, min_y, 80, 18);
                min_y = CGRectGetMaxY(self.statusRect)+10;
            }
        } else {
            self.statusRect = CGRectZero;
            min_y = CGRectGetMaxY(self.topicSummaryRect)+10;
        }
            
        if(self.needShowAllBtn){
            //图文超过1行，默认隐藏
            min_x = (min_view_w - 60)/2.0;
            self.showAllButtonRect = CGRectMake(min_x, min_y, 60, 18);
        }else{
//            min_y = CGRectGetMaxY(self.topicAllSummaryRect);
            self.showAllButtonRect = CGRectMake(min_x, min_y, 0, 0);
        }
        
        min_x = 0;
        self.attitudeRect = CGRectMake((min_view_w-220)/2.0, min_y+16, 220, 54);
        
        min_y = CGRectGetMaxY(self.attitudeRect) + gap;
        self.lineRect = CGRectMake(0, min_y, min_view_w, 8);
        
        self.height = CGRectGetMaxY(self.typeRect);
        self.allHeight = CGRectGetMaxY(self.typeRect);
        if(self.needShowAllBtn){
            self.height += gap;
            self.height += CGRectGetHeight(self.showAllButtonRect);
            self.height += gap;
            self.allHeight += gap;
            self.allHeight += CGRectGetHeight(self.showAllButtonRect);
            self.allHeight += gap;
        }
        
        if (!kIsEmptyString(data.content)) {
            self.height += CGRectGetHeight(self.topicSummaryRect);
            self.height += gap;
            self.allHeight += CGRectGetHeight(self.topicAllSummaryRect);
            self.allHeight += gap;
        }
        
        if (![data.status isEqualToString:@"normal"] && data.images.count == 0) {
            self.height += CGRectGetHeight(self.statusRect);
            self.height += gap;
            self.allHeight += CGRectGetHeight(self.statusRect);
            self.allHeight += gap;
        }
        
        if (data.images.count>0) {
            self.allHeight += CGRectGetHeight(self.imgsRect);
            self.allHeight += gap;
        }
    
        
        self.height += CGRectGetHeight(self.attitudeRect);
        self.height += gap;
        self.allHeight += CGRectGetHeight(self.attitudeRect);
        self.allHeight += gap;
        
        self.height += CGRectGetHeight(self.lineRect);
        self.allHeight += CGRectGetHeight(self.lineRect);
    }
    return self;
}

+(NSArray<CTFTopicInfoCellLayout*>*)converToLayout:(NSArray<CTFQuestionsModel*>*)list{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(CTFQuestionsModel *item in list){
        [arr addObject:[[CTFTopicInfoCellLayout alloc] initWithData:item]];
    }
    return arr;
}
@end
