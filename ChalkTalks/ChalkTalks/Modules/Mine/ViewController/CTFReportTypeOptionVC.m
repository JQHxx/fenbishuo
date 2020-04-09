//
//  CTFReportTypeOptionVC.m
//  ChalkTalks
//
//  Created by 陈昌华 on 2020/3/13.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFReportTypeOptionVC.h"

@interface CTFReportTypeOptionVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *feedBackContentType_nameArray;
@property (nonatomic, copy) NSArray *feedBackContentType_emunArray;

@property (nonatomic, assign) FeedBackType feedBackType;
@property (nonatomic, assign) FeedBackContentType feedBackContentType;
@property (nonatomic, assign) NSInteger resourceTypeId;
@end

@implementation CTFReportTypeOptionVC

- (instancetype)initWithFeedBackType:(FeedBackType)feedBackType
                      resourceTypeId:(NSInteger)resourceTypeId {
    if (self = [super init]) {
        self.feedBackType = feedBackType;
        self.resourceTypeId = resourceTypeId;
        [self setHidesBottomBarWhenPushed:YES];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.feedBackType == FeedBackType_Question) {
        self.baseTitle = @"举报话题";
        
    } else if (self.feedBackType == FeedBackType_Answer) {
        self.baseTitle = @"举报回答";
        
    } else if (self.feedBackType == FeedBackType_Comment) {
        self.baseTitle = @"举报评论";
        
    } else if (self.feedBackType == FeedBackType_Reply) {
        self.baseTitle = @"举报回复";
        
    } else {
        self.baseTitle = @"举报";
    }
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.baseNavView.mas_bottom);
        make.left.mas_equalTo(self.view.mas_left);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, kScreen_Height - self.baseNavView.bottom));
    }];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.backgroundColor = UIColorFromHEX(0xFFFFFF);
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.estimatedRowHeight = 60;
        _tableView.rowHeight = 60;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = UIColorFromHEX(0xEEEEEE);
        _tableView.showsVerticalScrollIndicator = YES;
    }
    return _tableView;
}

#pragma mark - tableViewDataSource,UITableViewDelegate

// Section
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// 行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

// cell
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    cell.textLabel.text = [self.feedBackContentType_nameArray objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = UIColorFromHEX(0x666666);
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = UIColorFromHEX(0xFAFAFA);
    UIImageView *rowImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 14)];
    rowImage.image = [UIImage imageNamed:@"icon_arrow_turnright_8x14"];
    cell.accessoryView = rowImage;
    cell.separatorInset = UIEdgeInsetsMake(0, -20, 0, 0);
    return cell;
}

// 区尾高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

// 自定义sectionheader显示的view
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 30)];
    [view setBackgroundColor:UIColorFromHEX(0xF1F1F1)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, kScreen_Width, 30)];
    titleLabel.text = @"请选择举报原因";
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = UIColorFromHEX(0x999999);
    [view addSubview:titleLabel];
    return view;
}

//设置sectionheader的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

//当已经点击cell时
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    self.feedBackContentType = [[self.feedBackContentType_emunArray objectAtIndex:indexPath.row] integerValue];
    CTFFeedBackVC *feedBackVC = [[CTFFeedBackVC alloc] initWithFeedBackType:self.feedBackType feedBackContentType:self.feedBackContentType resourceTypeId:self.resourceTypeId];
    [self.navigationController pushViewController:feedBackVC animated:YES];
}

- (NSArray *)feedBackContentType_nameArray {
    if (!_feedBackContentType_nameArray) {
        _feedBackContentType_nameArray = @[@"政治敏感、违法违规",
                                           @"色情低俗、少儿不宜",
                                           @"垃圾广告、售卖伪劣",
                                           @"盗用作品、版权问题",
                                           @"其他"];
    }
    return _feedBackContentType_nameArray;
}

- (NSArray *)feedBackContentType_emunArray {
    if (!_feedBackContentType_emunArray) {
        _feedBackContentType_emunArray = @[@(FeedBackContentType_Politics),
                                           @(FeedBackContentType_Sexy),
                                           @(FeedBackContentType_Garbage),
                                           @(FeedBackContentType_Copyright),
                                           @(FeedBackContentType_Other)];
    }
    return _feedBackContentType_emunArray;
}

-(void)leftNavigationItemAction {
    self.dismissBlock();
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
