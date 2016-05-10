//
//  CSIIUIAsyncImageView.m
//  BankofYingkou
//
//  Created by 刘旺 on 13-6-26.
//  Copyright (c) 2013年 科蓝公司. All rights reserved.
//

#import "CSIIUIAsyncImageView.h"
#import "MobileBankSession.h"
#import "CommonFunc.h"


@implementation CSIIUIAsyncImageView
{
    NSString *_strURL;
    NSMutableData *_data;
    NSString *md5ImageFile;

    NSFileManager *fm ;

}
@synthesize m_pImageView;
@synthesize m_pIndicator;
@synthesize m_bIsLoaded;

- (void) LoadImageWithUrlStr:(NSString *) strURL
{
    
    fm = [[NSFileManager alloc] init];
    NSString *imageCachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    [fm createDirectoryAtPath:[NSString stringWithFormat:@"%@/ADImage",imageCachePath] withIntermediateDirectories:YES attributes:nil error:nil];
    md5ImageFile = [CommonFunc md5:strURL];
    NSArray *fileArray = [fm contentsOfDirectoryAtPath:[self filePath] error:nil];
    NSString *uu = [NSString stringWithFormat:@"%@.png",md5ImageFile];
    for (int i=0; i<fileArray.count; i++) {
        if ([fileArray[i] hasSuffix:@"png"]) {
            if ([fileArray[i] rangeOfString:md5ImageFile].length>0) {
                if ([uu isEqualToString:fileArray[i]]) {
                    UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.png",[self filePath],md5ImageFile]];
                    [m_pImageView setImage:image];
                    return;
                }
            }
        }
    }
    _data = [NSMutableData data];
    _strURL = strURL;
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:strURL]];
    [NSURLConnection connectionWithRequest:request delegate:self];
}
-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}
-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    UIImage *image = [UIImage imageWithData:_data];
    //将图片写入缓存中
    
    if (_strURL&&image) {
        NSString *ss = [NSString stringWithFormat:@"%@/%@.png",[self filePath],md5ImageFile];
        [_data writeToFile:ss options:NSDataWritingFileProtectionNone error:nil];
    }
    [m_pImageView setImage:image];
    NSLog(@"%@",image);
    m_pImageView.frame = self.bounds;
    [m_pImageView setNeedsLayout];
    [self setNeedsLayout];
    
}
- (NSString*)filePath
{
    NSString *imageCachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * filePath = [imageCachePath stringByAppendingPathComponent:@"ADImage"];
    return filePath;
}
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		m_pImageView = [[UIImageView alloc] initWithFrame:frame];
		[self addSubview:m_pImageView];
        m_pImageView.image = [UIImage imageNamed:defaultImageName];
        m_pImageView.backgroundColor = [UIColor clearColor];
		m_pIndicator = [[UIActivityIndicatorView alloc] initWithFrame:frame];
		[m_pIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
        m_pIndicator.frame = CGRectMake(self.frame.size.width/2-10, self.frame.size.height/2-10, 20,20);
		[self addSubview:m_pIndicator];
		m_bIsLoaded = NO;
    }
    return self;
}

- (id)initWithTransaction:(CGRect)frame transactionId:(NSString*)transactionId argument:(NSDictionary*)argument;
{
    self = [self initWithFrame:frame];
	if (self) {
        [self LoadImageWithUrlStr:[self getUrlWithTransaction:transactionId argument:argument]];
    }
    return self;
}
- (id)initWithTransactionId:(NSString*)transactionId argument:(NSDictionary*)argument;
{
    if (self) {
        [self LoadImageWithUrlStr:[self getUrlWithTransaction:transactionId argument:argument]];
    }
    return self;
}

- (NSString*)getUrlWithTransaction:(NSString*)transactionId argument:(NSDictionary*)argument;
{
    NSMutableString *urlStr = [[NSMutableString alloc]initWithString:[NSString stringWithFormat:@"%@/%@",SERVER_BACKEND_URL,SERVER_BACKEND_CONTEXT]];
    [urlStr appendFormat:@"/%@",transactionId];
    if(argument && [argument isKindOfClass: [NSDictionary class]]){
        [urlStr appendFormat:@"?%@=%@",[argument allKeys][0],[argument allValues][0]];
    }
    return urlStr;
}

- (id)initWithTransaction:(CGRect)frame transactionId:(NSString*)transactionId argument:(NSDictionary*)argument defaultImageName:(NSString*)_defaultImageName;
{
    defaultImageName = _defaultImageName;
    return [self initWithTransaction:frame transactionId:transactionId argument:argument];
}

/********增加圆角********/
- (id)initWithTransaction:(CGRect)frame transactionId:(NSString *)transactionId argument:(NSDictionary *)argument defaultImageName:(NSString *)_defaultImageName andCornerRadius:(CGFloat)radius{
    self = [self initWithTransaction:frame transactionId:transactionId argument:argument defaultImageName:_defaultImageName];
    m_pImageView.layer.cornerRadius = radius;
    m_pImageView.layer.masksToBounds = YES;
    return self;
}

@end