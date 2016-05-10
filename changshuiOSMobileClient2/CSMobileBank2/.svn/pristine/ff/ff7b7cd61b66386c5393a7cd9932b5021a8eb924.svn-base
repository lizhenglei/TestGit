//
//  LWYTextField.m
//  MobileClient
//
//  Created by 李文友 on 14-4-8.
//  Copyright (c) 2014年 pro. All rights reserved.
//


#import "LWYTextField.h"
#import "CSIIUIToolbar.h"

#define PICKER_RECT_IPHONE CGRectMake(0.0, [[ UIScreen mainScreen ] applicationFrame].size.height - 216.0, 0.0, 0.0)
#define PICKER_RECT_IPAD CGRectMake(0.0, [[ UIScreen mainScreen ] applicationFrame].size.height - 264.0, 0.0, 0.0)

@interface LWYTextField (){
    
     UILabel *dispalyPickedDataLB;
    NSMutableDictionary *dateDic;
}

-(void) initializeBaiscAttribute;

@end

@implementation LWYTextField

@synthesize pickerDataMArray;
@synthesize pickerViewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initializeBaiscAttribute];
        self.text = @"";
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
    placeholder:(NSString *) placeholder
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initializeBaiscAttribute];
        
    }
    self.placeholder = [NSString stringWithFormat:@"请输入%@",placeholder];
    return self;
}

-(void) initializeBaiscAttribute{
    
    CSIIUIToolbar *toolBar = [[CSIIUIToolbar alloc]init];
    toolBar.delegate = self;
//    toolBar.doneDelegate = self;
    self.inputAccessoryView = toolBar;
    self.returnKeyType = UIReturnKeyDone;
    self.borderStyle = UITextBorderStyleNone;
    self.keyboardType = UIKeyboardTypeDefault;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.placeholder = @"";
//    self.background = [UIColor clearColor];
    self.borderStyle = UITextBorderStyleNone;
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.textAlignment = NSTextAlignmentLeft;
    self.font = [UIFont systemFontOfSize:14];
}


- (BOOL) validateTextFormat{//正则表达式
    
    if (self.text.length == 0) {
        if (_MustInput==YES) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"\n%@",self.placeholder] delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil];
            [alert show];
            return  NO;
        }
        else{
              self.text = @"";
        }
    }
    
    if (self.lwyType == LWYTextFieldType_Phone&&_MustInput == YES) {
        
        
        if (self.text.length!=11) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"手机号码格式不正确，请重新输入手机号码" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alert show];
            
            return NO;
        }
        
//        NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
//        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
//        BOOL isMatch = [pred evaluateWithObject:self.text];
//        正则表达式
//        if (!isMatch) {
//            
//        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"手机号码格式不正确，请重新输入手机号码" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
//            [alert show];
//            
//            return NO;
//        }
    }
    
    if (self.lwyType == LWYTextFieldType_IDNum&&_MustInput == YES) {
        if (self.text.length!=15&&self.text.length!=18) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"证件号码格式不正确，请重新输入" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
            [alert show];
            
            return NO;
        }
    }

    
    return YES;
}

- (BOOL)textLengthEqualZero {
    if (self.text.length == 0) {
        self.text = @"";
        return YES;
    }
    return NO;
}

#pragma mark - 实现协议UIPicerViewDelegate和UIPickerViewDataSource方法

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.pickerDataMArray count];
}

//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    return [self.pickerData objectAtIndex:row];
//}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.text = [self.pickerDataMArray objectAtIndex:row];
//    dispalyPickedDataLB.text = self.text;
    [self callDelegateMethod:(int)row];
}


#pragma mark - 注册键盘通知
-(void) registerKeyboardNotification{
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)name:UIKeyboardWillShowNotification object:nil];
//    
//    //    UIKeyboardWillHideNotification
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)name:UIKeyboardWillHideNotification object:nil];
    

}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12.0f, 0.0f, [pickerView rowSizeForComponent:component].width-12, [pickerView rowSizeForComponent:component].height)];
    
    [label setText:[pickerDataMArray objectAtIndex:row]];
    label.backgroundColor = [UIColor clearColor];
    [label setTextAlignment:NSTextAlignmentCenter];
    return label;
}

