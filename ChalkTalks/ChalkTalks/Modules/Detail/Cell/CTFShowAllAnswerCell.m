//
//  CTFShowAllAnswerCell.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/27.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFShowAllAnswerCell.h"
#import "UIButton+Composition.h"

@implementation CTFShowAllAnswerCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIButton  *allBtn = [[UIButton alloc] init];
        [allBtn setTitle:@"查看全部回答" forState:UIControlStateNormal];
        [allBtn setTitleColor:[UIColor ctMainColor] forState:UIControlStateNormal];
        allBtn.titleLabel.font = [UIFont mediumFontWithSize:14];
        [allBtn setImage:ImageNamed(@"topic_details_showall") forState:UIControlStateNormal];
        [allBtn ctfLayoutButtonWithEdgeInsetsStyle:CTFButtonEdgeInsetsType_ImageRight imageTitleSpace:2];
        [allBtn addTarget:self action:@selector(showAllAnswers) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:allBtn];
        [allBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView.mas_top).offset(5);
            make.centerX.equalTo(self);
            make.height.mas_equalTo(40);
        }];
    }
    return self;
}

-(void)showAllAnswers{
    if(self.didClickShowAllAnswer){
        self.didClickShowAllAnswer();
    }
}
@end
