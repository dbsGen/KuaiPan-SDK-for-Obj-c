//
//  KPOAuthInfo.m
//  KuaiPan
//
//  Created by zrz on 12-10-29.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "KPOAuthInfo.h"
#import <objc/runtime.h>

#define kOAuthToken     @"oauth_token"
#define kChargedDir     @"charged_dir"
#define kOAuthTokenSecret   @"oauth_token_secret"
#define kUserId         @"user_id"

@implementation KPOAuthInfo

- (id)initWithSourceDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        self.oauthToken = [dictionary objectForKey:kOAuthToken];
        self.oauthTokenSecret = [dictionary objectForKey:kOAuthTokenSecret];
        self.chargedDir = [dictionary objectForKey:kChargedDir];
        self.userId = [dictionary objectForKey:kUserId];
    }
    return self;
}

- (NSDictionary*)dictionary
{
    return @{kOAuthToken        : self.oauthToken,
            kOAuthTokenSecret   : self.oauthTokenSecret,
            kChargedDir         : self.chargedDir,
            kUserId             : self.userId};
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.oauthToken
                  forKey:kOAuthToken];
    [aCoder encodeObject:self.oauthTokenSecret
                  forKey:kOAuthTokenSecret];
    [aCoder encodeObject:self.chargedDir
                  forKey:kChargedDir];
    [aCoder encodeObject:self.userId
                  forKey:kUserId];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.oauthToken = [aDecoder decodeObjectForKey:kOAuthToken];
        self.oauthTokenSecret = [aDecoder decodeObjectForKey:kOAuthTokenSecret];
        self.chargedDir = [aDecoder decodeObjectForKey:kChargedDir];
        self.userId = [aDecoder decodeObjectForKey:kUserId];
    }
    return self;
}

@end
