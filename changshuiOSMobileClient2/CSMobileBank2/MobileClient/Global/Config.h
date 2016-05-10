//  Config.h
//  MobileClient
//
//  Created by lsh on 13-12-12.
//  Copyright (c) 2013年 pro. All rights reserved.
//

#ifndef Config_h
#define Config_h
//12345678909 11111111
/**************************************************/
//

/*
 上架注意：
 1，检查是不是生产地址
 2，检查是不是正式版
 3，检查极光推送的APPkey是不是正式账号的，极光推送测试的8e27f3c52ea0aadf7e7d9ee7
    正式的faa2853e4a18a76b11f659c3
 4，修改成realese模式，包括libCSIILib.a
 5，修改程序版本号和bulid号
 6,bundle identifier 正式的为com.csmobilebank.cn,检查生产证书
 7,是否有新的samples包要替换，替换后并修改为手机使用
 */

/*程序版本号*/
#define APP_VERSION_CODE @"2.0.3"
//校验交易上送版本号   转成整型
#define APP_VERSION_CODEID @"1"

//#define SERVER_BACKEND_URL @"http://10.44.51.1:8082"//内网开发
//#define SERVER_BACKEND_URL @"http://10.44.51.1:19080"//内网测试
//#define SERVER_BACKEND_URL @"https://mobile.csebank.com:453"//外网生产
#define SERVER_BACKEND_URL @"http://testmobile.csebank.com"//外网测试
//#define SERVER_BACKEND_URL @"http://ysmobilebank.csebank.com:80"//验收
//#define SERVER_BACKEND_URL @"https://58.211.237.140:453"//电信公网


#define SERVER_BACKEND_CONTEXT @"pmobile"
#define SERVER_BACKEND_PATH @"samples"

/*用于检测网络状态,不含端口号*/
//#define TEST_CHECK_NETWORK_URL @"10.44.51.1" //内网测试和内网开发
//#define TEST_CHECK_NETWORK_URL @"mobile.csebank.com" //外网生产
#define TEST_CHECK_NETWORK_URL @"testmobile.csebank.com" //外网测试
//#define TEST_CHECK_NETWORK_URL @"ysmobilebank.csebank.com" //验收
//#define TEST_CHECK_NETWORK_URL @"https://58.211.237.140" //电信公网

/**************************************************/

/*加上下面这段代码,系统类NSLog就只在编译配置为Debug下有输出，Release下不输出了*/
#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif

#ifdef DEBUG
#define DebugLog( s, ... ) NSLog( @"<%@:(%d)> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DebugLog( s, ... )
#endif

/**************************************************/

#endif
