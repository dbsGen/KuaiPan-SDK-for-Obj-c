//
//  KPViewController.m
//  KuaiPan
//
//  Created by zrz on 12-10-26.
//  Copyright (c) 2012年 zrz. All rights reserved.
//

#import "KPViewController.h"
#import "KPClient.h"
#import "KPAuthorizeViewController.h"

#warning 请替换成自己的key和secret以及callback
#define kConsumerKey    @"xcBJlaupNmsLNmHV"
#define kConsumerSecret @"eryHdR4EeDs6ePVb"
#define kCallbackAddress    @"http://zhaorenzhi.cn/"

void showAlert(NSString *content) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                    message:content
                                                   delegate:nil
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

@interface KPViewController ()
<UIWebViewDelegate, KPClientDelegate>

@end

@implementation KPViewController {
    KPClient    *_client;
    KPAuthorizeViewController   *_authorizeController;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        KPOAuthInfo *info = [self oauthInfo];
        if (info) {
            _client = [[KPClient alloc] initWithConsumerKey:kConsumerKey
                                             consumerSecret:kConsumerSecret
                                                  OAuthInfo:info];
        }else {
            _client = [[KPClient alloc] initWithConsumerKey:kConsumerKey
                                             consumerSecret:kConsumerSecret
                                                   callback:kCallbackAddress];
        }
        _client.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100, 33, 120, 33);
    [button setTitle:@"Login"
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(loginClick)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100, 76, 120, 33);
    [button setTitle:@"UserInfo"
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(getUserInfo)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100, 119, 120, 33);
    [button setTitle:@"Metadata"
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(getMetadata)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(100, 162, 120, 33);
    [button setTitle:@"CreateFolder"
            forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(createFolderClick)
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - access token cache

- (KPOAuthInfo *)oauthInfo
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userDefaults objectForKey:@"accessToken"];
    if (dic) {
        return [[KPOAuthInfo alloc] initWithSourceDictionary:dic];
    }
    return nil;
}

#pragma mark - kp delegate

- (void)oauthDidStartGetRequestToken:(KPOAuth *)oauth
{
    [_authorizeController showWaiting];
}

- (void)oauthDidStartInput:(KPOAuth *)oauth
{
    [_authorizeController missWaiting];
}

- (void)oauthDidStartGetAccessToken:(KPOAuth *)oauth
{
    [_authorizeController showWaiting];
}


- (void)oauth:(KPOAuth *)oauth seccussWithOAuthInfo:(KPOAuthInfo *)info
{
    showAlert(@"登陆成功");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:info.dictionary
                     forKey:@"accessToken"];
    [userDefaults synchronize];
    [self missAuthorizeController];
}

- (void)oauth:(KPOAuth *)oauth faildWithError:(NSError *)error
{
    showAlert(@"登陆失败");
    [self missAuthorizeController];
}

- (void)client:(KPClient *)client getAccountInfo:(NSDictionary *)dictionary withError:(NSError *)error
{
    if (error) {
        showAlert(@"获取信息失败");
        NSLog(@"%@", error);
    }else {
        showAlert(@"获取信息成功");
        NSLog(@"%@", dictionary);
    }
}

- (void)client:(KPClient *)client getMetadata:(NSDictionary *)dictionary withError:(NSError *)error
{
    if (error) {
        showAlert(@"获取信息失败");
        NSLog(@"%@", error);
    }else {
        showAlert(@"获取信息成功");
        NSLog(@"%@", dictionary);
    }
}

- (void)client:(KPClient *)client createFolder:(NSDictionary *)dictionary withError:(NSError *)error
{
    if (error) {
        showAlert(@"获取信息失败");
        NSLog(@"%@", error);
    }else {
        showAlert(@"获取信息成功");
        NSLog(@"%@", dictionary);
    }
}

#pragma mark - action 

- (void)missAuthorizeController
{
    if (_authorizeController) {
        CGFloat __systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
        if (__systemVersion >= 6.0) {
            [(id)self dismissViewControllerAnimated:YES
                                         completion:nil];
        }else {
            [(id)self dismissModalViewControllerAnimated:YES];
        }
        _authorizeController = nil;
    }
}

- (void)loginClick
{
    _authorizeController = [[KPAuthorizeViewController alloc] init];
    [_authorizeController view];
    [_client startOAuthWithWebView:_authorizeController.webView];
    CGFloat __systemVersion = [UIDevice currentDevice].systemVersion.floatValue;
    if (__systemVersion >= 6.0) {
        [(id)self presentViewController:_authorizeController
                           animated:YES
                         completion:nil];
    }else {
        [(id)self presentModalViewController:_authorizeController
                                animated:YES];
    }
}

- (void)getUserInfo
{
    [_client checkAccountInfo];
}

- (void)getMetadata
{
    NSString *path = @"/app_folder/我的应用/云酷/";
    path = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [_client metadataWithPath:path
                         list:nil
                    fileLimit:nil
                         page:nil
                     pageSize:nil
                    filterExt:nil
                       sortBy:nil];
}

- (void)createFolderClick
{
    [_client createFolderWithRoot:@"app_folder"
                             path:@"/我的应用/云酷"];
}

@end
