//
//  CTFPublishImageViewpointVC.h
//  ChalkTalks
//
//  Created by zingwin on 2019/12/12.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "BaseViewController.h"

@class CTDraftAnswer;

/// 发布图片观点
@interface CTFPublishImageViewpointVC : BaseViewController

@property (nonatomic,strong) CTDraftAnswer     *draftModel;
@property (nonatomic,strong) NSArray<UIImage*> *pickImages;

@end


