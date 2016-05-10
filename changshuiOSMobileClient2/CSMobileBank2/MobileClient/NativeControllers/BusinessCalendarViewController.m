//
//  BusinessCalendarViewController.m
//  MobileClient
//
//  Created by xiaoxin on 15/5/19.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "BusinessCalendarViewController.h"
#import "CustomAlertView.h"
#import "JSONKit.h"
@interface BusinessCalendarViewController ()<CustomAlertViewDelegate>
{
    UIView*footerView;
    UILabel*DateLab;
    UIButton*AddButton;
    UIScrollView*_scrollview;
    NSMutableArray*dataArray;           //存储查询回来的数据
    NSMutableArray*scrollData;             //需要显示的数据  服务器返回
    NSMutableArray*scrollLocaData;             //需要显示的数据   本地数据
    NSMutableArray*locaDataArray;       //存储本地的数据
    
    NSString*selectedDateStr;              //存储本地时的时间
    NSString*buttonType;                //点击按钮的类别   添加还是修改
    NSString *destDateString;//所点击的日期年－月－日
    NSMutableDictionary *infoDic;
    NSString *selectDateString;
    NSDate *date;
    UIView *hideKeyoardView;
    CustomAlertView*customAlert;
    UIScrollView *bgScrollView;
}
@property (nonatomic, strong) CalendarView * customCalendarView;
@property (nonatomic, strong) NSCalendar * gregorian;
@property (nonatomic, assign) NSInteger currentYear;

@end

@implementation BusinessCalendarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    ((UILabel *)[self.navigationController.navigationBar viewWithTag:99]).text = @"金融日历";
//    [self initCalendarView];

    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance]postToServer:@"FinanceCalendarQry.do" actionParams:nil method:@"POST"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFrame:) name:@"changeFooterViewFrame" object:nil];

}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
    buttonType = @"";
    
    scrollData = [[NSMutableArray alloc]init];
    scrollLocaData = [[NSMutableArray alloc]init];
    infoDic = [[NSMutableDictionary alloc]init];


}


