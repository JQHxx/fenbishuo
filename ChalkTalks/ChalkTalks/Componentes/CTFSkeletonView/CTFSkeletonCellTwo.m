//
//  CTFSkeletonCellTwo.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/1/19.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFSkeletonCellTwo.h"

@interface CTFSkeletonCellTwo ()

@end

@implementation CTFSkeletonCellTwo

+ (CGFloat)defaultHeight {
    return 114;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupViewContent];
    }
    return self;
}

- (void)setupViewContent {
    
    UIView *view1 = [[UIView alloc] init];
    view1.frame = CGRectMake(16,20,164,14);
    [self.contentView addSubview:view1];
    [view1 ctf_skeletonable:YES];
    
    UIView *view2 = [[UIView alloc] init];
    view2.frame = CGRectMake(16,50,107,14);
    [self.contentView addSubview:view2];
    [view2 ctf_skeletonable:YES];
    
    UIView *view3 = [[UIView alloc] init];
    view3.frame = CGRectMake(16,80,kScreen_Width-16-16,14);
    [self.contentView addSubview:view3];
    [view3 ctf_skeletonable:YES];
}

@end
