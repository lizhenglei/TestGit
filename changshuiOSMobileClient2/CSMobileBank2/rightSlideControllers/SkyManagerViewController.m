//
//  SkyManagerViewController.m
//  MobileClient
//
//  Created by xiaoxin on 15/4/28.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "SkyManagerViewController.h"
#import"MKNetworkKit.h"


@interface SkyManagerViewController ()
{
    NSMutableArray*buttonArray;
}
@end

@implementation SkyManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    buttonArray = [[NSMutableArray alloc]init];
    
    NSArray*SkyNameArray = @[@"天空蓝",@"芳草绿",@"活力橙"];
    NSArray*imgArray = @[@"style_blue",@"style_green",@"style_golden"];
    UIScrollView *backScroll = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    backScroll.contentSize = CGSizeMake(ScreenWidth, 70+2*260);
    [self.view addSubview:backScroll];
    NSString *skinString = [Context getNSUserDefaultskeyStr:@"skin"];
    
    for (int x = 0; x<3; x++) {
        UIView*backgroundView = [[UIView alloc]initWithFrame:CGRectMake(15+(15+(ScreenWidth-45)/2)*(x%2), 15+(30+210)*(x/2), (ScreenWidth-45)/2, 200+10)];
        backgroundView.backgroundColor = [UIColor whiteColor];
        backgroundView.layer.borderWidth = 1.0f;
        //            backgroundView.tag = [[TagArray objectAtIndex:x] integerValue];
        backgroundView.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:0.86 alpha:1.0] CGColor];
        
        UIImageView*imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 10,backgroundView.frame.size.width-40 , 180*(backgroundView.frame.size.width-40)/104)];
        imageView.image = [UIImage imageNamed:[imgArray objectAtIndex:x]];
        [backgroundView addSubview:imageView];
        
        UILabel*skyName = [[UILabel alloc]initWithFrame:CGRectMake(10, backgroundView.frame.size.height-25, 60, 20)];
        skyName.backgroundColor = [UIColor clearColor];
        skyName.font = [UIFont boldSystemFontOfSize:13];
        skyName.textAlignment = NSTextAlignmentCenter;
        skyName.textColor = [UIColor colorWithRed:0.50f green:0.50f blue:0.50f alpha:1.00f];
        skyName.text = [SkyNameArray objectAtIndex:x];
        [backgroundView addSubview:skyName];
        
        UIButton*btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor whiteColor];
        btn.layer.cornerRadius = 4;
        btn.frame = CGRectMake(backgroundView.frame.size.width-60 , backgroundView.frame.size.height-25, 50, 20);
        [btn setTitle:@"设置" forState:UIControlStateNormal];
        [btn setTitle:@"使用中" forState:UIControlStateSelected];
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [UIColor grayColor].CGColor;
        btn.titleLabel.font = [UIFont systemFontOfSize:12];
        btn.tag = x+101;
        [btn addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        //图片后面加上101，102等
        [backgroundView addSubview:btn];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [buttonArray addObject:btn];
        
        //            UITapGestureRecognizer*tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeSky:)];
        //            [backgroundView addGestureRecognizer:tap];
        [backScroll addSubview:backgroundView];
        
        
        
    }
    for (int i=101; i<104; i++) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i];
        if (skinString.length==0||[skinString  isEqualToString:@""]||[skinString isEqualToString:@"101"]) {
            if (btn.tag==101) {
                btn.selected = YES;
                btn.backgroundColor = [UIColor colorWithRed:0.01f green:0.42f blue:0.69f alpha:1.00f];
                btn.layer.borderWidth = 1;
                btn.layer.borderColor = [[UIColor colorWithRed:0.01f green:0.42f blue:0.69f alpha:1.00f]CGColor];
            }
        }
        
        else{
            if (btn.tag ==[skinString intValue]) {
                btn.selected = YES;
                btn.backgroundColor = [UIColor colorWithRed:0.01f green:0.42f blue:0.69f alpha:1.00f];
                btn.layer.borderWidth = 1;
                btn.layer.borderColor = [[UIColor colorWithRed:0.01f green:0.42f blue:0.69f alpha:1.00f]CGColor];
            }
        }
        
    }
    
    // Do any additional setup after loading the view.
}

-(void)checkAction:(UIButton *)sender{
    
    [MobileBankSession sharedInstance].changeSkinType = [NSString stringWithFormat:@"%ld",(long)sender.tag];
    [Context setNSUserDefaults:[NSString stringWithFormat:@"%ld",(long)sender.tag] keyStr:@"skin"];
    [self viewWillAppear:YES];
    
    
    for (int i=101; i<104; i++) {
        UIButton *button = (UIButton *)[self.view viewWithTag:i];
        button.backgroundColor = [UIColor whiteColor];
        button.selected = NO;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [[UIColor grayColor]CGColor];
    }
    sender.selected = YES;
    sender.backgroundColor = [UIColor colorWithRed:0.01f green:0.42f blue:0.69f alpha:1.00f];
    sender.layer.borderWidth = 1;
    sender.layer.borderColor = [[UIColor colorWithRed:0.01f green:0.42f blue:0.69f alpha:1.00f]CGColor];
    NSLog(@"%ld",(long)sender.tag);
}

+(MKNetworkOperation*) downloadFatAssFileFrom:(NSString*) remoteURL toFile:(NSString*) filePath {
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:@"10.44.51.1:8082" customHeaderFields:nil];//@"127.0.0.1:5558"
    MKNetworkOperation *op = [engine operationWithURLString:remoteURL
                                                     params:nil
                                                 httpMethod:@"GET"];
    
    [op addDownloadStream:[NSOutputStream outputStreamToFileAtPath:filePath
                                                            append:YES]];
    [engine enqueueOperation:op];
    return op;
}

+(void)testDownload{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *downloadPath = [cachesDirectory stringByAppendingPathComponent:@"index.html"];
    
    MKNetworkOperation *downloadOperation=[SkyManagerViewController downloadFatAssFileFrom:[NSString stringWithFormat:@"%@/%@/%@",SERVER_BACKEND_URL,SERVER_BACKEND_CONTEXT,SERVER_BACKEND_PATH]                     //@"http://127.0.0.1:5558/QQ"
                                                                                    toFile:downloadPath];
    
    [downloadOperation onDownloadProgressChanged:^(double progress) {
        //下载进度
        NSLog(@"download progress: %.2f", progress*100.0);
    }];
    //事件处理
    [downloadOperation addCompletionHandler:^(MKNetworkOperation* completedRequest) {
        NSLog(@"download file finished!");
    }  errorHandler:^(MKNetworkOperation *errorOp, NSError* err) {
        NSLog(@"download file error: %@", err);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = @"主题设置";
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