-(void)initCalendarView{

    
//    [_customCalendarView removeFromSuperview];
//    [footerView removeFromSuperview];
    
    NSString*locaDataStr = [Context getNSUserDefaultskeyStr:[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MobileNo"]];
    if (![locaDataStr isEqualToString:@""]&&locaDataStr !=nil) {
//        locaDataArray = [[NSMutableArray alloc]initWithArray:[[locaDataStr objectFromJSONString] objectForKey:@"List"]];
        locaDataArray = [[NSMutableArray alloc]initWithArray:[[Context jsonDicFromString:locaDataStr]objectForKey:@"List"]];
    }else
        locaDataArray = [[NSMutableArray alloc]init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    _gregorian       = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    _customCalendarView                             = [[CalendarView alloc]initWithFrame:CGRectMake(0, 10, ScreenWidth, 270)]; //在初始化方法里面动态设置
    _customCalendarView.isSignCalen = NO;
    _customCalendarView.dataArray                   = dataArray;
    _customCalendarView.locaDataArray               = locaDataArray;
    _customCalendarView.delegate                    = self;
    _customCalendarView.datasource                  = self;
    _customCalendarView.selectedDate                = selectedDateStr==nil?[NSDate date]:[dateFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",[selectedDateStr substringWithRange:NSMakeRange(0, 4)],[selectedDateStr substringWithRange:NSMakeRange(4, 2)],[selectedDateStr substringWithRange:NSMakeRange(6, 2)]]];
    _customCalendarView.calendarDate                = selectedDateStr==nil?[NSDate date]:[dateFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",[selectedDateStr substringWithRange:NSMakeRange(0, 4)],[selectedDateStr substringWithRange:NSMakeRange(4, 2)],[selectedDateStr substringWithRange:NSMakeRange(6, 2)]]];
    _customCalendarView.monthAndDayTextColor        = [UIColor colorWithRed:0.43f green:0.42f blue:0.41f alpha:1.00f];
    _customCalendarView.dayBgColorWithData          = [UIColor colorWithRed:0.83f green:0.94f blue:1.00f alpha:1.00f];
    _customCalendarView.dayBgColorWithoutData       = [UIColor colorWithRed:0.83f green:0.94f blue:1.00f alpha:1.00f];
    _customCalendarView.dayBgColorSelected          = [UIColor colorWithRed:0.60f green:0.82f blue:0.93f alpha:1.00f];
    _customCalendarView.dayTxtColorWithoutData      = [UIColor colorWithRed:0.46f green:0.45f blue:0.45f alpha:1.00f];
    _customCalendarView.dayTxtColorWithData         = [UIColor colorWithRed:0.43f green:0.42f blue:0.41f alpha:1.00f];
    _customCalendarView.dayTxtColorSelected         = [UIColor colorWithRed:0.46f green:0.45f blue:0.45f alpha:1.00f];
    _customCalendarView.borderColor                 = [UIColor colorWithRed:0.98f green:0.98f blue:0.98f alpha:1.00f];
    _customCalendarView.borderWidth                 = 3;
    _customCalendarView.allowsChangeMonthByDayTap   = YES;
    _customCalendarView.allowsChangeMonthByButtons  = YES;
    _customCalendarView.keepSelDayWhenMonthChange   = YES;
    _customCalendarView.nextMonthAnimation          = UIViewAnimationOptionTransitionFlipFromRight;
    _customCalendarView.prevMonthAnimation          = UIViewAnimationOptionTransitionFlipFromLeft;
    _dayInfoUnits               = NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    //    _customCalendarView.backgroundColor = [UIColor redColor];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [bgScrollView addSubview:_customCalendarView];
        _customCalendarView.center = CGPointMake(self.view.center.x, _customCalendarView.center.y);
    });
    
    NSDateComponents * yearComponent = [_gregorian components:NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:[NSDate date]];
    _currentYear = yearComponent.month;
    
    destDateString = [dateFormatter stringFromDate:[NSDate date]];
    NSMutableArray*datearray = [[NSMutableArray alloc]initWithArray:[destDateString componentsSeparatedByString:@"-"]]; //用来显示
    
    if (selectedDateStr == nil) {
        selectedDateStr = [destDateString stringByReplacingOccurrencesOfString:@"-" withString:@""];                       //存储保存本地的时间
        
    }else{

        NSDate *destDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",[selectedDateStr substringWithRange:NSMakeRange(0, 4)],[selectedDateStr substringWithRange:NSMakeRange(4, 2)],[selectedDateStr substringWithRange:NSMakeRange(6, 2)]]];
        destDateString = [dateFormatter stringFromDate:destDate];
        datearray = [[NSMutableArray alloc]initWithArray:[destDateString componentsSeparatedByString:@"-"]]; //用来显示
    }
    
    
    bgScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-72-64)];
    bgScrollView.contentSize = CGSizeMake(ScreenWidth-20, _customCalendarView.frame.size.height+_scrollview.contentSize.height+30);
    bgScrollView.bounces = NO;
    bgScrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bgScrollView];
    
    _customCalendarView.backgroundColor = [UIColor clearColor];
    
    footerView = [[UIView alloc]initWithFrame:CGRectMake(2, _customCalendarView.frame.origin.y+_customCalendarView.frame.size.height, ScreenWidth-4, _scrollview.contentSize.height+140)];
    footerView.backgroundColor = [UIColor whiteColor];
    footerView.layer.cornerRadius = 1;
    [bgScrollView addSubview:footerView];
    [self addBottomMenus];
    
    DateLab = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, footerView.frame.size.width-60, 40)];
    DateLab.text = [NSString stringWithFormat:@"%@年%@月%@日",datearray[0],datearray[1],datearray[2]];
    DateLab.backgroundColor = [UIColor clearColor];
    [footerView addSubview:DateLab];
    
    UIView*blueLine = [[UIView alloc]initWithFrame:CGRectMake(10, 40, footerView.frame.size.width-20, 1.5)];
    blueLine.backgroundColor = [UIColor colorWithRed:0.80f green:0.93f blue:1.00f alpha:1.00f];
    [footerView addSubview:blueLine];
    
    AddButton = [UIButton buttonWithType:UIButtonTypeCustom];
    AddButton.backgroundColor = [UIColor clearColor];
    [AddButton setBackgroundImage:[UIImage imageNamed:@"CalenderAdd3"] forState:UIControlStateNormal];
    
    
    NSDateComponents *componentsToday = [_gregorian components:_dayInfoUnits fromDate:[NSDate date]];
    componentsToday.hour         = 0;
    componentsToday.minute       = 0;
    componentsToday.second       = 0;
    
    if ([selectedDateStr==nil?[NSDate date]:[dateFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",[selectedDateStr substringWithRange:NSMakeRange(0, 4)],[selectedDateStr substringWithRange:NSMakeRange(4, 2)],[selectedDateStr substringWithRange:NSMakeRange(6, 2)]]] compare:[_gregorian dateFromComponents:componentsToday]] == NSOrderedAscending) {
        AddButton.hidden = YES;
    }

    if([selectedDateStr==nil?[NSDate date]:[dateFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",[selectedDateStr substringWithRange:NSMakeRange(0, 4)],[selectedDateStr substringWithRange:NSMakeRange(4, 2)],[selectedDateStr substringWithRange:NSMakeRange(6, 2)]]] compare:[_gregorian dateFromComponents:componentsToday]] == NSOrderedDescending){
        AddButton.hidden = NO;
    }
    
    if([selectedDateStr==nil?[NSDate date]:[dateFormatter dateFromString:[NSString stringWithFormat:@"%@-%@-%@",[selectedDateStr substringWithRange:NSMakeRange(0, 4)],[selectedDateStr substringWithRange:NSMakeRange(4, 2)],[selectedDateStr substringWithRange:NSMakeRange(6, 2)]]] compare:[_gregorian dateFromComponents:componentsToday]] == NSOrderedSame){
        AddButton.hidden = NO;
    }
    
    AddButton.frame = CGRectMake(footerView.frame.size.width-40, 7.5, 25, 25);
    [AddButton addTarget:self action:@selector(AddbuttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:AddButton];

    [self initScrollview];
}

-(void)changeFrame:(NSNotification *)note{
    
   footerView.frame = CGRectMake(2, _customCalendarView.frame.origin.y+_customCalendarView.frame.size.height, ScreenWidth-4, bgScrollView.contentSize.height-140);
    
    _scrollview.frame = CGRectMake(10, 42, footerView.frame.size.width-20, footerView.frame.size.height-42);
    bgScrollView.contentSize = CGSizeMake(ScreenWidth-20, _customCalendarView.frame.size.height+_scrollview.contentSize.height+30);
}

-(void)initScrollview{
    
    [_scrollview removeFromSuperview];
    [scrollLocaData removeAllObjects];
    [scrollData removeAllObjects];
    
    
    for (int x = 0; x<dataArray.count; x++) {
        if (![[dataArray[x] objectForKey:@"FinanceDate"]isEqualToString:@""]&&[[dataArray[x] objectForKey:@"FinanceDate"]isEqualToString:selectedDateStr]) {
            [scrollData addObject:dataArray[x]];
        }
    }
    
    for (int x = 0; x<locaDataArray.count; x++) {
        if (![[locaDataArray[x] objectForKey:@"FinanceDate"]isEqualToString:@""]&&[[locaDataArray[x] objectForKey:@"FinanceDate"]isEqualToString:selectedDateStr]) {
            
            [scrollLocaData addObject:locaDataArray[x]];
        }
    }
    
    _scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(10, 42, footerView.frame.size.width-20, footerView.frame.size.height-42)];
    _scrollview.backgroundColor = [UIColor clearColor];//[UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    _scrollview.showsVerticalScrollIndicator = NO;
    [footerView addSubview:_scrollview];
    
    
    for (int x = 0; x<scrollData.count; x++) {
        UILabel*lab = [[UILabel alloc]initWithFrame:CGRectMake(0, x*40, _scrollview.frame.size.width, 40)];
        lab.text = [scrollData[x]objectForKey:@"Description"];
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont systemFontOfSize:15];
        [_scrollview addSubview:lab];
    }
    
    for (int x = 0; x<scrollLocaData.count; x++) {
        
        UILabel*lab = [[UILabel alloc]initWithFrame:CGRectMake(0, (scrollData.count+x)*40, _scrollview.frame.size.width-60, 30)];
        lab.text = [scrollLocaData[x]objectForKey:@"Description"];
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont systemFontOfSize:14];
        UILabel *tishiTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, IOS7_OR_LATER?30:22, 200, 10)];
        
        NSString *time = [NSString stringWithFormat:@"%@",[scrollLocaData[x]objectForKey:@"date"]];
        tishiTimeLabel.text = [NSString stringWithFormat:@"%@%@",@"提醒时间：",[time substringWithRange:NSMakeRange(11, 5)]];
        tishiTimeLabel.textColor = [UIColor grayColor];
        tishiTimeLabel.backgroundColor = [UIColor clearColor];
        tishiTimeLabel.font = [UIFont systemFontOfSize:12];
        [lab addSubview:tishiTimeLabel];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 43, footerView.frame.size.width-20, 1)];
        lineView.backgroundColor = [UIColor grayColor];
        lineView.alpha = 0.5f;
        [lab addSubview:lineView];
        [_scrollview addSubview:lab];
        
        UIButton*changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        changeBtn.frame = CGRectMake(_scrollview.frame.size.width-75, (scrollData.count+x)*40+4, 32, 32);
        changeBtn.backgroundColor = [UIColor clearColor];
        changeBtn.tag = x+1;
        [changeBtn setImage:[UIImage imageNamed:@"pen"] forState:UIControlStateNormal];
        [changeBtn addTarget:self action:@selector(changeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollview addSubview:changeBtn];
        
        UIButton*deleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        deleBtn.frame = CGRectMake(_scrollview.frame.size.width-40, (scrollData.count+x)*40+4, 32, 32);
        deleBtn.backgroundColor = [UIColor clearColor];
        deleBtn.tag = x+1;
        [deleBtn setImage:[UIImage imageNamed:@"CalenderDele"] forState:UIControlStateNormal];
        [deleBtn addTarget:self action:@selector(deleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollview addSubview:deleBtn];
        
    }

    UIImageView *hintsImageView = [self addDefaultHints:@"您的查询间隔为前后3个月。" FromY:(scrollLocaData.count+scrollData.count)*40+5 FromX:0];
    [_scrollview addSubview:hintsImageView];
    
//    if (scrollLocaData.count>0) {
//        UIView*blueLine = [[UIView alloc]initWithFrame:CGRectMake(0, hintsImageView.frame.origin.y-2, footerView.frame.size.width-20, 1.5)];
//        blueLine.backgroundColor = [UIColor colorWithRed:0.80f green:0.93f blue:1.00f alpha:1.00f];
//        [_scrollview addSubview:blueLine];
//    }
    
    _scrollview.contentSize = CGSizeMake(_scrollview.frame.size.width, (scrollData.count+scrollLocaData.count)*40+80);

}

