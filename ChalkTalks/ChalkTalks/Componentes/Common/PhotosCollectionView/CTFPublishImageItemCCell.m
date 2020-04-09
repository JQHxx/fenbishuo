//
//  CTFPublishImageItemCCell.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/12.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFPublishImageItemCCell.h"
#import "NSURL+Ext.h"

@implementation CTFPublishImageItemCCell{
    UIImageView *imageView;
    UIButton    *deletButton;
    UIView      *uploadProgressView;
    UILabel     *uploadLabel;
    UILabel     *tipsLab;
    UIView      *failView;
    UIImageView *failImageView;
    UIButton    *reUploadBtn;
    
    UploadImageFileModel *curModel;
}

+(NSString*)identifier{
    return NSStringFromClass(self);
}

+(CGSize)itemSize{
    int row = 3;
    CGFloat itemWidth = floorf(((kScreen_Width - 2*kMarginLeft - (row-1)*kMutiImagesSpace) )/3.0);
    return CGSizeMake(itemWidth, itemWidth);
}

+(CGSize)itemSizeWidthPading:(CGFloat)padding{
    int row = 3;
    CGFloat itemWidth = floorf(((kScreen_Width - 2*kMarginLeft - 2*padding - (row-1)*kMutiImagesSpace) )/3.0);
    return CGSizeMake(itemWidth, itemWidth);
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 6;
        [self setupUI];
        [self setupUILayout];
    }
    return self;
}

-(void)setIsFeedback:(BOOL)isFeedback{
    _isFeedback = isFeedback;
    tipsLab.hidden = !isFeedback;
}

-(void)fillCellContent:(UploadImageFileModel*)model showadd:(BOOL)showadd{
    curModel = model;
    if(showadd){
        tipsLab.hidden = !self.isFeedback;
        imageView.image = ImageNamed(@"video_upload_more");
        deletButton.hidden = uploadLabel.hidden = failView.hidden = YES;
        uploadProgressView.alpha = 0;
    }else{
        tipsLab.hidden = YES;
        deletButton.hidden = NO;
        
        if (model.imageUrl != nil) {
            [imageView ct_setImageWithURL:[NSURL safe_URLWithString:model.imageUrl] placeholderImage:[UIImage ctPlaceholderImage] animated:YES];
            uploadLabel.hidden = YES;
            uploadProgressView.alpha = 0;
            failView.hidden = TRUE;
            return;
        }
        
        imageView.image = model.localImage;
        
        //图片上传状态
        if([model.status isEqualToString:@"succeed"] || model.uploadCompleted){
            uploadLabel.hidden = YES;
            uploadProgressView.alpha = 0;
        }else{
            uploadLabel.hidden = NO;
            uploadProgressView.alpha = 1.0;
         }
        failView.hidden = !model.uploadError;
    }
}

-(void)uploadProgress:(CGFloat)progress{
    if(progress >= 0.999f){
        uploadProgressView.alpha = 0.0;
        [uploadLabel setHidden:YES];
    }else{
        uploadProgressView.alpha = 1.0;
        [uploadLabel setHidden:NO];
        uploadLabel.text = [NSString stringWithFormat:@"%ld%%",(NSInteger)(progress*100)];
    }
}

#pragma mark - Action
-(void)deleteImg:(id)sender{
    if(self.deleteSeletedImage){
        self.deleteSeletedImage(curModel);
    }
}

-(void)reUploadTap:(id)sender{
    if(self.reUoloadImage){
        self.reUoloadImage(curModel);
    }
}

#pragma mark - UI
-(void)setupUI{
    imageView = [[UIImageView alloc] init];
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = kCornerRadius;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    
    uploadProgressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [CTFPublishImageItemCCell itemSize].width, [CTFPublishImageItemCCell itemSize].height)];
    uploadProgressView.backgroundColor = UIColorFromHEXWithAlpha(0x000000, 0.6);
    uploadProgressView.alpha = 1.0;
    [self addSubview:uploadProgressView];
    
    uploadLabel = [[UILabel alloc] init];
    uploadLabel.font = [UIFont systemFontOfSize:14];
    uploadLabel.textColor = [UIColor whiteColor];
    uploadLabel.text = @"上传中...";
    uploadLabel.hidden = YES;
    [self addSubview:uploadLabel];
    
    tipsLab = [[UILabel alloc] init];
    tipsLab.font = [UIFont regularFontWithSize:12];
    tipsLab.textColor = [UIColor ctColor99];
    tipsLab.text = @"最多上传9张";
    tipsLab.hidden = YES;
    [self addSubview:tipsLab];
        
    failView = [[UIView alloc] initWithFrame:CGRectMake(0,0, [CTFPublishImageItemCCell itemSize].width, [CTFPublishImageItemCCell itemSize].height)];
    failView.backgroundColor = UIColorFromHEX(0xeeeeee);
    [self addSubview:failView];
    
    failImageView = [[UIImageView alloc] init];
    failImageView.image = ImageNamed(@"pub_img_fail");
    failImageView.contentMode = UIViewContentModeScaleAspectFit;
    [failView addSubview:failImageView];
    
    reUploadBtn = [[UIButton alloc] init];
    [reUploadBtn setTitleColor:[UIColor ctMainColor] forState:UIControlStateNormal];
    [reUploadBtn setTitle:@"重新上传" forState:UIControlStateNormal];
    reUploadBtn.titleLabel.font = kSystemFont(14);
    [reUploadBtn addTarget:self action:@selector(reUploadTap:) forControlEvents:UIControlEventTouchUpInside];
    [failView addSubview:reUploadBtn];
    
    deletButton = [[UIButton alloc] init];
    [deletButton addTarget:self action:@selector(deleteImg:) forControlEvents:UIControlEventTouchUpInside];
    [deletButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [deletButton setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [deletButton setImage:ImageNamed(@"pub_delete_selimg") forState:UIControlStateNormal];
    [self addSubview:deletButton];
}

-(void)setupUILayout{
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [deletButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(25, 25));
        make.top.equalTo(self.mas_top).offset(6);
        make.right.equalTo(self.mas_right).offset(-6);
    }];
    
    [uploadLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
    
    [tipsLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.mas_equalTo(self).offset(-10);
        make.height.mas_equalTo(17);
    }];
    
    [failImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_offset(CGSizeMake(40, 40));
        make.centerX.equalTo(failView.mas_centerX);
        make.centerY.equalTo(failView.mas_centerY).offset(-10);
    }];
    
    [reUploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(failView.mas_centerX);
        make.top.equalTo(failImageView.mas_bottom);
        make.size.mas_equalTo(CGSizeMake(90, 30));
    }];
    
}
@end
