//
//  SkyManagerViewController.m
//  MobileClient
//
//  Created by xiaoxin on 15/4/28.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "SkyManagerViewController.h"
#import"MKNetworkKit.h"

#import "ZipArchive.h"

#import "CSIIUIAsyncImageView.h"

#import "CommonFunc.h"

@interface SkyManagerViewController ()
{
    NSMutableArray*buttonArray;
    NSMutableArray*SkyNameArray;
    NSMutableArray*imgArray;
    NSMutableArray *skinImageViewArray;
    NSString *midSkinString;
    UIButton *midSkinBtn;
    UIView*backgroundView;
}
@end

@implementation SkyManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    buttonArray = [[NSMutableArray alloc]init];
    
    [MobileBankSession sharedInstance].delegate =self;
    [[MobileBankSession sharedInstance]postToServer:@"SkinNameQry.do" actionParams:nil method:@"POST"];
    SkyNameArray = [[NSMutableArray alloc]initWithObjects:@"天空蓝",@"芳草绿",@"活力橙", nil];
    imgArray = [[NSMutableArray alloc]initWithObjects:@"skyblue",@"gressgreen",@"energyorange", nil];

    skinImageViewArray = [[NSMutableArray alloc]init];
    for (int i=0; i<[imgArray count]; i++) {
        UIImageView *imageView = [[UIImageView alloc]init];
        [Context setNSUserDefaults:imgArray[i] keyStr:imgArray[i]];
        imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",imgArray[i]]];
        imageView.frame = CGRectMake(20, 10,(ScreenWidth-45)/2-40 , 180*((ScreenWidth-45)/2-40)/104);
        [skinImageViewArray addObject:imageView];
    }
}

-(void)getReturnData:(id)data WithActionName:(NSString *)action
{
    if ([action isEqualToString:@"SkinNameQry.do"]) {
        if ([[data objectForKey:@"_RejCode"]isEqualToString:@"000000"]) {
            NSLog(@"%@",data);
            NSMutableArray *skinNameArray = [[NSMutableArray alloc]init];
            skinNameArray = [data objectForKey:@"List"];
            
        for (int i=0; i<skinNameArray.count; i++) {
            if (![[skinNameArray[i]objectForKey:@"SKINNAME"] isEqualToString:@"skyblue"]&&![[skinNameArray[i]objectForKey:@"SKINNAME"] isEqualToString:@"gressgreen"]&&![[skinNameArray[i]objectForKey:@"SKINNAME"] isEqualToString:@"energyorange"]) {
                [imgArray addObject:[skinNameArray[i] objectForKey:@"SKINNAME"]];
                [SkyNameArray addObject:[skinNameArray[i] objectForKey:@"SKINVALUE"]];
                
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                    [dic setObject:[skinNameArray[i] objectForKey:@"SKINNAME"]  forKey:@"SkinName"];
                    CSIIUIAsyncImageView *asyncImageView = [[CSIIUIAsyncImageView alloc]initWithTransaction:CGRectMake(0, 0,(ScreenWidth-45)/2-40 , 180*((ScreenWidth-45)/2-40)/104) transactionId:@"IconImageQry.do" argument:dic];
                    [skinImageViewArray addObject:asyncImageView];
                }

            }
            [self createImageUI];
        }
    }
    if ([action isEqualToString:@"SkinIconZipQry.do"]) {
        NSLog(@" 整套皮肤%@",data);
        [midSkinBtn setTitle:@"设置" forState:UIControlStateNormal];
        if ([MobileBankSession sharedInstance].changeSkinColor) {
            NSString *string = [CommonFunc base64EncodedStringFrom:data];
            [Context setNSUserDefaults:string keyStr:midSkinString];
        }

        NSString *unZipPath = [Context unZipPath];
        [data writeToFile:[NSString stringWithFormat:@"%@/%@.zip",unZipPath,midSkinString] options:NSDataWritingFileProtectionNone error:nil];
        NSFileManager *fm= [[NSFileManager alloc]init];
        NSArray *arr33 = [fm directoryContentsAtPath:[NSString stringWithFormat:@"%@/",unZipPath]];
        NSLog(@"3333%@",arr33);
    }

}
-(void)createImageUI
{
    UIScrollView *backScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-72)];
    backScroll.contentSize = CGSizeMake(ScreenWidth, (skinImageViewArray.count%2==0?(skinImageViewArray.count/2):(skinImageViewArray.count/2+1))*(225+15));
    [self.view addSubview:backScroll];
    
    for (int x=0; x<skinImageViewArray.count; x++) {
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(15+(15+(ScreenWidth-45)/2)*(x%2), 15+(30+210)*(x/2), (ScreenWidth-45)/2, 200+10)];
        backgroundView.backgroundColor = [UIColor whiteColor];
        backgroundView.layer.borderWidth = 1.0f;
        //            backgroundView.tag = [[TagArray objectAtIndex:x] integerValue];
        backgroundView.layer.borderColor = [[UIColor colorWithHue:0 saturation:0 brightness:0.86 alpha:1.0] CGColor];
        UIImageView *imageView = skinImageViewArray[x];
        imageView.frame = CGRectMake(20, 10,(ScreenWidth-45)/2-40 , 180*((ScreenWidth-45)/2-40)/104);
        NSLog(@"大小%@",imageView);
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
        btn.tag = x+100;
        [btn addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:btn];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [buttonArray addObject:btn];
        [backScroll addSubview:backgroundView];
    }
    [self selectBtnShow];
}

