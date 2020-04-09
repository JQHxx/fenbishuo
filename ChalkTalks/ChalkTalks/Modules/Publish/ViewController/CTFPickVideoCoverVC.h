//
//  CTFPickVideoCoverVC.h
//  ChalkTalks
//
//  Created by zingwin on 2020/1/9.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "BaseViewController.h"
#import "CTFVideoImagesSlice.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTFPickVideoCoverVC : BaseViewController
@property(nonatomic, copy) void (^ _Nonnull pickedVideoCover)(CTFVideoImageModel *selModel);
@end

NS_ASSUME_NONNULL_END
