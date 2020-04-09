//
//  CTFTopicInfoCell.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/12.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFTopicInfoCell.h"
#import "CTFPhotosColletionView.h"
#import "CTFNewCareEventView.h"
#import "CTFCommonManager.h"
#import "NSURL+Ext.h"

@interface CTFTopicInfoCell(){
    UIImageView              *avaterImageView;
    UILabel                  *nickLabel;
    UILabel                  *signerLabel;
    UILabel                  *timeLabel;
    UIImageView              *typeImgView;
    UILabel                  *topicLabel;
    UIVisualEffectView       *titleEffectView;
    UILabel                  *descLabel;
    UIVisualEffectView       *descEffectView;
    UILabel                  *statusLabel;
    UIButton                 *showAllDescButton;
    CTFPhotosColletionView   *imgsCollectionView;
    CTFNewCareEventView      *careEventView;
    UIView                   *lineView;
    
    CTFTopicInfoCellLayout  *curModel;
    
    BOOL     refreshed;
}

@end

@implementation CTFTopicInfoCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)fillContentWithData:(CTFTopicInfoCellLayout*)obj{
    curModel = obj;
    
    [avaterImageView ct_setImageWithURL:[NSURL safe_URLWithString:obj.model.author.avatarUrl] placeholderImage:[UIImage ctUserPlaceholderImage] animated:YES];
    nickLabel.text = obj.model.author.name;
    signerLabel.text = kIsEmptyString(obj.model.author.headline)?@"还没有签名":obj.model.author.headline;
    timeLabel.text = [CTDateUtils formatTimeAgoWithTimestamp:obj.model.createdAt];
    typeImgView.image = [obj.model.type isEqualToString:@"demand"]?ImageNamed(@"home_topic_demand"):ImageNamed(@"home_topic_recommend");
    if (kIsEmptyString(obj.model.shortTitle)&&kIsEmptyString(obj.model.suffix)) {
        topicLabel.text = obj.model.title;
    } else {
        topicLabel.attributedText = [CTFCommonManager setTopicTitleWithType:obj.model.type shortTitle:obj.model.shortTitle suffix:obj.model.suffix];
    }
    
    if ([curModel.model.status isEqualToString:@"normal"]) {
        titleEffectView.hidden = descEffectView.hidden = statusLabel.hidden = YES;
    } else {
        statusLabel.hidden = curModel.model.images.count > 0;
        titleEffectView.hidden = NO;
        if (!kIsEmptyString(curModel.model.content)) {
            descEffectView.hidden = NO;
        } else {
            descEffectView.hidden = YES;
        }
    }
    
    if (!kIsEmptyString(obj.model.content)) {
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:obj.model.content];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.lineSpacing = 4;
        [attributeStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, obj.model.content.length)];
        descLabel.attributedText = attributeStr;
    }
    [imgsCollectionView fillImagesData:curModel.model.images status:curModel.model.status];
    showAllDescButton.selected = curModel.model.showAll;
    [careEventView fillCareEventWithModel:obj.model indexPath:self.cardIndexPath];
    
}

#pragma mark - Action
-(void)showAllDescTap:(id)sender{
    curModel.model.showAll = !curModel.model.showAll;
    if(self.switchShowAllTopicContent){
        self.switchShowAllTopicContent();
    }
    showAllDescButton.selected = curModel.model.showAll;
    [self setNeedsLayout];
}

-(void)userInfoPressed{
    [ROUTER routeByCls:kCTFHomePageVC withParam:@{@"userId": @(curModel.model.author.authorId)}];
}

#pragma mark 点击话题标题
- (void)topicTitlePressed{
    [self routerEventWithName:kTopicTitleEvent userInfo:@{kViewpointDataModelKey: curModel.model}];
}

#pragma mark - UI
-(void)layoutSubviews{
    [super layoutSubviews];
    
    avaterImageView.frame = curModel.headerRect;
    nickLabel.frame = curModel.nickNameRect;
    signerLabel.frame = curModel.signRect;
    timeLabel.frame = curModel.timeRect;
    typeImgView.frame = curModel.typeRect;
    topicLabel.frame = curModel.topicContentRect;
    titleEffectView.frame = curModel.topicContentRect;
    statusLabel.frame = curModel.statusRect;
    [showAllDescButton setHidden:!curModel.needShowAllBtn];
    showAllDescButton.frame = curModel.showAllButtonRect;
    if (curModel.model.showAll) { //显示全部
        descLabel.frame = curModel.topicAllSummaryRect;
        descEffectView.frame = curModel.topicAllSummaryRect;
        if (curModel.model.images.count > 0) {
            imgsCollectionView.frame = curModel.imgsRect;
            imgsCollectionView.y = CGRectGetMaxY(descLabel.frame)+10;
            showAllDescButton.y = CGRectGetMaxY(imgsCollectionView.frame)+10;
            careEventView.frame = curModel.attitudeRect;
            careEventView.y = CGRectGetMaxY(showAllDescButton.frame)+16;
            lineView.frame = curModel.lineRect;
            lineView.y = CGRectGetMaxY(careEventView.frame);
        } else {
            careEventView.frame = curModel.attitudeRect;
            lineView.frame = curModel.lineRect;
            if (curModel.needShowAllBtn) {
                statusLabel.y = CGRectGetMaxY(descLabel.frame)+10;
                showAllDescButton.y = CGRectGetMaxY(statusLabel.frame)+10;
                careEventView.y = CGRectGetMaxY(showAllDescButton.frame)+16;
            } else {
                statusLabel.y = CGRectGetMaxY(descLabel.frame)+10;
                careEventView.y = CGRectGetMaxY(statusLabel.frame)+10;
            }
            lineView.y = CGRectGetMaxY(careEventView.frame);
        }
    } else { //收起
        imgsCollectionView.frame = CGRectZero;
        descLabel.frame = curModel.topicSummaryRect;
        descEffectView.frame = curModel.topicSummaryRect;
        statusLabel.frame = curModel.statusRect;
        careEventView.frame = curModel.attitudeRect;
        lineView.frame = curModel.lineRect;
        if (curModel.needShowAllBtn) {
            if (curModel.model.images.count > 0) {
                showAllDescButton.y = CGRectGetMaxY(descLabel.frame)+10;
            } else {
                statusLabel.y = CGRectGetMaxY(descLabel.frame)+10;
                showAllDescButton.y = CGRectGetMaxY(statusLabel.frame)+10;
            }
            careEventView.y = CGRectGetMaxY(showAllDescButton.frame)+16;
        } else {
            if (curModel.model.images.count > 0) {
                careEventView.y = CGRectGetMaxY(descLabel.frame)+10;
            } else {
                statusLabel.y = CGRectGetMaxY(descLabel.frame)+10;
                careEventView.y = CGRectGetMaxY(statusLabel.frame)+10;
            }
        }
        lineView.y = CGRectGetMaxY(careEventView.frame);
    }
}

