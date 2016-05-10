//
//  CSIICachingURLProtocol.m
//  LibCommcation
//
//  Created by Yuxiang on 13-5-14.
//  Copyright (c) 2013年 中关村. All rights reserved.
//

#import "CSIICachingURLProtocol.h"
#import "MyHTTPURLResponse.h"

@interface CSIICachedData : NSObject<NSCoding>
@property (nonatomic ,readwrite ,strong) NSData *data;
@property (nonatomic ,readwrite ,strong) NSURLResponse *response;
@end

static NSString *const kDataKey = @"data";
static NSString *const kResponseKey = @"response";
static int maskNum;//加载动画显示次数
@implementation CSIICachedData
@synthesize data = data_;
@synthesize response = response_;

-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:[self data] forKey:kDataKey];
    [aCoder encodeObject:[self response] forKey:kResponseKey];
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self != nil) {
        [self setData:[aDecoder decodeObjectForKey:kDataKey]];
        [self setResponse:[aDecoder decodeObjectForKey:kResponseKey]];
    }
    return self;
}

@end


static NSString *CSIICachingURLHeader = @"X-CSIICache";
@interface CSIICachingURLProtocol ()
@property (nonatomic, readwrite, strong) NSURLRequest *request;
@property (nonatomic, readwrite, strong) NSURLConnection *connection;
@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;
- (void)appendData:(NSData *)newData;
@end



@implementation CSIICachingURLProtocol
@synthesize request = request_;
@synthesize connection = connection_;
@synthesize data = data_;
@synthesize response = response_;

+ (BOOL)canInitWithRequest:(NSURLRequest *)request{
//    DebugLog(@"\n URL scheme:%@ \n URL absoluteString:%@ \n URL relativePath:%@ \n HTTPHeaderField:X-CSIICache,value:%@", [[request URL]scheme], [[request URL] absoluteString], [[request URL] relativePath], [request valueForHTTPHeaderField:CSIICachingURLHeader]);  
    
    if (([[[request URL]scheme] isEqualToString:@"http"] || [[[request URL]scheme] isEqualToString:@"https"])
        &&  [request valueForHTTPHeaderField:CSIICachingURLHeader] == nil
        &&  [[[request URL] absoluteString] rangeOfString:@".apple.com"].location == NSNotFound) {
        return YES;
    }
    return  NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    return request;
}

- (id)initWithRequest:(NSURLRequest *)request
       cachedResponse:(NSCachedURLResponse *)cachedResponse
               client:(id <NSURLProtocolClient>)client
{
    NSMutableURLRequest *myRequest = [request mutableCopy];
    [myRequest setValue:@"" forHTTPHeaderField:CSIICachingURLHeader];
    
    NSString *url = [[myRequest URL] absoluteString];
//    DebugLog(@"###initWithRequest ---1: \n%@\n",url);
    
    if([url hasSuffix:@".js"] && [url rangeOfString:@"127.0.0.1:9000/pweb"].location != NSNotFound && [url rangeOfString:@"samples/htmls/"].location != NSNotFound)
    {
        //http://127.0.0.1:9000/pweb/samples/htmls/BankInnerTransfer/BankInnerTransfer.js
        
//        NSString * sUrl = [url stringByReplacingOccurrencesOfString:@"127.0.0.1:9000/pweb" withString:[NSString stringWithFormat:@"%@/%@",[Context sharedInstance].server_backend_name,SERVER_BACKEND_CONTEXT]];
        
        NSString *sUrl = @"";
//        DebugLog(@"###initWithRequest ---2: \n%@\n",sUrl);
        [myRequest setURL:[NSURL URLWithString:sUrl]];
        
        /*
        NSArray *array=[[NSArray alloc]initWithArray:[url componentsSeparatedByString:@"//"]];
        if (array.count==2)
        {
            NSString *httpStr = (NSString *)array[0];
            
            NSMutableArray *array2=[[NSMutableArray alloc]initWithArray:[ array[1] componentsSeparatedByString:@"/"]];
            
            if(array2.count>=3)
            {
                [array2 replaceObjectAtIndex:0 withObject:[Context sharedInstance].server_backend_name];
                [array2 replaceObjectAtIndex:1 withObject:SERVER_BACKEND_CONTEXT];
                
                NSMutableString *urlString=[NSMutableString string];
                [urlString appendString:httpStr];
                [urlString appendString:@"//"];
                for(int i=0; i<array2.count; i++)
                {
                    [urlString appendString:array2[i]];
                    if(i != array2.count-1)
                        [urlString appendString:@"/"];
                }
                
                DebugLog(@"###initWithRequest ---2: \n%@\n",urlString);
                [myRequest setURL:[NSURL URLWithString:urlString]];
            }
            
        }*/
    }
    else if(([url hasSuffix:@".do"] && [url rangeOfString:@"127.0.0.1:9000/pweb"].location != NSNotFound))
    {
        //http://127.0.0.1:9000/pweb/BankGenAcTokenImg.do
        
        NSString *sUrl = @"";
        
//        NSString * sUrl = [url stringByReplacingOccurrencesOfString:@"127.0.0.1:9000/pweb" withString:[NSString stringWithFormat:@"%@/%@",[Context sharedInstance].server_backend_name,SERVER_BACKEND_CONTEXT]];
        
//        DebugLog(@"###initWithRequest ---3: \n%@\n",sUrl);
        [myRequest setURL:[NSURL URLWithString:sUrl]];
        
    }
    else if(([url hasSuffix:@".do"] && [url rangeOfString:@"127.0.0.1:9000"].location != NSNotFound))
    {
        //http://127.0.0.1:9000/pmobile/BankGenAcTokenImg.do
        NSString *sUrl = @"";
//        NSString * sUrl = [url stringByReplacingOccurrencesOfString:@"127.0.0.1:9000" withString:[Context sharedInstance].server_backend_name];
        
//        DebugLog(@"###initWithRequest ---4: \n%@\n",sUrl);
        [myRequest setURL:[NSURL URLWithString:sUrl]];
        
    }
    
    self = [super initWithRequest:myRequest
                   cachedResponse:cachedResponse
                           client:client];
    
    if (self)
    {
        [self setRequest:myRequest];
    }
    return self;
}

