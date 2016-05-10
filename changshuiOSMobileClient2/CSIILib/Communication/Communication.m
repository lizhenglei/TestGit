
//
//  Communication.m
//  Communication
//
//  Created by Yuxiang on 13-6-9.
//  Copyright (c) 2013年 中关村. All rights reserved.
//

#import "Communication.h"
#import "MKNetworkEngine.h"
#import "MKNetworkOperation.h"
#import "CommonFunc.h"


@interface Communication ()

@property(nonatomic,retain)NSString* returnString;
@property(nonatomic,retain)NSDictionary* returnDictionary;
@property(nonatomic,retain)NSData* returnData;
@property(nonatomic,retain)NSString* errorMessage;
@property(nonatomic,assign)WorkMode workMode;

@end


@implementation Communication
@synthesize delegate;
@synthesize returnData;
@synthesize returnString;
@synthesize errorMessage;
@synthesize workMode;



/*
 
 Could not connect to the server.
 The request timed out.
 The network connection was lost.
 */

-(NSString *)getErrorMessage:(NSString *)englishErrorMessage{
    if ([englishErrorMessage isEqualToString:@"Could not connect to the server."]) {
        return @"网络连接失败，请检查网络连接!";
    }
    else if([englishErrorMessage isEqualToString:@"The request timed out."]){
        return @"请求超时！";
    }
    else if([englishErrorMessage isEqualToString:@"未能连接到服务器。"]){
        return @"未能连接到服务器。";
    }
    else if([englishErrorMessage isEqualToString:@"The network connection was lost."]){
        return @"网络丢失,交易状态不明,请查询该交易状态！";
    }
    else if([englishErrorMessage rangeOfString:@"400"].location!=NSNotFound){
        return @"400, Bad Request！";
    }
    else if([englishErrorMessage rangeOfString:@"401"].location!=NSNotFound){
        return @"401, Unauthorized！";
    }
    else if([englishErrorMessage rangeOfString:@"402"].location!=NSNotFound){
        return @"402, Payment Required！";
    }
    else if([englishErrorMessage rangeOfString:@"403"].location!=NSNotFound){
        return @"403, Forbidden!";
    }
    else if([englishErrorMessage rangeOfString:@"404"].location!=NSNotFound){
        return @"404, 链接服务器失败!";
    }
    else if([englishErrorMessage rangeOfString:@"405"].location!=NSNotFound){
        return @"405, Method NotAllowed！";
    }
    else if([englishErrorMessage rangeOfString:@"406"].location!=NSNotFound){
        return @"406, Not Acceptable！";
    }
    else if([englishErrorMessage rangeOfString:@"407"].location!=NSNotFound){
        return @"407, Proxy AuthenticationRequired！";
    }
    else if([englishErrorMessage rangeOfString:@"408"].location!=NSNotFound){
        return @"408, Request Time-out！";
    }
    else if([englishErrorMessage rangeOfString:@"409"].location!=NSNotFound){
        return @"409, Conflict！";
    }
    else if([englishErrorMessage rangeOfString:@"410"].location!=NSNotFound){
        return @"410, Gone！";
    }
    else if([englishErrorMessage rangeOfString:@"411"].location!=NSNotFound){
        return @"411, Length Required！";
    }
    else if([englishErrorMessage rangeOfString:@"412"].location!=NSNotFound){
        return @"412, PreconditionFailed！";
    }
    else if([englishErrorMessage rangeOfString:@"413"].location!=NSNotFound){
        return @"413, PreconditionFailed！";
    }
    else if([englishErrorMessage rangeOfString:@"414"].location!=NSNotFound){
        return @"414, Request-URI TooLarge！";
    }
    else if([englishErrorMessage rangeOfString:@"415"].location!=NSNotFound){
        return @"415, Unsupported MediaType！";
    }
    else if([englishErrorMessage rangeOfString:@"416"].location!=NSNotFound){
        return @"416, Requested range notsatisfiable！";
    }
    else if([englishErrorMessage rangeOfString:@"417"].location!=NSNotFound){
        return @"417, ExpectationFailed！";
    }
    else if([englishErrorMessage rangeOfString:@"500"].location!=NSNotFound){
        return @"500, Internal ServerError！";
    }
    else if([englishErrorMessage rangeOfString:@"501"].location!=NSNotFound){
        return @"501, Not Implemented！";
    }
    else if([englishErrorMessage rangeOfString:@"502"].location!=NSNotFound){
        return @"502, Bad Gateway！";
    }
    else if([englishErrorMessage rangeOfString:@"503"].location!=NSNotFound){
        return @"503, ServiceUnavailable！";
    }
    else if([englishErrorMessage rangeOfString:@"504"].location!=NSNotFound){
        return @"504, 网关超时!";
    }
    else if([englishErrorMessage rangeOfString:@"505"].location!=NSNotFound){
        return @"505, HTTP Version notsupported！";
    }
    else if([englishErrorMessage rangeOfString:@"timed out"].location!=NSNotFound)
    {
        return @"超时！";
    }
    else if([englishErrorMessage rangeOfString:@"请求超时。"].location!=NSNotFound)
    {
        return @"请求超时！";
    }else{
        
        return @"网络异常，如正在进行交易，请稍后核实交易状态，避免重复交易";//@“未知错误”
        
    }
    
    return englishErrorMessage;
}


