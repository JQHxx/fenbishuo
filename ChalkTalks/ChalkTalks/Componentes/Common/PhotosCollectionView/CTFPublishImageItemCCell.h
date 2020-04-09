//
//  CTFPublishImageItemCCell.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/12.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "CTModels.h"
#import "UIView+Frame.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFPublishImageItemCCell : UICollectionViewCell
@property(nonatomic, copy) void (^ _Nonnull deleteSeletedImage)(UploadImageFileModel *model);
@property(nonatomic, copy) void (^ _Nonnull reUoloadImage)(UploadImageFileModel *model);

@property (nonatomic,assign) BOOL  isFeedback;

+(NSString*)identifier;
+(CGSize)itemSize;
+(CGSize)itemSizeWidthPading:(CGFloat)padding;

-(void)fillCellContent:(UploadImageFileModel*)model showadd:(BOOL)showadd;

-(void)uploadProgress:(CGFloat)progress;

@end

NS_ASSUME_NONNULL_END
