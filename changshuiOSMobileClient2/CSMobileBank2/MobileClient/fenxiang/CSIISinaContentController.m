//
//  CSIISinaContentController.m
//
//  Created by 胡中楷 on 14-11-1.
//  Copyright (c) 2014年 胡中楷. All rights reserved.
//

#import "CSIISinaContentController.h"
#import "WeiboSDK.h"
#import "CSIIShareHandle.h"
#import "CSIISinaAuthorViewController.h"

#import "myErWeiMaViewController.h"

#import "MobileBankSession.h"


@interface CSIISinaContentController ()<UITextViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,CSIISinaAuthorViewControllerDelegate>{
    UIView *_backView;//背景图
    UITextView *_textView;//文本域
    UIImageView *_imgView;//分享图片视图
    int wordLength;//文字个数
    UILabel *_lblWordCount;//显示字数lable
    
    UIActionSheet *_photoSheet;//
    BOOL isErWeiMa;
}

@end

@implementation CSIISinaContentController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [UIColor whiteColor];
        self.title = @"内容分享";
        wordLength = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createView];
}

- (void)createView{
    CGRect frame = self.view.bounds;
    
    _backView = [[UIView alloc] initWithFrame:CGRectMake(frame.origin.y, frame.origin.y+35+64, frame.size.width-10, 205)];
    _backView.center = CGPointMake(frame.size.width/2, 64+10+100);
    _backView.backgroundColor = [UIColor grayColor];
    _backView.layer.cornerRadius = 2.5f;
    _backView.layer.masksToBounds = YES;
    _backView.userInteractionEnabled = YES;
    
    
    
    _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 200,195)];
    
    if ([Context getNSUserDefaultskeyStr:@"erWeiMa"].length>0) {
        NSData *data = [Context dataWithBase64EncodedString:[Context getNSUserDefaultskeyStr:@"saveViewImage"]];
        _imgView.image = [UIImage imageWithData:data];
        isErWeiMa = YES;
    }else{
        _imgView.image = [UIImage imageNamed:@"shareimage"];
        isErWeiMa = NO;
    }
    [_backView addSubview:_imgView];
    
    
    //自定义工具栏
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 35)];
    UILabel *lblT = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
    lblT.text = @"分享到:";
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:lblT];
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    imgV.image = [UIImage imageNamed:@"sns_icon_1.png"];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:imgV];
    UIBarButtonItem *item3 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *item4 = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleBordered target:self action:@selector(clickFinish)];
    toolBar.items = [NSArray arrayWithObjects:item1,item2,item3,item4, nil];
    
    
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(210, 5, _backView.frame.size.width-200-15, 205-10)];
    [_textView becomeFirstResponder];
    _textView.backgroundColor = [UIColor whiteColor];
    [_textView setTextAlignment:NSTextAlignmentLeft];
    [_textView becomeFirstResponder];
    _textView.autocapitalizationType=UITextAutocapitalizationTypeNone;
    _textView.font=[UIFont systemFontOfSize:14];
    _textView.keyboardType = UIKeyboardTypeDefault;
    _textView.returnKeyType=UIReturnKeyDone;
    _textView.delegate=self;
    _textView.autocorrectionType=UITextAutocorrectionTypeNo; //关闭自动更正
    //    _textView.contentInset = UIEdgeInsetsMake(-68, 0, 0, 0);
    _textView.inputAccessoryView = toolBar;
    [_backView addSubview:_textView];
    //UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(5, 130, 95, 25)];
    //lbl.text = @"点击图片选择";
    //lbl.font = [UIFont systemFontOfSize:14.0f];
    //lbl.textAlignment = UITextAlignmentCenter;
    //[_backView addSubview:lbl];
    
    //    UIButton *btnPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    //    btnPhoto.frame = CGRectMake(5, 130, 95, 25);
    //    btnPhoto.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    //    [btnPhoto setTitle:@"点击图片选择" forState:UIControlStateNormal];
    //    btnPhoto.backgroundColor = [UIColor redColor];
    //    [btnPhoto addTarget:self action:@selector(clickAddPhoto) forControlEvents:UIControlEventTouchUpInside];
    //    [_backView addSubview:btnPhoto];
    
    
    //    _lblWordCount = [[UILabel alloc] initWithFrame:CGRectMake(245, 125, 60, 30)];//字数限制
    //    _lblWordCount.font = [UIFont systemFontOfSize:14.0f];
    //    _lblWordCount.text = [NSString stringWithFormat:@"%d/140",wordLength];
    //    _lblWordCount.textAlignment = NSTextAlignmentCenter;
    //    _lblWordCount.backgroundColor = [UIColor greenColor];
    //
    //    [_backView addSubview:_lblWordCount];
    [self.view addSubview:_backView];
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(clickBack)];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStyleBordered target:self action:@selector(clickSendMessage)];
    
    self.navigationItem.leftBarButtonItem = left;
    self.navigationItem.rightBarButtonItem = right;
}