#pragma mark - Gesture recognizer

-(void)swipeleft:(id)sender
{
    [_customCalendarView showNextMonth];
}

-(void)swiperight:(id)sender
{
    [_customCalendarView showPreviousMonth];
}

#pragma mark - CalendarDelegate protocol conformance

-(void)dayChangedToDate:(NSDate *)selectedDate
{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    //zzz表示时区，zzz可以删除，这样返回的日期字符将不包含时区信息。
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
   NSString * destDateString = [dateFormatter stringFromDate:selectedDate];
    
    NSDateFormatter *selectDateFormatter = [[NSDateFormatter alloc]init];
    [selectDateFormatter setDateFormat:@"yyyy-MM-dd"];
    selectDateString = [selectDateFormatter stringFromDate:selectedDate];
    
    
    NSMutableArray*datearray = [[NSMutableArray alloc]initWithArray:[destDateString componentsSeparatedByString:@"-"]]; //用来显示
    NSString*dateStr = [destDateString stringByReplacingOccurrencesOfString:@"-" withString:@""];                       //用来比较
    
    selectedDateStr = dateStr;
    
    NSLog(@"selected %@",destDateString);
    DateLab.text = [NSString stringWithFormat:@"%@年%@月%@日",datearray[0],datearray[1],datearray[2]];
    
    NSDateComponents *componentsToday = [_gregorian components:_dayInfoUnits fromDate:[NSDate date]];
    componentsToday.hour         = 0;
    componentsToday.minute       = 0;
    componentsToday.second       = 0;
    
    if ([selectedDate compare:[_gregorian dateFromComponents:componentsToday]] == NSOrderedAscending) {
        AddButton.hidden = YES;
    }else if([selectedDate compare:[_gregorian dateFromComponents:componentsToday]] == NSOrderedSame){
        AddButton.hidden = NO;
    }else
        AddButton.hidden = NO;
    
    [self initScrollview];
    
    footerView.frame = CGRectMake(2, _customCalendarView.frame.origin.y+_customCalendarView.frame.size.height, ScreenWidth-4, bgScrollView.contentSize.height-140);
    
    _scrollview.frame = CGRectMake(10, 42, footerView.frame.size.width-20, footerView.frame.size.height-42);
    bgScrollView.contentSize = CGSizeMake(ScreenWidth-20, _customCalendarView.frame.size.height+_scrollview.contentSize.height+30);
}

