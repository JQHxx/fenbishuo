//
//  CTFAnswerDetailUserInfoView.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/23.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFAnswerDetailUserInfoView.h"
#import "NSDictionary+Safety.h"
#import "CTFCommonManager.h"

@interface CTFAnswerDetailUserInfoView (){
    UIImageView   *avaterImageView;
    UILabel       *nickLabel;
    UILabel       *signerLabel;
    UILabel       *timeLabel;
    UIButton      *followButton;
    AnswerModel   *curModel;
    NSIndexPath   *curIndexPath;
}

@end

@implementation CTFAnswerDetailUserInfoView


-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        [self setupUILayout];
    }
    return self;
}

-(void)fillContentWithData:(AnswerModel*)model indexPath:(NSIndexPath*)indexPath{
    curModel = model;
    curIndexPath = indexPath;
    
    [avaterImageView ct_setImageWithURL:[NSURL safe_URLWithString:model.author.avatarUrl] placeholderImage:[UIImage ctUserPlaceholderImage] animated:YES];
    nickLabel.text = model.author.name;
    signerLabel.text = kIsEmptyString(model.author.headline)?@"还没有签名":model.author.headline;
   
    followButton.enabled = !model.author.isFollowing;
    if (model.author.isFollowing||model.isAuthor) {
        followButton.hidden = YES;
    }else{
        followButton.hidden = NO;
        followButton.layer.borderColor = [UIColor ctColor66].CGColor;
        followButton.layer.borderWidth = 1.0;
    }
    
    timeLabel.text = [CTDateUtils formatTimeAgoWithTimestamp:model.createdAt];
}

#pragma mark - Actoin
-(void)followTap:(id)sender{
    if(curModel.author.isFollowing) return;
    if (![self.findViewController ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic safe_setObject:curIndexPath forKey:kCellIndexPathKey];
    [dic safe_setObject:curModel forKey:kViewpointDataModelKey];
    [self routerEventWithName:kFollowUserEvent userInfo:dic];
}

#pragma mark 个人主页
-(void)userInfoPressed{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic safe_setObject:curIndexPath forKey:kCellIndexPathKey];
    [dic safe_setObject:curModel forKey:kViewpointDataModelKey];
    [self routerEventWithName:kViewpointUserInfoEvent userInfo:dic];
}

#pragma mark - UI
-(void)setupUI{
    avaterImageView = [[UIImageView alloc] init];
    avaterImageView.layer.cornerRadius = 16;
    avaterImageView.clipsToBounds = YES;
    avaterImageView.contentMode = UIViewContentModeScaleAspectFill;
    [avaterImageView addTapPressed:@selector(userInfoPressed) target:self];
    [self addSubview:avaterImageView];
    
    nickLabel = [[UILabel alloc] init];
    nickLabel.font = [UIFont systemFontOfSize:13];
    nickLabel.textColor = [UIColor ctColor33];
    [nickLabel addTapPressed:@selector(userInfoPressed) target:self];
    [self addSubview:nickLabel];
    
    signerLabel = [[UILabel alloc] init];
    signerLabel.font = [UIFont systemFontOfSize:11];
    signerLabel.textColor = [UIColor ctColorC2];
    [signerLabel addTapPressed:@selector(userInfoPressed) target:self];
    [self addSubview:signerLabel];
    
    timeLabel = [[UILabel alloc] init];
    timeLabel.font = [UIFont systemFontOfSize:11];
    timeLabel.textColor = [UIColor ctColorC2];
    timeLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:timeLabel];
    
    followButton = [[UIButton alloc] init];
    followButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [followButton setTitleColor:[UIColor ctColor66] forState:UIControlStateNormal];
    [followButton setTitle:@"+关注" forState:UIControlStateNormal];
    followButton.titleLabel.font = kSystemFont(12);
    followButton.layer.cornerRadius = 12.5;
    [followButton addTarget:self action:@selector(followTap:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:followButton];
}

-(void)setupUILayout{
    [avaterImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(32, 32));
        make.centerY.equalTo(self.mas_centerY);
        make.left.mas_equalTo(kMarginLeft);
    }];
    
    [nickLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(avaterImageView.mas_right).offset(6);
        make.top.equalTo(avaterImageView.mas_top);
        make.height.mas_equalTo(18);
    }];
    
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(nickLabel.mas_right).offset(6);
        make.centerY.equalTo(nickLabel.mas_centerY);
    }];
    
    [followButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(56, 25));
        make.right.equalTo(self.mas_right).offset(-kMarginRight);
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [signerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(avaterImageView.mas_right).offset(6);
        make.right.equalTo(followButton.mas_left).offset(-5);
        make.top.equalTo(nickLabel.mas_bottom);
        make.height.mas_equalTo(16);
    }];
}
@end
