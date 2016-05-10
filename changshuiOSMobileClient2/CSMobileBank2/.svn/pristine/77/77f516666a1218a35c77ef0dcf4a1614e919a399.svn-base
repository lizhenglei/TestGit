//
//  CSIITextField.m
//  SDPocProject
//
//  Created by Yuxiang on 13-3-2.
//  Copyright (c) 2013年 liuwang. All rights reserved.
//

#import "CSIITextField.h"

@implementation CSIITextField
@synthesize beginFrame;
@synthesize currentIndex;
@synthesize index;
@synthesize isRemarkText;
@synthesize isPayeeBookText;
@synthesize pickerViewObjectArr;
@synthesize textFieldToolbar;
@synthesize inputPickerView;
@synthesize inputDatePickerView;
@synthesize value;
@synthesize date;
@synthesize inputPickerData;
@synthesize configData;
@synthesize returnDataArray;
@synthesize returnData;
@synthesize dateFormatter;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createTextField];
    }
        return self;
}

-(id)init{
    self = [super init];
    if(self != nil){
        [self createTextField];
    }
    return self;
}


-(void)createTextField;
{
    self.textFieldToolbar = [[CSIIUIToolbar alloc]init];
    self.textFieldToolbar.delegate = self;
    self.inputAccessoryView = self.textFieldToolbar;
    self.returnKeyType=UIReturnKeyDone;
    self.borderStyle = UITextBorderStyleNone;
//    self.keyboardAppearance = UIKeyboardAppearanceAlert;
    self.keyboardType = UIKeyboardTypeDefault;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.placeholder = @"";
    self.background = IPAD ?IMAGE(@"输入框_ipad"):IMAGE(@"输入框");
    self.borderStyle= UITextBorderStyleNone;
    
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.font = [UIFont systemFontOfSize:14];

 
}
-(void)createPicker;
{
    [self addTarget:self action:@selector(onEditingDidBeginAction:) forControlEvents:UIControlEventEditingDidBegin];
    [self addTarget:self action:@selector(onEditingDidEndAction:) forControlEvents:UIControlEventEditingDidEnd];
    self.textFieldToolbar = [[CSIIUIToolbar alloc]init];
    self.textFieldToolbar.delegate = self;
    self.inputAccessoryView = self.textFieldToolbar;
    self.borderStyle = UITextBorderStyleNone;
    self.clearButtonMode=UITextFieldViewModeNever;
    CGRect bounds = [ [ UIScreen mainScreen ] applicationFrame ];
    
    UIPickerView *pickView = nil;
    if(IPHONE)
    {
        pickView = [ [ UIPickerView alloc ] initWithFrame: CGRectMake(0.0, bounds.size.height - 216.0, 0.0, 0.0) ];
    }else
    {
         pickView= [ [ UIPickerView alloc ] initWithFrame: CGRectMake(0.0, bounds.size.height - 264.0, 0.0, 0.0) ];
    }
    self.inputPickerView = pickView;
    self.inputPickerView.delegate = self;
    self.inputPickerView.dataSource = self;
    self.inputPickerView.showsSelectionIndicator = YES;
    self.inputView = self.inputPickerView;
    
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.borderStyle= UITextBorderStyleRoundedRect;
}
-(void)createDatePicker;
{
    self.textFieldToolbar = [[CSIIUIToolbar alloc]init];
    self.textFieldToolbar.delegate = self;
    self.inputAccessoryView = self.textFieldToolbar;
    
    self.clearButtonMode=UITextFieldViewModeNever;
    self.borderStyle = UITextBorderStyleNone;
    self.returnKeyType=UIReturnKeyDone;
    CGRect bounds = [ [ UIScreen mainScreen ] applicationFrame ];
    if(IPHONE)
    {
        self.inputDatePickerView = [[  UIDatePicker alloc ] initWithFrame: CGRectMake(0.0, bounds.size.height - 216.0, 0.0, 0.0) ];
    }else
    {
        self.inputDatePickerView = [[  UIDatePicker alloc ] initWithFrame: CGRectMake(0.0, bounds.size.height - 264.0, 0.0, 0.0) ];
    }
    [self.inputDatePickerView addTarget:self action:@selector(setDateInfo:) forControlEvents:UIControlEventValueChanged];
    self.inputDatePickerView.datePickerMode = UIDatePickerModeDate;
    self.inputView = self.inputDatePickerView;
    ((CSIIUIToolbar*)self.inputAccessoryView).segmentedControl1s.hidden = NO;
    [((UIDatePicker*)self.inputView) sendActionsForControlEvents:UIControlEventValueChanged];
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.borderStyle= UITextBorderStyleRoundedRect;
}
-(void)setDateInfo:(UIDatePicker*)sender;
{
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.date = sender.date;
    self.text = [self.dateFormatter stringFromDate:sender.date];
}
-(void)setToday;
{
    [((UIDatePicker*)self.inputView) setDate:[[NSDate alloc]init] animated:YES];
    [((UIDatePicker*)self.inputView) sendActionsForControlEvents:UIControlEventValueChanged];
}



