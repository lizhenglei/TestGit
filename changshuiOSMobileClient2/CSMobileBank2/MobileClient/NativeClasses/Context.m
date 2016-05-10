//
//  Context.m
//  MobileClient
//
//  Created by fb on 13-7-24.
//  Copyright (c) 2013年 pro. All rights reserved.
//

#import "Context.h"
#import "DeviceInfo.h"
#pragma DES加密
#import "CommonFunc.h"

#import "MobileBankSession.h"

static Context *sharedInstance=nil;

static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";


@implementation Context

@synthesize cunAnimationID;
@synthesize preAnimationID;
@synthesize firstFlage;
@synthesize rateDic;
@synthesize menuInfo_UserInfo_Hints;
@synthesize server_backend_ssl;
@synthesize server_backend_name;
@synthesize encryption_platform_modulus;
@synthesize appVersionCode;
@synthesize curNativeRelatedPageServerHints;

+ (Context *)sharedInstance
{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{//线程安全
        sharedInstance = [[Context alloc] init];
        sharedInstance.firstFlage=YES;
        sharedInstance.cunAnimationID = 0;
        sharedInstance.preAnimationID = 0;
        
    });
    return sharedInstance;
}

-(id)init
{
    if(self = [super init])
    {
        self.rateDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (NSInteger)navigationBarHeight {
    float version = [[[UIDevice currentDevice]systemVersion]floatValue];
    if (version < 7.0) {
        return 44;
    } else {
        return 20 + 44;
    }
}

+ (BOOL)iOS7 {
    return [[[UIDevice currentDevice]systemVersion]floatValue] > 6.9;
}

+ (UIDeviceResolution) currentResolution {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        if ([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            result = CGSizeMake(result.width * [UIScreen mainScreen].scale, result.height * [UIScreen mainScreen].scale);
            if (result.height <= 480.0f)
                return UIDevice_iPhoneStandardRes;
            return (result.height > 960 ? UIDevice_iPhoneTallerHiRes : UIDevice_iPhoneHiRes);
        } else
            return UIDevice_iPhoneStandardRes;
    } else
        return (([[UIScreen mainScreen] respondsToSelector: @selector(scale)]) ? UIDevice_iPadHiRes : UIDevice_iPadStandardRes);
}

/******************************************************************************
 函数名称 : + (UIDeviceResolution) currentResolution
 函数描述 : 当前是否运行在iPhone5端
 输入参数 : N/A
 输出参数 : N/A
 返回参数 : N/A
 备注信息 :
 ******************************************************************************/
+(BOOL)iPhone5{
    if ([self currentResolution] == UIDevice_iPhoneTallerHiRes) {
        return YES;
    }
    return NO;
}

+ (BOOL)iPhone4 {
    if ([self currentResolution] == UIDevice_iPhoneHiRes) {
        return YES;
    }
    return NO;
}
/******************************************************************************
 函数名称 : + (BOOL)isRunningOniPhone
 函数描述 : 当前是否运行在iPhone端
 输入参数 : N/A
 输出参数 : N/A
 返回参数 : N/A
 备注信息 :
 ******************************************************************************/
+ (BOOL)isRunningOniPhone{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

+ (void)setNSUserDefaults:(NSString*)text keyStr:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] setObject:[CommonFunc base64StringFromTextDES:text] forKey:key];
}

+ (NSString*)getNSUserDefaultskeyStr:(NSString *)key{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:key]==nil) {
        return nil;
    }
    return [CommonFunc textFromBase64StringDES:[[NSUserDefaults standardUserDefaults] objectForKey:key]];
}

+(NSString *)isArm64OrArm32
{
    NSString *numStr = @"5294967296";//找个大于32位的能用64位表示的数据
    long num = numStr.integerValue;
    NSString *numStr2 = [[NSNumber numberWithLong:num] stringValue];
    if ([numStr2 isEqualToString:numStr]) {
        return @"64";
    }
    return @"";
//    返回值若是5294967296则是64位下的。若是2147483647则是32位
}
+ (NSMutableDictionary *)jsonDicFromString:(NSString *)jsonStr{
    if (jsonStr == nil) {
        return nil;
    }
    NSError *error = nil;
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(error) {
        NSLog(@"------json解析失败：%@",error);
        return nil;
    }
    return dic;
}
+ (NSString *)jsonStrFromDic:(NSDictionary *)jsonDic{
    if (jsonDic == nil) {
        return nil;
    }
    NSError *parseError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonDic options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}
