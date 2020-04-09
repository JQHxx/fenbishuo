//
//  CTFSectorProgressView.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/9.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFSectorProgressView.h"

@interface CTFSectorProgressView ()
@property (nonatomic, strong) UIView *centerView;
@end

@implementation CTFSectorProgressView

- (void)drawRect:(CGRect)rect {
    
    self.backgroundColor = UIColorFromHEX(0x15E3BA);
    
    //定义扇形中心
    CGPoint origin = CGPointMake(31, 31);
    //定义扇形半径
    CGFloat radius = 31;
    //设定扇形起点位置
    CGFloat startAngle = M_PI_2 * 3;
    //根据进度计算扇形结束位置
    CGFloat endAngle = startAngle - self.progress * M_PI * 2;
    
    //根据起始点、原点、半径绘制弧线
    UIBezierPath *sectorPath = [UIBezierPath bezierPathWithArcCenter:origin radius:radius startAngle:startAngle endAngle:endAngle clockwise:YES];
    //从弧线结束为止绘制一条线段到圆心。这样系统会自动闭合图形，绘制一条从圆心到弧线起点的线段。
    [sectorPath addLineToPoint:origin];
    //设置扇形的填充颜色
    [[UIColor whiteColor] set];
    //设置扇形的填充模式
    [sectorPath fill];
    
    self.centerView.hidden = NO;
    
    self.progressLabel.hidden = NO;
}

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    self.progressLabel.text = [NSString stringWithFormat:@"%0.0f%%", progress * 100];
    [self setNeedsDisplay];
}

- (UILabel *)progressLabel {
    if (!_progressLabel) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.font = [UIFont systemFontOfSize:16];
        _progressLabel.textColor = UIColorFromHEX(0x15E3BA);
        _progressLabel.frame = CGRectMake(0, 20, 58, 20);
        _progressLabel.textAlignment = NSTextAlignmentCenter;
        [self.centerView addSubview:_progressLabel];
    }
    return _progressLabel;
}

- (UIView *)centerView {
    if (!_centerView) {
        _centerView = [[UIView alloc] init];
        _centerView.backgroundColor = [UIColor blackColor];
        _centerView.frame = CGRectMake(2, 2, 58, 58);
        _centerView.layer.cornerRadius = 29;
        [self addSubview:_centerView];
    }
    return _centerView;
}

- (CGSize)intrinsicContentSize {
    CGFloat contentViewH = 62;
    CGFloat contentViewW = 62;
    return CGSizeMake(contentViewW, contentViewH);
}


- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        self.layer.cornerRadius = 31;
        self.layer.masksToBounds = YES;
    }
    return self;
}

@end