//通讯模块初始化，默认的为生产环境
-(id)init{
    self=[super init];
    if (self) {
        self.workMode=Product;
        
    }
    return self;
}


-(BOOL)judgeSSLStateByUrl:(NSString*)url{
    
    if (url) {
        if ([url hasPrefix:@"http:"]) {
            return NO;
        }
        if ([url hasPrefix:@"https:"]) {
            return YES;
        }
    }
    return NO;
}

-(void)getWorkModeState:(WorkMode)mode;
{
    self.workMode=mode;
}


-(NSString *)getHostName{
    return [NSString stringWithFormat:@"%@/%@",[Context sharedInstance].server_backend_name,SERVER_BACKEND_CONTEXT];
    
}

-(NSString *)getPostUrl:(NSString *)url{
    if (!url) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"当前为测试环境，请检查url的值是否为空" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }else if ([url hasPrefix:@"http://"]|| [url hasPrefix:@"https://"]) {
        if ([self judgeSSLStateByUrl:url]==NO ) {
            url=[url substringFromIndex:7];
        }else {
            url=[url substringFromIndex:8];
        }
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"url格式有误，请检查url格式" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
    }
    return url;
}

-(void)PostToServer:(id)json  actionName:(NSString*)action postUrl:(NSString*)url;
{
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(returndatafromhacker:) name:@"succeed" object:nil];
    //
    //    h=[[hacker alloc]init];
    //    [h PostToServer:json actionName:action postUrl:url];
    //
    //    return;
    
    DebugLog(@"PostUrl : %@ Action : %@ Params : %@",url,action,json);
    
#ifdef GET_DATA_FROM_LOCAL_FILE
    /////////////////内部挡板,从本地文件读取数据,不走服务器//////////////////
    //    if ([(NSString*)[[NSUserDefaults standardUserDefaults]stringForKey:@"SERVER_BACKEND_NAME"] hasPrefix: @"127.0.0.1"])
    {
        [self performSelector:@selector(getDataFromLocalFile_1:) withObject:action afterDelay:0];
        
        return;
    }
    //////////////////////////////////////////////
