//
//  KPOAuth.h
//  KuaiPan
//
//  Created by zrz on 12-10-26.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPOAuthInfo.h"

@protocol KPOAuthDelegate;

@interface KPOAuth : NSObject
<UIWebViewDelegate>

@property (nonatomic, readonly) NSString    *consumerKey;
@property (nonatomic, readonly) NSString    *consumerSecret;
@property (nonatomic, readonly) UIWebView   *webView;
@property (nonatomic, strong)   NSOperationQueue    *queue;

@property (nonatomic, assign)   id<KPOAuthDelegate> delegate;

//回调地址
@property (nonatomic, strong)   NSString    *callback;

- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret;

- (BOOL)startOAuthWithWebView:(UIWebView *)webView;

@end

@protocol KPOAuthDelegate <NSObject>

@optional
- (void)oauthDidStartGetRequestToken:(KPOAuth *)oauth;
- (void)oauthDidStartInput:(KPOAuth *)oauth;
- (void)oauthDidStartGetAccessToken:(KPOAuth *)oauth;

- (void)oauth:(KPOAuth *)oauth faildWithError:(NSError *)error;
- (void)oauth:(KPOAuth *)oauth seccussWithOAuthInfo:(KPOAuthInfo *)info;

@end