//
//  CTFCellularPlayerVideo.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/16.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "CTFCellularPlayerVideo.h"

@implementation CTFCellularPlayerVideo
{
    
}

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    static CTFCellularPlayerVideo *cellularmanager = nil;
    dispatch_once(&onceToken, ^{
        cellularmanager = [[self alloc] init];
    });
    return cellularmanager;
}
@end
