//
//  CTFVideoPickImageCCell.h
//  ChalkTalks
//
//  Created by zingwin on 2020/1/9.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTFVideoImagesSlice.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFVideoPickImageCCell : UICollectionViewCell
+(NSString*)identifier;
+(CGSize)itemSize;

-(void)fillContentView:(CTFVideoImageModel*)image;
@end

NS_ASSUME_NONNULL_END
