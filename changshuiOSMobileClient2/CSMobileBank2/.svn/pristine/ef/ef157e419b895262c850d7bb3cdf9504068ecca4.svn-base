//
//  CSIIConfigDeviceInfo.m
//  MobileBank
//
//  Created by Yuxiang on 13-5-2.
//
//

#import "CSIIConfigDeviceInfo.h"
#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <CommonCrypto/CommonDigest.h>
//#import <AdSupport/AdSupport.h>
//判断是否越狱的字段
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

@implementation CSIIConfigDeviceInfo

+(NSString*)fileMD5:(NSString*)path
{
	NSFileHandle *handle = [NSFileHandle fileHandleForReadingAtPath:path];
	if( handle== nil )
        return nil;
    
    CC_MD5_CTX md5;
	CC_MD5_Init(&md5);
	
	BOOL done = NO;
	while(!done)
	{
		NSData* fileData = [handle readDataOfLength: 1024 ];
		CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
		if( [fileData length] == 0 ) done = YES;
	}
    
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final(digest, &md5);
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

+ (NSString *)getDeviceID
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
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
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
//    DebugLog(@"Mac Address: %@", macAddressString);
    
    // Release the buffer memory
    free(msgBuffer);
    if ([[[UIDevice currentDevice] systemVersion]intValue]<6) {
        return macAddressString;
    }else{
//        return [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
}



- (BOOL) hasAPT
{
    return [[NSFileManager defaultManager] fileExistsAtPath:@"/private/var/lib/apt/"];
}

- (BOOL) successCallSystem
{
    return (system("ls") == 0) ? YES : NO;
}

+(BOOL) isJailBroken
{
    // Now check for known jailbreak apps. If we encounter one, the device is jailbroken.
    for(int i = 0; jailbreak_apps[i] != NULL; ++i)
    {
        if([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_apps[i]]])
        {
            //NSLog(@"isjailbroken: %s", jailbreak_apps[i]);
            return YES;
        }
    }
    
    // TODO: Add more checks? This is an arms-race we're bound to lose.
    
    return NO;
}


@end