#pragma mark - CalendarDataSource protocol conformance

-(BOOL)isDataForDate:(NSDate *)date
{
    if ([date compare:[NSDate date]] == NSOrderedAscending)
        return YES;
    return NO;
}

-(BOOL)canSwipeToDate:(NSDate *)date//前后个三个月
{
    NSDateComponents * yearComponent = [_gregorian components:NSEraCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:date];
    if (_currentYear+3>12) {//10--12
        
        switch (_currentYear) {
            case 10:
                return (yearComponent.month >= _currentYear-3 || (yearComponent.month==10||yearComponent.month==11||yearComponent.month==12||(yearComponent.year+1&&yearComponent.month==1)));
                break;
            case 11:
                return (yearComponent.month >= _currentYear-3 || (yearComponent.month==11||yearComponent.month==12||(yearComponent.year+1&&yearComponent.month==1)||(yearComponent.year+1&&yearComponent.month==2)));
                break;
            case 12:
                return (yearComponent.month >= _currentYear-3 || (yearComponent.month==12||(yearComponent.year+1&&yearComponent.month==1)||(yearComponent.year+1&&yearComponent.month==2)||(yearComponent.year+1&&yearComponent.month==3)));
                break;
            default:
                break;
        }
        
        return (yearComponent.month >= _currentYear-3 && yearComponent.month  <= _currentYear+3);
        
    }else if(_currentYear-3<1){//1--3
        
        switch (_currentYear) {
            case 1:
                return (yearComponent.month  <= _currentYear+3||((yearComponent.year-1&&yearComponent.month==12)||(yearComponent.year-1&&yearComponent.month==11)||(yearComponent.year-1&&yearComponent.month==10)||yearComponent.month==1));
                break;
            case 2:
                return (yearComponent.month  <= _currentYear+3||((yearComponent.year-1&&yearComponent.month==12)||(yearComponent.year-1&&yearComponent.month==11)||yearComponent.month==2||yearComponent.month==1));

                break;
            case 3:
                return (yearComponent.month  <= _currentYear+3||((yearComponent.year-1&&yearComponent.month==12)||yearComponent.month==1||yearComponent.month==2||yearComponent.month==3));

                break;
            default:
                break;
        }
        return (yearComponent.month >= _currentYear-3 && yearComponent.month  <= _currentYear+3);

    }else//4--9
    return (yearComponent.month >= _currentYear-3 && yearComponent.month  <= _currentYear+3);
    //二月到八月
}

