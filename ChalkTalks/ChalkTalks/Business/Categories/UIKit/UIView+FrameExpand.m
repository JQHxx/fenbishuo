//
//  UIView+FrameExpand.m
//  HiTao
//
//  Created by hitao on 16/3/8.
//  Copyright © 2016年 hitao. All rights reserved.
//

#import "UIView+FrameExpand.h"
#import "UIColor+DefColors.h"
#import "UIView+Frame.h"


@implementation UIView (FrameExpand)
- (UIView *)obtainBottomLine {
    
    return [self viewWithTag:0xff0b];
}

- (UIView *)obtainTopLine {
    
    return [self viewWithTag:0xff0a];
}

- (UIView *)obtainLeftLine {
    
    return [self viewWithTag:0xff0c];
}

- (UIView *)obtainRightLine {
    
    return [self viewWithTag:0xff0d];
}

- (void)addBottomLineWithStartX:(NSInteger)x withEnd:(bool)bEnd {
    
    @autoreleasepool {
        
        if([self viewWithTag:0xff0b]) {
            
        }
        else {
            
            NSInteger w = self.width - (bEnd ? 1 : 2) * x;
            
            __autoreleasing UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x, self.height - 0.55, w, 0.55)];
            v.backgroundColor = [UIColor ctSeparatorColor];//RGBACOLOR(0xdb, 0xda, 0xd5, 1)
            [self addSubview:v];
            v.tag = 0xff0b;
        }
    }
}

- (void)addTopLineWithStartX:(NSInteger)x withEnd:(bool)bEnd {
    
    @autoreleasepool {
        
        if([self viewWithTag:0xff0a]) {
            
        }
        else {
            
            NSInteger w = self.width - (bEnd ? 1 : 2) * x;
            
            __autoreleasing UIView *v = [[UIView alloc] initWithFrame:CGRectMake(x, 0, w, 0.55)];
            v.backgroundColor = [UIColor ctSeparatorColor];//RGBACOLOR(0xdb, 0xda, 0xd5, 1)
            [self addSubview:v];
            v.tag = 0xff0a;
        }
    }
}

- (void)addLeftLineWithStartY:(NSInteger)y withEnd:(bool)bEnd {
    
    @autoreleasepool {
        
        if([self viewWithTag:0xff0c]) {
            
        }
        else {
            
            NSInteger h = self.height - (bEnd ? 1 : 2) * y;
            
            __autoreleasing UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, y, 0.55, h)];
            v.backgroundColor = [UIColor ctSeparatorColor];//RGBACOLOR(0xdb, 0xda, 0xd5, 1)
            [self addSubview:v];
            v.tag = 0xff0c;
        }
    }
}

- (void)addRightLineWithStartY:(NSInteger)y withEnd:(bool)bEnd {
    
    @autoreleasepool {
        
        if([self viewWithTag:0xff0d]) {
            
        }
        else {
            
            NSInteger h = self.height - (bEnd ? 1 : 2) * y;
            
            __autoreleasing UIView *v = [[UIView alloc] initWithFrame:CGRectMake(self.width - 0.55, y, 0.55, h)];
            v.backgroundColor = [UIColor ctSeparatorColor];//RGBACOLOR(0xdb, 0xda, 0xd5, 1)
            [self addSubview:v];
            v.tag = 0xff0d;
        }
    }
}

@end
