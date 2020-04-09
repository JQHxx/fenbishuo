//
//  TopicTitleTailSelectViewCell.m
//  ChalkTalks
//
//  Created by zingwin on 2020/1/13.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "TopicTitleTailSelectViewCell.h"
#import "CTFConfigsModel.h"

@implementation TopicTitleTailSelectViewCell
{
    UILabel *titleLabel;
    UIView *lineView;
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self setupUI];
        [self setupUILayout];
    }
    return self;
}

+(CGFloat)height{
    return 56;
}

- (void)fillContentWithData:(id)obj {
    CTFSuffixModel * model = (CTFSuffixModel *)obj;
    titleLabel.text = model.suffix;
    titleLabel.highlighted = model.isSelected;
}

-(void)setupUI{
    titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont regularFontWithSize:16];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor ctColor99];
    titleLabel.highlightedTextColor = [UIColor ctMainColor];
    [self.contentView addSubview:titleLabel];
    
    lineView = [[UIView alloc] init];
    lineView.backgroundColor = [UIColor ctColorEE];
    [self.contentView addSubview:lineView];
}

-(void)setupUILayout{
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.contentView);
        make.height.mas_equalTo(0.5f);
    }];
}
@end