#pragma mark - 取消按钮
- (void)clickBack{
    [_textView resignFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CSIISinaAuthorViewControllerDelegate 新浪微博授权回调方法
- (void)SinaAuthorViewDidFailAndErrorInfo:(NSDictionary *)error{
    NSLog(@"____失败。");
}

- (void)SinaAuthorViewUserCancel{
    NSLog(@"____取消。");
}

- (void)SinaAuthorViewDidFinishAndAuthorInfo:(NSDictionary *)authorInfo{
    NSLog(@"____完成。%@",authorInfo);
}

#pragma mark - 分享按钮
- (void)clickSendMessage{
    if([_textView.text isEqualToString:@""] || _textView.text.length == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息" message:@"分享内容不能为空" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [_textView resignFirstResponder];
    CSIIShareHandle *handle = [CSIIShareHandle ShareHandleInstance];
    if(![CSIIShareHandle SinaWeiBoTokenIsInvalid]){
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:kSinaAppKey forKey:@"source"];
        [dict setObject:handle.SinaWBToken forKey:@"access_token"];
        [dict setObject:_textView.text forKey:@"status"];
        UIImage *img = [self getImageFromImage:_imgView.image and:6 and:6];
        if(_imgView.image != nil){
            [dict setObject:(img != nil ? img : _imgView.image) forKey:@"pic"];
            //上传图片并发布一条微博
            //            [WBHttpRequest requestWithURL:kSinaUploadURL httpMethod:@"POST" params:dict delegate:handle withTag:@"sendMessage"];
            if (isErWeiMa) {
                WBMessageObject *objMessage = [handle messageToSinaShareWords:_textView.text andImg:_imgView.image];
                WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:objMessage authInfo:nil access_token:handle.SinaWBToken];
                [WeiboSDK sendRequest:request];
            }else{
                WBMessageObject *messageObj;
                if (self.WebShareUrl) {
                     messageObj = [handle messageToSinaShareNews:@"indentifier1" andTitle:[NSString stringWithFormat:@"%@\n%@ %@",self.WebShareName,self.WebShareText,_textView.text] Description:_textView.text ImgSmall:[UIImage imageNamed:@"shareimage"] Url:self.WebShareUrl];

                }else{
                     messageObj = [handle messageToSinaShareNews:@"indentifier1" andTitle:[NSString stringWithFormat:@"%@\n%@",@"常熟农商银行",_textView.text] Description:@"常熟农商银行" ImgSmall:[UIImage imageNamed:@"shareimage"] Url:@"http://www.csrcbank.com/download.html"];

                }
                //图文片信息
                //                WBMessageObject *messageObj = [handle messageToSinaShareWords:@"哈哈哈哈——————测试用得åå" andImg:[UIImage imageNamed:@"icon7"]];
                //文字信息
                //WBMessageObject *messageObj = [handle messageToSinaShareOnlyWords:@"仅仅是文字信息的发布。____测试。"];
                
                WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:messageObj authInfo:nil access_token:handle.SinaWBToken];
                [WeiboSDK sendRequest:request];
                
            }
            
        }else{
            //发布一条微博信息
            [WBHttpRequest requestWithURL:kSinaUpdateURL httpMethod:@"POST" params:dict delegate:handle withTag:@"sendMessage"];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        //发起授权
        NSDictionary *authorInfo = [handle SinaParamsWithKey:kSinaAppKey redirectUrl:kSinaRedirectURI andScope:@"all" State:@"0" DisplayType:@"mobile" forceLogin:NO Language:@""];
        CSIISinaAuthorViewController *author = [[CSIISinaAuthorViewController alloc] initWithParms:authorInfo andUrl:kSinaWeiboWebAuthURL];
        author.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:author];
        [self presentViewController:nav animated:YES completion:nil];
        [CSIIShareView shareViewHide];
    }
}

