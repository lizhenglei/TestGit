//
//  shahaiKeyBoard.h
//  shahaiKeyBoard
//
//  Created by 付希凯 on 14-11-5.
//  Copyright (c) 2014年 fxk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShaHaiView.h"
#import "keyboardencrypt.h"

@interface shahaiKeyBoard : NSObject
-(void)show1:(ShaHaiView*)view;
-(void)show2:(ShaHaiView*)view;
+(void)dissMiss:(ShaHaiView*)view;
+(void)dissMisskeyboard:(ShaHaiView*)view;
-(void)dissMissSystemKeyboard;
-(void)addTextfield:(NSArray *)textfieldArr;

+(NSArray *)getPasswordAndLength;
- (void)setDefaultValue:(NSString *)value;

-(void)initShahaiKeboard;
@property (nonatomic,assign) BOOL DeveloperMode;//是否显示密码
//外部点击确定

@property (nonatomic, assign) BOOL needHighlighted;
@property (copy,nonatomic)ShaHaiView * myKeyboardView;

//@property (nonatomic,assign)BOOL keboardType;
@property (nonatomic,assign)int  maxLen;
@property(nonatomic,assign)int  minLen;
@property (nonatomic,assign) BOOL randomLetter;
@property (nonatomic,assign) BOOL randomNumber;
@property (nonatomic,assign) BOOL randomSpecial;

//输⼊入的值是否需要加密
@property (nonatomic,copy) NSString * time;
@property (nonatomic, assign) BOOL encrypt;
@property (nonatomic,retain)NSMutableArray * arr;
@property(nonatomic,assign)KeyBoardType keyboardtyp;
@property(nonatomic,assign)showStyle showStyle;
@end