- (NSString *)cachePathForRequest:(NSURLRequest *)aRequest{
    NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    return [cachesPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%lx", (unsigned long)[[[aRequest URL] absoluteString] hash]]];
}

- (void)startLoading{
    
    NSBundle * mainBundle = [NSBundle mainBundle];
    NSString * url = [[[self request] URL] absoluteString];
    
    NSLog(@"URL地址===%@",url);
    NSRange tempRang=[url rangeOfString:@"ShowMask"];
    
    //http://127.0.0.1:9000/LocalActions/ShowMask
    if (tempRang.location!=NSNotFound) {
        NSLog(@"当前地址%@",url);
        maskNum++;
        NSLog(@"maskNum当前值==%d",maskNum);
        
    }
    NSArray *array=[[NSArray alloc]initWithArray:[url componentsSeparatedByString:@"/"]];
    NSMutableString *urlString=[NSMutableString string];
    
    if (array.count>2) {
        [urlString appendString:[array objectAtIndex:0]];
        [urlString appendString:@"//"];
        [urlString appendString:[array objectAtIndex:2]];
    }
    
    //去掉scheme和ip，只保留路径部分
    NSString * filePath = [url stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",urlString] withString:@""];
   
    //Process Local Actions
    if([filePath hasPrefix:@"LocalActions/"])
    {
        NSString * actname = [filePath stringByReplacingOccurrencesOfString:@"LocalActions/" withString:@"LocalAction_"];
        NSArray *array=[NSArray array];
        array= [actname componentsSeparatedByString:@"___"];
        if(array.count==1){//不包含三条下划线，正常状态
            if (tempRang.location!=NSNotFound&&maskNum==2){
                maskNum=0;
                //[[NSNotificationCenter defaultCenter] postNotificationName:actname object:nil];
            }
            //else  if(![actname isEqualToString:@"LocalAction_ShowMask"])
            [[NSNotificationCenter defaultCenter] postNotificationName:actname object:nil];
        }else if(array.count==2){//包含三条下划线,一个参数
            
    
            NSString *stringindex=[array objectAtIndex:1];  //userInfo
            actname=[array objectAtIndex:0];                          //NotificationName
            [[NSNotificationCenter defaultCenter] postNotificationName:actname object:nil userInfo:[[NSDictionary alloc]initWithObjectsAndKeys:stringindex,@"index", nil]];
            
        }else if (array.count==3) {//两个参数
            
            NSString *stringindex=[array objectAtIndex:1];
            NSString *stringStart=[array objectAtIndex:2];
            actname=[array objectAtIndex:0];                          //NotificationName
            [[NSNotificationCenter defaultCenter] postNotificationName:actname object:nil userInfo:[[NSDictionary alloc]initWithObjectsAndKeys:stringindex,@"index",stringStart,@"start", nil]];
        }
        
//        DebugLog(@"Posting Notification: %@", actname);
        
        NSData * data = [@"<xml></xml>" dataUsingEncoding:NSStringEncodingConversionAllowLossy];
        NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[[self request] URL] MIMEType:@"text/xml" expectedContentLength:11 textEncodingName:@"UTF-8"];
        
        [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
        [[self client] URLProtocol:self didLoadData:data];
        [[self client] URLProtocolDidFinishLoading:self];
        return;
    }
    
    //保证宏里面的代码有效--即保证页面在加随机码的状态下缓存可以从本地读取。（余翔）
    /*手机银行动态页面截取*/
//    if ([filePath rangeOfString:@"?v"].location!=NSNotFound) {
//        NSRange range;
//        range=[filePath rangeOfString:@"?"];
//        filePath=[filePath substringToIndex:range.location];
//    }
//    if ([filePath rangeOfString:@"?_"].location!=NSNotFound) {
//        NSRange range;
//        range=[filePath rangeOfString:@"?"];
//        filePath=[filePath substringToIndex:range.location];
//    }
    
    NSString * resourcePath = [mainBundle pathForResource:filePath ofType:@"" inDirectory:@"LocalFiles"];
    
    NSString * mimeType = @"application/octet-stream";
    if([url rangeOfString:@".js"].location != NSNotFound)
    {
        mimeType = @"text/javascript";
    }
    else if([url rangeOfString:@".css"].location != NSNotFound){
        mimeType = @"text/css";
    }
    else if([url rangeOfString:@".html"].location != NSNotFound){
        mimeType = @"text/html";
    }
    else if([url rangeOfString:@".txt"].location != NSNotFound){
        mimeType = @"text/plain";
    }
    else if([url rangeOfString:@".xml"].location != NSNotFound){
        mimeType = @"text/xml";
    }
    else if([url rangeOfString:@".ttf"].location != NSNotFound){
        mimeType = @"application/x-font-ttf";
    }
    else if([url rangeOfString:@".png"].location != NSNotFound){
        mimeType = @"image/png";
    }
    else if([url rangeOfString:@".json"].location != NSNotFound){
        mimeType = @"text/plain";
    }
    
    NSData *data;
    
    if (resourcePath == nil ) {
//        DebugLog(@"CACHE: File Not Cached: %@", filePath);
        NSMutableURLRequest *myRequest = [[self request] mutableCopy];
        [myRequest setValue:@"" forHTTPHeaderField:CSIICachingURLHeader];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:myRequest
                                                                    delegate:self];
        [self setConnection:connection];
    }
    else {
//        DebugLog(@"CACHED: %@", filePath);
        data = [NSData dataWithContentsOfFile:resourcePath];
        
        /*5.0以上系统使用NSURLResponse 5.0一下系统使用自定义的MyHTTPURLResponse,二者都是为了加载缓存，加快速度-yuxiang*/
        NSURLResponse *response;
        MyHTTPURLResponse *myResponse;
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0) {
            myResponse = [[MyHTTPURLResponse alloc] initWithURL:[[self request] URL] MIMEType:mimeType expectedContentLength:[data length] textEncodingName:nil];
            [[self client] URLProtocol:self didReceiveResponse:myResponse cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [[self client] URLProtocol:self didLoadData:data];
            [[self client] URLProtocolDidFinishLoading:self];
        }
        else
        {
            response = [[NSHTTPURLResponse alloc] initWithURL:[[self request] URL] statusCode:200 HTTPVersion:@"1.1" headerFields:nil];
            [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [[self client] URLProtocol:self didLoadData:data];
            [[self client] URLProtocolDidFinishLoading:self];
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTTPAccess" object:nil];
}

- (void)stopLoading
{
   [[self connection] cancel];
}

#pragma mark NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [[self client] URLProtocol:self didLoadData:data];
    [self appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [[self client] URLProtocol:self didFailWithError:error];
    [self setConnection:nil];
    [self setData:nil];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [self setResponse:response];
    [[self client] URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [[self client] URLProtocolDidFinishLoading:self];
    [self setConnection:nil];
    [self setData:nil];
}

- (void)appendData:(NSData *)newData;{
    if ([self data] == nil)
    {
        [self setData:[[NSMutableData alloc] initWithData:newData]];
    }
    else
    {
        [[self data] appendData:newData];
    }
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response{
    if (response != nil) {
        [[self client] URLProtocol:self wasRedirectedToRequest:request redirectResponse:response];
    }
    return request;
}

@end

