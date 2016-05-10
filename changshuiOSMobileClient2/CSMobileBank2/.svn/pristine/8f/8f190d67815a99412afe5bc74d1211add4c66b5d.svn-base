//
//  MobileBankCommcation.h
//  MobileBankCommcation
//
//  Created by Yuxiang on 13-5-15.
//  Copyright (c) 2013年 中关村. All rights reserved.
//

#import <Foundation/Foundation.h>


/*!
 *  通讯模块，该模块不能被其他模块调用
 *  
 *
 *  该模块负责报文解析，同服务端交互，以及部分错误处理
 *
 *
 *
 */

@protocol MobileBankCommcationDelegate <NSObject>
-(void)getConnectState:(NSString*)state;
-(void)getErrorMessageWithServer:(NSError*)error;
-(void)getReturnDataWithServer:(NSDictionary*)dic;
@end


@interface MobileBankCommcation : NSObject{

}

@property(nonatomic,retain)id<MobileBankCommcationDelegate>delegate;

+(id)jsonAnalysis:(NSString *)string;
+(id)jsonString:(NSDictionary *)dic;

-(void)operationWithHostName:(NSString*)hostName
                      path:(NSString *)path
                    params:(NSDictionary*)body
                httpMethod:(NSString*)method
                       ssl:(BOOL) useSSL;


//url
//path


@end
