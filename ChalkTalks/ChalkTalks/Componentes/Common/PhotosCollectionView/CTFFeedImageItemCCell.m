//
//  CTFFeedImageItemCCell.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/10.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFFeedImageItemCCell.h"
#import "CTFStatusErrorView.h"

@interface CTFFeedImageItemCCell (){
    UIImageView         *imageView;
    CTFStatusErrorView  *statusView;
}

@end

@implementation CTFFeedImageItemCCell


+(NSString*)identifier{
    return NSStringFromClass(self);
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
        [self setupUILayout];
    }
    return self;
}

#pragma mark 填充数据
-(void)fillCellContent:(ImageItemModel*)model w400:(BOOL)isW400 status:(NSString *)status{
    if (model.isLocal) {
        imageView.image = model.image;
    } else {
        NSString *imageUrl = isW400 ? [AppUtils imgUrlForGridSingle:model.url] : [AppUtils imgUrlForGrid:model.url];
        if ([status isEqualToString:@"normal"]) {
            statusView.hidden = YES;
            imageView.hidden = NO;
            [imageView ct_setImageWithURL:[NSURL safe_URLWithString:imageUrl] placeholderImage:[UIImage ctPlaceholderImage] animated:YES];
        } else {
            statusView.hidden = NO;
            imageView.hidden = YES;
            [statusView fillErrorViewWithCoverImage:imageUrl status:status];
        }
    }
}

#pragma mark 界面初始化
-(void)setupUI{
    imageView = [[UIImageView alloc] init];
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = kCornerRadius;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.backgroundColor = [UIColor ctColorEE];
    [self addSubview:imageView];
    
    statusView = [[CTFStatusErrorView alloc] init];
    [self addSubview:statusView];
    statusView.hidden = YES;
}

-(void)setupUILayout{
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}
@end
