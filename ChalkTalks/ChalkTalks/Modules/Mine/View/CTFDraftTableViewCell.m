//
//  CTFDraftTableViewCell.m
//  ChalkTalks
//
//  Created by vision on 2020/3/5.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFDraftTableViewCell.h"

@interface CTFDraftTableViewCell ()

@property (nonatomic,strong) UILabel   *topicTitleLab;  //话题标题
@property (nonatomic,strong) UILabel   *answerTipsLab;  //回答类型 图片、视频、语音
@property (nonatomic,strong) UILabel   *answerDescLab;  //回答文字内容
@property (nonatomic,strong) UIControl *cellControl;
@property (nonatomic,strong) UILabel   *timeLab;        //创建时间
@property (nonatomic,strong) UIButton  *deleteBtn;      //删除
@property (nonatomic,strong) UIView    *lineView;       //线条
@property (nonatomic,strong) CTDraftAnswer  *model;

@end

@implementation CTFDraftTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

#pragma mark -- Event response
#pragma mark 删除
- (void)deleteDraftDataAction:(UIButton *)sender {
    self.didDeleteDraftAnswer(self.model);
}

#pragma mark
- (void)cellControlAction {
    self.didSelectedDraftAnswer(self.model);
}

#pragma mark 填充数据
- (void)fillContentWithData:(id)obj {
    self.model = (CTDraftAnswer *)obj;
    self.topicTitleLab.text = self.model.questionTitle;
    if (self.model.type == DraftAnswerTypeVideo) {
        self.answerTipsLab.text = @"【视频】";
    } else if (self.model.type == DraftAnswerTypePhotoWithAudio) {
        self.answerTipsLab.text = @"【图片+语音】";
    } else if (self.model.type == DraftAnswerTypePhoto)  {
        if (self.model.items.count>0) {
           self.answerTipsLab.text = @"【图片】";
        } else {
            self.answerTipsLab.text = @"";
        }
    }
    
    self.answerDescLab.text = self.model.content;
    self.timeLab.text = [CTDateUtils formatTimeAgoWithTimestamp:self.model.updateAt];
}

#pragma mark 初始化界面
- (void)setupUI{
    [self.contentView addSubview:self.topicTitleLab];
    [self.topicTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.left.mas_equalTo(16);
        make.width.mas_equalTo(kScreen_Width-2*kMarginLeft);
    }];
    
    [self.contentView addSubview:self.answerTipsLab];
    [self.answerTipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topicTitleLab.mas_bottom).offset(6);
        make.left.mas_equalTo(self.topicTitleLab.mas_left).offset(-6);
    }];
    
    [self.contentView addSubview:self.answerDescLab];
    [self.answerDescLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.width.mas_equalTo(kScreen_Width-2*kMarginLeft);
        make.top.mas_equalTo(self.answerTipsLab.mas_bottom);
    }];
    
    [self.contentView addSubview:self.cellControl];
    [self.cellControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.bottom.mas_equalTo(self.answerDescLab.mas_bottom);
    }];
    
    [self.contentView addSubview:self.timeLab];
    [self.timeLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.answerDescLab.mas_left);
        make.top.mas_equalTo(self.answerDescLab.mas_bottom);
        make.height.mas_equalTo(30);
    }];
    
    [self.contentView addSubview:self.deleteBtn];
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.contentView.mas_right).offset(-12);
        make.top.mas_equalTo(self.answerDescLab.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.contentView addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deleteBtn.mas_bottom).offset(5);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(1);
        make.bottom.mas_equalTo(self.contentView.mas_bottom);
    }];
}

#pragma mark -- Getters
#pragma mark 话题标题
- (UILabel *)topicTitleLab {
    if (!_topicTitleLab) {
        _topicTitleLab = [[UILabel alloc] init];
        _topicTitleLab.font = [UIFont mediumFontWithSize:15];
        _topicTitleLab.textColor = [UIColor ctColor33];
        _topicTitleLab.numberOfLines = 0;
    }
    return _topicTitleLab;
}

#pragma mark 回答类型
- (UILabel *)answerTipsLab {
    if (!_answerTipsLab) {
        _answerTipsLab = [[UILabel alloc] init];
        _answerTipsLab.font = [UIFont regularFontWithSize:13];
        _answerTipsLab.textColor = [UIColor ctColor99];
    }
    return _answerTipsLab;
}

#pragma mark 回答内容
- (UILabel *)answerDescLab {
    if (!_answerDescLab) {
        _answerDescLab = [[UILabel alloc] init];
        _answerDescLab.font = [UIFont regularFontWithSize:13];
        _answerDescLab.textColor = [UIColor ctColor99];
        _answerDescLab.numberOfLines = 2;
    }
    return _answerDescLab;
}

- (UIControl *)cellControl {
    if (!_cellControl) {
        _cellControl = [[UIControl alloc] init];
        [_cellControl addTarget:self action:@selector(cellControlAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cellControl;
}

#pragma mark 时间
- (UILabel *)timeLab {
    if (!_timeLab) {
        _timeLab = [[UILabel alloc] init];
        _timeLab.font = [UIFont regularFontWithSize:13];
        _timeLab.textColor = [UIColor ctColor99];
    }
    return _timeLab;
}

#pragma mark 删除
- (UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc] init];
        [_deleteBtn setImage:ImageNamed(@"draft_box_delete") forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(deleteDraftDataAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

#pragma mark 线条
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor ctColorEE];
    }
    return _lineView;
}


@end
