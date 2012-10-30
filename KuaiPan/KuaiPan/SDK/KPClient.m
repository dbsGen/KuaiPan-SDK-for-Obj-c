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
    NSMutableDictionary *dataParams = [NSMutableDictionary dictionary];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSData class]]) {
            [dataParams setObject:obj forKey:key];
        }else [sourceParams setObject:obj forKey:key];
    }];
    
    NSString *secret = [_oauth.consumerSecret stringByAppendingString:@"&"];
    if (_oauthInfo.oauthTokenSecret) secret = [secret stringByAppendingString:_oauthInfo.oauthTokenSecret];
    NSString *signature = [KPTools oauthSignature:method
                                              url:[kBaseURLString stringByAppendingString:path]
                                           params:sourceParams
                                           secret:secret];
    [sourceParams setObject:signature
                     forKey:@"oauth_signature"];
    if ([method isEqualToString:@"POST"]) {
        NSMutableString *newPath = [path mutableCopy];
        [newPath appendString:@"?"];
        __block BOOL first = YES;
        [sourceParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (first) {
                first = NO;
                [newPath appendFormat:@"%@=%@", key, obj];
            }else {
                [newPath appendFormat:@"&%@=%@", key, obj];
            }
        }];
        return [[KPTools httpClient] multipartFormRequestWithMethod:method
                                                               path:[newPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                                         parameters:nil
                                          constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                {
                    [dataParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        [formData appendPartWithFileData:obj
                                                    name:key
                                                fileName:key
                                                mimeType:@"Multipart/form-data"];
                    }];
                }];
    }
    return [[KPTools httpClient] requestWithMethod:method
                                              path:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                        parameters:sourceParams];
}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                   urlPath:(NSString *)path
                                    params:(NSDictionary *)params
                                   baseUrl:(NSString *)baseUrl
{
    NSMutableDictionary *sourceParams = [self oauthParams];
    NSMutableDictionary *dataParams = [NSMutableDictionary dictionary];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSData class]]) {
            [dataParams setObject:obj forKey:key];
        }else [sourceParams setObject:obj forKey:key];
    }];
    
    NSString *secret = [_oauth.consumerSecret stringByAppendingString:@"&"];
    if (_oauthInfo.oauthTokenSecret) secret = [secret stringByAppendingString:_oauthInfo.oauthTokenSecret];
    NSString *signature = [KPTools oauthSignature:method
                                              url:[baseUrl stringByAppendingString:path]
                                           params:sourceParams
                                           secret:secret];
    [sourceParams setObject:signature
                     forKey:@"oauth_signature"];
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    if ([method isEqualToString:@"POST"]) {
        NSMutableString *newPath = [path mutableCopy];
        [newPath appendString:@"?"];
        __block BOOL first = YES;
        [sourceParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (first) {
                first = NO;
                [newPath appendFormat:@"%@=%@", key, obj];
            }else {
                [newPath appendFormat:@"&%@=%@", key, obj];
            }
        }];
        
        return [client multipartFormRequestWithMethod:method
                                                 path:[newPath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                           parameters:nil
                            constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                {
                    [dataParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        [formData appendPartWithFileData:obj
                                                    name:key
                                                fileName:key
                                                mimeType:@"Multipart/form-data"];
                    }];
                }];
    }
    return [client requestWithMethod:method
                                path:[path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
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
                                                   urlPath:[kMetadataURLAdd stringByAppendingString:
                                                            [NSString stringWithFormat:@"/%@%@",self.root,path]]
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

- (void)createFolderWithPath:(NSString *)path
{
    NSDictionary *params = @{@"root" : self.root, @"path" : path};
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

- (void)getShareAddress:(NSString *)path name:(NSString *)name accessToken:(NSString *)accessToken
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (name) {
        [params setObject:name
                   forKey:@"name"];
    }
    if (accessToken) {
        [params setObject:accessToken
                   forKey:@"access_code"];
    }
    
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:[kShareLinkURLAdd stringByAppendingFormat:
                                                            @"/%@%@", self.root, path]
                                                    params:params];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained KPClient *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:getShareLink:withError:)]) {
            [this.delegate client:this
                     getShareLink:[responseObject JSONValue]
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:getShareLink:withError:)]) {
            [this.delegate client:this
                     getShareLink:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)fileHistory:(NSString *)path
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:[kFileHistoryURLAdd stringByAppendingFormat:
                                                            @"/%@%@", self.root, path]
                                                    params:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained KPClient *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:fileHistory:withError:)]) {
            [this.delegate client:this
                     fileHistory:[responseObject JSONValue]
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:fileHistory:withError:)]) {
            [this.delegate client:this
                     fileHistory:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)deleteFile:(NSString *)path toRecycle:(NSString *)toRecycle
{
    NSDictionary *params = @{@"root" : self.root, @"path" : path, @"to_recycle" : toRecycle};
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:kFileDeleteURLAdd
                                                    params:params];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained KPClient *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:deleteFile:withError:)]) {
            [this.delegate client:this
                       deleteFile:[responseObject JSONValue]
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:deleteFile:withError:)]) {
            [this.delegate client:this
                       deleteFile:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:operation];
}