-(void)getReturnData:(id)data WithActionName:(NSString *)action{

    if ([action isEqualToString:@"FinanceCalendarQry.do"]) {
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]){
        dataArray = [[NSMutableArray alloc]initWithArray:[data objectForKey:@"List"]];
            NSLog(@"金融日历系统提醒%@",data);
        [self initCalendarView];
        }else{
        
        }
    }
}

-(void)AddbuttonAction:(UIButton*)btn{
    buttonType = @"Add";
    customAlert = [[CustomAlertView alloc]initCalendarWithDelegate:self context:@"" title:@"新增"];
    customAlert.contextTF.delegate = self;
    [customAlert show];
    NSLog(@"点击了添加");
}

-(void)changeButtonAction:(UIButton*)btn{
    buttonType = @"Change";
    customAlert = [[CustomAlertView alloc]initCalendarWithDelegate:self context:[[scrollLocaData objectAtIndex:btn.tag-1] objectForKey:@"Description"] title:@"修改"];
    customAlert.contextTF.delegate = self;
    customAlert.tag = btn.tag;
    [customAlert show];
    NSLog(@"点击了修改");
}

//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    
//    NSString* real = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    return real.length < 16;
//    
//}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboard];
    return YES;
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    hideKeyoardView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, customAlert.frame.size.width, customAlert.frame.size.height)];
    hideKeyoardView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    [hideKeyoardView addGestureRecognizer:tap];
    [customAlert addSubview:hideKeyoardView];

}
-(void)hideKeyboard
{
    [customAlert.contextTF resignFirstResponder];
    [hideKeyoardView removeFromSuperview];
}
-(void)deleBtnAction:(UIButton*)btn{
    
    UIAlertView*alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您是否确认删除？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    alert.tag = btn.tag;
    [alert show];

    NSLog(@"点击了删除");
}

