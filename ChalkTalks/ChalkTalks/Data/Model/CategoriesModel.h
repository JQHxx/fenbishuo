//
//  CategoriesModel.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/4.
//  Copyright © 2019 amzwin. All rights reserved.
//

#import "BaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CategoriesModel : BaseModel
@property(nonatomic,assign) NSInteger categoryId;
@property(nonatomic,copy) NSString *name;
@end

NS_ASSUME_NONNULL_END
