//
//  CTFFeedImageCellLayout.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/28.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFFeedCellLayout.h"
#import "NSString+Size.h"

@interface CTFFeedCellLayout()
@property (nonatomic, assign) CGRect titleRect;
@property (nonatomic, assign) CGRect authorRect;     //发布者
@property (nonatomic, assign) CGRect videoRect;
@property (nonatomic, assign) CGRect imgsRect;
@property (nonatomic, assign) CGRect audioRect;
@property (nonatomic, assign) CGRect descRect;
@property (nonatomic, assign) CGRect infoRect;    //回答发布者
@property (nonatomic, assign) CGRect handleRect;
@property (nonatomic, assign) CGRect separationRect;
@property (nonatomic, assign) CGFloat height;
@end

@implementation CTFFeedCellLayout
- (instancetype)initWithData:(AnswerModel *)data{
    self = [super init];
    if (self) {
        self.model = data;
        
        CGFloat min_x = kMarginLeft;
        CGFloat min_y = kMarginTop;
        CGFloat min_w = kScreen_Width-2*kMarginLeft;
        CGFloat min_h = 0;
        CGFloat min_view_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat gap = 10;
        
        //标题
        CGFloat titleHeight = [data.question.title boundingRectWithSize:CGSizeMake(kScreen_Width-2*kMarginLeft, CGFLOAT_MAX) withTextFont:[UIFont mediumFontWithSize:18]].height;
        self.titleRect = CGRectMake(min_x, min_y, min_w, titleHeight);
        min_y = CGRectGetMaxY(self.titleRect)+4;
        //发布者
        self.authorRect = CGRectMake(0, min_y, min_view_w, 20);
        
        min_y = CGRectGetMaxY(self.authorRect);
        if([data.type isEqualToString:@"video"]){
            self.imgsRect = self.audioRect = CGRectZero;
            CGFloat videoHeight = 0.0;
            if(data.video.url && data.video.width > 0 && data.video.height > 0){
                videoHeight = [AppMargin getAspectVideoHeightWithWidth:data.video.width height:data.video.height rotation:data.video.rotation];
            }
            self.videoRect = CGRectMake(min_x, min_y+8, min_w, videoHeight);
            min_y = CGRectGetMaxY(self.videoRect);
        }else if([data.type isEqualToString:@"images"]){
            self.videoRect = self.audioRect = CGRectZero;
            if (data.images.count>0) {
                FeedImageSize imgsSize =  [AppMargin feedImageDimensions:data.images viewWidith:kScreen_Width-2*kMarginLeft];
                self.imgsRect = CGRectMake(min_x, min_y+8, imgsSize.imgContainerWidth, imgsSize.imgContainerHeight);
            }else{
                self.imgsRect = CGRectMake(min_x, min_y, 0, 0);
            }
            min_y = CGRectGetMaxY(self.imgsRect);
        }else if ([data.type isEqualToString:@"audioImage"]){
            self.videoRect = self.imgsRect = CGRectZero;
            if (data.audioImage.count>0) {
                self.audioRect = CGRectMake(min_x, min_y+8, min_w, min_w*(4.0/3.5));
            }else{
                self.audioRect = CGRectMake(min_x, min_y, 0, 0);
            }
            min_y = CGRectGetMaxY(self.audioRect);
        }
        
        if(!kIsEmptyString(data.content)){
            min_y += gap;
            CGSize contentSize = [data.content ctTextSizeWithFont:[UIFont regularFontWithSize:14] numberOfLines:2 constrainedWidth:min_w];
            self.descRect = CGRectMake(min_x, min_y, contentSize.width, contentSize.height);
        }else{
            self.descRect = CGRectMake(min_x, min_y, 0, 0);
        }
        min_y = CGRectGetMaxY(self.descRect);
        self.infoRect = CGRectMake(min_x, min_y+8,min_view_w-2*kMarginLeft, 26);
        self.handleRect = CGRectMake(0,CGRectGetMaxY(self.infoRect)+6,min_view_w, 35);
        
        min_y = CGRectGetMaxY(self.handleRect)+gap;
        //线条
        self.separationRect = CGRectMake(0, min_y, min_view_w, 10);
        
        if([data.type isEqualToString:@"video"] || [data.type isEqualToString:@"images"]|| [data.type isEqualToString:@"audioImage"]){
            self.height = CGRectGetMaxY(self.separationRect);
        }else{
            self.height = 0;
        }
    }
    return self;
}

+(NSArray<CTFFeedCellLayout*>*)converToLayout:(NSArray<AnswerModel*>*)list{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(AnswerModel *item in list){
        [arr addObject:[[CTFFeedCellLayout alloc] initWithData:item]];
    }
    return arr;
}
@end
