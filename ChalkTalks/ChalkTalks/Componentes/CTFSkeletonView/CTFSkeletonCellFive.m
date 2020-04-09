//
//  CTFSkeletonCellFive.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/1/19.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFSkeletonCellFive.h"

@interface CTFSkeletonCellFive ()

@end


@implementation CTFSkeletonCellFive

+ (CGFloat)defaultHeight {
    return 308;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViewContent];
    }
    return self;
}

- (void)setupViewContent {
    
    UIView *view1 = [[UIView alloc] init];
    view1.frame = CGRectMake(16,30,kScreen_Width-16-16,14);
    [self.contentView addSubview:view1];
    [view1 ctf_skeletonable:YES];

    UIView *view2 = [[UIView alloc] init];
    view2.frame = CGRectMake(16,70,158,14);
    [self.contentView addSubview:view2];
    [view2 ctf_skeletonable:YES];
    
    UIView *view3 = [[UIView alloc] init];
    view3.frame = CGRectMake(16,100,280,14);
    [self.contentView addSubview:view3];
    [view3 ctf_skeletonable:YES];
    
    UIView *view4 = [[UIView alloc] init];
    view4.frame = CGRectMake(16,130,112,14);
    [self.contentView addSubview:view4];
    [view4 ctf_skeletonable:YES];

    UIView *view5 = [[UIView alloc] init];
    view5.frame = CGRectMake(16,160,kScreen_Width-16-16,166);
    [self.contentView addSubview:view5];
    [view5 ctf_skeletonable:YES];
}

@end
