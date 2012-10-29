//
//  KPClient.m
//  KuaiPan
//
//  Created by zrz on 12-10-26.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "KPClient.h"
#import "MTSelecterTransation.h"
#import "KPTools.h"
#import "SBJson.h"

@implementation KPClient {
    MTSelecterTransation    *_transtion;
}

@synthesize oauth = _oauth;
@synthesize queue = _queue;
@synthesize oauthInfo = _oauthInfo;
@synthesize delegate = _delegate;

- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
                 callback:(NSString *)callback
{
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc] init];
        [_queue setSuspended:NO];
        _oauth = [[KPOAuth alloc] initWithConsumerKey:consumerKey
                                       consumerSecret:consumerSecret];
        _oauth.callback = callback;
        
        _transtion = [[MTSelecterTransation alloc] init];
        _transtion.sourceDelegate = self;
        _transtion.targetDelegate = self;
        _transtion.cross = YES;
        _transtion.protocol = @protocol(KPOAuthDelegate);
        
        _oauth.delegate = (id)_transtion;
    }
    return self;
}

- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
                OAuthInfo:(KPOAuthInfo *)oauthInfo
{
    self = [super init];
    if (self) {
        _oauth = [[KPOAuth alloc] initWithConsumerKey:consumerKey
                                       consumerSecret:consumerSecret];
        _oauthInfo = oauthInfo;
        _queue = [[NSOperationQueue alloc] init];
        [_queue setSuspended:NO];
    }
    return self;
}

- (BOOL)startOAuthWithWebView:(UIWebView *)webView
{
    return [_oauth startOAuthWithWebView:webView];
}

#pragma mark - oauth  delegate

- (void)setDelegate:(id<KPClientDelegate>)delegate
{
    _delegate = delegate;
    _transtion.targetDelegate = _delegate;
}

- (void)oauth:(KPOAuth *)oauth seccussWithOAuthInfo:(KPOAuthInfo *)info
{
    _oauthInfo = info;
}

#pragma mark - net work 

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method urlPath:(NSString *)path params:(NSDictionary *)params
{
    NSMutableDictionary *sourceParams = [self oauthParams];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [sourceParams setObject:obj forKey:key];
    }];
    
    NSString *secret = [_oauth.consumerSecret stringByAppendingString:@"&"];
    if (_oauthInfo.oauthTokenSecret) secret = [secret stringByAppendingString:_oauthInfo.oauthTokenSecret];
    NSString *signature = [KPTools oauthSignature:method
                                              url:[kBaseURLString stringByAppendingString:path]
                                           params:sourceParams
                                           secret:secret];
    [sourceParams setObject:signature
                     forKey:@"oauth_signature"];
    return [[KPTools httpClient] requestWithMethod:method
                                              path:path
                                        parameters:sourceParams];
}

- (void)checkAccountInfo
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:kUserInfoURLAdd
                                                    params:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained KPClient *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:getAccountInfo:withError:)]) {
            [this.delegate client:this
                     getAccountInfo:[responseObject JSONValue]
                          withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:getAccountInfo:withError:)]) {
            [this.delegate client:this
                     getAccountInfo:nil
                          withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)metadataWithPath:(NSString *)path
                    list:(NSNumber *)isList
               fileLimit:(NSNumber *)fileLimit
                    page:(NSNumber *)page
                pageSize:(NSNumber *)pageSize
               filterExt:(NSString *)filter
                  sortBy:(NSString *)sortBy
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (isList) {
        [params setObject:isList.stringValue
                   forKey:@"list"];
    }
    if (fileLimit) {
        [params setObject:fileLimit.stringValue
                   forKey:@"list_limit"];
    }
    if (page) {
        [params setObject:page.stringValue
                   forKey:@"page"];
    }
    if (pageSize) {
        [params setObject:pageSize.stringValue
                   forKey:@"page_size"];
    }
    if (filter) {
        [params setObject:filter
                   forKey:@"filter_ext"];
    }
    if (sortBy) {
        [params setObject:sortBy
                   forKey:@"sort_by"];
    }
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:[kMetadataURLAdd stringByAppendingString:path]
                                                    params:params];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained KPClient *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:getMetadata:withError:)]) {
            [this.delegate client:this
                      getMetadata:[responseObject JSONValue]
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:getMetadata:withError:)]) {
            [this.delegate client:this
                      getMetadata:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)createFolderWithRoot:(NSString *)root path:(NSString *)path
{
    NSDictionary *params = @{@"root" : root, @"path" : path};
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:kCreateFolderURLAdd
                                                    params:params];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained KPClient *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:createFolder:withError:)]) {
            [this.delegate client:this
                     createFolder:[responseObject JSONValue]
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:createFolder:withError:)]) {
            [this.delegate client:this
                     createFolder:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

#pragma mark - private

- (NSMutableDictionary *)oauthParams
{
    return [@{@"oauth_nonce"    : [KPTools UUID],
    @"oauth_timestamp"          : [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]],
    @"oauth_consumer_key"       : _oauth.consumerKey,
    @"oauth_signature_method"   : @"HMAC-SHA1",
    @"oauth_version"            : kKuaiPanApiVersion,
    @"oauth_token"              : _oauthInfo.oauthToken} mutableCopy];
    
}

@end
