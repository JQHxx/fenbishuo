//
//  CTFMineVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/3/10.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFMineVC.h"
#import "CTFMineOptionCell.h"
#import "CTFMineHeadView.h"
#import "YBImageBrowser.h"
#import "CTFMineViewModel.h"
#import "CTFUserLikeView.h"
#import "CTFFeedBackVC.h"

@interface CTFMineVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *mineTableView;
@property (nonatomic, strong) CTFMineHeadView *headView;
@property (nonatomic, copy) NSArray *optionCellImages;
@property (nonatomic, copy) NSArray *optionCellNames;

@property (nonatomic, strong) CTFMineViewModel *adpater;

@end

@implementation CTFMineVC

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadData_userInfo];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.isHiddenNavBar = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    self.adpater = [[CTFMineViewModel alloc] init];
    [self setupViewContent];
}

// 获取用户个人信息
- (void)loadData_userInfo {
    @weakify(self);
    [self.adpater svr_fetchMineUserMessage:^(BOOL isSuccess) {
        @strongify(self);
        if (isSuccess) {
            [UserCache saveUserInfo:self.adpater.currentUserMessage];
        }
        [self fillDataToView];
    }];
}

// 将数据加载到页面中
- (void)fillDataToView {
    [self.headView updataViewContent];
}

- (void)setupViewContent {
    
    [self.view addSubview:self.mineTableView];
    [self.mineTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    
    self.headView = [[CTFMineHeadView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 416)];
    self.mineTableView.tableHeaderView = self.headView;
}

- (UITableView *)mineTableView {
    if (!_mineTableView) {
        _mineTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _mineTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _mineTableView.backgroundColor = [UIColor whiteColor];
        _mineTableView.delegate = self;
        _mineTableView.dataSource = self;
        _mineTableView.estimatedRowHeight = UITableViewAutomaticDimension;
        _mineTableView.rowHeight = UITableViewAutomaticDimension;
        _mineTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _mineTableView.showsVerticalScrollIndicator = NO;
        [_mineTableView registerClass:[CTFMineOptionCell class] forCellReuseIdentifier:@"CTFMineOptionCell"];
    }
    return _mineTableView;
}

#pragma mark - tableViewDataSource,UITableViewDelegate

// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.optionCellNames.count;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CTFMineOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CTFMineOptionCell"];
    NSString *imageName = [self.optionCellImages objectAtIndex:indexPath.row];
    NSString *titleName = [self.optionCellNames objectAtIndex:indexPath.row];
    NSUInteger cacheSize_image = [[SDImageCache sharedImageCache] totalDiskSize];
    NSString *cacheSizeString_image = [NSString stringWithFormat:@"%@",[self adjusted_fileSizeWithInterge:cacheSize_image]];
    NSString *message = indexPath.row == 2 ? cacheSizeString_image : @"";
    [cell fillDataWithTitleImageName:imageName titleName:titleName message:message];
    return cell;
}

// 区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

// 当已经点击cell时
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 0) {
        [self skipPersnalSettingVC];
    } else if (indexPath.row == 1) {
        [self aboutUsControlAction];
    } else if (indexPath.row == 2) {
        [self clearCacheControlAction];
    } else if (indexPath.row == 3) {
        [self feedBackControlAction];
    } else {
        
    }
}

- (NSArray *)optionCellImages {
    if (!_optionCellImages) {
        _optionCellImages = @[@"icon_setting", @"icon_aboutUs", @"icon_clearCache", @"icon_feedback"];
    }
    return _optionCellImages;
}

- (NSArray *)optionCellNames {
    if (!_optionCellNames) {
        _optionCellNames = @[@"个人设置", @"关于我们", @"清除缓存", @"向我们反馈"];
    }
    return _optionCellNames;
}

// 字节不同单位间的转换显示
- (NSString *)adjusted_fileSizeWithInterge:(NSInteger)size {
    CGFloat aFloat = size / (1024 * 1024);
    return [NSString stringWithFormat:@"%.1fMB",aFloat];
}