#endif
    
    MKNetworkEngine *engin=nil;
    MKNetworkOperation *operation=nil;
    
    
    if (self.workMode==Product) {
        url = [self getHostName];
        engin=[[MKNetworkEngine alloc]initWithHostName:[self getHostName]];
        operation=[engin operationWithPath:action params:json httpMethod:@"GET" ssl:[Context sharedInstance].server_backend_ssl];
        
    }else{
        engin=[[MKNetworkEngine alloc]initWithHostName:[self getPostUrl:url]];
        operation=[engin operationWithPath:action params:json httpMethod:@"GET" ssl:[self judgeSSLStateByUrl:url]];
    }
    
    DebugLog(@"##PostToServer:actionName:postUrl:\n httpMethod:GET \n PostUrl : %@ \n Action : %@ \n Params : %@",url,action,json);
    
    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
#ifdef TRANS_DATA_WRITE_TO_FILE
        [self writeToDocumentFolder:action data:[completedOperation responseString]];
#endif
        self.returnDictionary = [completedOperation responseJSON];
        if (self.returnDictionary) {
            DebugLog(@"returndic = %@",self.returnDictionary);
            DebugLog(@"通讯模块接受数据向委托发送数据（字典）");
            [self.delegate getReturnDataFromServer:self.returnDictionary withActionName:action];
        }
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        DebugLog(@"[error localizedDescription] : %@",[error localizedDescription]);
        
        NSMutableDictionary* sendDic = [[NSMutableDictionary alloc]init];
        [sendDic setObject:@"999999" forKey:@"_RejCode"];
        [sendDic setObject:[self getErrorMessage:[error localizedDescription]] forKey:@"jsonError"];
        
        [self.delegate getReturnDataFromServer:sendDic withActionName:action];
        
        
    }];
    [engin enqueueOperation:operation];
    
}
-(void)PostToServer:(id)json  actionName:(NSString*)action method:(NSString*)method returnBlock:(RetrunDataBlock)_returnData
{
    DebugLog(@"method : %@ \nAction : %@ \nParams : %@",method,action,json);
    
//    //菜单项九宫格都是从本地的CheckVersion.do文件中取，把走网络层拦截掉
//    if ([action isEqualToString:@"CheckVersion.do"] || [action isEqualToString:@"CheckVersion3.do"]) {
//        
//        //        [self performSelector:@selector(getDataFromLocalFile_1:) withObject:action afterDelay:0];     不调用方法   改成下面的
//        [self getDataFromLocalFile_1:action];
//        return;
//    }
    
    if ([action hasSuffix:@"html"]) {
        [self performSelector:@selector(getDataFromLocalFile_2:) withObject:action afterDelay:0.01];
        return;
    }
#ifdef GET_DATA_FROM_LOCAL_FILE
    /////////////////内部挡板,从本地文件读取数据,不走服务器//////////////////
    //    if ([(NSString*)[[NSUserDefaults standardUserDefaults]stringForKey:@"SERVER_BACKEND_NAME"] hasPrefix: @"127.0.0.1"])
    {
        if([action rangeOfString:@".do"].length != 0)
        {
            //交易数据
            [self performSelector:@selector(getDataFromLocalFile_1:) withObject:action afterDelay:0];
            
        }else{
            
            //网页代码string
            [self performSelector:@selector(getDataFromLocalFile_2:) withObject:action afterDelay:0.01];
        }
        
        return;
    }
    //////////////////////////////////////////////
#endif
    
    MKNetworkEngine *engin=nil;
    MKNetworkOperation *operation=nil;
    
    if (self.workMode==Product) {
        DebugLog(@"workMode = Product --- > ");
        engin=[[MKNetworkEngine alloc]initWithHostName:[self getHostName]];
        operation=[engin operationWithPath:action params:json httpMethod:method ssl:[Context sharedInstance].server_backend_ssl];
    }else{
        DebugLog(@"workMode = Test---->");
        engin=[[MKNetworkEngine alloc]initWithHostName:[self getHostName]];
        operation=[engin operationWithPath:action params:json httpMethod:method ssl:NO];
    }
    
    DebugLog(@"##PostToServer:actionName:method:\n httpMethod:%@ \n PostUrl : %@ \n Action : %@ \n Params : %@",method,[self getHostName],action,json);
    
    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        //DebugLog(@"responseString : %@",[completedOperation responseString]);
        if([action rangeOfString:@".do"].length != 0)
        {
#ifdef TRANS_DATA_WRITE_TO_FILE
            [self writeToDocumentFolder:action data:[completedOperation responseString]];
#endif

            {
                self.returnDictionary = [completedOperation responseJSON];
                
            }
            
            if (self.returnDictionary) {
                //DebugLog(@"returndic = %@",self.returnDictionary);
                DebugLog(@"通讯模块接受数据向委托发送数据.do（字典,数组）");
                _returnData(self.returnDictionary);
            }
        }
        else //if ([method isEqualToString:@"GET"])
        {
            //网页html代码string
            self.returnDictionary = [NSDictionary dictionaryWithObjectsAndKeys:completedOperation.responseString,@"WebData",[ NSNumber numberWithInteger:[completedOperation HTTPStatusCode] ],@"httpStatus",nil];
            DebugLog(@"通讯模块接受数据向委托发送.html代码 .json数据）");
            _returnData(self.returnDictionary);
        }
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        DebugLog(@"[error localizedDescription] : %@",[error localizedDescription]);
        NSMutableDictionary* sendDic = [[NSMutableDictionary alloc]init];
        [sendDic setObject:[self getErrorMessage:[error localizedDescription]] forKey:@"jsonError"];
        [sendDic setObject:@"999999" forKey:@"_RejCode"];
        _returnData(sendDic);        
        
    }];
    [engin enqueueOperation:operation];
    
}

