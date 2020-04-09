//
//  CTFVideoPickImageCCell.m
//  ChalkTalks
//
//  Created by zingwin on 2020/1/9.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFVideoPickImageCCell.h"

@implementation CTFVideoPickImageCCell
{
    UIImageView *imageView;
    UIView *maskView;
}

+(NSString*)identifier{
    return NSStringFromClass(self);
}

+(CGSize)itemSize{
    return CGSizeMake(kResetDimension(59), kResetDimension(92));
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        [self setupUI];
        [self setupUILayout];
    }
    return self;
}

-(void)fillContentView:(CTFVideoImageModel*)data{
    imageView.image = data.cropImage;
    maskView.hidden = data.isSelected;
}

#pragma mark - UI
-(void)setupUI{
    imageView = [[UIImageView alloc] init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self addSubview:imageView];
    
    maskView = [[UIView alloc] init];
    maskView.backgroundColor = UIColorFromHEXWithAlpha(0xFFFFFF, 0.5);
    [self addSubview:maskView];
}

-(void)setupUILayout{
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}
@end
