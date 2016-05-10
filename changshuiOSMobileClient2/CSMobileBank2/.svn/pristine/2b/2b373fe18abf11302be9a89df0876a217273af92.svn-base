//
//  Communication.h
//  Communication
//
//  Created by Yuxiang on 13-6-9.
//  Copyright (c) 2013年 中关村. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Config.h"
#import "Context.h"
typedef void (^RetrunDataBlock)(NSDictionary *data);
/*
 *  环境设置，缺省值为Product
 */
typedef enum {
    Product = 0,
    Test,
    Development
} WorkMode;

#define IsPrintfUserInfo YES


@protocol CommunicationDelegate <NSObject>

/*
 *  服务端返回数据的回调方法，data为服务端返回的数据，action为对应的actionName
 *  如果返回的数据中包含_RejCode字段且为444444，则相应的errmsg字段为错误信息（http错误信息）。否则都为服务端返回的数据。
 *  服务端返回的数据若含字段_RejCode且为000000则为正确的返回数据。
 */

-(void)getReturnDataFromServer:(id )data withActionName:(NSString*)action;

@end


@interface Communication : NSObject
{
    
}

@property(nonatomic,assign)id<CommunicationDelegate> delegate;

//初始化方法
-(id)init;
/*
 *  设置环境，默认为生产环境。
 */

-(void)getWorkModeState:(WorkMode)mode;
/*
 *  url格式：url=@"http://192.168.0.1:8080/pweb",如果为生产环境，url==nil，其他情况需要url
 *  actionName例如：login.do
 *  json一般为字典类型或者为nil
 *  PostToServerStream获取数据流的时候使用
 */

-(void)PostToServer:(id)json  actionName:(NSString*)action postUrl:(NSString*)url;
-(void)PostToServerStream:(id)json actionName:(NSString*)action postUrl:(NSString*)url;

//WEB模块 通讯接口
-(void)PostToServer:(id)json  actionName:(NSString*)action method:(NSString*)method;
-(void)PostToServer:(id)json  actionName:(NSString*)action method:(NSString*)method returnBlock:(RetrunDataBlock)_returnData;
//通讯取消





@end




