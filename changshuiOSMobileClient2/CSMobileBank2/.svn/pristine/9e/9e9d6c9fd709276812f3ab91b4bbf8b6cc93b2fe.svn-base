//
//  DeviceInfo.m
//  deviert
//
//  Created by fb on 13-6-5.
//  Copyright (c) 2013年 fb. All rights reserved.
//

#import "DeviceInfo.h"
#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <CommonCrypto/CommonDigest.h>

@implementation DeviceInfo
static const char* jailbreak_apps[] =
{
    "/Applications/Cydia.app",
    "/Applications/limera1n.app",
    "/Applications/greenpois0n.app",
    "/Applications/blackra1n.app",
    "/Applications/blacksn0w.app",
    "/Applications/redsn0w.app",
    "/Applications/Absinthe.app",
    NULL,
};
//MD5
+(NSString *)fileMD5:(NSString *)path
{
    NSFileHandle *hanle=[NSFileHandle fileHandleForReadingAtPath:path];
    if(hanle==nil)
    {
        return nil;
    }
    CC_MD5_CTX md5;
    CC_MD5_Init(&md5);
    BOOL done=NO;
    while (!done) {
        NSData *fileData=[hanle readDataOfLength:1024];
        CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
        if([fileData length]==0)
            done=YES;
    }
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &md5);
    
    [hanle closeFile];
    NSString* s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
				   digest[0], digest[1],
				   digest[2], digest[3],
				   digest[4], digest[5],
				   digest[6], digest[7],
				   digest[8], digest[9],
				   digest[10], digest[11],
				   digest[12], digest[13],
				   digest[14], digest[15]];
	return s;
}

+(NSString *)executablePathMD5{
    NSString *appPath = [[NSBundle mainBundle] executablePath];
    NSString *appmd5string = [DeviceInfo fileMD5:appPath];
    //DebugLog(@"app md5 string = %@",appmd5string);
    return appmd5string;
}
//越狱
+(BOOL)isJailBrojen
{
    for(int i = 0; jailbreak_apps[i] != NULL; ++i)
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_apps[i]]])
        {
            return YES;
        }
    }
    
    
    BOOL jailbroken = NO;
    NSString *cydiaPath = @"/Applications/Cydia.app";
    NSString *aptPath = @"/private/var/lib/apt/";
    if ([[NSFileManager defaultManager] fileExistsAtPath:cydiaPath]) {
        jailbroken = YES;
    }
    if ([[NSFileManager defaultManager] fileExistsAtPath:aptPath]) {
        jailbroken = YES;
    }
    return jailbroken;
    
    return NO;

}
+(NSDictionary *)deviceInfo
{
    NSMutableDictionary *dic=[[NSMutableDictionary alloc]init];
    [dic setObject:@"" forKey:@"DeviceId"];
    [dic setObject:@"0" forKey:@"DeviceType"];//0：手机 1：平板 2：电视 3：其他
    [dic setObject:@"iOS" forKey:@"DeviceOsType"];
    [dic setObject:[self getMacAddress] forKey:@"DeviceMac"];
    [dic setObject:[UIDevice currentDevice].model forKey:@"DeviceModel"];
    [dic setObject:[self getDeviceDisplayMetrics] forKey:@"DeviceMetrics"];
    
    return dic;
}


+ (NSString *)getDeviceDisplayMetrics {
    NSString *DisplayMetrics;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if ([Context iPhone5]) {
            DisplayMetrics=@"1136*640";
        }
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            DisplayMetrics=@"960*640";
        }
        else {
            DisplayMetrics=@"480*320";
        }
    }else {
        if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
            ([UIScreen mainScreen].scale == 2.0)) {
            DisplayMetrics=@"1024*768";
        }
        else {
            DisplayMetrics=@"2048*1536";
        }
    }
    return DisplayMetrics;
}
+ (NSString *)getMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    NSString            *macAddressString = nil;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        //DebugLog(@"Error: %@", errorFlag);
        
        //修改 by liangSuhua 2014.1.17
        //return errorFlag;
        macAddressString = nil;
    }
    else
    {
        // Map msgbuffer to interface message structure
        interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
        
        // Map to link-level socket structure
        socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
        
        // Copy link layer address data in socket structure to an array
        memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
        
        // Read from char array into a string object, into traditional Mac address format
        macAddressString = [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X",
                                      macAddress[0], macAddress[1], macAddress[2],
                                      macAddress[3], macAddress[4], macAddress[5]];
        
        // Release the buffer memory
        free(msgBuffer);
    }
    

    if ([[[UIDevice currentDevice] systemVersion]intValue]<6)
    {
        if(macAddressString == nil || [macAddressString isEqualToString:@""])
            return @"000000000000";
        
        return macAddressString;
    }
    else if ([[[UIDevice currentDevice] systemVersion]intValue]==6)
    {
        if(macAddressString == nil || [macAddressString isEqualToString:@""])
        {
            //iOS6也可以获取广告识别码
            //96FEADAA-884B-405A-A382-9E275FC15580
            NSString *adUUIDString = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
            if(adUUIDString != nil && ![adUUIDString isEqualToString:@""])
                return [adUUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
            else
                return @"000000000000";
            
        }
        else
        {
            return macAddressString;
        }
    }
    else
    {
        //所有iOS7设备mac地址都返回020000000000,在此直接用广告识别码代替
        
        //96FEADAA-884B-405A-A382-9E275FC15580
        NSString *adUUIDString = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        if(adUUIDString != nil && ![adUUIDString isEqualToString:@""])
            return [adUUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
        else
            return @"000000000000";
    }
}



+(NSDictionary *)appVersionInfo
{
    
    NSDictionary *infoDic=[[NSBundle mainBundle] infoDictionary];
    
    //  CFShow((__bridge CFTypeRef)(infoDic));
    //app名称
    NSString *app_Name=[infoDic objectForKey:@"CFBundleDisplayName"];
    //app版本号
    NSString *app_Version=[infoDic objectForKey:@"CFBundleVersion"];
    //
    
    NSDictionary *versionDic=[NSDictionary dictionaryWithObjectsAndKeys:app_Name,@"VersionName",app_Version,@"VersionCode",@"",@"VersionType",@"",@"VersionSource", nil];
   
    return versionDic;
    
}


@end