#pragma mark - 调用协议LWYPickerViewDelegate方法 

-(void) callDelegateMethod:(int) row{
    //实现联动效果
    if (pickerViewDelegate && [pickerViewDelegate respondsToSelector:@selector(myPickerView: DidSlecetedAtRow:)])
    {
        [pickerViewDelegate myPickerView:self DidSlecetedAtRow: row];
    }
}


#pragma mark - 重载UItextfield方法 控制placeHolder、显示文本、编辑文本的位置

//控制placeHolder的位置
-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
    if (self.lwyType == LWYTextFieldType_Login) {
        CGRect inset = CGRectMake(bounds.origin.x+55, bounds.origin.y, bounds.size.width-55, bounds.size.height);
        return inset;
    }
    CGRect inset = CGRectMake(bounds.origin.x+5, bounds.origin.y, bounds.size.width-5, bounds.size.height);
    return inset;
}
//控制显示文本的位置
-(CGRect)textRectForBounds:(CGRect)bounds
{
    if (self.lwyType == LWYTextFieldType_Login) {
        CGRect inset = CGRectMake(bounds.origin.x+55, bounds.origin.y, bounds.size.width-55, bounds.size.height);
        return inset;
    }
    CGRect inset = CGRectMake(bounds.origin.x+5, bounds.origin.y, bounds.size.width-5, bounds.size.height);
    return inset;
}
//控制编辑文本的位置
-(CGRect)editingRectForBounds:(CGRect)bounds
{
    if (self.lwyType == LWYTextFieldType_Login) {
        CGRect inset = CGRectMake(bounds.origin.x+55, bounds.origin.y, bounds.size.width-55, bounds.size.height);
        return inset;
    }
    CGRect inset = CGRectMake(bounds.origin.x+5, bounds.origin.y, bounds.size.width-5-25, bounds.size.height);
    return inset;
}

#pragma mark - 覆盖文本框
-(void) overViewTextTield{
    //覆盖文本框
    UIImageView *maskIMGV = [[UIImageView alloc] initWithFrame:self.frame];
    maskIMGV.image = IPAD ?IMAGE(@"输入框_ipad"):IMAGE(@"输入框");
    dispalyPickedDataLB = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, self.frame.size.width -25, 24)];
    dispalyPickedDataLB.font = self.font;
    dispalyPickedDataLB.backgroundColor = [UIColor clearColor];

    [maskIMGV addSubview:dispalyPickedDataLB];
    UIImageView *downView = [[UIImageView alloc] initWithFrame:CGRectMake(170, 15, 26/2, 15/2)];
    
    downView.image = [UIImage imageNamed:@"下箭头.png"];
    [maskIMGV addSubview:downView];

    self.rightView = maskIMGV;
    self.rightViewMode = UITextFieldViewModeAlways;
}

@end


@implementation LWYTextField (datePickerCreation)

-(id) initDatePicerViewWithFrame:(CGRect) frame andString:(NSString *)str{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeBaiscAttribute];
        self.text = [self formateDate:[NSDate date]];//2014-07-05
        [self overViewTextTield];
        _datePicer = [[UIDatePicker alloc] init];
        
        NSDateFormatter *todayFormatter = [[NSDateFormatter alloc]init];
        todayFormatter.dateFormat = @"yyyy-MM-dd";
        NSTimeZone *zone = [NSTimeZone defaultTimeZone];
        todayFormatter.timeZone = zone;
        NSDate *todayDate = [todayFormatter dateFromString:self.text];
        _datePicer.maximumDate = todayDate;//最大日期
        [_datePicer setDate:[todayFormatter dateFromString:str]];

        
        _datePicer.datePickerMode = UIDatePickerModeDate;
        [_datePicer addTarget:self action:@selector(dateDidSeledted:) forControlEvents:UIControlEventValueChanged];
        self.inputView = _datePicer;
        
        //  注册键盘通知
        [self registerKeyboardNotification];
    }
    return self;
}

