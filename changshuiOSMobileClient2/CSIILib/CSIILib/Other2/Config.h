//  Config.h
//  MobileClient
//
//  Created by lsh on 13-12-12.
//  Copyright (c) 2013年 pro. All rights reserved.
//

#ifndef Config_h
#define Config_h

/**************************************************/

/*程序版本号*/
#define APP_VERSION_CODE @"1.0"
//校验交易上送版本号   转成整型
#define APP_VERSION_CODEID @"1"

#define SERVER_BACKEND_URL @"http://10.44.51.1:8083"//内网测试环境
//#define SERVER_BACKEND_URL @"http://10.44.51.1:19080"//sit测试  内网

//#define SERVER_BACKEND_URL @"http://170.101.101.19:9080"//银行测试环境
//#define SERVER_BACKEND_URL @"http://10.44.51.1:8082"//内网测试环境


#define SERVER_BACKEND_CONTEXT @"pmobile"
#define SERVER_BACKEND_PATH @"samples"

/*用于检测网络状态*/

#define TEST_CHECK_NETWORK_URL @"10.44.51.1" //测试环境

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
