//
//  CTFFeedImageItemCCell.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/10.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "CTModels.h"
#import "UIImageView+CTWebImage.h"
#import "NSURL+Ext.h"
#import "UIImage+Ext.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFFeedImageItemCCell : UICollectionViewCell
+(NSString*)identifier;

//显示单图，样式不同
-(void)fillCellContent:(ImageItemModel*)model w400:(BOOL)isW400 status:(NSString *)status;

@end

NS_ASSUME_NONNULL_END
