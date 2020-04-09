//
//  CTFBasePublishView.m
//  ChalkTalks
//
//  Created by vision on 2020/2/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFBasePublishView.h"

@implementation CTFBasePublishView

- (instancetype)initWithFrame:(CGRect)frame desc:(NSString *)desc image:(NSString *)image{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setBorderWithCornerRadius:15 type:UIViewCornerTypeAll];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width-92)/2.0,22, 92, 33)];
        imgView.image = ImageNamed(image);
        [self addSubview:imgView];
        
        UILabel *descLab = [[UILabel alloc] initWithFrame:CGRectMake(10,imgView.bottom+15, frame.size.width-20, 40)];
        descLab.font = [UIFont regularFontWithSize:13.0f];
        descLab.numberOfLines = 0;
        descLab.textAlignment = NSTextAlignmentCenter;
        descLab.textColor = UIColorFromHEX(0x9B9B9B);
        descLab.text = desc;
        [self addSubview:descLab];
    }
    return self;
}

@end
