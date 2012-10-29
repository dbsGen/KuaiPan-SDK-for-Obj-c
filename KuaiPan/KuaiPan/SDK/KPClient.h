//
//  KPClient.h
//  KuaiPan
//
//  Created by zrz on 12-10-26.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KPOAuth.h"
#import "KPOAuthInfo.h"

@protocol KPClientDelegate;

@interface KPClient : NSObject
<KPOAuthDelegate>

@property (nonatomic, readonly) NSOperationQueue    *queue;
@property (nonatomic, readonly) KPOAuth     *oauth;
@property (nonatomic, readonly) KPOAuthInfo *oauthInfo;

@property (nonatomic, assign)   id<KPClientDelegate>    delegate;

//两种初始化方式
//第一种是需要用户认证的时候使用。
- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
                 callback:(NSString *)callback;
//第二种是用于载入保存的accessToken时使用。
- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret
                OAuthInfo:(KPOAuthInfo *)oauthInfo;

//直接调用oauth里面的startOAuthWithWebView:
- (BOOL)startOAuthWithWebView:(UIWebView *)webView;

//生成请求，params中不用写oauth参数
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                   urlPath:(NSString *)path
                                    params:(NSDictionary *)params;

#pragma mark - apis

//  1/account_info
- (void)checkAccountInfo;

/**  1/metadata/<root>/<path>
 *  @param  path 网络硬盘路径 /<root>/<path> 
 *          root:如果应用是全局的root=kuaipan
 *          否则root=app_folder   必须
 *  @param  isList  是否列出子文件可以为空
 *  @param  fileLimit 文件数目限制最多10000,超过会出错406 可为空
 *  @param  page 分页页数 可为空 默认0
 *  @param  pageSize 分页单页数量 可为空 默认20
 *  @param  filter 通过后缀名过滤 可为空
 *  @param  sortBy 排列 可为空 候选值:date,name,size
 *
 */
- (void)metadataWithPath:(NSString *)path
                    list:(NSNumber *)isList
               fileLimit:(NSNumber *)fileLimit
                    page:(NSNumber *)page
                pageSize:(NSNumber *)pageSize
               filterExt:(NSString *)filter
                  sortBy:(NSString *)sortBy;

/**
 *  1/fileops/create_folder
 *  @param root 同上
 *  @param path 同上
 */
- (void)createFolderWithRoot:(NSString *)root
                        path:(NSString *)path;

@end

@protocol KPClientDelegate <KPOAuthDelegate>

@optional
//获得用户信息
- (void)client:(KPClient *)client
  getAccountInfo:(NSDictionary *)dictionary
       withError:(NSError *)error;

//获得文件信息
- (void)client:(KPClient *)client
   getMetadata:(NSDictionary *)dictionary
     withError:(NSError *)error;

//创建文件夹
- (void)client:(KPClient *)client
  createFolder:(NSDictionary *)dictionary
     withError:(NSError *)error;

@end