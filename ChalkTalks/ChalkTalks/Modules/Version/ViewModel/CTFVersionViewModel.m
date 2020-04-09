//
//  CTFVersionViewModel.m
//  ChalkTalks
//
//  Created by vision on 2020/1/1.
//  Copyright © 2020 xiaohuangren. All rights reserved.
//

#import "CTFVersionViewModel.h"

@interface CTFVersionViewModel ()

@property (nonatomic,strong) CTFVersionModel *version;

@end

@implementation CTFVersionViewModel

-(instancetype)init{
    self = [super init];
    if (self) {
        self.version = [[CTFVersionModel alloc] init];
    }
    return self;
}

#pragma mark -- 检测版本
-(void)checkVersioncomplete:(AdpaterComplete)complete{
    CTRequest *request = [CTFUtilsApi checkVersion];
     @weakify(self);
    [request requstApiComplete:^(BOOL isSuccess, id  _Nullable data, NSError * _Nullable error) {
         @strongify(self);
        [self handlerError:error];
        if(isSuccess){
            [self.version yy_modelSetWithJSON:data];
           complete(YES);
        }else{
            complete(NO);
        }
    }];
}

-(CTFVersionModel *)getTargetVersion{
    return self.version;
}

@end
