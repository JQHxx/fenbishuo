//
//  CTFDraftBoxVC.m
//  ChalkTalks
//
//  Created by vision on 2020/3/5.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFDraftBoxVC.h"
#import "CTFPublishImageViewpointVC.h"
#import "CTFPublishVideoViewpointVC.h"
#import "CTFDraftTableViewCell.h"
#import "CTFCommonManager.h"

@interface CTFDraftBoxVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView      *draftTableView;
@property (nonatomic,strong) UIView           *blankView;
@property (nonatomic,strong) NSMutableArray   *draftAnswersArray;

@end

@implementation CTFDraftBoxVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.baseTitle = @"草稿箱";
    [self.view addSubview:self.draftTableView];
    [self.draftTableView addSubview:self.blankView];
    self.blankView.hidden = YES;
    [self loadDraftAnswersData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDraftDataNotification:) name:[CTDrafts share].kStoredNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteDraftDataNotification:) name:[CTDrafts share].kDeleteDraftNotification object:nil];
}

#pragma mark -- UITableViewDataSource and UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.draftAnswersArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CTFDraftTableViewCell";
    CTFDraftTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[CTFDraftTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    CTDraftAnswer *model = [self.draftAnswersArray safe_objectAtIndex:indexPath.row];
    [cell fillContentWithData:model];
    @weakify(self)
    cell.didDeleteDraftAnswer = ^(CTDraftAnswer * _Nonnull model) {
        @strongify(self)
        [self deleteDraftAnswer:model];
    };
    cell.didSelectedDraftAnswer = ^(CTDraftAnswer * _Nonnull model) {
        @strongify(self)
        [self didSelectedDraftCellWithAnswer:model];
    };
    return cell;
}

#pragma mark -- Private methods
#pragma mark 获取数据
- (void)loadDraftAnswersData {
    [self.draftAnswersArray removeAllObjects];
    NSArray *data = [[CTDrafts share] allDrafts];
    if (data.count > 0) {
        NSArray *sortedArray = [data sortedArrayUsingComparator:^NSComparisonResult(CTDraftAnswer *draft1, CTDraftAnswer *draft2){
            return draft1.updateAt < draft2.updateAt;
        }];
        [self.draftAnswersArray addObjectsFromArray:sortedArray];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.blankView.hidden = data.count > 0;
        [self.draftTableView reloadData];
    });
}

#pragma mark 点击草稿
- (void)didSelectedDraftCellWithAnswer:(CTDraftAnswer *)model {
    // 取数据库最新状态
    CTDraftAnswer *updatedModel = [[CTDrafts share] getDraftWithQuestionId:model.questionId];
    if (updatedModel == nil) {
        return;
    }
    
    if (model.type == DraftAnswerTypePhoto) {
        CTFPublishImageViewpointVC *publishImageVC = [[CTFPublishImageViewpointVC alloc] init];
        publishImageVC.draftModel = updatedModel;
        publishImageVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:publishImageVC animated:YES completion:nil];
    } else if (model.type == DraftAnswerTypeVideo) {
        CTFPublishVideoViewpointVC *publishVideoVC = [[CTFPublishVideoViewpointVC alloc] init];
        publishVideoVC.draftModel = updatedModel;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:publishVideoVC];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    } else if (model.type == DraftAnswerTypePhotoWithAudio) { //图语
        CTPublishPhotoWithAudioController *audioImgVC = [[CTPublishPhotoWithAudioController alloc] initWithDraft:updatedModel];
        [self.navigationController pushViewController:audioImgVC animated:YES];
    }
}

#pragma mark 删除草稿
- (void)deleteDraftAnswer:(CTDraftAnswer *)model {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"是否删除该草稿？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *otherAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [otherAction setValue:[UIColor ctMainColor] forKey:@"titleTextColor"];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [[CTDrafts share] removeDraftWithId:model.draftId];
        [self.draftAnswersArray removeObject:model];
        [self.draftTableView reloadData];
        self.blankView.hidden = self.draftAnswersArray.count>0;
    }];
    [cancelAction setValue:[UIColor ctColor99] forKey:@"titleTextColor"];
    [alertController addAction:otherAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark -- Notification
#pragma mark 保存草稿成功回调
- (void)refreshDraftDataNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [kKeyWindow makeToast:@"内容保存到草稿箱"];
    });
    [self loadDraftAnswersData];
}

#pragma mark 删除草稿成功回调
- (void)deleteDraftDataNotification:(NSNotification *)notification {
    [self loadDraftAnswersData];
}

#pragma mark -- getters
#pragma mark 草稿箱
- (UITableView *)draftTableView {
    if (!_draftTableView) {
        _draftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kNavBar_Height, kScreen_Width, kScreen_Height-kNavBar_Height) style:UITableViewStylePlain];
        _draftTableView.dataSource = self;
        _draftTableView.delegate = self;
        _draftTableView.showsVerticalScrollIndicator = NO;
        _draftTableView.estimatedRowHeight = 60;
        _draftTableView.rowHeight = UITableViewAutomaticDimension;
        _draftTableView.tableFooterView = [[UIView alloc] init];
        _draftTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _draftTableView;
}

#pragma mark 空白页
- (UIView *)blankView {
    if (!_blankView) {
        _blankView = [[UIView alloc] initWithFrame:self.draftTableView.bounds];
        
        UIImageView *myImgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreen_Width-92)/2.0, 140, 92, 84)];
        myImgView.image = ImageNamed(@"empty_NoDraft_92x84");
        [_blankView addSubview:myImgView];
        
        UILabel *tipslab = [[UILabel alloc] initWithFrame:CGRectMake(10, myImgView.bottom+30, kScreen_Width-20, 22)];
        tipslab.font = [UIFont regularFontWithSize:15];
        tipslab.textColor = [UIColor ctColor99];
        tipslab.textAlignment = NSTextAlignmentCenter;
        tipslab.text = @"暂时还没有草稿";
        [_blankView addSubview:tipslab];
    }
    return _blankView;
}

- (NSMutableArray *)draftAnswersArray {
    if (!_draftAnswersArray) {
        _draftAnswersArray = [[NSMutableArray alloc] init];
    }
    return _draftAnswersArray;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[CTDrafts share].kStoredNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:[CTDrafts share].kDeleteDraftNotification object:nil];
}

@end
