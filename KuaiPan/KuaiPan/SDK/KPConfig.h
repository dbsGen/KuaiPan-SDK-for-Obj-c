//
//  KPConfig.h
//  KuaiPan
//
//  Created by zrz on 12-10-30.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "MTConfig.h"

#pragma mark - define

#define kKuaiPanApiVersion  [[KPConfig defaultConfig] objectForKey:@"KuaiPanApiVersion"]

#define kBaseURLString      [[KPConfig defaultConfig] objectForKey:@"BaseURLString"]
#define kFileServerBaseURLString    [[KPConfig defaultConfig] objectForKey:@"FileServerBaseURLString"]

#define kRequestTokenURLAdd [[KPConfig defaultConfig] objectForKey:@"RequestTokenURLAdd"]
#define kAccessTokenURLAdd  [[KPConfig defaultConfig] objectForKey:@"AccessTokenURLAdd"]
#define kUserInfoURLAdd     [[KPConfig defaultConfig] objectForKey:@"UserInfoURLAdd"]
#define kMetadataURLAdd     [[KPConfig defaultConfig] objectForKey:@"MetadataURLAdd"]
#define kCreateFolderURLAdd [[KPConfig defaultConfig] objectForKey:@"CreateFolderURLAdd"]
#define kShareLinkURLAdd    [[KPConfig defaultConfig] objectForKey:@"ShareLinkURLAdd"]
#define kFileHistoryURLAdd  [[KPConfig defaultConfig] objectForKey:@"FileHistoryURLAdd"]
#define kFileDeleteURLAdd   [[KPConfig defaultConfig] objectForKey:@"FileDeleteURLAdd"]
#define kUploadLocateURLAdd [[KPConfig defaultConfig] objectForKey:@"UploadLocateURLAdd"]
#define kUploadFileURLAdd   [[KPConfig defaultConfig] objectForKey:@"UploadFileURLAdd"]
#define kDownloadFileURLAdd [[KPConfig defaultConfig] objectForKey:@"DownloadFileURLAdd"]

#define kAuthorizeURLString [[KPConfig defaultConfig] objectForKey:@"AuthorizeURLString"]

@interface KPConfig : MTConfig

@end