-(void)PostToServer:(id)json  actionName:(NSString*)action method:(NSString*)method
{
    if (IsPrintfUserInfo) {
        DebugLog(@"method : %@ \nAction : %@ \nParams : %@",method,action,json);
    }
    
    //菜单项九宫格都是从本地的CheckVersion.do文件中取，把走网络层拦截掉
    if ([action isEqualToString:@"CheckVersion.do"] || [action isEqualToString:@"CheckVersion3.do"]) {
        
//        [self performSelector:@selector(getDataFromLocalFile_1:) withObject:action afterDelay:0];     不调用方法   改成下面的
        [self getDataFromLocalFile_1:action];
        return;
    }
    
    /*
     //从本地取页面打开下面这个方法
     if ([action hasSuffix:@"html"]) {
     [self performSelector:@selector(getDataFromLocalFile_2:) withObject:action afterDelay:0.01];
     return;
     }
     */
    
#ifdef GET_DATA_FROM_LOCAL_FILE
    /////////////////内部挡板,从本地文件读取数据,不走服务器//////////////////
    //    if ([(NSString*)[[NSUserDefaults standardUserDefaults]stringForKey:@"SERVER_BACKEND_NAME"] hasPrefix: @"127.0.0.1"])
    {
        if([action rangeOfString:@".do"].length != 0)
        {
            //交易数据
            [self performSelector:@selector(getDataFromLocalFile_1:) withObject:action afterDelay:0];
            
        }else{
            
            //网页代码string
            [self performSelector:@selector(getDataFromLocalFile_2:) withObject:action afterDelay:0.01];
        }
        
        return;
    }
    //////////////////////////////////////////////
#endif
    
    MKNetworkEngine *engin=nil;
    MKNetworkOperation *operation=nil;
    
    if (self.workMode==Product) {
        DebugLog(@"workMode = Product --- > ");
        engin=[[MKNetworkEngine alloc]initWithHostName:[self getHostName]];
        operation=[engin operationWithPath:action params:json httpMethod:method ssl:[Context sharedInstance].server_backend_ssl];
    }else{
        DebugLog(@"workMode = Test---->");
        engin=[[MKNetworkEngine alloc]initWithHostName:[self getHostName]];
        operation=[engin operationWithPath:action params:json httpMethod:method ssl:NO];
    }
    
    if (IsPrintfUserInfo) {
        DebugLog(@"##PostToServer:actionName:method:\n httpMethod:%@ \n PostUrl : %@ \n Action : %@ \n Params : %@",method,[self getHostName],action,json);
    }
    
    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
        //DebugLog(@"responseString : %@",[completedOperation responseString]);
        if([action rangeOfString:@".do"].length != 0)
        {
#ifdef TRANS_DATA_WRITE_TO_FILE
            [self writeToDocumentFolder:action data:[completedOperation responseString]];
#endif
            // 交易数据
            //            if ([[[UIDevice currentDevice] systemVersion]intValue]<5) {
            //                self.returnDictionary = [[completedOperation responseString]objectFromJSONString];
            //            }
            //            else
            
//#warning yuxiang--Vx页面上获取图形验证码时候返回base64
            if ([action rangeOfString:@"GenTokenImg.do"].length!=0) {

                [self.delegate getReturnDataFromServer:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc base64EncodedStringFrom:[completedOperation responseData]],@"imgKey", nil] withActionName:action];
            }
            else{
                self.returnDictionary = [completedOperation responseJSON];
            }
            
            if (self.returnDictionary) {
                //DebugLog(@"returndic = %@",self.returnDictionary);
                DebugLog(@"通讯模块接受数据向委托发送数据.do（字典,数组）");
                [self.delegate getReturnDataFromServer:self.returnDictionary withActionName:action];
            }
        }
        else //if ([method isEqualToString:@"GET"])
        {
            //网页html代码string
            self.returnDictionary = [NSDictionary dictionaryWithObjectsAndKeys:completedOperation.responseString,@"WebData",[ NSNumber numberWithInteger:[completedOperation HTTPStatusCode] ],@"httpStatus",nil];
            //DebugLog(@"responseString = %@",completedOperation.responseString);
            DebugLog(@"通讯模块接受数据向委托发送.html代码 .json数据）");
            [self.delegate getReturnDataFromServer:self.returnDictionary withActionName:action];
        }
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        DebugLog(@"[error localizedDescription] : %@",[error localizedDescription]);
        NSMutableDictionary* sendDic = [[NSMutableDictionary alloc]init];
        [sendDic setObject:[self getErrorMessage:[error localizedDescription]] forKey:@"jsonError"];
        [sendDic setObject:@"999999" forKey:@"_RejCode"];
        [self.delegate getReturnDataFromServer:sendDic withActionName:action];
        
        
    }];
    [engin enqueueOperation:operation];
    
    
}


