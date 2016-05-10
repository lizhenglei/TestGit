//
//  LWYTextField.h
//  MobileClient
//
//  Created by 李文友 on 14-4-8.
//  Copyright (c) 2014年 pro. All rights reserved.
//

//NSString * regex = @"^[A-Za-z0-9]{9,15}$";
//NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//BOOL isMatch = [pred evaluateWithObject:txtfldPhoneNumber.text];

#import <UIKit/UIKit.h>
typedef enum
{
    LWYTextFieldType_None,
    LWYTextFieldType_IDCard,
    LWYTextFieldType_Email,
    LWYTextFieldType_UserName,
    LWYTextFieldType_Login,
    LWYTextFieldType_Phone,
    LWYTextFieldType_IDNum
    
}LWYTextFieldType;


@class LWYTextField;
@protocol LWYPickerViewDelegate <NSObject>

@optional
-(void) myPickerView:(LWYTextField *)pickerView DidSlecetedAtRow:(int) row;

@end

@protocol LWYDoneDelegate <NSObject>

@optional
-(void)LWYDoneClick;

@end


@interface LWYTextField : UITextField<UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate>
@property(nonatomic,assign)BOOL MustInput;
@property(nonatomic,strong) NSString *checkProperty;
@property(nonatomic,strong) NSMutableArray *pickerDataMArray;
@property(nonatomic,assign) id<LWYPickerViewDelegate> pickerViewDelegate;
@property(nonatomic,retain) UIPickerView *pickerView;
@property(nonatomic,retain) UIDatePicker *datePicer;
@property (nonatomic) LWYTextFieldType lwyType;


- (id)initWithFrame:(CGRect)frame
        placeholder:(NSString *) placeholder;
- (BOOL) validateTextFormat;
- (BOOL) textLengthEqualZero;
@end

@interface LWYTextField (datePickerCreation)
- (NSDate *)getThreeMonthBeforeDate;
-(id) initDatePicerViewWithFrame:(CGRect) frame beginDate:(BOOL)isBegin;
-(id) initDatePicerViewWithFrame:(CGRect) frame andString:(NSString *)str;
+(BOOL)pickerChanged:(LWYTextField*)BeginDate End:(LWYTextField*)EndDate;//判断日期间隔三个月
+(BOOL)pickerChangedOne:(LWYTextField*)BeginDate End:(LWYTextField*)EndDate;//判断日期间隔一个月
-(id) initDatePicerViewWithFrame:(CGRect) frame CDate:(BOOL)isCDate;

-(id) initOneMouthDatePicerViewWithFrame:(CGRect) frame beginDate:(BOOL)isBegin;
- (NSDate *)getOneMonthBeforeDate;
+ (NSDate *)getOneMonthBeforeDate;
-(id) initOneMonthEnDDatePicerViewWithFrame:(CGRect) frame;
@end



@interface LWYTextField (pickerCreation)

-(id) initPicerViewWithFrame:(CGRect) frame picerDataArray:(NSMutableArray *) dataArray;

@end