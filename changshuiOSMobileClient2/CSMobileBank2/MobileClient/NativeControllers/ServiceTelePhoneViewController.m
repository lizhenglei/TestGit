//
//  ServiceTelePhoneViewController.m
//  MobileClient
//
//  Created by 李正雷 on 15-5-7.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "ServiceTelePhoneViewController.h"
#import "CSIITextField.h"
#import "uiCopyLabel.h"
#import "LDKGloableVariable.h"
#import "XHDrawerController.h"

#define tableViewHeight 44
#define bankWeiChatNumber @"CRCB4009962000"

#define telephoneRect CGRectMake(ScreenWidth-70, 10, 47/2, 46/2)
@interface ServiceTelePhoneViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>{
    UITableView *_tableView;
    NSArray *_cellImages;
    UIImageView *imageView;
    UIButton *allScreenBtn;

}

@end

@implementation ServiceTelePhoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.97f green:0.97f blue:0.97f alpha:1.00f];
    // Do any additional setup after loading the view.
    CGRect tableFrame;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_OR_LATER)
    {
        tableFrame = CGRectMake(0, 0, ScreenWidth, ScreenHeight-80);
    }
    else
#endif
        tableFrame = CGRectMake(0, 64, ScreenWidth, ScreenHeight-72-64);
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 10, ScreenWidth-20, ScreenHeight-72-44-20) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_tableView];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 7;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell==nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 2, tableView.frame.size.width, 40)];
    UIImageView *telephone = [[UIImageView alloc]initWithFrame:telephoneRect];
    telephone.image = [UIImage imageNamed:@"telephone"];
    [cell.contentView addSubview:view];
  
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"客服电话";
            cell.textLabel.font = [UIFont systemFontOfSize:17];
        }
            break;
        case 1:
        {
            UILabel *firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 110, 30)];
            UILabel *secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 5, 50, 30)];
            firstLabel.textColor = [UIColor colorWithRed:0.01f green:0.51f blue:0.78f alpha:1.00f];;
            firstLabel.text = @"962000";
            secondLabel.text = @"(江苏)";
            firstLabel.backgroundColor = [UIColor clearColor];
            secondLabel.backgroundColor = [UIColor clearColor];
            [view addSubview:firstLabel];
            [view addSubview:secondLabel];
            [cell.contentView addSubview:telephone];
        }
            break;
        case 2:
        {
            UILabel *firstLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 110, 30)];
            UILabel *secondLabel = [[UILabel alloc]initWithFrame:CGRectMake(120, 5, 50, 30)];
            firstLabel.textColor = [UIColor colorWithRed:0.01f green:0.51f blue:0.78f alpha:1.00f];
            firstLabel.backgroundColor = [UIColor clearColor];
            secondLabel.backgroundColor = [UIColor clearColor];
            firstLabel.text = @"4009962000";
            secondLabel.text = @"(全国)";
            [view addSubview:firstLabel];
            [view addSubview:secondLabel];
            [cell.contentView addSubview:telephone];
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"网站首页";
            cell.textLabel.font = [UIFont systemFontOfSize:17];
        }
            break;
        case 4:
        {
            cell.textLabel.text = @"http://www.csrcbank.com";
            cell.textLabel.textColor = [UIColor colorWithRed:0.01f green:0.51f blue:0.78f alpha:1.00f];;
        }
            break;
        case 5:
        {
            cell.textLabel.text = @"微信公众号";
            cell.textLabel.font = [UIFont systemFontOfSize:17];
        }
            break;
        case 6:
        {
            
           uiCopyLabel *weixinNumLabel = [[uiCopyLabel alloc]initWithFrame:CGRectMake(20, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height)];
            weixinNumLabel.text = bankWeiChatNumber;
            weixinNumLabel.backgroundColor = [UIColor clearColor];
//            weixinNumTextField.delegate= self;
            weixinNumLabel.textColor = [UIColor colorWithRed:0.01f green:0.51f blue:0.78f alpha:1.00f];
            [cell.contentView addSubview:weixinNumLabel];
            
            
//            cell.textLabel.text = bankWeiChatNumber;//微信公众号
//            cell.textLabel.textColor = [UIColor colorWithRed:0.01f green:0.51f blue:0.78f alpha:1.00f];
//            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            [btn setTitle:@"点击扫描二维码" forState:UIControlStateNormal];
//            [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
//            btn.frame = CGRectMake(ScreenWidth-20-130, 5, 120, 30);
//            [btn setTitleColor:[UIColor colorWithRed:0.95f green:0.54f blue:0.09f alpha:1.00f] forState:UIControlStateNormal];
//            btn.titleLabel.font = [UIFont systemFontOfSize:15];
//            [cell.contentView addSubview:btn];
        }
            break;
        default:
            break;
    }
        return cell;
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *real = [textField.text stringByReplacingCharactersInRange:range withString:string];
    return real.length==14;
}

-(void)btnClick
{
    allScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    allScreenBtn.frame = CGRectMake(0, 0, _tableView.frame.size.width, _tableView.frame.size.height);
    allScreenBtn.frame = self.view.bounds;
    [allScreenBtn addTarget:self action:@selector(btnDismiss) forControlEvents:UIControlEventTouchUpInside];
    allScreenBtn.backgroundColor = [UIColor blackColor];
    [_tableView addSubview:allScreenBtn];
    
    allScreenBtn.alpha = 0.7;
    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(_tableView.frame.size.width/2-10, self.view.frame.size.height-10, 20, 20)];
    [self.view addSubview:imageView];

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    imageView.frame = CGRectMake(ScreenWidth/2-100, ScreenHeight/2-100-64, 200, 200);
    imageView.image = [UIImage imageNamed:@"wxGuanZhu"];
    [UIView commitAnimations];
}
-(void)btnDismiss
{
    [imageView removeFromSuperview];
    [allScreenBtn removeFromSuperview];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.row==1) {
        [self makeACall:@"962000"];
    }
    else if (indexPath.row ==2)
    {
        [self makeACall:@"4009962000"];
    }
    else if (indexPath.row ==4){
        UIAlertView*alertview = [[UIAlertView alloc]initWithTitle:@"提示" message:@"是否访问官方网站" delegate:self cancelButtonTitle:@"确认" otherButtonTitles:@"取消", nil];
        alertview.tag = 101;
        [alertview show];
    }
    else if(indexPath.row ==6){
        NSLog(@"点击扫描二维码");
//        [self btnClick];
    }else{
    
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth-20, 265/2)];
    headerView.backgroundColor = [UIColor whiteColor];
    UIImageView *headerImageView = [[UIImageView alloc]initWithFrame:CGRectMake((ScreenWidth-20)/2-265/4, 0, 265/2, 265/2)];
    headerImageView.image = [UIImage imageNamed:@"finish_logo"];
    [headerView addSubview:headerImageView];
    return headerView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 265/2;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = @"关于我们";

}


- (void) makeACall:(NSString *)phoneNum {//打电话，先弹框再打电话
    NSString *num = [[NSString alloc] initWithFormat:@"telprompt:%@",phoneNum];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]]; //拨号
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return tableViewHeight;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{

    alertView.hidden = YES;
    if (alertView.tag == 101) {
        if (buttonIndex==0) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"http://www.csrcbank.com"]];
        }else{}
    }
//    NSString *urlString = @"http://www.csrcbank.com";
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
