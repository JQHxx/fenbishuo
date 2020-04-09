//
//  CTBaseCard.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/3.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIKit+Alloc.h"
#import "UIView+Frame.h"
#import "UIResponder+Event.h"
#import "UIColor+DefColors.h"
#import "UIImageView+CTWebImage.h"
#import <Masonry/Masonry.h>
#import "AppMargin.h"
#import "CTModels.h"
#import "NSDictionary+Safety.h"
#import "NSArray+Safety.h"
#import "UIImage+Ext.h"
#import "NSURL+Ext.h"

NS_ASSUME_NONNULL_BEGIN

//@protocol CTBaseCardDelegate<NSObject>
//@end

@interface CTBaseCard : UITableViewCell
//@property(nonatomic,weak) id<CTBaseCardDelegate> delegate;
@property(nonatomic, strong) NSIndexPath *cardIndexPath;

+(NSString*)identifier;
+(CGFloat)height;
+(CGFloat)heightForCellByData:(id)data;
-(void)fillContentWithData:(id)obj;
@end

NS_ASSUME_NONNULL_END