#pragma mark ----CustomAlertViewDelegate------
-(void)leftBtnPressedWithinalertView:(CustomAlertView *)alert{
    alert.hidden = YES;
}

-(void)rightBtnPressedWithinalertView:(CustomAlertView *)alert andHourString:(NSString *)hour andMinuteString:(NSString *)minute{
    
    if ([alert.contextTF.text isEqualToString:@""]||alert.contextTF == nil) {
        ShowToast(@"请输入内容");
        return;
    }
    
    if (alert.contextTF.text.length>15) {
        ShowToast(@"输入内容不得大于15字");
        return;
    }
    
    NSDate *todayDate = [[NSDate alloc]init];
    NSDateFormatter *todayFormatter = [[NSDateFormatter alloc]init];
    [todayFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *todayDateString = [todayFormatter stringFromDate:todayDate];
    NSString *today = [todayDateString substringToIndex:10];
    
    NSDateFormatter *dateFor = [[NSDateFormatter alloc]init];
    [dateFor setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = nil;
    if (selectDateString.length==0||[selectDateString isEqualToString:today]) {
        dateString = [NSString stringWithFormat:@"%@ %@:%@:00",destDateString,hour,minute];
    }else{
        dateString = [NSString stringWithFormat:@"%@ %@:%@:00",selectDateString,hour,minute];
    }
    date = [dateFor dateFromString:dateString];//选择提醒的日期,格式2015-07-28 16:00:00 +0000
    
    if (selectDateString.length==0||[selectDateString isEqualToString:today]) {
        NSComparisonResult result = [dateString compare:todayDateString];
        NSLog(@"选择的日期%@",dateString);
        NSLog(@"当天的日期%@",todayDateString);
        if (result == NSOrderedAscending) {
            ShowToast(@"提醒时间不能小于当前时间");
            return;
        }
    }else{
        NSDate *date = [[NSDate alloc]init];
        NSDateFormatter *ff = [[NSDateFormatter alloc]init];
//        [ff setDateFormat:@"HH:mm:00"];
        [ff setDateFormat:@"yyyy-MM-dd"];
        NSString *selectTime = [ff stringFromDate:date];
        
//        NSString *selectString = [NSString stringWithFormat:@"%@ %@",selectDateString,selectTime];
        NSComparisonResult result = [selectDateString compare:selectTime];
        if (result == NSOrderedAscending) {
            ShowToast(@"提醒时间不能小于当前时间");
            return;
        }
    }
    
    NSDateFormatter *ff = [[NSDateFormatter alloc]init];
    [ff setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *tt = [ff stringFromDate:date];
    if ([buttonType isEqualToString:@"Add"]) {                       //添加
        
        NSMutableDictionary*dic = [[NSMutableDictionary alloc]init];
        [dic setObject:alert.contextTF.text forKey:@"Description"];
        [dic setObject:selectedDateStr forKey:@"FinanceDate"];
        [dic setObject:[NSString stringWithFormat:@"%@",tt] forKey:@"date"];
        [dic setObject:@"1" forKey:@"Flag"];                   //标记本地添加，可以删除和修改
        [locaDataArray addObject:dic];
        
    }else{                                                       //修改
        [locaDataArray removeObject:[scrollLocaData objectAtIndex:alert.tag-1]];
        NSMutableDictionary*dic = [[NSMutableDictionary alloc]init];
        [dic setObject:alert.contextTF.text forKey:@"Description"];
        [dic setObject:selectedDateStr forKey:@"FinanceDate"];
        [dic setObject:[NSString stringWithFormat:@"%@",tt] forKey:@"date"];
        [dic setObject:@"1" forKey:@"Flag"];                   //标记本地添加，可以删除和修改
        [locaDataArray insertObject:dic atIndex:alert.tag-1];
    }
    
    NSMutableDictionary*listData = [[NSMutableDictionary alloc]init];
    [listData setObject:locaDataArray forKey:@"List"];
    [Context setNSUserDefaults:[Context jsonStrFromDic:listData] keyStr:[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MobileNo"]];
    
    [self initCalendarView];
    
    [alert hideAlertView];

    //创建一个本地推送
    UILocalNotification *noti = [[UILocalNotification alloc] init];
    if (noti) {
        //设置推送时间
        noti.fireDate = date;
        //设置时区
        noti.timeZone = [NSTimeZone defaultTimeZone];
        //设置重复间隔
//        noti.repeatInterval = NSWeekCalendarUnit;
        //推送声音
        noti.soundName = UILocalNotificationDefaultSoundName;
        
        //显示内容，去掉下面2行就不会弹出提示框
        noti.alertBody=alert.contextTF.text;//提示信息 弹出提示框
//        noti.alertAction = @"打开";  //提示框按钮
        NSString *string = [[NSUserDefaults standardUserDefaults] objectForKey:@"tuiSong"];
        if ([string intValue]==0) {
            string = @"0";
        }
        //显示在icon上的红色圈中的数子
//        noti.applicationIconBadgeNumber = [string intValue]+1;
        noti.applicationIconBadgeNumber = 0;
        [[NSUserDefaults standardUserDefaults]setValue:[NSString stringWithFormat:@"%ld",(long)noti.applicationIconBadgeNumber] forKey:@"tuiSong"];
        [[NSUserDefaults standardUserDefaults]synchronize];

        //设置userinfo 方便在之后需要撤销的时候使用
//        [infoDic setObject:[NSString stringWithFormat:@"name%ld",(long)noti.applicationIconBadgeNumber] forKey:@"key"];
        [infoDic setObject:@"name" forKey:@"key"];
        noti.userInfo = infoDic;
        //添加推送到uiapplication
        UIApplication *app = [UIApplication sharedApplication];
        [app scheduleLocalNotification:noti];
    }

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    alertView.hidden = YES;
    if (buttonIndex == 1) {
        [locaDataArray removeObject:[scrollLocaData objectAtIndex:alertView.tag-1]];
        NSMutableDictionary*listData = [[NSMutableDictionary alloc]init];
        [listData setObject:locaDataArray forKey:@"List"];
        [Context setNSUserDefaults:[Context jsonStrFromDic:listData] keyStr:[[MobileBankSession sharedInstance].Userinfo objectForKey:@"MobileNo"]];
        
        //取消某一个通知
        NSArray *notificaitons = [[UIApplication sharedApplication] scheduledLocalNotifications];
        //获取当前所有的本地通知
        if (!notificaitons || notificaitons.count <= 0) {
            [self initCalendarView];
            return;
        }
        for (UILocalNotification *notify in notificaitons) {
            if ([[notify.userInfo objectForKey:@"key"] isEqualToString:@"name"]) {
                //取消一个特定的通知
                [[UIApplication sharedApplication] cancelLocalNotification:notify];
                break;
            }
        }
        
        [self initCalendarView];
    }
}

#pragma mark - Action methods

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