//-(void)onEditingDidBeginAction:(id)sender;
//{
//    if([[self.inputPickerData objectAtIndex:0] count]==0){
//        return;
//    }
//    [((CSIIUIPickerViewObject*)[self.pickerViewObjectArr objectAtIndex:self.currentIndex])startAnimation];
//}
//-(void)onEditingDidEndAction:(id)sender;
//{
//    if([[self.inputPickerData objectAtIndex:0] count]==0){
//        return;
//    }
//    [((CSIIUIPickerViewObject*)[self.pickerViewObjectArr objectAtIndex:self.currentIndex])endAnimation];
//}

-(id)initWithPicker:(CGRect)frame pickerData:(NSMutableArray*)pickerData;
{
    self = [super initWithFrame:frame];
    if(self != nil){
        [self createPicker];
        self.inputPickerData = pickerData;
    }
    self.font = [UIFont systemFontOfSize:14];
    return self;
}

-(id)initWithPicker:(NSMutableArray*)pickerData;
{
    self = [super init];
    if(self != nil){
        [self createPicker];
        self.inputPickerData = pickerData;
    }
    self.font = [UIFont systemFontOfSize:14];
    return self;
}


-(void)setInputPickerData:(NSMutableArray*)data;
{
    if (inputPickerData != data) {
        self.pickerViewObjectArr = [[NSMutableArray alloc]init];
        self.pickerViewObjectArr = data;
//        for (int i =0; i<[[data objectAtIndex:0] count]; i++) {
//            CSIIUIPickerViewObject *pickerViewObject = [[CSIIUIPickerViewObject alloc]initWithTitle:[[data objectAtIndex:0] objectAtIndex:i]];
//            [self.pickerViewObjectArr addObject:pickerViewObject];
//        }
    }
    self.currentIndex=0;
}
//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view;
//{
//    if([[self.inputPickerData objectAtIndex:0] count]==0){
//        return nil;
//    }
//    return  [self.pickerViewObjectArr objectAtIndex:row];
//}
- (void)pickerView:(NSInteger)row inComponent:(NSInteger)component;
{
    self.inputPickerData=(NSMutableArray *)accountsPP;
    
    if([[self.inputPickerData objectAtIndex:0] count]==0){
        self.enabled = NO;
        if ([self.delegate isKindOfClass:[CSIISuperViewController class]]) {
        }
//        else if ([self.delegate isKindOfClass:[CSIIUISuperTableViewController class]]) {
//            [(CSIIUISuperTableViewController*)self.delegate setPickerReturnData:self data:nil];
//        }
        return;
    }else {
        self.enabled = YES;
    }
//    
//    [((CSIIUIPickerViewObject*)[self.pickerViewObjectArr objectAtIndex:self.currentIndex])endAnimation];
//    [((CSIIUIPickerViewObject*)[self.pickerViewObjectArr objectAtIndex:row])startAnimation];
//    self.currentIndex = row;
    
    
    [self.inputPickerView selectRow:row inComponent:component animated:NO];
    self.text = [[self.inputPickerData objectAtIndex:component]objectAtIndex:row];
    self.index = row;
    
    self.returnData = [[NSMutableDictionary alloc]init];
    
    [self.returnData setObject:[[NSNumber alloc]initWithInt:(int)self.index] forKey:@"index"];
    [self.returnData setObject:self.text forKey:@"text"];
    if ([self.returnDataArray count]>0) {
        [self.returnData setObject:[self.returnDataArray objectAtIndex:row] forKey:@"data"];
    }
    if ([self.delegate isKindOfClass:[CSIISuperViewController class]]) {
    }
//    else if ([self.delegate isKindOfClass:[CSIIUISuperTableViewController class]]) {
//        [(CSIIUISuperTableViewController*)self.delegate setPickerReturnData:self data:self.returnData];
//    }
}








