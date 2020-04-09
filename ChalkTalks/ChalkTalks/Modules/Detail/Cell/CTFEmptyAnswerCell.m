//
//  CTFEmptyAnswerCell.m
//  ChalkTalks
//
//  Created by zingwin on 2020/1/6.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFEmptyAnswerCell.h"

@implementation CTFEmptyAnswerCell
{
    UIImageView *emptyImageView;
    UILabel *tipsLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        emptyImageView = [[UIImageView alloc] init];
        emptyImageView.image = ImageNamed(@"empty_NoAction_120x120");
        [self.contentView addSubview:emptyImageView];
        
        tipsLabel = [[UILabel alloc] init];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
        tipsLabel.textColor = [UIColor ctColor99];
        tipsLabel.text = @"有的没的，都来说说你的观点~";
        [self.contentView addSubview:tipsLabel];
        
        [emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(120, 120));
            make.centerX.equalTo(self.mas_centerX);
            make.top.mas_equalTo(65);
        }];
        
        [tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.top.equalTo(emptyImageView.mas_bottom).offset(20);
        }];
    }
    return self;
}

+ (CGFloat)height {
    return 330;
}
@end
