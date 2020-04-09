//
//  CTFAnswerDetailCellLayout.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFAnswerDetailCellLayout.h"
#import "NSString+Size.h"

@interface CTFAnswerDetailCellLayout()
@property (nonatomic, assign) CGRect userInfoRect;
@property (nonatomic, assign) CGRect videoRect;
@property (nonatomic, assign) CGRect imgsRect;
@property (nonatomic, assign) CGRect audioRect;
@property (nonatomic, assign) CGRect viewpointRect;
@property (nonatomic, assign) CGRect statusRect;
@property (nonatomic, assign) CGRect viewCountRect;    //阅读量
@property (nonatomic, assign) CGRect handleRect;       //更多\评论\靠谱事件
@property (nonatomic, assign) CGRect separationRect;
@end

@implementation CTFAnswerDetailCellLayout
- (instancetype)initWithData:(AnswerModel *)data{
    self = [super init];
    if (self) {
        self.model = data;
        
        CGFloat min_x = 0;
        CGFloat min_y = 0;
        CGFloat min_w = 0;
        CGFloat min_h = 0;
        CGFloat min_view_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat gap = 10;
    
        self.userInfoRect = CGRectMake(min_x, min_y, min_view_w, 62);
        
        min_x = kMarginLeft;
        min_y = CGRectGetMaxY(self.userInfoRect);
        min_w = min_view_w - 2 * kMarginLeft;
        min_h = FeedVideoHeight;
        
        self.statusRect = CGRectZero;
        if ([data.type isEqualToString:@"video"]) {
            self.imgsRect = self.audioRect = CGRectZero;
            if (data.video.url && data.video.width > 0 && data.video.height > 0) {
                min_h = [AppMargin getAspectVideoHeightWithWidth:data.video.width height:data.video.height rotation:data.video.rotation];
            } else {
                min_h = 0;
            }
            self.videoRect = CGRectMake(min_x, min_y, min_w, min_h);
            min_y = CGRectGetMaxY(self.videoRect)+gap;
        }else if ([data.type isEqualToString:@"images"]){
            self.videoRect = self.audioRect = CGRectZero;
            if (data.images.count>0) {
                FeedImageSize imgsSize =  [AppMargin feedImageDimensions:data.images viewWidith:kScreen_Width-2*kMarginLeft];
                self.imgsRect = CGRectMake(min_x, min_y, imgsSize.imgContainerWidth, imgsSize.imgContainerHeight);
                min_y = CGRectGetMaxY(self.imgsRect)+gap;
            }else{
                self.imgsRect = CGRectMake(min_x, min_y, 0, 0);
                min_y = CGRectGetMaxY(self.imgsRect);
            }
        }else if ([data.type isEqualToString:@"audioImage"]){
            self.videoRect = self.imgsRect = CGRectZero;
            if (data.audioImage.count>0) {
                self.audioRect = CGRectMake(min_x, min_y, min_w, min_w*(4.0/3.5));
                min_y = CGRectGetMaxY(self.audioRect)+gap;
            }else{
                self.audioRect = CGRectMake(min_x, min_y, 0, 0);
                min_y = CGRectGetMaxY(self.audioRect);
            }
        }
        if (!kIsEmptyString(data.content)) {
            min_h = [data.content boundingRectWithSize:CGSizeMake(min_w, CGFLOAT_MAX) lineSpacing:4 textFont:[UIFont regularFontWithSize:16]].height;
            self.viewpointRect = CGRectMake(min_x, min_y, min_w, min_h);
            min_y = CGRectGetMaxY(self.viewpointRect) + gap;
            
            if (![data.status isEqualToString:@"normal"] && [data.type isEqualToString:@"images"] && data.images.count == 0) {
                self.statusRect = CGRectMake(min_x, min_y, 80, 18);
                min_y = CGRectGetMaxY(self.statusRect) + 5;
            }
        }else{
            self.viewpointRect = CGRectMake(min_x, min_y, min_w,0);
            min_y = CGRectGetMaxY(self.viewpointRect) + 5;
        }

        //阅读量
        NSString *viewTitle = [NSString stringWithFormat:@"%ld人阅读",data.viewCount];
        CGFloat viewCountW = [viewTitle boundingRectWithSize:CGSizeMake(min_w, 18) withTextFont:[UIFont regularFontWithSize:11]].width;
        self.viewCountRect = CGRectMake(min_x, min_y, viewCountW + 50, 26);
        
        min_y = CGRectGetMaxY(self.viewCountRect) + 5;
        self.handleRect = CGRectMake(0, min_y, min_view_w, 35);
        
        min_y = CGRectGetMaxY(self.handleRect) + 8;
        self.separationRect = CGRectMake(0, min_y, min_view_w, 8);
        min_y = CGRectGetMaxY(self.separationRect);
    
        if([data.type isEqualToString:@"video"] || [data.type isEqualToString:@"images"]|| [data.type isEqualToString:@"audioImage"]){
           self.height = CGRectGetMaxY(self.separationRect);
        }else{
           self.height = 0;
        }
    }
    return self;
}

+(NSArray<CTFAnswerDetailCellLayout*>*)converToLayout:(NSArray<AnswerModel*>*)list{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(AnswerModel *item in list){
        [arr addObject:[[CTFAnswerDetailCellLayout alloc] initWithData:item]];
    }
    return arr;
}
@end
