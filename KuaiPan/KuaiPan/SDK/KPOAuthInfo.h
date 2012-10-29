//
//  KPOAuthInfo.h
//  KuaiPan
//
//  Created by zrz on 12-10-29.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KPOAuthInfo : NSObject
<NSCoding>

@property (nonatomic, strong)   NSString    *oauthToken,
                                            *oauthTokenSecret,
                                            *chargedDir,
                                            *userId;

- (id)initWithSourceDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionary;

@end
