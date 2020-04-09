//
//  CTFSkeletonCellThree.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/1/19.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFSkeletonCellThree.h"

@interface CTFSkeletonCellThree ()

@end

@implementation CTFSkeletonCellThree

+ (CGFloat)defaultHeight {
    return 176;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViewContent];
    }
    return self;
}

- (void)setupViewContent {
    
    UIView *view1 = [[UIView alloc] init];
    view1.frame = CGRectMake(16,30,34,34);
    view1.layer.cornerRadius = 17;
    view1.layer.masksToBounds = YES;
    [self.contentView addSubview:view1];
    [view1 ctf_skeletonable:YES];
    
    UIView *view2 = [[UIView alloc] init];
    view2.frame = CGRectMake(63,30,50,12);
    [self.contentView addSubview:view2];
    [view2 ctf_skeletonable:YES];
    
    UIView *view3 = [[UIView alloc] init];
    view3.frame = CGRectMake(63,49,149,12);
    [self.contentView addSubview:view3];
    [view3 ctf_skeletonable:YES];
    
    UIView *view4 = [[UIView alloc] init];
    view4.frame = CGRectMake(16,84,kScreen_Width-16-16,14);
    [self.contentView addSubview:view4];
    [view4 ctf_skeletonable:YES];
    
    UIView *view5 = [[UIView alloc] init];
    view5.frame = CGRectMake(16,114,183,14);
    [self.contentView addSubview:view5];
    [view5 ctf_skeletonable:YES];
    
    UIView *view6 = [[UIView alloc] init];
    view6.frame = CGRectMake(16,144,238,14);
    [self.contentView addSubview:view6];
    [view6 ctf_skeletonable:YES];
}

@end
