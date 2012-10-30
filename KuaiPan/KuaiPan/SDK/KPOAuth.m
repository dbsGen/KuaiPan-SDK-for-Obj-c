//
//  KPOAuth.m
//  KuaiPan
//
//  Created by zrz on 12-10-26.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "KPOAuth.h"
#import "AFNetworking.h"
#import "KPTools.h"
#import "SBJson.h"
#import "MTSelecterTransation.h"
#import "KPOAuthInfo.h"

@implementation KPOAuth {
    BOOL    _loading;
    BOOL    _waitingForLoadOver;
    AFHTTPClient    *_httpClient;
    NSString        *_oauthTokenSecret;
    MTSelecterTransation    *_transation;
}

@synthesize consumerKey = _consumerKey;
@synthesize consumerSecret = _consumerSecret;
@synthesize webView = _webView;

- (void)dealloc
{
    [self.queue cancelAllOperations];
}

- (id)initWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret
{
    self = [super init];
    if (self) {
        _consumerKey = consumerKey;
        _consumerSecret = consumerSecret;
    }
    return self;
}

- (BOOL)startOAuthWithWebView:(UIWebView *)webView
{
    if (_loading) {
        NSLog(@"Oauth running please try me later");
        return NO;
    }
    if (!webView) {
        NSLog(@"webView is nil");
        return NO;
    }
    _webView = webView;
    [self startRequest];
    return YES;
}

#pragma mark - net work

- (NSOperationQueue *)queue
{
    if (!_queue) {
        _queue = [[NSOperationQueue alloc] init];
        [_queue setSuspended:NO];
    }
    return _queue;
}

- (void)startRequest
{
    if ([self.delegate respondsToSelector:@selector(oauthDidStartGetRequestToken:)]) {
        [self.delegate oauthDidStartGetRequestToken:self];
    }
    
    NSDictionary *sourceParams =
    @{@"oauth_consumer_key"     : _consumerKey,
    @"oauth_signature_method"   : @"HMAC-SHA1" ,
    @"oauth_timestamp"          : [NSString stringWithFormat:@"%d",
                                   (int)[[NSDate date] timeIntervalSince1970]],
    @"oauth_nonce"              : [KPTools UUID],
    @"oauth_version"            : kKuaiPanApiVersion ,
    @"oauth_callback"           : self.callback};
    
    NSDictionary *params = [self signatureWithParams:sourceParams
                                              method:@"GET"
                                                 url:[kBaseURLString stringByAppendingString:
                                                      kRequestTokenURLAdd]];
    
    NSMutableURLRequest *request = [[KPTools httpClient] requestWithMethod:@"GET"
                                                                   path:kRequestTokenURLAdd
                                                             parameters:params];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained KPOAuth *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [this getRequestToken:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if ([this.delegate respondsToSelector:@selector(oauth:faildWithError:)]) {
            [this.delegate oauth:this faildWithError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)getRequestToken:(NSData *)responseData
{
    NSDictionary *requstResult = [responseData JSONValue];
    NSString *oauthToken = [requstResult objectForKey:@"oauth_token"];
    _oauthTokenSecret = [requstResult objectForKey:@"oauth_token_secret"];
    
    if (_webView.delegate) {
        _transation = [[MTSelecterTransation alloc] init];
        _transation.sourceDelegate = self;
        _transation.targetDelegate = _webView.delegate;
        _transation.protocol = @protocol(UIWebViewDelegate);
        _transation.cross = YES;
        _webView.delegate = (id)_transation;
    }else {
        _transation = nil;
        _webView.delegate = self;
    }
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[kAuthorizeURLString
                                                                               stringByAppendingFormat:@"?ac=open&op=authorise&oauth_token=%@", oauthToken]]];
    [_webView loadRequest:request];
    _waitingForLoadOver = YES;
}

- (void)getOAuthToken:(NSString *)urlString
{
    if ([self.delegate respondsToSelector:@selector(oauthDidStartGetAccessToken:)]) {
        [self.delegate oauthDidStartGetAccessToken:self];
    }
    NSDictionary *params = [KPTools decodeURLString:urlString];
    NSString *oauthToken = [params objectForKey:@"oauth_token"];
    NSString *oauthVerifier = [params objectForKey:@"oauth_verifier"];
    
    NSDictionary *sourceParams =
    @{@"oauth_consumer_key"     : self.consumerKey,
    @"oauth_signature_method"   : @"HMAC-SHA1",
    @"oauth_timestamp"          : [NSString stringWithFormat:@"%d",
                                   (int)[[NSDate date] timeIntervalSince1970]],
    @"oauth_nonce"              : [KPTools UUID],
    @"oauth_version"            : kKuaiPanApiVersion,
    @"oauth_token"              : oauthToken,
    @"oauth_verifier"           : oauthVerifier};
    
    NSDictionary *resultParams = [self signatureWithParams:sourceParams
                                                    method:@"GET"
                                                       url:[kBaseURLString stringByAppendingString:kAccessTokenURLAdd]];
    
    NSMutableURLRequest *request = [[KPTools httpClient] requestWithMethod:@"GET"
                                    path:kAccessTokenURLAdd
                              parameters:resultParams];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained KPOAuth *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [this getAccessToken:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@", error);
        if ([this.delegate respondsToSelector:@selector(oauth:faildWithError:)]) {
            [this.delegate oauth:this faildWithError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)getAccessToken:(NSData *)data
{
    NSDictionary *result = [data JSONValue];
    KPOAuthInfo *info = [[KPOAuthInfo alloc] initWithSourceDictionary:result];
    if ([self.delegate respondsToSelector:@selector(oauth:seccussWithOAuthInfo:)]) {
        [self.delegate oauth:self seccussWithOAuthInfo:info];
    }
}

#pragma mark - web view delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *urlString = request.URL.description;
    if ([urlString hasPrefix:self.callback]) {
        [self getOAuthToken:urlString];
        _webView.delegate = _transation.targetDelegate;
        _transation = nil;
        return NO;
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (_waitingForLoadOver) {
        _waitingForLoadOver = NO;
        if ([self.delegate respondsToSelector:@selector(oauthDidStartInput:)]) {
            [self.delegate oauthDidStartInput:self];
        }
    }
}

#pragma mark - private method

- (NSDictionary *)signatureWithParams:(NSDictionary *)params
                               method:(NSString *)method
                                  url:(NSString *)urlString
{
    NSString *secret = [_consumerSecret stringByAppendingString:@"&"];
    if (_oauthTokenSecret) {
        secret = [secret stringByAppendingString:_oauthTokenSecret];
    }
    NSMutableDictionary *outParams = [params mutableCopy];
    NSString *sign = [KPTools oauthSignature:method
                                         url:urlString
                                      params:params
                                      secret:secret];
    
    [outParams setObject:sign
               forKey:@"oauth_signature"];
    return [outParams copy];
}

@end
