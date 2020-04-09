//
//  AppDelegate+WX.m
//  ChalkTalks
//
//  Created by zingwin on 2019/12/2.
//  Copyright © 2019 xiaohuangren. All rights reserved.
//

#import "AppDelegate+WX.h"

#import "LibKey.h"
#import "AppNotification.h"


@implementation AppDelegate (WX)

/* 要使你的程序启动后微信能响应你的程序，必须在代码中向微信终端注册你的ID */
- (void)configWx {
    [WXApi registerApp:wxAPPID];
}

/* 如果第三方程序向微信发送了 sendReq 的请求，那么 onResp 会被回调。sendReq 请求调用后，会切到微信终端程序界面 */
- (void)onResp:(BaseResp *)resp {
    
    if([resp isKindOfClass:[SendAuthResp class]]){//判断是否为授权登录类

        SendAuthResp *req = (SendAuthResp *)resp;
        if([req.state isEqualToString:@"wx_oauth_authorization_state"]){//微信授权成功
            [[NSNotificationCenter defaultCenter] postNotificationName:kWechatLoginSuccessNotification object:req.code];
        } else {//授权失败
            [[NSNotificationCenter defaultCenter] postNotificationName:kWechatLoginFailedNotification object:nil];
        }
    }
}
@end