-(void)PostToServerStream:(id)json actionName:(NSString*)action postUrl:(NSString*)url;
{
    //    h=[[hacker alloc]init];
    //    [h PostToServer:json actionName:action postUrl:url];
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(returndatafromhacker:) name:@"succeed" object:nil];
    //    return;
    
    DebugLog(@"PostUrl : %@ Action : %@ Params : %@",url,action,json);
    
#ifdef GET_DATA_FROM_LOCAL_FILE
    /////////////////内部挡板,从本地文件读取数据,不走服务器//////////////////
    //    if ([(NSString*)[[NSUserDefaults standardUserDefaults]stringForKey:@"SERVER_BACKEND_NAME"] hasPrefix: @"127.0.0.1"])
    {
        [self performSelector:@selector(getDataFromLocalFile_3:) withObject:action afterDelay:0];
        
        return;
    }
    //////////////////////////////////////////////
#endif
    
    MKNetworkEngine *engin=nil;
    MKNetworkOperation *operation=nil;
    
    if (self.workMode==Product) {
        engin=[[MKNetworkEngine alloc]initWithHostName:[self getHostName]];
        operation=[engin operationWithPath:action params:json httpMethod:@"GET" ssl:[Context sharedInstance].server_backend_ssl];
    }else{
        engin=[[MKNetworkEngine alloc]initWithHostName:[self getPostUrl:url]];
        operation=[engin operationWithPath:action params:json httpMethod:@"GET" ssl:[self judgeSSLStateByUrl:url]];
    }
    
    [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
#ifdef TRANS_DATA_WRITE_TO_FILE
        [self writeToDocumentFolder:action data:[completedOperation responseData]];
#endif
        self.returnData =   [completedOperation responseData];
        if (self.returnData) {
            DebugLog(@"通讯模块接受数据向委托发送数据（数据流）");
            [self.delegate getReturnDataFromServer:self.returnData withActionName:action];
        }
        
    } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
        DebugLog(@"[error localizedDescription] : %@",[error localizedDescription]);
        
        NSMutableDictionary* sendDic = [[NSMutableDictionary alloc]init];
        [sendDic setObject:[self getErrorMessage:[error localizedDescription]] forKey:@"jsonError"];
        [sendDic setObject:@"999999" forKey:@"_RejCode"];
        [self.delegate getReturnDataFromServer:sendDic withActionName:action];
        
    }];
    [engin enqueueOperation:operation];
    
}