-(void)setupUI{
    avaterImageView = [[UIImageView alloc] init];
    avaterImageView.layer.cornerRadius = 16;
    avaterImageView.clipsToBounds = YES;
    avaterImageView.contentMode = UIViewContentModeScaleAspectFill;
     [avaterImageView addTapPressed:@selector(userInfoPressed) target:self];
    [self.contentView addSubview:avaterImageView];
    
    nickLabel = [[UILabel alloc] init];
    nickLabel.font = [UIFont mediumFontWithSize:14];
    nickLabel.textColor = [UIColor ctColor33];
     [nickLabel addTapPressed:@selector(userInfoPressed) target:self];
    [self.contentView addSubview:nickLabel];
    
    signerLabel = [[UILabel alloc] init];
    signerLabel.font = [UIFont systemFontOfSize:11];
    signerLabel.textColor = [UIColor ctColorC2];
    [self.contentView addSubview:signerLabel];
    
    timeLabel = [[UILabel alloc] init];
    timeLabel.font = [UIFont regularFontWithSize:11];
    timeLabel.textColor = [UIColor ctColorC2];
    [self.contentView addSubview:timeLabel];
    
    typeImgView = [[UIImageView alloc] init];
    [self.contentView addSubview:typeImgView];
    
    topicLabel = [[UILabel alloc] init];
    topicLabel.font = [UIFont mediumFontWithSize:20];
    topicLabel.textColor = [UIColor ctColor33];
    topicLabel.lineBreakMode = NSLineBreakByCharWrapping;
    topicLabel.numberOfLines = 0;
    [topicLabel addTapPressed:@selector(topicTitlePressed) target:self];
    [self.contentView addSubview:topicLabel];
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    titleEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    [self.contentView addSubview:titleEffectView];
    titleEffectView.hidden = YES;
    
    descLabel = [[UILabel alloc] init];
    descLabel.font = [UIFont regularFontWithSize:16];
    descLabel.numberOfLines = 0;
    descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    descLabel.textColor = [UIColor ctColor33];
    [self.contentView addSubview:descLabel];
    
    descEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    [self.contentView addSubview:descEffectView];
    descEffectView.hidden = YES;
    
    statusLabel = [[UILabel alloc] init];
    statusLabel.text = @"内容审核中";
    statusLabel.font = [UIFont regularFontWithSize:12.0f];
    statusLabel.textColor = UIColorFromHEX(0xFF5757);
    [self.contentView addSubview:statusLabel];
    statusLabel.hidden = YES;
    
    showAllDescButton = [[UIButton alloc] init];
    [showAllDescButton addTarget:self action:@selector(showAllDescTap:) forControlEvents:UIControlEventTouchUpInside];
    showAllDescButton.titleLabel.font = [UIFont ctfFeedIntrFont];
    [showAllDescButton setTitleColor:[UIColor ctColor80] forState:UIControlStateNormal];
    [showAllDescButton setTitle:@"展开" forState:UIControlStateNormal];
    [showAllDescButton setTitle:@"收起" forState:UIControlStateSelected];
    [showAllDescButton setImage:ImageNamed(@"topic_details_expand") forState:UIControlStateNormal];
    [showAllDescButton setImage:ImageNamed(@"topic_details_retake") forState:UIControlStateSelected];
    [showAllDescButton ctfLayoutButtonWithEdgeInsetsStyle:CTFButtonEdgeInsetsType_ImageRight imageTitleSpace:4];
    [showAllDescButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.contentView addSubview:showAllDescButton];
    
    //图片
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    imgsCollectionView = [[CTFPhotosColletionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.contentView addSubview:imgsCollectionView];
    
    //踩
    careEventView = [[CTFNewCareEventView alloc] init];
    [self.contentView addSubview:careEventView];
    
    lineView = [[UIView alloc] init];
    lineView.backgroundColor = UIColorFromHEX(0xF8F8F8);
    [self.contentView addSubview:lineView];
}
@end
