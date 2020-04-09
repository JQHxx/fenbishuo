//
//  CTFNewCareEventView.m
//  ChalkTalks
//
//  Created by vision on 2020/1/17.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFNewCareEventView.h"
#import "UIResponder+Event.h"

@interface CTFNewCareEventView ()

@property (nonatomic,strong) UIButton    *careButton;             //关心按钮
@property (nonatomic,strong) UIButton    *stepButton;             //踩的按钮
@property (nonatomic,strong) CTFQuestionsModel  *question;
@property (nonatomic,strong) NSIndexPath     *myIndexPath;


@end

@implementation CTFNewCareEventView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.careButton];
        [self addSubview:self.stepButton];
    }
    return self;
}

#pragma mark -- Event response
#pragma mark 关心
-(void)careAction:(UIButton *)sender{
    if (![self.findViewController ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    if (![self.question.status isEqualToString:@"normal"]) {
        [kKeyWindow makeToast:@"该话题尚在审核中"];
        return;
    }
    if ([self.question.attitude isEqualToString:@"like"]) {
        self.question.attitude = @"neutral";
    }else{
        self.question.attitude = @"like";
    }
    [self updateEventView];
    [self routerEventWithName:kTopicLikeEvent userInfo:@{kTopicDataModelKey:self.question,kCellIndexPathKey:self.myIndexPath}];
}

#pragma mark 踩
-(void)stepAction:(UIButton *)sender{
    if (![self.findViewController ctf_checkLoginStatementByNeededStation:CTFNeededLoginStationType_Binded]) {
        return;
    }
    if (![self.question.status isEqualToString:@"normal"]) {
        [kKeyWindow makeToast:@"该话题尚在审核中"];
        return;
    }
    if ([self.question.attitude isEqualToString:@"unlike"]) {
        self.question.attitude = @"neutral";
    }else{
        self.question.attitude = @"unlike";
    }
    [self updateEventView];
    [self routerEventWithName:kTopicUnlikeEvent userInfo:@{kTopicDataModelKey:self.question,kCellIndexPathKey:self.myIndexPath}];
}

#pragma mark 填充数据
-(void)fillCareEventWithModel:(CTFQuestionsModel *)model indexPath:(NSIndexPath *)indexPath{
    self.question = model;
    self.myIndexPath = indexPath;
    [self updateEventView];
}

-(void)setBtnDisabled:(BOOL)btnDisabled{
    _btnDisabled = btnDisabled;
    if (btnDisabled) {
        self.stepButton.userInteractionEnabled = self.careButton.userInteractionEnabled = NO;
    }
}

#pragma mark -- Setters
#pragma mark 设置状态
-(void)updateEventView{
    if ([self.question.attitude isEqualToString:@"unlike"]) {
        self.stepButton.selected = YES;
        self.careButton.selected = NO;
    }else if ([self.question.attitude isEqualToString:@"like"]){
        self.stepButton.selected = NO;
        self.careButton.selected = YES;
    }else{
        self.stepButton.selected = NO;
        self.careButton.selected = NO;
    }
}

#pragma mark -- Getters
#pragma mark 关心
-(UIButton *)careButton{
    if (!_careButton) {
        _careButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 110, 34)];
        [_careButton setImage:ImageNamed(@"details_care_black") forState:UIControlStateNormal];
        [_careButton setImage:ImageNamed(@"details_care_white") forState:UIControlStateSelected];
        [_careButton addTarget:self action:@selector(careAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _careButton;
}

#pragma mark 踩
-(UIButton *)stepButton{
    if (!_stepButton) {
        _stepButton = [[UIButton alloc] initWithFrame:CGRectMake(self.careButton.right-1, 0, 110, 34)];
        [_stepButton setImage:ImageNamed(@"details_step_black") forState:UIControlStateNormal];
        [_stepButton setImage:ImageNamed(@"details_step_white") forState:UIControlStateSelected];
        [_stepButton addTarget:self action:@selector(stepAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stepButton;
}


@end