// 跳转到个人设置界面
- (void)skipPersnalSettingVC {
    [MobClick event:@"homepage_setting"];
    [ROUTER routeByCls:@"CTFPersonalSettingVC"];
}

// 跳转到关于我们界面
- (void)aboutUsControlAction {
    [MobClick event:@"my_aboutus"];
    [ROUTER routeByCls:@"CTFAboutUsVC"];
}

// 清除缓存
- (void)clearCacheControlAction {
    [MobClick event:@"my_clear"];
    [self showAlert_clearCache];
}

// 跳转到问题反馈界面
- (void)feedBackControlAction {
    [MobClick event:@"my_feedback"];
    CTFFeedBackVC *feedBackVC = [[CTFFeedBackVC alloc] initWithFeedBackType:FeedBackType_FeedBack feedBackContentType:-1 resourceTypeId:0];
    [self.navigationController pushViewController:feedBackVC animated:YES];
}

//
- (void)showAlert_clearCache {
    NSString *title = @"清除应用缓存";
    NSString *message = @"";
    NSString *cancelButtonTitle = @"取消";
    NSString *otherButtonTitle = @"确定";

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    
    @weakify(self);
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:otherButtonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        @strongify(self);
        [[SDImageCache sharedImageCache] clearMemory];
        @weakify(self);
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
            @strongify(self);
            [self.view makeToast:@"缓存清除成功！"];
            [self.mineTableView reloadData];
        }];
    }];
    
    [otherAction setValue:UIColorFromHEX(0xFF6885) forKey:@"titleTextColor"];
    [cancelAction setValue:UIColorFromHEX(0x999999) forKey:@"titleTextColor"];
    
    [alertController addAction:cancelAction];
    [alertController addAction:otherAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 头像点击放大
- (void)headImageControlAction {
    YBIBImageData *data = [YBIBImageData new];
    if (self.adpater.currentUserMessage.avatarUrl.length > 0) {
        data.imageURL = [NSURL safe_URLWithString:self.adpater.currentUserMessage.avatarUrl];
    }else {
        data.imageName = @"placeholder_headView_375x375";
    }
    data.allowSaveToPhotoAlbum = YES;

    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSourceArray = @[data];
    browser.currentPage = 0;
    [browser show];
}

// 跳转到个人主页
- (void)homePageButtonAction {
    [MobClick event:@"my_homepage"];
    [ROUTER routeByCls:kCTFHomePageVC withParam:@{@"userId":@(self.adpater.currentUserMessage.userId)}];
}

// 点击赞同按钮
- (void)agreeControlAction {
    [MobClick event:@"my_upclick"];
    [CTFUserLikeView showUserLikeViewWithFrame:CGRectMake(0, 0, 247, 239) isMine:YES name:UserCache.getUserInfo.name like:UserCache.getUserInfo.likeCount dismiss:nil];
}

// 跳转到我的粉丝列表界面
- (void)fansControlAction {
    [MobClick event:@"my_fansclick"];
    [ROUTER routeByCls:@"CTFMineFansListVC" withParam:@{@"userId" : [NSNumber numberWithInteger:[UserCache getUserInfo].userId]}];
}

// 跳转到我的关注列表界面
- (void)careControlAction {
    [MobClick event:@"my_followclick"];
    [ROUTER routeByCls:@"CTFMineFollowListVC" withParam:@{@"userId" : [NSNumber numberWithInteger:[UserCache getUserInfo].userId]}];
}

// 跳转到我的话题界面
- (void)mineTopicButtonAction {
    [MobClick event:@"my_mytopic"];
    [ROUTER routeByCls:@"CTFMineTopicListVC"];
}

// 跳转到我关心话题界面
- (void)careTopicButtonAction {
    [MobClick event:@"my_focustopic"];
    [ROUTER routeByCls:@"CTFMineCareTopicListVC"];
}

// 跳转到我的观点界面
- (void)mineViewPointButtonAction {
    [MobClick event:@"my_myanswer"];
    [ROUTER routeByCls:@"CTFMineViewPointListVC"];
}

@end