#pragma mark - 获取图片
- (void)clickAddPhoto{
    [_textView resignFirstResponder];
    _photoSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"相册选择", nil];
    _photoSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [_photoSheet showInView:self.view];
}

#pragma mark -UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 2){
        
    }else if (buttonIndex == 0){
        //暂不做iPad适配
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypeCamera;
            if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
                UIImagePickerController *picker=[[UIImagePickerController alloc]init];
                picker.delegate=self;
                picker.sourceType=sourceType;
                [self presentViewController:picker animated:YES completion:nil];
            }
        }
    }else if (buttonIndex == 1){
        //暂不做iPad适配
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
                UIImagePickerController *picker=[[UIImagePickerController alloc]init];
                picker.delegate = self;
                picker.sourceType=sourceType;
                picker.allowsEditing=NO;       //可编辑状态
                [self presentViewController:picker animated:YES completion:nil];
            }
        }
    }else{
        [actionSheet dismissWithClickedButtonIndex:2 animated:YES];
    }
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!img) {
        img=[info objectForKey:UIImagePickerControllerOriginalImage];
    }
    _imgView.image = img;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 自定义工具栏的完成隐藏键盘事件
- (void)clickFinish{
    [_textView resignFirstResponder];
}

#pragma mark - UITextViewDelegate 控制文本输入字数
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@""]){
        wordLength = (int)range.location;
        return YES;
    }else{
        if(textView.text.length > 140){
            //将光标移动到跳到最后面去
            NSRange rangeForEnd;
            rangeForEnd.location = textView.text.length - 1;
            rangeForEnd.length = 0;
            textView.selectedRange = rangeForEnd;
            wordLength = (int)range.location;
            return NO;
        }else if(range.location > 140){
            wordLength = (int)range.location;
            return NO;
        }else{
            wordLength = (int)range.location;
            return YES;
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    _lblWordCount.text = [NSString stringWithFormat:@"%d/140",(int)textView.text.length];
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    if(textView.text.length > 140){
        textView.text = [textView.text substringWithRange:NSMakeRange(0, 140)];
        _lblWordCount.text = [NSString stringWithFormat:@"%d/140",(int)textView.text.length];
    }
}

#pragma mark - 对获取到的图片处理
-(UIImage *)getImageFromImage:(UIImage*)bigImage and:(double)x and:(double)y
{
    CGSize targetSize = CGSizeMake(bigImage.size.width/x,  bigImage.size.height/y);
    UIImage *sourceImage = bigImage;
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.4;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.4;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil)
        NSLog(@"could not scale image");
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

/*
 - (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
 {
 CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
 // Lock the base address of the pixel buffer
 CVPixelBufferLockBaseAddress(imageBuffer,0);
 
 // Get the number of bytes per row for the pixel buffer
 size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
 // Get the pixel buffer width and height
 size_t width = CVPixelBufferGetWidth(imageBuffer);
 size_t height = CVPixelBufferGetHeight(imageBuffer);
 
 // Create a device-dependent RGB color space
 CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
 if (!colorSpace)
 {
 NSLog(@"CGColorSpaceCreateDeviceRGB failure");
 return nil;
 }
 
 // Get the base address of the pixel buffer
 void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
 // Get the data size for contiguous planes of the pixel buffer.
 size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
 
 // Create a Quartz direct-access data provider that uses data we supply
 CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize,
 NULL);
 // Create a bitmap image from data supplied by our data provider
 CGImageRef cgImage =
 CGImageCreate(width,
 height,
 8,
 32,
 bytesPerRow,
 colorSpace,
 kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
 provider,
 NULL,
 true,
 kCGRenderingIntentDefault);
 CGDataProviderRelease(provider);
 CGColorSpaceRelease(colorSpace);
 
 // Create and return an image object representing the specified Quartz image
 UIImage *image = [UIImage imageWithCGImage:cgImage];
 
 
 return image;
 }
 */
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"erWeiMa"];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