+(NSString *)jsonStrFromArray:(NSMutableArray *)jsonArray
{
    if (jsonArray.count == 0) {
        return nil;
    }
    NSError *parseError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:jsonArray options:0 error:&parseError];
    NSString *str = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    return str;
}
+(NSArray *)jsonArrayFromString:(NSString *)string
{
    if (string.length==0) {
        return nil;
    }
    NSError *error = nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(error) {
        NSLog(@"------json解析失败：%@",error);
        return nil;
    }
    return array;
}

+ (NSData *)dataWithBase64EncodedString:(NSString *)string
{
    //    if (string == nil)
    //        [NSException raise:NSInvalidArgumentException format:nil];
    if ([string length] == 0)
        return [NSData data];
    
    static char *decodingTable = NULL;
    if (decodingTable == NULL)
    {
        decodingTable = malloc(256);
        if (decodingTable == NULL)
            return nil;
        memset(decodingTable, CHAR_MAX, 256);
        NSUInteger i;
        for (i = 0; i < 64; i++)
            decodingTable[(short)encodingTable[i]] = i;
    }
    
    const char *characters = [string cStringUsingEncoding:NSASCIIStringEncoding];
    if (characters == NULL)     //  Not an ASCII string!
        return nil;
    char *bytes = malloc((([string length] + 3) / 4) * 3);
    if (bytes == NULL)
        return nil;
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (YES)
    {
        char buffer[4];
        short bufferLength;
        for (bufferLength = 0; bufferLength < 4; i++)
        {
            if (characters[i] == '\0')
                break;
            if (isspace(characters[i]) || characters[i] == '=')
                continue;
            buffer[bufferLength] = decodingTable[(short)characters[i]];
            if (buffer[bufferLength++] == CHAR_MAX)      //  Illegal character!
            {
                free(bytes);
                return nil;
            }
        }
        
        if (bufferLength == 0)
            break;
        if (bufferLength == 1)      //  At least two characters are needed to produce one byte!
        {
            free(bytes);
            return nil;
        }
        
        //  Decode the characters in the buffer to bytes.
        bytes[length++] = (buffer[0] << 2) | (buffer[1] >> 4);
        if (bufferLength > 2)
            bytes[length++] = (buffer[1] << 4) | (buffer[2] >> 2);
        if (bufferLength > 3)
            bytes[length++] = (buffer[2] << 6) | buffer[3];
    }
    
    bytes = realloc(bytes, length);
    return [NSData dataWithBytesNoCopy:bytes length:length];
}
+(UIImage *)ImageName:(NSString *)imageName
{//换肤
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);//使用C函数NSSearchPathForDirectoriesInDomains来获得沙盒中目录的全路径。
    NSString *ourDocumentPath =[documentPaths objectAtIndex:0];
    NSString *unZipPath = [NSString stringWithFormat:@"%@/book",ourDocumentPath];
    UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/%@.png",unZipPath,[MobileBankSession sharedInstance].changeSkinColor,imageName]];
//    NSFileManager *fm = [[NSFileManager alloc]init];
//    NSArray *array = [fm directoryContentsAtPath:[NSString stringWithFormat:@"%@/%@",unZipPath,[MobileBankSession sharedInstance].changeSkinColor]];
//    NSLog(@"%@",array);
    return image;
}
+(NSString *)unZipPath
{
    NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,  NSUserDomainMask,YES);//使用C函数NSSearchPathForDirectoriesInDomains来获得沙盒中目录的全路径。
    NSString *ourDocumentPath =[documentPaths objectAtIndex:0];
    NSString *unZipPath = [NSString stringWithFormat:@"%@/book",ourDocumentPath];
    return unZipPath;
}
@end