-(id)initWithDate:(CGRect)frame pickerData:(NSDictionary*)pickerData;
{
    self = [super initWithFrame:frame];
    if(self != nil){
        self.configData = pickerData;
        [self createDatePicker];
    }
    return self;
}
-(id)initWithDate:(NSDictionary*)pickerData;
{
    self = [super init];
    if(self != nil){
        self.configData = pickerData;
        [self createDatePicker];
    }
    return self;
}


-(id)initWithAccount:(id)delegateParam frame:(CGRect)frame pickerData:(NSDictionary*)pickerData;//
{
    self = [super initWithFrame:frame];
    if(self != nil){
        NSString *path=[[NSBundle mainBundle] pathForResource:@"PayerAcNoList" ofType:@"json"];
        accountsPP = [[NSArray alloc]init];
        accountsPP =[CSIIDataAnalysis initWithArrayPath:path];
        
        self.delegate = delegateParam;
        [self createPicker];
        self.text=[[accountsPP objectAtIndex:0]objectForKey:@"AcNo"];
    }
    return self;
}


#pragma pickerViewDelegge/pickerViewDataSource method

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component;{
    return [[accountsPP objectAtIndex:row]objectForKey:@"AcNo"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
{
//    [self pickerView:row inComponent:component];
    self.text=[[accountsPP objectAtIndex:row]objectForKey:@"AcNo"];

}
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;
{
    return [accountsPP count];
}


-(id)initWithAccount:(id)delegateParam pickerData:(NSDictionary*)pickerData;{
    self = [super init];
    if(self != nil){
        self.delegate = delegateParam;
        [self createPicker];
        self.returnDataArray = [[NSMutableArray alloc]init];
        
    }
    return self;
}

-(id)initWithPayerAcNo:(id)delegateParam frame:(CGRect)frame pickerData:(NSDictionary*)pickerData;
{
    self = [super initWithFrame:frame];
    if(self != nil){
        self.delegate = delegateParam;
        [self createPicker];
        self.returnDataArray = [[NSMutableArray alloc]init];

    }
    return self;
}
-(id)initWithPayerAcNo:(id)delegateParam pickerData:(NSDictionary*)pickerData;
{
    self = [super init];
    if(self != nil){
        self.delegate = delegateParam;
        [self createPicker];
        self.returnDataArray = [[NSMutableArray alloc]init];

    }
    return self;
}

-(id)initWithProvinces:(id)delegateParam frame:(CGRect)frame pickerData:(NSDictionary*)pickerData{
    self = [super initWithFrame:frame];
    if(self != nil){
        self.delegate = delegateParam;
        [self createPicker];
        self.returnDataArray = [[NSMutableArray alloc]init];
    }
    return self;
}

//控制placeHolder的位置
-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x+5, bounds.origin.y, bounds.size.width-5, bounds.size.height);
    return inset;
}
//控制显示文本的位置
-(CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x+5, bounds.origin.y, bounds.size.width-5, bounds.size.height);
    return inset;     
}
//控制编辑文本的位置
-(CGRect)editingRectForBounds:(CGRect)bounds
{   
    CGRect inset = CGRectMake(bounds.origin.x+5, bounds.origin.y, bounds.size.width-5-25, bounds.size.height);
    return inset;
}

@end
