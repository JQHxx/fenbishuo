//
//  CTFMyAnswerCellLayout.m
//  ChalkTalks
//
//  Created by vision on 2020/1/7.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFMyAnswerCellLayout.h"
#import "NSString+Size.h"

@interface CTFMyAnswerCellLayout ()

@property (nonatomic, assign) CGRect myTitleRect;
@property (nonatomic, assign) CGRect titleRect;
@property (nonatomic, assign) CGRect authorRect;
@property (nonatomic, assign) CGRect videoRect;
@property (nonatomic, assign) CGRect imgsRect;
@property (nonatomic, assign) CGRect audioRect;
@property (nonatomic, assign) CGRect descRect;
@property (nonatomic, assign) CGRect statusRect;
@property (nonatomic, assign) CGRect answerInfoRect;
@property (nonatomic, assign) CGRect eventRect;
@property (nonatomic, assign) CGRect separationRect;
@property (nonatomic, assign) CGFloat height;


@end

@implementation CTFMyAnswerCellLayout

-(instancetype)initWithData:(AnswerModel *)data{
    self = [super init];
    if (self) {
        self.model = data;
        
        CGFloat min_x = kMarginLeft;
        CGFloat min_y = kMarginTop;
        CGFloat min_w = kScreen_Width-2*kMarginLeft;
        CGFloat min_view_w = kScreen_Width;
        
        self.myTitleRect = CGRectMake(min_x, min_y, min_w, 20);
        if (data.hideTitle) {
            self.titleRect = self.authorRect = CGRectZero;
            min_y = CGRectGetMaxY(self.myTitleRect) + 6;
        }else{
            min_y = CGRectGetMaxY(self.myTitleRect);
            CGFloat titleHeight = [data.question.title boundingRectWithSize:CGSizeMake(kScreen_Width-2*kMarginLeft, CGFLOAT_MAX) withTextFont:[UIFont mediumFontWithSize:16]].height;
            self.titleRect = CGRectMake(min_x, min_y + 6, min_w, titleHeight);
            self.authorRect = CGRectMake(0, CGRectGetMaxY(self.titleRect), min_view_w, 32);
            min_y = CGRectGetMaxY(self.authorRect);
        }
        
        if([data.type isEqualToString:@"video"]){
            self.imgsRect = self.audioRect = CGRectZero;
            CGFloat videoH = 0.0;
            if (!kIsEmptyString(data.video.url) && data.video.width > 0 && data.video.height > 0) {
                videoH = [AppMargin getAspectVideoHeightWithWidth:data.video.width height:data.video.height rotation:data.video.rotation];
            }
            self.videoRect = CGRectMake(min_x, min_y, min_w, videoH);
            min_y = CGRectGetMaxY(self.videoRect);
        }else  if([data.type isEqualToString:@"images"]){
            self.videoRect = self.audioRect =  CGRectZero;
            if (data.images.count>0) {
                FeedImageSize imgsSize =  [AppMargin feedImageDimensions:data.images viewWidith:kScreen_Width-2*kMarginLeft];
                self.imgsRect = CGRectMake(min_x, min_y, imgsSize.imgContainerWidth, imgsSize.imgContainerHeight);
            }else{
                self.imgsRect = CGRectMake(min_x, min_y, 0, 0);
            }
            min_y = CGRectGetMaxY(self.imgsRect);
        }else if ([data.type isEqualToString:@"audioImage"]){
            self.videoRect = self.imgsRect = CGRectZero;
            if (data.audioImage.count>0) {
                self.audioRect = CGRectMake(min_x, min_y, min_w, min_w*(4.0/3.5));
            }else{
                self.audioRect = CGRectMake(min_x, min_y, 0, 0);
            }
            min_y = CGRectGetMaxY(self.audioRect);
        }
        
        self.statusRect = CGRectZero;
        if(!kIsEmptyString(data.content)){
            CGFloat descH = [data.content ctTextSizeWithFont:[UIFont regularFontWithSize:13] numberOfLines:2 lineSpacing:4 constrainedWidth:min_w].height;
            self.descRect = CGRectMake(min_x, min_y+4, min_w, descH);
            min_y = CGRectGetMaxY(self.descRect) + 9;
            if (![data.status isEqualToString:@"normal"] && [data.type isEqualToString:@"images"] && data.images.count == 0) {
                self.statusRect = CGRectMake(min_x, min_y - 4, 80, 18);
                min_y = CGRectGetMaxY(self.statusRect) + 5;
            }
        }else{
            self.descRect = CGRectMake(min_x, min_y, 0, 0);
            min_y = CGRectGetMaxY(self.descRect) + 9;
        }

        self.answerInfoRect = CGRectMake(min_x, min_y, min_view_w-2*kMarginLeft, 26);
    
        min_y = CGRectGetMaxY(self.answerInfoRect);
        self.eventRect = CGRectMake(0, min_y, min_view_w, 45);

        min_y = CGRectGetMaxY(self.eventRect)+10;
        
       //线条
        CGFloat lineH;
        if (data.hideTitle) {
           lineH = 2.0;
        }else{
           lineH = 4.0;
        }
        self.separationRect = CGRectMake(0, min_y, min_view_w, lineH);
       
        if([data.type isEqualToString:@"video"] || [data.type isEqualToString:@"images"]|| [data.type isEqualToString:@"audioImage"]){
           self.height = CGRectGetMaxY(self.separationRect);
        }else{
           self.height = 0;
        }
        
    }
    return self;
}


+(NSArray<CTFMyAnswerCellLayout*>*)converToLayout:(NSArray<AnswerModel*>*)list{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for(AnswerModel *item in list){
        [arr addObject:[[CTFMyAnswerCellLayout alloc] initWithData:item]];
    }
    return arr;
}

@end
