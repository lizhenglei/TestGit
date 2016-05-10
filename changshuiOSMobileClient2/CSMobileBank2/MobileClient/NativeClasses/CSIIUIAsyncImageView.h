//
//  CSIIUIAsyncImageView.h
//  BankofYingkou
//
//  Created by 刘旺 on 13-6-26.
//  Copyright (c) 2013年 科蓝公司. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface CSIIUIAsyncImageView : UIView<NSURLConnectionDataDelegate>
{
	UIImageView *m_pImageView;
	UIActivityIndicatorView *m_pIndicator;
	bool m_bIsLoaded;
    NSString *defaultImageName;
}
@property (nonatomic, retain) UIImageView *m_pImageView;
@property (nonatomic, retain) UIActivityIndicatorView *m_pIndicator;
@property (nonatomic) bool m_bIsLoaded;
- (void) LoadImageWithUrlStr:(NSString *) strURL;
- (id)initWithTransaction:(CGRect)frame transactionId:(NSString*)transactionId argument:(NSDictionary*)argument;
- (id)initWithTransaction:(CGRect)frame transactionId:(NSString*)transactionId argument:(NSDictionary*)argument defaultImageName:(NSString*)_defaultImageName;

- (id)initWithTransactionId:(NSString*)transactionId argument:(NSDictionary*)argument;


/*************增加圆角的方法****************/
- (id)initWithTransaction:(CGRect)frame transactionId:(NSString*)transactionId argument:(NSDictionary*)argument defaultImageName:(NSString*)_defaultImageName andCornerRadius:(CGFloat) radius;
@end