-(void)selectBtnShow
{
    NSString *skinTagString = [Context getNSUserDefaultskeyStr:@"skinTag"];
    for (int i=100; i<100+skinImageViewArray.count; i++) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i];
        if (skinTagString.length==0||[skinTagString  isEqualToString:@""]||[skinTagString isEqualToString:@"100"]) {
            if (btn.tag==100) {
                btn.selected = YES;
                btn.backgroundColor = [UIColor colorWithRed:0.01f green:0.42f blue:0.69f alpha:1.00f];
                btn.layer.borderWidth = 1;
                btn.layer.borderColor = [[UIColor colorWithRed:0.01f green:0.42f blue:0.69f alpha:1.00f]CGColor];
            }
        }
        
        else{
            if (btn.tag ==[skinTagString intValue]) {
                btn.selected = YES;
                btn.backgroundColor = [UIColor colorWithRed:0.01f green:0.42f blue:0.69f alpha:1.00f];
                btn.layer.borderWidth = 1;
                btn.layer.borderColor = [[UIColor colorWithRed:0.01f green:0.42f blue:0.69f alpha:1.00f]CGColor];
            }
        }
        if ([Context getNSUserDefaultskeyStr:imgArray[i-100]].length>0) {
            //            [btn setTitle:@"设置" forState:UIControlStateNormal];
        }else
            [btn setTitle:@"下载" forState:UIControlStateNormal];
    }
}


