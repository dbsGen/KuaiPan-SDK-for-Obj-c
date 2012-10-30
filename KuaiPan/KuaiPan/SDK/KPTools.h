//
//  KPTools.h
//  KuaiPan
//
//  Created by zrz on 12-10-26.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "KPConfig.h"


#define mark - tools

@interface KPTools : NSObject

+ (NSString *)UUID;

//获得签名
+ (NSString *)oauthSignature:(NSString *)method
                         url:(NSString *)urlString
                      params:(NSDictionary *)params
                      secret:(NSString *)secret;

+ (NSDictionary *)decodeURLString:(NSString *)urlString;

+ (NSString *)encodeWithUTF8:(NSString *)inString;

+ (NSString *)encodeWithHMAC_SHA1:(NSString *)inString
                           secret:(NSString *)secret;

+ (AFHTTPClient *)httpClient;

@end
