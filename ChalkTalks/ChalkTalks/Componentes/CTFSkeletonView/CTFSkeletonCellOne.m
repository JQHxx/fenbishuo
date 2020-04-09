//
//  CTFSkeletonCellOne.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/1/19.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFSkeletonCellOne.h"

@interface CTFSkeletonCellOne ()

@end

@implementation CTFSkeletonCellOne

+ (CGFloat)defaultHeight {
    return 74;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViewContent];
    }
    return self;
}

- (void)setupViewContent {
    
    UIView *view1 = [[UIView alloc] init];
    view1.frame = CGRectMake(16,20,34,34);
    view1.layer.cornerRadius = 17;
    view1.layer.masksToBounds = YES;
    [self.contentView addSubview:view1];
    [view1 ctf_skeletonable:YES];
    
    UIView *view2 = [[UIView alloc] init];
    view2.frame = CGRectMake(63,20,92,12);
    [self.contentView addSubview:view2];
    [view2 ctf_skeletonable:YES];
    
    UIView *view3 = [[UIView alloc] init];
    view3.frame = CGRectMake(63,39,kScreen_Width-63-16,12);
    [self.contentView addSubview:view3];
    [view3 ctf_skeletonable:YES];
}

@end
