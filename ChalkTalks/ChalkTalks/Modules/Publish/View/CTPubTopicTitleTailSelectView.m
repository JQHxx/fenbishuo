//
//  CTPubTopicTitleTailSelectView.m
//  ChalkTalks
//
//  Created by zingwin on 2020/1/13.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTPubTopicTitleTailSelectView.h"
#import "TopicTitleTailSelectViewCell.h"
@interface CTPubTopicTitleTailSelectView()<UITableViewDelegate,UITableViewDataSource>{
    UIView       *bgView;
    UIView       *bottomView;
    UILabel      *titleLabel;
    UIButton     *closeButton;
    UITableView  *selectTableView;
}
@property(nonatomic, copy ) void   (^didSelected)(CTFSuffixModel *suffixModel);
@property(nonatomic, copy ) void    (^dismissBlock)(void);
@property(nonatomic,strong) CTFSuffixModel             *selSuffix;
@property(nonatomic, copy ) NSArray<CTFSuffixModel *>  *titleList;
@end

@implementation CTPubTopicTitleTailSelectView


+ (void)showTopicTitleTailSelectView:(NSArray<CTFSuffixModel *> *)titleList
                           selSuffix:(CTFSuffixModel *)selSuffix
                        dismissBlock:(void (^)(void))dismissBlock
                  didSelectedHandler:(void (^)(CTFSuffixModel *))didSelectedHandler{
    CTPubTopicTitleTailSelectView *av = [[CTPubTopicTitleTailSelectView alloc] initWithTitles:titleList selSuffix:selSuffix dismissBlock:dismissBlock didSelectedHandler:didSelectedHandler];
    [av show];
}

-(instancetype)initWithTitles:(NSArray<CTFSuffixModel *> *)titleList
                     selSuffix:(CTFSuffixModel *)selSuffix
                 dismissBlock:(void (^)(void))dismissBlock
           didSelectedHandler:(void (^) (CTFSuffixModel *)) didSelectedHandler{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if(self){
        self.dismissBlock = dismissBlock;
        self.didSelected = didSelectedHandler;
        self.titleList = titleList;
        self.selSuffix = selSuffix;
        [self setupUI];
    }
    return self;
}


- (void)show{
    //不要在uiwindow直接添加view. 不能监听屏幕横竖
//    [self.currentWindow.rootViewController.view addSubview:self];
    [[self mainWindow] addSubview:self];
    @weakify(self);
    [UIView animateWithDuration:0.25f delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.9 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        @strongify(self);
        self->bgView.alpha = 1.f;
        self->bottomView.y = kScreen_Height - [self bottomViewHeight];
        self->bgView.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.5f);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss{
    self.dismissBlock();
    @weakify(self);
    [UIView animateWithDuration:0.25f animations:^{
        @strongify(self);
        self->bgView.alpha = 0.f;
        self->bottomView.y = kScreen_Height;
        self->bgView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.0f];
    } completion:^(BOOL finished) {
        @strongify(self);
        self.userInteractionEnabled = NO;
        [self removeFromSuperview];
    }];
}

-(UIWindow*)mainWindow{
    id appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate && [appDelegate respondsToSelector:@selector(window)]) {
        return [appDelegate window];
    }
    NSArray *windows = [UIApplication sharedApplication].windows;
    if ([windows count] == 1) {
        return [windows firstObject];
    } else {
        for (UIWindow *window in windows) {
            if (window.windowLevel == UIWindowLevelNormal) {
                return window;
            }
        }
    }
    return  [[UIApplication sharedApplication] keyWindow];
}

-(CGFloat)bottomViewHeight{
    return 280 + AppMargin.notchScreenBottom;
}

-(void)setupUI{
    bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height)];
    [bgView addTapPressed:@selector(dismiss) target:self];
    bgView.alpha = 0;
    bgView.userInteractionEnabled = YES;
    [self addSubview:bgView];
    
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, [self bottomViewHeight]+20)];
    bottomView.backgroundColor = UIColorFromHEX(0xFFFFFF);
    bottomView.clipsToBounds = YES;
    bottomView.layer.cornerRadius = 10;
    bottomView.userInteractionEnabled = YES;
    [self addSubview:bottomView];
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMarginLeft, 0, 200, 56)];
    titleLabel.text = @"选择后缀";
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightMedium];
    titleLabel.textColor = [UIColor ctColor33];
    [bottomView addSubview:titleLabel];
    
    closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 18, 20, 20)];
    closeButton.x = kScreen_Width - 20 - kMarginLeft;
    [closeButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [closeButton setImage:ImageNamed(@"pub_delete_selimg") forState:UIControlStateNormal];
    [closeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [bottomView addSubview:closeButton];
    
    selectTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, titleLabel.bottom, kScreen_Width, [self bottomViewHeight] - titleLabel.bottom - AppMargin.notchScreenBottom) style:UITableViewStylePlain];
    selectTableView.dataSource = self;
    selectTableView.delegate = self;
    [selectTableView registerClass:[TopicTitleTailSelectViewCell class] forCellReuseIdentifier:[TopicTitleTailSelectViewCell identifier]];
    [selectTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [bottomView addSubview:selectTableView];
}

#pragma mark -
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [TopicTitleTailSelectViewCell height];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.titleList count];
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TopicTitleTailSelectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[TopicTitleTailSelectViewCell identifier] forIndexPath:indexPath];
    CTFSuffixModel *model = [self.titleList safe_objectAtIndex:indexPath.row];
    [cell fillContentWithData:model];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CTFSuffixModel *model = [self.titleList safe_objectAtIndex:indexPath.row];
    [selectTableView reloadData];
    [self dismiss];
    if(self.didSelected){
        self.didSelected(model);
    }
}
@end