-(void)checkAction:(UIButton *)sender{
    
    
    if (sender.tag<103) {
        [MobileBankSession sharedInstance].changeSkinColor = imgArray[sender.tag-100];
        [Context setNSUserDefaults:[NSString stringWithFormat:@"%ld",(long)sender.tag] keyStr:@"skinTag"];
        [self getUpdateMenuPic];//请求更新的菜单图片
        [self changeSkin];//更换本地皮肤
        [self btnSelected:sender];
        [self viewWillAppear:YES];//刷新主题界面图片
    }else{
        if ([Context getNSUserDefaultskeyStr:imgArray[sender.tag-100]]) {
            [MobileBankSession sharedInstance].changeSkinColor = imgArray[sender.tag-100];
            [Context setNSUserDefaults:[NSString stringWithFormat:@"%ld",(long)sender.tag] keyStr:@"skinTag"];

//            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
//            [dic setObject:[MobileBankSession sharedInstance].changeSkinColor forKey:@"SkinName"];
//            if ([Context getNSUserDefaultskeyStr:[NSString stringWithFormat:@"%@SkinUpdateTime",[Context getNSUserDefaultskeyStr:@"skin"]]].length==0) {
//                [dic setObject:@"" forKey:@"UpdateTime"];
//            }else{
//                [dic setObject:[Context getNSUserDefaultskeyStr:[NSString stringWithFormat:@"%@SkinUpdateTime",[Context getNSUserDefaultskeyStr:@"skin"]]] forKey:@"UpdateTime"];
//            }
//            [MobileBankSession sharedInstance].delegate = self;
//            [[MobileBankSession sharedInstance] postToServer:@"IconZipInfoQry.do" actionParams:dic method:@"POST"];
//            [Context setNSUserDefaults:[NSString stringWithFormat:@"%@",[MobileBankSession sharedInstance].changeSkinColor] keyStr:@"skin"];
            [self getUpdateMenuPic];//请求更新的菜单图片
            [self changeSkinFromServe];//更换从服务器获取的菜单图片
            [self btnSelected:sender];
            [self viewWillAppear:YES];//刷新主题界面图片
        }else{
            [MobileBankSession sharedInstance].delegate = self;
            midSkinString = imgArray[sender.tag-100];
        midSkinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        midSkinBtn = sender;
            NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
            [dic setObject:imgArray[sender.tag-100] forKey:@"SkinName"];
            [[MobileBankSession sharedInstance] postToServerStream:@"SkinIconZipQry.do" actionParams:dic];
        }
           }
}
-(void)getUpdateMenuPic
{
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:[MobileBankSession sharedInstance].changeSkinColor forKey:@"SkinName"];
    if ([Context getNSUserDefaultskeyStr:[NSString stringWithFormat:@"%@SkinUpdateTime",[MobileBankSession sharedInstance].changeSkinColor]].length==0) {
        [dic setObject:@"" forKey:@"UpdateTime"];
    }else{
        [dic setObject:[Context getNSUserDefaultskeyStr:[NSString stringWithFormat:@"%@SkinUpdateTime",[MobileBankSession sharedInstance].changeSkinColor]] forKey:@"UpdateTime"];
    }
    [MobileBankSession sharedInstance].delegate = self;
    [[MobileBankSession sharedInstance] postToServer:@"IconZipInfoQry.do" actionParams:dic method:@"POST"];
    
    [Context setNSUserDefaults:[NSString stringWithFormat:@"%@",[MobileBankSession sharedInstance].changeSkinColor] keyStr:@"skin"];

}
-(void)changeSkinFromServe
{
    // 文件管理器
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSString *unZipPath = [Context unZipPath];
    
    // 判断解压缩完的路径文件是否存在
    NSString *bookPath = [NSString stringWithFormat:@"%@/%@.zip",unZipPath,[MobileBankSession sharedInstance].changeSkinColor];
    
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    // 判断解压文件是否可以打开
    if([zipArchive UnzipOpenFile:bookPath])
    {
        // 解压缩到指定路径
        [zipArchive UnzipFileTo:[NSString stringWithFormat:@"%@/%@",unZipPath,[MobileBankSession sharedInstance].changeSkinColor] overWrite:YES];
        NSLog(@"文件解压缩成功");
        //                    BOOL bb = [fm moveItemAtPath:bookPath22 toPath:[NSString stringWithFormat:@"%@/blue%@",unZipPath,[array[0][i]objectForKey:@"IconZipName"]] error:nil];
        //                    if (bb) {
        //                        NSLog(@"移动成功");
        //                    }
    }
//    NSArray *arr = [fm directoryContentsAtPath:[NSString stringWithFormat:@"%@",unZipPath]];
    NSArray *arr = [fm contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@",unZipPath] error:nil];
    NSLog(@"2222%@",arr);
    NSArray *arr33 = [fm directoryContentsAtPath:[NSString stringWithFormat:@"%@/%@",unZipPath,[MobileBankSession sharedInstance].changeSkinColor]];
    NSLog(@"3333%@",arr33);
}
-(void)changeSkin
{
    // 解压缩完的路径
    NSString *unZipPath = [Context unZipPath];
    // 文件管理器
    NSFileManager *fm = [[NSFileManager alloc] init];
    // 判断解压缩完的路径文件是否存在
    //    if(![fm fileExistsAtPath:unZipPath])
    //    {
//    NSLog(@"文件不存在,需要解压缩");
    // book.zip路径
    NSString *bookPath = [NSString stringWithFormat:@"%@/%@.zip",[[NSBundle mainBundle] resourcePath],[MobileBankSession sharedInstance].changeSkinColor];
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    // 判断解压文件是否可以打开
    if([zipArchive UnzipOpenFile:bookPath])
    {
        // 解压缩到指定路径
        [zipArchive UnzipFileTo:unZipPath overWrite:YES];
        NSLog(@"文件解压缩成功");
    }
    else
        NSLog(@"文件无法打开，无法解压缩");
    //    }
    NSArray *arr = [fm directoryContentsAtPath:[NSString stringWithFormat:@"%@/%@",unZipPath,[MobileBankSession sharedInstance].changeSkinColor]];
    NSLog(@"%@",arr);
}

-(void)btnSelected:(UIButton *)sender
{
    
    for (int i=100; i<100+skinImageViewArray.count; i++) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = @"主题设置";
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [self.view sendSubviewToBack:backgroundView];

}
@end
