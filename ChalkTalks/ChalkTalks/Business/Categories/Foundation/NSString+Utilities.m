//
//  NSString+Utilities.m
//  StarryNight
//
//  Created by zingwin on 2017/2/21.
//  Copyright © 2017年 zwin. All rights reserved.
//

#import "NSString+Utilities.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Utilities)
- (BOOL)sn_containsString:(NSString *)string
{
    if (![string length]) {
        return NO;
    }
    return [self rangeOfString:string].location != NSNotFound;
}

- (NSDictionary *)sn_dictionaryByBreakParameterString
{
    NSArray *array = [self componentsSeparatedByString:@"&"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    for (NSString *pairString in array) {
        NSArray *pair = [pairString componentsSeparatedByString:@"="];
        if ([pair count] == 2) {
            NSString *value = pair[1];
            value = [value URLDecodedString];
            parameters[pair[0]] = value;
        } else if ([pair count] > 2) {
            NSString *value = [pairString substringFromIndex:([pair[0] length] + 1)];
            value = [value URLDecodedString];
            parameters[pair[0]] = value;
        }
        
    }
    
    return parameters;
}

- (NSDictionary *)sn_dictionaryByShareUrl{
    
    if (self.length == 0) return nil;
    
    
    NSRange Range = [self rangeOfString:@"&"];
    
    
    if (Range.location > self.length) return nil;
    
    
    NSString *beformStr = [self substringToIndex:Range.location];
    
    NSString *afterStr = [self substringFromIndex:NSMaxRange(Range)];
    
    NSArray *pairs = @[beformStr,afterStr];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    for (NSString *pairString in pairs) {
        NSArray *pair = [pairString componentsSeparatedByString:@"="];
        if ([pair count] == 2) {
            NSString *value = pair[1];
            value = [value URLDecodedString];
            parameters[pair[0]] = value;
        } else if ([pair count] > 2) {
            NSString *value = [pairString substringFromIndex:([pair[0] length] + 1)];
            value = [value URLDecodedString];
            parameters[pair[0]] = value;
        }
        
    }
    return parameters;
}

- (NSString *)URLEncodedString
{
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                             (__bridge CFStringRef)self,
                                                                                             NULL,
                                                                                             CFSTR("!*'()^;:@&=+$,/?%#[]"),
                                                                                             kCFStringEncodingUTF8);
    return result;
}

- (NSString*)URLDecodedString
{
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                                                                             (__bridge CFStringRef)self,
                                                                                                             CFSTR(""),
                                                                                                             kCFStringEncodingUTF8);
    return result;
}

- (NSString *)md5String
{
    if(self == nil || [self length] == 0){
        return nil;
    }
    const char *value = [self UTF8String];
    
    uint8_t digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), digest);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",digest[count]];
    }
    
    return outputString;
}

- (NSString *)sha1String
{
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
    
    NSMutableString *outputString = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [outputString appendFormat:@"%02x", digest[i]];
    
    return outputString;
}

- (NSString *)phoneSeparatorString {
    return @"";
}


- (NSString *)passwordEncrypt{
    
    if (self.length == 0) return nil;
    
    return  [self encryptString:self publicKey:RSA_PUBLIC_KEY];
    
}

#pragma mark - private

- (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey{
    NSData *data = [self encryptData:[str dataUsingEncoding:NSUTF8StringEncoding] publicKey:pubKey];
    NSString *ret = base64_encode_data(data);
    return ret;
}

- (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey{
    if(!data || !pubKey){
        return nil;
    }
    SecKeyRef keyRef = [self addPublicKey:pubKey];
    if(!keyRef){
        return nil;
    }
    
    const uint8_t *srcbuf = (const uint8_t *)[data bytes];
    size_t srclen = (size_t)data.length;
    
    size_t outlen = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
    if(srclen > outlen - 11){
        CFRelease(keyRef);
        return nil;
    }
    void *outbuf = malloc(outlen);
    
    OSStatus status = noErr;
    status = SecKeyEncrypt(keyRef,
                           kSecPaddingPKCS1,
                           srcbuf,
                           srclen,
                           outbuf,
                           &outlen
                           );
    NSData *ret = nil;
    if (status != 0) {
        //NSLog(@"SecKeyEncrypt fail. Error Code: %ld", status);
    }else{
        ret = [NSData dataWithBytes:outbuf length:outlen];
    }
    free(outbuf);
    CFRelease(keyRef);
    return ret;
}


static NSData *base64_decode(NSString *str){
    NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return data;
}

static NSString *base64_encode_data(NSData *data){
    data = [data base64EncodedDataWithOptions:0];
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return ret;
}

- (NSData *)stripPublicKeyHeader:(NSData *)d_key{
    // Skip ASN.1 public key header
    if (d_key == nil) return(nil);
    
    unsigned long len = [d_key length];
    if (!len) return(nil);
    
    unsigned char *c_key = (unsigned char *)[d_key bytes];
    unsigned int  idx	 = 0;
    
    if (c_key[idx++] != 0x30) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] =
    { 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
        0x01, 0x05, 0x00 };
    if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
    
    idx += 15;
    
    if (c_key[idx++] != 0x03) return(nil);
    
    if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
    else idx++;
    
    if (c_key[idx++] != '\0') return(nil);
    
    // Now make a new NSData from this buffer
    return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

- (SecKeyRef)addPublicKey:(NSString *)key{
    
    // This will be base64 encoded, decode it.
    NSData *data = base64_decode(key);
    data = [self stripPublicKeyHeader:data];
    if(!data){
        return nil;
    }
    
    //a tag to read/write keychain storage
    NSString *tag = @"RSAUtil_PubKey";
    NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
    
    // Delete any old lingering key with the same tag
    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKey);
    
    // Add persistent version of the key to system keychain
    [publicKey setObject:data forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)
     kSecAttrKeyClass];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
     kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
    if (persistKey != nil){
        CFRelease(persistKey);
    }
    if ((status != noErr) && (status != errSecDuplicateItem)) {
        return nil;
    }
    
    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
    [publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    [publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    
    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;
    status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
    if(status != noErr){
        return nil;
    }
    return keyRef;
}

-(NSDictionary*)dictionaryWithJsonString{
    if(self == nil || self.length <=0) return nil;
    
    NSError *error;
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if(error) return nil;
    return dic;
}

- (NSMutableAttributedString *)blurryEffectWithString {
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:self];
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 4.0;
    shadow.shadowOffset = CGSizeMake(2, 2);
    shadow.shadowColor = [UIColor blackColor];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paragraphStyle.lineSpacing = 4;
    
    [attributeStr addAttributes:@{NSShadowAttributeName:shadow,NSParagraphStyleAttributeName:paragraphStyle} range:NSMakeRange(0, self.length)];
    
    return attributeStr;
}

@end
