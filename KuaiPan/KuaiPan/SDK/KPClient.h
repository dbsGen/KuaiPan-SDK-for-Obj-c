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

/** root权限
 *  如果这个程序有权限root=kuaipan 否则root=app_folder
 *  默认是app_folder
 */
@property (nonatomic, strong)   NSString    *root;

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

/** 生成请求，params中不用写oauth参数
 *  第一个方法使用默认的baseUrl   http://openapi.kuaipan.cn/
 *  第二个方法使用自定的baseUrl
 */
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                   urlPath:(NSString *)path
                                    params:(NSDictionary *)params;

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                   urlPath:(NSString *)path
                                    params:(NSDictionary *)params
                                   baseUrl:(NSString *)baseUrl;

#pragma mark - apis

//  1/account_info
- (void)checkAccountInfo;

/**  1/metadata/<root>/<path>
 *  @param  path 网络硬盘路径 必须
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
 *  @param path 同上
 */
- (void)createFolderWithPath:(NSString *)path;

/**
 *  1/shares/<root>/<path>
 *  @param  path 同上
 *  @param  name 下载页面中显示的名字
 *  @param  accessToken 提取码
 */
- (void)getShareAddress:(NSString *)path
                   name:(NSString *)name
            accessToken:(NSString *)accessToken;

/**
 *  1/history/<root>/<path>
 *  @param  path 同上
 */
- (void)fileHistory:(NSString *)path;

/**
 *  1/fileops/delete
 *  @param  path 同上
 *  @param  toRecycle True or False 字符型(?) 默认为True 可为空
 */

- (void)deleteFile:(NSString *)path
         toRecycle:(NSString *)toRecycle;

/**
 *  1/fileops/upload_locate
 *  @param  path    同上
 *  @param  file    上传的文件   必须
 *  @param  overWrite   是否覆盖 
 *  @param  sourceIp    自身的ip 可选
 */
- (void)uploadFile:(NSString *)path
              file:(NSData *)file
         overWritr:(BOOL)overWrite
          sourceIp:(NSString *)sourceIp;

/**
 *  1/fileops/download_file
 *  @param  path 同上
 *  @param  rev 版本 可选
 */
- (void)downloadFile:(NSString *)path
                 rev:(NSString *)rev;

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

//分享连接
- (void)client:(KPClient *)client
  getShareLink:(NSDictionary *)dictionary
     withError:(NSError *)error;

//获得文件历史
- (void)client:(KPClient *)client
   fileHistory:(NSDictionary *)dictionary
     withError:(NSError *)error;


//删除文件
- (void)client:(KPClient *)client
    deleteFile:(NSDictionary *)dictionary
     withError:(NSError *)error;

//上传文件
- (void)client:(KPClient *)client
    uploadFile:(NSDictionary *)dictionary
     withError:(NSError *)error;

//下载文件
- (void)client:(KPClient *)client
  downloadFile:(NSData *)file
     withError:(NSError *)error;

@end