//将字符串转换成一定格式的NSDate类型
- (NSDate *)formateStrToDate:(NSString *)str{
    NSString* string = [[NSString alloc] initWithString:str];
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init] ;
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ];
    [inputFormatter setDateFormat:@"MMddYYYY"];
    NSDate* inputDate = [inputFormatter dateFromString:string];
    NSLog(@"date = %@", inputDate);
    return inputDate;
}

-(id) initDatePicerViewWithFrame:(CGRect) frame beginDate:(BOOL)isBegin{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeBaiscAttribute];
        self.text = [self formateDate:[self getThreeMonthBeforeDate]];//2014-07-05
        
        [self overViewTextTield];
        _datePicer = [[UIDatePicker alloc] init];
        _datePicer.datePickerMode = UIDatePickerModeDate;

        [_datePicer setDate:[self getThreeMonthBeforeDate]];
        [_datePicer addTarget:self action:@selector(dateDidSeledted:) forControlEvents:UIControlEventValueChanged];
        self.inputView = _datePicer;
        
        //  注册键盘通知
        [self registerKeyboardNotification];
    }
    return self;
    
    
}


- (NSDate *)getThreeMonthBeforeDate{
    NSArray *arr = [[self formateDate:[NSDate date]] componentsSeparatedByString:@"-"];
    NSString *month = [arr objectAtIndex:1];
    NSString *day = [arr objectAtIndex:2];
    NSString *year = [arr objectAtIndex:0];
    
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    
    if (month.integerValue<=3) {
        switch (month.integerValue) {
            case 1:{
                [comps setMonth:10];
            }
                break;
            case 2:{
                [comps setMonth:11];
            }
                break;
            case 3:{
                [comps setMonth:12];
            }
                break;
            default:
                break;
        }
    }else{
        [comps setMonth:month.integerValue-3];
    }
    
    [comps setDay:day.integerValue];
    [comps setYear:year.integerValue];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [calendar dateFromComponents:comps];
    return date;

}

+ (NSDate *)getThreeMonthBeforeDate{
    NSArray *arr = [[self formateDate:[NSDate date]] componentsSeparatedByString:@"-"];
    NSString *month = [arr objectAtIndex:1];
    NSString *day = [arr objectAtIndex:2];
    NSString *year = [arr objectAtIndex:0];
    
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    
    if (month.integerValue<=3) {
        switch (month.integerValue) {
            case 1:{
                [comps setMonth:10];
            }
                break;
            case 2:{
                [comps setMonth:11];
            }
                break;
            case 3:{
                [comps setMonth:12];
            }
                break;
            default:
                break;
        }
    }else{
        [comps setMonth:month.integerValue-3];
    }
    
    [comps setDay:day.integerValue];
    [comps setYear:year.integerValue];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [calendar dateFromComponents:comps];
    return date;
    
}




-(id) initEnDDatePicerViewWithFrame:(CGRect) frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeBaiscAttribute];
//        self.text = [self formateDate:[NSDate ]];
        [self overViewTextTield];
        _datePicer = [[UIDatePicker alloc] init];
        _datePicer.datePickerMode = UIDatePickerModeDate;
        [_datePicer addTarget:self action:@selector(dateDidSeledted:) forControlEvents:UIControlEventValueChanged];
        self.inputView = _datePicer;
        
        //  注册键盘通知
        [self registerKeyboardNotification];
    }
    return self;
}


#pragma mark -- 时间间隔为一个月
-(id) initOneMouthDatePicerViewWithFrame:(CGRect) frame beginDate:(BOOL)isBegin{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeBaiscAttribute];
        self.text = [self formateDate:[self getOneMonthBeforeDate]];//2014-07-05
        
        [self overViewTextTield];
        _datePicer = [[UIDatePicker alloc] init];
        _datePicer.datePickerMode = UIDatePickerModeDate;
        
        [_datePicer setDate:[self getOneMonthBeforeDate]];
        [_datePicer addTarget:self action:@selector(dateDidSeledted:) forControlEvents:UIControlEventValueChanged];
        self.inputView = _datePicer;
        
        //  注册键盘通知
        [self registerKeyboardNotification];
    }
    return self;
    
    
}

