//
//  CSIITextField.h
//  SDPocProject
//
//  Created by Yuxiang on 13-3-2.
//  Copyright (c) 2013年 liuwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSIIUIToolbar.h"
//#import "CSIIUIToolbarDelegate.h"
#import "CSIISuperViewController.h"
#import "CSIIDataAnalysis.h"
@interface CSIITextField : UITextField<UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate>{
    CSIIUIToolbar *textFieldToolbar;
    UIPickerView *inputPickerView;
    UIDatePicker *inputDatePickerView;
    NSMutableArray *inputPickerData;
    NSDictionary *configData;
    NSMutableArray *returnDataArray;
    NSMutableDictionary *returnData;
    NSDateFormatter *dateFormatter;
    NSDate *date;
    NSString *value;
    NSInteger index;
    BOOL isRemarkText;
    BOOL isPayeeBookText;
    
    CGRect beginFrame;
    NSMutableArray *pickerViewObjectArr;
    NSInteger currentIndex;
    
    NSArray *accountsPP;
}
@property (nonatomic, assign)CGRect beginFrame;
@property (nonatomic, assign)NSInteger currentIndex;
@property (nonatomic, assign)NSInteger index;
@property (nonatomic, assign)BOOL isRemarkText;
@property (nonatomic, assign)BOOL isPayeeBookText;

@property (nonatomic, retain) NSMutableArray *pickerViewObjectArr;
@property (nonatomic, retain) CSIIUIToolbar *textFieldToolbar;
@property (nonatomic, retain) UIPickerView *inputPickerView;
@property (nonatomic, retain) UIDatePicker *inputDatePickerView;
@property (nonatomic, copy) NSString *value;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, retain , setter=setInputPickerData:) NSMutableArray *inputPickerData;
@property (nonatomic, retain) NSDictionary *configData;
@property (nonatomic, retain) NSMutableArray *returnDataArray;
@property (nonatomic, retain) NSMutableDictionary *returnData;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;



-(id)initWithAccount:(id)delegateParam pickerData:(NSDictionary*)pickerData;
-(id)initWithAccount:(id)delegateParam frame:(CGRect)frame pickerData:(NSDictionary*)pickerData;
-(id)initWithDate:(CGRect)frame pickerData:(NSDictionary*)pickerData;
-(id)initWithDate:(NSDictionary*)pickerData;
-(id)initWithProvinces:(id)delegateParam frame:(CGRect)frame pickerData:(NSDictionary*)pickerData;

-(id)initWithPicker:(CGRect)frame pickerData:(NSMutableArray*)pickerData;

@end
