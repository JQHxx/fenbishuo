//
//  CTFInvitedUserDisplayCell.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/2/27.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFInvitedUserDisplayCell.h"
#import <SDWebImage.h>

@interface CTFUserHeaderNameItem : UICollectionViewCell
@property (nonatomic, strong) UIImageView *headerImage;//图片
@property (nonatomic, strong) UILabel *nameLabel;//名称
@end

@implementation CTFUserHeaderNameItem

- (void)fillDataByName:(NSString *)name image:(NSString *)imageUrl {
    self.nameLabel.text = name;
    [self.headerImage sd_setImageWithURL:[NSURL URLWithString:imageUrl]
                        placeholderImage:[UIImage imageNamed:@"placeholder_head_78x78"]];
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:10];
        _nameLabel.textColor = UIColorFromHEX(0x999999);
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_nameLabel];
        [_nameLabel sizeToFit];
        [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(80, 14));
            make.bottom.equalTo(self.mas_bottom).offset(-12);
        }];
    }
    return _nameLabel;
}

- (UIImageView *)headerImage {
    if (_headerImage == nil) {
        _headerImage = [[UIImageView alloc]init];
        _headerImage.layer.cornerRadius = 20;
        _headerImage.layer.masksToBounds = YES;
        [self.contentView addSubview:_headerImage];
        [_headerImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(0);
            make.centerX.mas_equalTo(self.contentView.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(40, 40));
            make.bottom.equalTo(self.nameLabel.mas_top).offset(-4);
        }];
    }
    return _headerImage;
}
@end

@interface CTFInvitedUserDisplayCell () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UICollectionView *userListCollectionView;
@property (nonatomic, copy) NSArray *invitedUserList;
@end

@implementation CTFInvitedUserDisplayCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = UIColorFromHEX(0xFFFFFF);
        [self setupViewContent];
    }
    return self;
}

- (void)fillContentWithData:(NSArray *)userList {
    self.invitedUserList = userList;
    if (userList.count > 0) {
        self.titleLabel.hidden = NO;
        self.titleLabel.text = @"已邀请以下用户回答你的问题";
    }
    [self.userListCollectionView reloadData];
}

- (void)setupViewContent {
    UIView *titleBgView = [[UIView alloc] init];
    titleBgView.backgroundColor = UIColorFromHEX(0xF8F8F8);
    [self.contentView addSubview:titleBgView];
    [titleBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left);
        make.right.mas_equalTo(self.contentView.mas_right);
        make.top.mas_equalTo(self.contentView.mas_top);
        make.height.mas_equalTo(42);
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [titleBgView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(titleBgView.mas_left).offset(16);
        make.right.mas_equalTo(titleBgView.mas_right);
        make.top.mas_equalTo(titleBgView.mas_top).offset(0);
        make.height.mas_equalTo(32);
    }];
    self.titleLabel.hidden = YES;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 5;
    
    self.userListCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
    self.userListCollectionView.backgroundColor = UIColorFromHEX(0xFFFFFF);
    self.userListCollectionView.scrollsToTop = NO;
    self.userListCollectionView.delegate = self;
    self.userListCollectionView.dataSource = self;
    self.userListCollectionView.showsHorizontalScrollIndicator = NO;
    self.userListCollectionView.showsVerticalScrollIndicator = NO;
    [self.userListCollectionView registerClass:[CTFUserHeaderNameItem class] forCellWithReuseIdentifier:@"CTFUserHeaderNameItem"];
    [self.contentView addSubview:self.userListCollectionView];
    [self.userListCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_left).offset(19);
        make.right.mas_equalTo(self.contentView.mas_right).offset(-19);
        make.top.mas_equalTo(titleBgView.mas_bottom).offset(15);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.invitedUserList.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 70);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UserModel *userModel = [self.invitedUserList objectAtIndex:indexPath.row];
    
    CTFUserHeaderNameItem *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CTFUserHeaderNameItem" forIndexPath:indexPath];
    [cell fillDataByName:userModel.name image:userModel.avatarUrl];
    return cell;
}

@end