- (NSDate *)getOneMonthBeforeDate{
    NSArray *arr = [[self formateDate:[NSDate date]] componentsSeparatedByString:@"-"];
    NSString *month = [arr objectAtIndex:1];
    NSString *day = [arr objectAtIndex:2];
    NSString *year = [arr objectAtIndex:0];
    
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    
    if (month.integerValue<=3) {
        switch (month.integerValue) {
            case 1:{
                [comps setMonth:10];
            }
                break;
            case 2:{
                [comps setMonth:11];
            }
                break;
            case 3:{
                [comps setMonth:12];
            }
                break;
            default:
                break;
        }
    }else{
        [comps setMonth:month.integerValue-1];
    }
    
    [comps setDay:day.integerValue];
    [comps setYear:year.integerValue];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [calendar dateFromComponents:comps];
    return date;
    
}

+ (NSDate *)getOneMonthBeforeDate{
    NSArray *arr = [[self formateDate:[NSDate date]] componentsSeparatedByString:@"-"];
    NSString *month = [arr objectAtIndex:1];
    NSString *day = [arr objectAtIndex:2];
    NSString *year = [arr objectAtIndex:0];
    
    NSDateComponents *comps = [[NSDateComponents alloc]init];
    
    if (month.integerValue<=3) {
        switch (month.integerValue) {
            case 1:{
                [comps setMonth:10];
            }
                break;
            case 2:{
                [comps setMonth:11];
            }
                break;
            case 3:{
                [comps setMonth:12];
            }
                break;
            default:
                break;
        }
    }else{
        [comps setMonth:month.integerValue-1];
    }
    
    [comps setDay:day.integerValue];
    [comps setYear:year.integerValue];
    NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [calendar dateFromComponents:comps];
    return date;
    
}




-(id) initOneMonthEnDDatePicerViewWithFrame:(CGRect) frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeBaiscAttribute];
        //        self.text = [self formateDate:[NSDate ]];
        [self overViewTextTield];
        _datePicer = [[UIDatePicker alloc] init];
        _datePicer.datePickerMode = UIDatePickerModeDate;
        [_datePicer addTarget:self action:@selector(dateDidSeledted:) forControlEvents:UIControlEventValueChanged];
        self.inputView = _datePicer;
        
        //  注册键盘通知
        [self registerKeyboardNotification];
    }
    return self;
}




