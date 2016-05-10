

#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]


#import <UIKit/UIKit.h>


@protocol CalendarDelegate;
@protocol CalendarDataSource;


@interface CalendarView : UIView

-(void)showNextMonth;
-(void)showPreviousMonth;

@property (nonatomic,strong) NSDate *calendarDate;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSDate * selectedDate;

@property (nonatomic,strong) NSMutableArray *locaDataArray;
@property (nonatomic,weak) id<CalendarDelegate> delegate;
@property (nonatomic,weak) id<CalendarDataSource> datasource;
@property (nonatomic,assign)CGFloat frameHeight;

// Font
@property (nonatomic, strong) UIFont * defaultFont;
@property (nonatomic, strong) UIFont * dateFont;     //日期字体
@property (nonatomic, strong) UIFont * holidayFont;           //农历节日字体

@property (nonatomic, strong) UIFont * titleFont;

// Text color for month and weekday labels
@property (nonatomic, strong) UIColor * monthAndDayTextColor;

// Border
@property (nonatomic, strong) UIColor * borderColor;
@property (nonatomic, assign) NSInteger borderWidth;

// Button color
@property (nonatomic, strong) UIColor * dayBgColorWithoutData;
@property (nonatomic, strong) UIColor * dayBgColorWithData;
@property (nonatomic, strong) UIColor * dayBgColorSelected;
@property (nonatomic, strong) UIColor * dayTxtColorWithoutData;
@property (nonatomic, strong) UIColor * dayTxtColorWithData;
@property (nonatomic, strong) UIColor * dayTxtColorSelected;

// Allows or disallows the user to change month when tapping a day button from another month
@property (nonatomic, assign) BOOL allowsChangeMonthByDayTap;
@property (nonatomic, assign) BOOL allowsChangeMonthBySwipe;
@property (nonatomic, assign) BOOL allowsChangeMonthByButtons;

// origin of the calendar Array
@property (nonatomic, assign) NSInteger originX;
@property (nonatomic, assign) NSInteger originY;

// "Change month" animations
@property (nonatomic, assign) UIViewAnimationOptions nextMonthAnimation;
@property (nonatomic, assign) UIViewAnimationOptions prevMonthAnimation;

// Miscellaneous
@property (nonatomic, assign) BOOL keepSelDayWhenMonthChange;
@property (nonatomic, assign) BOOL hideMonthLabel;

@property(nonatomic,assign)BOOL isSignCalen;
@property(nonatomic,strong)NSArray *signCalendarData;
@end



@protocol CalendarDelegate <NSObject>

-(void)dayChangedToDate:(NSDate *)selectedDate;

@optional
-(void)setHeightNeeded:(NSInteger)heightNeeded;
-(void)setMonthLabel:(NSString *)monthLabel;
-(void)setEnabledForPrevMonthButton:(BOOL)enablePrev nextMonthButton:(BOOL)enableNext;

@end



@protocol CalendarDataSource <NSObject>

-(BOOL)isDataForDate:(NSDate *)date;
-(BOOL)canSwipeToDate:(NSDate *)date;

@end// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com