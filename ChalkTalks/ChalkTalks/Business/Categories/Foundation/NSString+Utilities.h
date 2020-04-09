//
//  NSString+Utilities.h
//  StarryNight
//
//  Created by zingwin on 2017/2/21.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RSA_PUBLIC_KEY @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDBuJfZfete+sUiaf9JYqreYO8imJiQGyii0Koy5uZ5AAkq8/thS44/+TN4IErwCDxHIZgzJMkdXRXRkqDGxivczrPpzAW67vfQwuDt/ZkD+Vp92rSTwCkXbhCrKPlBHCBVzfw8nlAT8UzQ+Xhcd9sroOtlFl66JroJym+oNtyxawIDAQA"

@interface NSString (Utilities)
- (BOOL)sn_containsString:(NSString *)string;
- (NSDictionary *)sn_dictionaryByBreakParameterString;
- (NSDictionary *)sn_dictionaryByShareUrl;

- (NSString *)URLEncodedString;
- (NSString*)URLDecodedString;
- (NSString *)md5String;
- (NSString *)sha1String;

- (NSString *)phoneSeparatorString;

- (NSString *)passwordEncrypt; // base64 -> rsa

- (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;
- (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey;

-(NSDictionary*)dictionaryWithJsonString;

- (NSMutableAttributedString *)blurryEffectWithString;

@end