+(BOOL)pickerChanged:(LWYTextField*)BeginDate End:(LWYTextField*)EndDate{
    
    NSString *BeginDateStr= BeginDate.text;// 2012-05-17 11:23:23
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *fromdate=[format dateFromString:BeginDateStr];
    NSTimeZone *fromzone = [NSTimeZone systemTimeZone];
    NSInteger frominterval = [fromzone secondsFromGMTForDate: fromdate];
    NSDate *fromDate = [fromdate  dateByAddingTimeInterval: frominterval];
    NSLog(@"fromdate=%@",fromDate);
    
    NSString*EndDateStr = EndDate.text;
    
    NSDate *date = [format dateFromString:EndDateStr];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    NSLog(@"enddate=%@",localeDate);
    NSDateComponents *components = [gregorian components:unitFlags fromDate:fromDate toDate:localeDate options:0];
    NSInteger months = [components month];
    NSInteger days = [components day];//年[components year]
    
    NSLog(@"month=%ld",(long)months);
    NSLog(@"days=%ld",(long)days);
    
//    if (months==0&&days==0) {
//        dateStr=[[dateStr substringFromIndex:11]substringToIndex:5];
////        cell.textLabel.text=[NSString stringWithFormat:@"今天 %@",dateStr];//今天 11:23
//    }else if(months==0&&days==1){
//        dateStr=[[dateStr substringFromIndex:11]substringToIndex:5];
////        cell.textLabel.text=[NSString stringWithFormat:@"昨天 %@",dateStr];//昨天 11:23
//    }else{
//        dateStr=[dateStr substringToIndex:10];
////        cell.textLabel.text=dateStr;
//    }

    
//    NSTimeInterval time=[BeginDate.datePicer.date timeIntervalSinceDate:EndDate.datePicer.date];
//    int days=((int)time)/(3600*24);
////    int hours=((int)time)%(3600*24)/3600;
//    NSString *dateContent=[[NSString alloc] initWithFormat:@"%i",days];
//    NSLog(@"%@*************",dateContent);
//    if (BeginDate.inputView) {
    
        if ([BeginDate.text compare:EndDate.text] == NSOrderedDescending ) {
            BeginDate.datePicer.date = [self getThreeMonthBeforeDate];
            [BeginDate.datePicer sendActionsForControlEvents:UIControlEventValueChanged];
            UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"起始时间不能晚于结束时间" delegate:Nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
            [alert show];
            return NO;
        }else if ([BeginDate.text compare:EndDate.text] == NSOrderedDescending ) {
            EndDate.datePicer.date = [NSDate date];
            [EndDate.datePicer sendActionsForControlEvents:UIControlEventValueChanged];
            UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"终止时间不能比起始时间早" delegate:Nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
            [alert show];
            return NO;
        }else if(months>3){

            BeginDate.datePicer.date = [self getThreeMonthBeforeDate];
            [BeginDate.datePicer sendActionsForControlEvents:UIControlEventValueChanged];
            UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"日期间隔不能大于三个月" delegate:Nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
            [alert show];
            return NO;
            
        }else if(months==3&&days!=0){
            
            BeginDate.datePicer.date = [self getThreeMonthBeforeDate];
            [BeginDate.datePicer sendActionsForControlEvents:UIControlEventValueChanged];
            UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"日期间隔不能大于三个月" delegate:Nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
            [alert show];
            return NO;
            
        } else{
            return YES;
        }
}


