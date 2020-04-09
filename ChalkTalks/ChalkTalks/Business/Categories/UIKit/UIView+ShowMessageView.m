//
//  UIView+ShowMessageView.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2019/12/5.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "UIView+ShowMessageView.h"
#import "UIView+Frame.h"
#import <Masonry.h>
#import "CTFBlockButton.h"
#import <ReactiveObjC.h>

@interface UIView ()

@end

@implementation UIView (ShowMessageView)

- (void)ctfEmptyViewWhetherShow:(BOOL)showEmpty imageName:(NSString *)imageName message:(nullable NSString *)message clickString:(nullable NSString *)clickString clickBlock:(nullable void(^)(void))block whetherNavigationBar:(BOOL)whetherNavigationBar topOffset:(NSInteger)topOffset {
    
    if (!showEmpty) {
        if ([self isKindOfClass:UITableView.class]) {
            UITableView *tableView = (UITableView *)self;
            tableView.backgroundView = nil;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }else if ([self isKindOfClass:UICollectionView.class]) {
            UICollectionView *collectionView = (UICollectionView *)self;
            collectionView.backgroundView = nil;
        }else {
            [self.subviews.firstObject removeFromSuperview];
        }
        return ;
    }
    
    NSInteger y = 0;
    if (whetherNavigationBar) {
        y = kNavBar_Height;
    } else {
        y = 0;
    }
    UIView *showMessageView = [[UIView alloc]initWithFrame:CGRectMake(0, y, self.bounds.size.width, self.bounds.size.height)];
    showMessageView.backgroundColor = [UIColor whiteColor];
    
    //添加图片
    UIImageView *notFoundImageView = [[UIImageView alloc]init];
    notFoundImageView.image = [UIImage imageNamed:imageName];
    [showMessageView addSubview:notFoundImageView];
    [notFoundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(showMessageView.mas_top).offset(topOffset);
        make.left.mas_equalTo(showMessageView.left);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 260*kScreen_Width/375.0));
    }];
    
    //添加文字说明
    UILabel *messageLabel = nil;
    if (message) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.text = message;
        messageLabel.numberOfLines = 0;
        messageLabel.font = [UIFont systemFontOfSize:15];
        [messageLabel setTextColor:UIColorFromHEX(0x999999)];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [showMessageView addSubview:messageLabel];
        [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(notFoundImageView.mas_bottom).offset(23);
            make.left.mas_equalTo(showMessageView);
            make.width.mas_equalTo(kScreen_Width);
        }];
    }
    
    //添加按钮
    if (clickString && block) {
        UIView *bottomView = [[UIView alloc] init];
        bottomView.backgroundColor = [UIColor clearColor];
        [showMessageView addSubview:bottomView];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(messageLabel.mas_bottom).offset(28).priority(1000);
            make.top.mas_equalTo(notFoundImageView.bottom).offset(28).priority(200);
            make.centerX.equalTo(showMessageView);
            make.size.mas_equalTo(CGSizeMake(100, 35));
        }];

        CTFBlockButton *clickBtn = [CTFBlockButton buttonWithType:UIButtonTypeCustom];
        [clickBtn setBackgroundImage:[UIImage imageNamed:@"tuoyuan_blue"] forState:UIControlStateNormal];
        [clickBtn setTitle:[NSString stringWithFormat:@"    %@    ", clickString] forState:UIControlStateNormal];
        [clickBtn setTitleColor:UIColorFromHEX(0x15E3BA) forState:UIControlStateNormal];
        [clickBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        clickBtn.layer.borderColor = UIColorFromHEX(0x15E3BA).CGColor;
        clickBtn.layer.borderWidth = 1;
        clickBtn.layer.cornerRadius = 15;
        [bottomView addSubview:clickBtn];
        [clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bottomView);
            make.centerX.equalTo(bottomView);
        }];
        @weakify(self)
        [clickBtn addTouchUpInsideBlock:^(UIButton *button) {
            @strongify(self)
            if ([self isKindOfClass:UITableView.class]) {
                UITableView *tableView = (UITableView *)self;
                tableView.backgroundView = nil;
                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            }else if ([self isKindOfClass:UICollectionView.class]) {
                UICollectionView *collectionView = (UICollectionView *)self;
                collectionView.backgroundView = nil;
            }else {
                [showMessageView removeFromSuperview];
            }
            block();
        }];
    }
    
    if ([self isKindOfClass:UITableView.class]) {
        UITableView *tableView = (UITableView *)self;
        tableView.backgroundView = showMessageView;
    }else if ([self isKindOfClass:UICollectionView.class]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        collectionView.backgroundView = showMessageView;
    }else {
        [self addSubview:showMessageView];
    }
}

