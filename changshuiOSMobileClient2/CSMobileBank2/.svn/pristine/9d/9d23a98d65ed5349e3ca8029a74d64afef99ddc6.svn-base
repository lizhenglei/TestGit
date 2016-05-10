//
//  ShaHaiView.h
//  fxk
//
//  Created by M T on 14-6-13.
//  Copyright (c) 2014年 李强. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
typedef enum KeyBoardType{
    KeyBoardTypeNone = 0,
    KeyBoardTypeNumber ,//纯数字键盘
    KeyBoardTypeMoney ,//⾦金额键盘,⼿手机
    KeyBoardTypeLetter,
    KeyBoardTypeSpecial,
    keyBoardTypeLetterAndNumber
    
} KeyBoardType;

typedef enum showStyle{
    showStyleLetter= 0,
    showStyleNumber,
} showStyle;

typedef void(^keyClickBlock)(NSInteger length, NSString *value);
typedef void(^keyCancleBlock)(NSInteger length, NSString *value);
typedef void(^keyReturnBlock)(NSInteger length, NSString *value);
@protocol ShaHaiViewDelegate <NSObject>

-(void)password:(NSString*)str;
-(void)cancle;
-(void)btndelete:(BOOL)islong;
- (void)retunResult:(NSDictionary *)dic;
-(void)backViewalpha:(BOOL)alpha;
@end

@interface ShaHaiView : UIView<AVAudioPlayerDelegate>
{
    AVAudioPlayer * _player;
    keyClickBlock _cilckBlock;
    keyCancleBlock _cancleBlock;
    keyReturnBlock _returnBlock;
    NSMutableString  * pwdBufMuStr;
    NSMutableString  * starBufs;
    NSString * TestUserName;
    NSString * TestBind;
    NSString * client_key;
    NSString * TestTime;
    NSMutableString  * timeStr;
    NSNotificationCenter *center;
    
    NSMutableString * maxLen;
    NSMutableString * minLen;
    
    
    
    
    UIButton * char_btn;
    
    
    
    UIButton * pun_btn;
    
    UIButton * num_btn;
    UIButton * changepunbtn;
    UIButton * changenumberbtn;
    UIButton * changecharbtn;
    
    
    UIButton * _punbutn;
    UIButton * _numbtn;
    //进入view界面
    
    UIView * _lowView;
    UIView * _bigView;
    UIView * _numView;
    UIView * _punView;
    NSMutableDictionary *_dic;
    NSMutableDictionary *_dic1;
    NSMutableArray * _array;
    UIView *inputview;
    
    //  大小写切换按键
    BOOL cap ;
    
    //  弹出效果
    BOOL show;
    
    //  输入框
    UITextField*passfield;
    
    //
    //    UITextField*inputfield;
    
    
@private
    
    NSArray * SH_Arr;
    
}

-(void)cilck:(keyClickBlock)intext;
-(void)cancle:(keyCancleBlock)intext;
-(void)returnKey:(keyReturnBlock)intext;
-(void)jiami;
-(void)initKeyboard;


- (id)initWithFrame:(CGRect)frame size:(float)x keyBoardStyle:(BOOL)style isRandomLetter:(BOOL)letter isRandomNumber:(BOOL)number isRandomSpecial:(BOOL)special isEncrypt:(BOOL)isEncrypt maxLen:(int)max minLen:(int)min Highlighted:(BOOL)needHighlighted Time:(NSString *)time tp:(KeyBoardType)tp style:(showStyle)showstyle;
+(NSArray*)passwordAndoriginallength:(NSArray*)array;
+(UIColor *)colorWithR:(NSInteger)r G:(NSInteger)g B:(NSInteger)b alpha:(CGFloat)alpha;
@property (nonatomic,assign)id<ShaHaiViewDelegate>delegate;
@property (nonatomic,copy)UITextField * inputfield;
@property (nonatomic, assign) BOOL isHighlighted;
@property (nonatomic,assign) BOOL randomLetter;
@property (nonatomic,assign) BOOL randomNumber;
@property (nonatomic,assign) BOOL randomSpecial;
@property (nonatomic,copy)NSString * gold; //当前金额
@property (nonatomic,copy)NSString * password; //当前密码
//输⼊入的值是否需要加密
@property (nonatomic, assign) BOOL encrypt;
@property (nonatomic, assign) KeyBoardType type;
@property (nonatomic, assign) showStyle showStyle;
//整数部分⻓长度,只针对⾦金额键盘,默认是10
@property (nonatomic,assign) NSString *integer; //⼩小数部分⻓长度,只针对⾦金额键盘,默认是2
@property (nonatomic,assign) NSString *decimal;
@property (nonatomic,assign) BOOL dio;
@property (nonatomic,assign) float width;
@property (nonatomic,assign) BOOL moneybtn;
@property (nonatomic,assign) BOOL dioBefor;
@property (nonatomic,assign) BOOL dioLatter;
@property (nonatomic,retain)NSString * time;
@end