#ifdef TRANS_DATA_WRITE_TO_FILE
- (void)writeToDocumentFolder:(NSString*)actionName data:(id)data
{
    //捕获交易报文，来用于内部挡板,从本地文件读取数据
    
    //保存到Documents目录下的文件中
    NSString *fileName = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",actionName]];
    DebugLog(@"writeToFile:%@",fileName);
    
    // 先删除已经存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:fileName error:nil];
    // 写入文件
    if([data isKindOfClass:[NSString class]])
    {
        [(NSString*)data writeToFile:fileName atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
    else if([data isKindOfClass:[NSData class]])
    {
        [(NSData*)data writeToFile:fileName atomically:YES];
    }
    
}
#endif

//#ifdef GET_DATA_FROM_LOCAL_FILE
-(void)getDataFromLocalFile_1:(NSString*)action
{
    NSString *fileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Web/pweb/%@",action]];
    DebugLog(@"getDataFromLocalFile:%@",fileName);
    
    //交易数据
    NSData *jsonData = [[NSData alloc] initWithContentsOfFile:fileName];
    
    NSError *error = nil;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if(error){
        DebugLog(@"JSON Parsing Error: %@", error);
        [[[UIAlertView alloc]initWithTitle:@"提示" message:@"返回交易数据，JSON解析出错" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil] show];
        return;
    }
    self.returnDictionary = dict;
    
    if (self.returnDictionary) {
        DebugLog(@"returndic = %@",self.returnDictionary);
        DebugLog(@"通讯模块接受数据向委托发送数据（字典）");
        [self.delegate getReturnDataFromServer:self.returnDictionary withActionName:action];
    }
}

-(void)getDataFromLocalFile_2:(NSString*)action
{
    //网页代码string
    NSString *fileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Web/pweb/%@",action]];
    DebugLog(@"getDataFromLocalFile:%@",fileName);
    
    
    //网页html代码string
    self.returnDictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:nil],@"WebData",[ NSNumber numberWithInteger:200 ],@"httpStatus",nil];
    //DebugLog(@"responseString = %@",completedOperation.responseString);
    DebugLog(@"通讯模块接受数据向委托发送.html代码 .json数据）");
    [self.delegate getReturnDataFromServer:self.returnDictionary withActionName:action];
}

-(void)getDataFromLocalFile_3:(NSString*)action
{
    NSString *fileName = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"Web/pweb/%@",action]];
    DebugLog(@"getDataFromLocalFile:%@",fileName);
    
    //图片数据流
    self.returnData =  [[NSData alloc] initWithContentsOfFile:fileName];
    if (self.returnData) {
        DebugLog(@"通讯模块接受数据向委托发送数据（数据流）");
        [self.delegate getReturnDataFromServer:self.returnData withActionName:action];
    }
}
//#endif

@end