+(BOOL)pickerChangedOne:(LWYTextField*)BeginDate End:(LWYTextField*)EndDate{
    
    NSString *BeginDateStr= BeginDate.text;// 2012-05-17 11:23:23
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSMonthCalendarUnit | NSDayCalendarUnit;
    NSDateFormatter *format=[[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd"];
    NSDate *fromdate=[format dateFromString:BeginDateStr];
    NSTimeZone *fromzone = [NSTimeZone systemTimeZone];
    NSInteger frominterval = [fromzone secondsFromGMTForDate: fromdate];
    NSDate *fromDate = [fromdate  dateByAddingTimeInterval: frominterval];
    NSLog(@"fromdate=%@",fromDate);
    
    NSString*EndDateStr = EndDate.text;
    
    NSDate *date = [format dateFromString:EndDateStr];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    NSLog(@"enddate=%@",localeDate);
    NSDateComponents *components = [gregorian components:unitFlags fromDate:fromDate toDate:localeDate options:0];
    NSInteger months = [components month];
    NSInteger days = [components day];//年[components year]
    
    NSLog(@"month=%ld",(long)months);
    NSLog(@"days=%ld",(long)days);
    
    //    if (months==0&&days==0) {
    //        dateStr=[[dateStr substringFromIndex:11]substringToIndex:5];
    ////        cell.textLabel.text=[NSString stringWithFormat:@"今天 %@",dateStr];//今天 11:23
    //    }else if(months==0&&days==1){
    //        dateStr=[[dateStr substringFromIndex:11]substringToIndex:5];
    ////        cell.textLabel.text=[NSString stringWithFormat:@"昨天 %@",dateStr];//昨天 11:23
    //    }else{
    //        dateStr=[dateStr substringToIndex:10];
    ////        cell.textLabel.text=dateStr;
    //    }
    
    
    //    NSTimeInterval time=[BeginDate.datePicer.date timeIntervalSinceDate:EndDate.datePicer.date];
    //    int days=((int)time)/(3600*24);
    ////    int hours=((int)time)%(3600*24)/3600;
    //    NSString *dateContent=[[NSString alloc] initWithFormat:@"%i",days];
    //    NSLog(@"%@*************",dateContent);
    //    if (BeginDate.inputView) {
    
    if ([BeginDate.text compare:EndDate.text] == NSOrderedDescending ) {
        BeginDate.datePicer.date = [self getThreeMonthBeforeDate];
        [BeginDate.datePicer sendActionsForControlEvents:UIControlEventValueChanged];
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"起始时间不能晚于结束时间" delegate:Nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
        [alert show];
        return NO;
    }else if ([BeginDate.text compare:EndDate.text] == NSOrderedDescending ) {
        EndDate.datePicer.date = [NSDate date];
        [EndDate.datePicer sendActionsForControlEvents:UIControlEventValueChanged];
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"终止时间不能比起始时间早" delegate:Nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
        [alert show];
        return NO;
    }else if(months>1){
        
        BeginDate.datePicer.date = [self getThreeMonthBeforeDate];
        [BeginDate.datePicer sendActionsForControlEvents:UIControlEventValueChanged];
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"日期间隔不能大于一个月" delegate:Nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
        [alert show];
        return NO;
        
    }else if(months==1&&days!=0){
        
        BeginDate.datePicer.date = [self getThreeMonthBeforeDate];
        [BeginDate.datePicer sendActionsForControlEvents:UIControlEventValueChanged];
        UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示信息" message:@"日期间隔不能大于一个月" delegate:Nil cancelButtonTitle:@"确认" otherButtonTitles:Nil, nil];
        [alert show];
        return NO;
        
    } else{
        return YES;
    }
}




-(void) dateDidSeledted:(id) sender{
    
    NSDate *date = ((UIDatePicker *)sender).date;
    self.text = [NSString stringWithFormat:@"%@",[self formateDate:date]];
    dispalyPickedDataLB.text = self.text;
    dateDic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:self.text,@"dateNum", nil];
}
-(void)DoneClick
{
    if (dateDic ==nil) {
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LocalAction_GetDatePickerString" object:nil userInfo:dateDic];
    
}
-(NSString *) formateDate:(NSDate *) date{
    if (date) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];//用[NSDate date]可以获取系统当前时间
        NSString *currentDateStr = [dateFormatter stringFromDate:date];
        return currentDateStr;
    }
    return @"";
}
+(NSString *) formateDate:(NSDate *) date{
    if (date) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //设定时间格式,这里可以设置成自己需要的格式
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];//用[NSDate date]可以获取系统当前时间
        NSString *currentDateStr = [dateFormatter stringFromDate:date];
        return currentDateStr;
    }
    return @"";
}
@end


@implementation LWYTextField (pickerCreation)


-(id) initPicerViewWithFrame:(CGRect) frame picerDataArray:(NSMutableArray *) dataArray{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeBaiscAttribute];
        self.pickerDataMArray = dataArray;
        if ([dataArray count] > 0) {
            self.text = [dataArray objectAtIndex:0];
        }
        [self overViewTextTield]; //覆盖文本框
//        UIPickerView *pickerView = ;
        if(IPHONE){
            _pickerView = [[ UIPickerView alloc ] initWithFrame: PICKER_RECT_IPHONE ];
        }else{
            _pickerView= [[ UIPickerView alloc ] initWithFrame: PICKER_RECT_IPAD];
        }
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        _pickerView.showsSelectionIndicator = YES;
        self.inputView = _pickerView;
        
        UIImage*image = [UIImage imageNamed:@"select_down"];
        
        UIImageView*rightimg = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width-image.size.width-30+20, (self.frame.size.height-image.size.height)/2, image.size.width, image.size.height)];
        rightimg.image = image;
        rightimg.userInteractionEnabled = YES;
        [self addSubview:rightimg];
        
//  注册键盘通知
        [self registerKeyboardNotification];
    }
    return self;
}

#pragma mark - 响应键盘通知
-(void)keyboardWillShow:(id) sender{
    dispalyPickedDataLB.text = self.text;
}

-(void)keyboardWillHide:(id) sender{
    dispalyPickedDataLB.text = @"";
}


@end