- (void)uploadFile:(NSString *)path file:(NSData *)file overWritr:(BOOL)overWrite sourceIp:(NSString *)sourceIp
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (sourceIp) {
        [params setObject:sourceIp forKey:@"source_ip"];
    }
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:kUploadLocateURLAdd
                                                    params:params
                                                   baseUrl:kFileServerBaseURLString];
    AFHTTPRequestOperation *opretion = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained KPClient *this = self;
    [opretion setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSDictionary *result = [responseObject JSONValue];
        NSString *stat = [result objectForKey:@"stat"];
        
        if ([stat isEqualToString:@"OK"]) {
            NSString *url = [result objectForKey:@"url"];
            NSLog(@"%@", url);
            NSDictionary *params =
            @{
            @"overwrite"    : overWrite ? @"true" : @"false",
            @"file"         : file,
            @"root"         : self.root,
            @"path"         : path
            };
            NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                           urlPath:kUploadFileURLAdd
                                                            params:params
                                                           baseUrl:url];
            AFHTTPRequestOperation *opretion = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [opretion setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                if ([this.delegate respondsToSelector:@selector(client:uploadFile:withError:)]) {
                    [this.delegate client:self
                               uploadFile:[responseObject JSONValue]
                                withError:nil];
                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                if ([this.delegate respondsToSelector:@selector(client:uploadFile:withError:)]) {
                    [this.delegate client:self
                               uploadFile:nil
                                withError:error];
                }
            }];
            [this.queue addOperation:opretion];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        if ([this.delegate respondsToSelector:@selector(client:uploadFile:withError:)]) {
            [this.delegate client:self
                       uploadFile:nil
                        withError:error];
        }
    }];
    [self.queue addOperation:opretion];
}

- (void)downloadFile:(NSString *)path rev:(NSString *)rev
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.root, @"root", path, @"path", nil];
    if (rev) {
        [params setObject:rev forKey:@"rev"];
    }
    
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                   urlPath:kDownloadFileURLAdd
                                                    params:params
                                                   baseUrl:kFileServerBaseURLString];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    __unsafe_unretained KPClient *this = self;
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([this.delegate respondsToSelector:@selector(client:downloadFile:withError:)]) {
            [this.delegate client:self
                     downloadFile:responseObject
                        withError:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if ([this.delegate respondsToSelector:@selector(client:downloadFile:withError:)]) {
            [this.delegate client:self
                     downloadFile:nil
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

#pragma mark - getter and setter

- (NSString *)root
{
    if (!_root) {
        _root = @"app_folder";
    }
    return _root;
}

@end