- (void)ctfEmptyViewWhetherShow:(BOOL)showEmpty imageName:(NSString *)imageName message:(nullable NSString *)message clickString:(nullable NSString *)clickString clickBlock:(nullable void(^)(void))block topOffset:(NSInteger)topOffset {
    
    if (!showEmpty) {
        if ([self isKindOfClass:UITableView.class]) {
            UITableView *tableView = (UITableView *)self;
            tableView.backgroundView = nil;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        }else if ([self isKindOfClass:UICollectionView.class]) {
            UICollectionView *collectionView = (UICollectionView *)self;
            collectionView.backgroundView = nil;
        }else {
            [self.subviews.firstObject removeFromSuperview];
        }
        return ;
    }
    
    UIView *showMessageView = [[UIView alloc]initWithFrame:self.bounds];
    showMessageView.backgroundColor = [UIColor whiteColor];
    
    //添加图片
    UIImageView *notFoundImageView = [[UIImageView alloc]init];
    notFoundImageView.image = [UIImage imageNamed:imageName];
    [showMessageView addSubview:notFoundImageView];
    [notFoundImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(showMessageView.mas_top).offset(topOffset);
        make.left.mas_equalTo(showMessageView.left);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 260*kScreen_Width/375.0));
    }];
    
    //添加文字说明
    UILabel *messageLabel = nil;
    if (message) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.text = message;
        messageLabel.numberOfLines = 0;
        messageLabel.font = [UIFont systemFontOfSize:15];
        [messageLabel setTextColor:UIColorFromHEX(0x999999)];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [showMessageView addSubview:messageLabel];
        [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(notFoundImageView.mas_bottom).offset(23);
            make.left.mas_equalTo(showMessageView);
            make.width.mas_equalTo(kScreen_Width);
        }];
    }
    
    //添加按钮
    if (clickString && block) {
        UIView *bottomView = [[UIView alloc] init];
        bottomView.backgroundColor = [UIColor clearColor];
        [showMessageView addSubview:bottomView];
        [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(messageLabel.mas_bottom).offset(28).priority(1000);
            make.top.mas_equalTo(notFoundImageView.bottom).offset(28).priority(200);
            make.centerX.equalTo(showMessageView);
            make.size.mas_equalTo(CGSizeMake(100, 35));
        }];

        CTFBlockButton *clickBtn = [CTFBlockButton buttonWithType:UIButtonTypeCustom];
        [clickBtn setBackgroundImage:[UIImage imageNamed:@"tuoyuan_blue"] forState:UIControlStateNormal];
        [clickBtn setTitle:[NSString stringWithFormat:@"    %@    ", clickString] forState:UIControlStateNormal];
        [clickBtn setTitleColor:UIColorFromHEX(0x15E3BA) forState:UIControlStateNormal];
        [clickBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        clickBtn.layer.borderColor = UIColorFromHEX(0x15E3BA).CGColor;
        clickBtn.layer.borderWidth = 1;
        clickBtn.layer.cornerRadius = 15;
        [bottomView addSubview:clickBtn];
        [clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(bottomView);
            make.centerX.equalTo(bottomView);
        }];
        @weakify(self)
        [clickBtn addTouchUpInsideBlock:^(UIButton *button) {
            @strongify(self)
            if ([self isKindOfClass:UITableView.class]) {
                UITableView *tableView = (UITableView *)self;
                tableView.backgroundView = nil;
                tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            }else if ([self isKindOfClass:UICollectionView.class]) {
                UICollectionView *collectionView = (UICollectionView *)self;
                collectionView.backgroundView = nil;
            }else {
                [showMessageView removeFromSuperview];
            }
            block();
        }];
    }
    
    if ([self isKindOfClass:UITableView.class]) {
        UITableView *tableView = (UITableView *)self;
        tableView.backgroundView = showMessageView;
    }else if ([self isKindOfClass:UICollectionView.class]) {
        UICollectionView *collectionView = (UICollectionView *)self;
        collectionView.backgroundView = showMessageView;
    }else {
        [self addSubview:showMessageView];
    }
}

+ (void)ctfEmptyViewWithNetLossToView:(UIView *)callerView topOffset:(NSInteger)topOffset{
    [callerView ctfEmptyViewWhetherShow:YES imageName:@"empty_NoNetwork_154x154" message:@"网络出了一点小意外~" clickString:@"刷新试试" clickBlock:^{
        
    } topOffset:topOffset];
}

@end
