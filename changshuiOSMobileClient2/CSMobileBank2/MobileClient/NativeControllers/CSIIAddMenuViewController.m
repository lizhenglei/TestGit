//
//  CSIIAddMenuViewController.h.m
//  MobileClient
//
//  Created by shuangchun che on 13-7-24.
//  Copyright (c) 2013年 pro. All rights reserved.

#import "CSIIAddMenuViewController.h"
#import "CSIIMenuViewController.h"


#define checkBtnFrame2 CGRectMake(10, 0, 44, 44)//二级菜单按钮
#define checkImgFrame2 CGRectMake(50,7,30,30)//二级菜单图片
#define checkNameFrame2 CGRectMake(95,12,120,20)//二级菜单名字

#define checkBtnFrame1 CGRectMake(ScreenWidth -50, 0, 44, 44)//一级菜单按钮
#define checkImgFrame1 CGRectMake(10,7,30,30)//一级菜单图片
#define checkNameFrame1 CGRectMake(50,12,120,20)//一级菜单名字

#define titleImgFrame CGRectMake(25,7,30,30)//一级菜单下的添加头菜单
#define titleNameFrame CGRectMake(70,12,120,20)

@interface CSIIAddMenuViewController ()
{
    
    NSMutableArray *addedMenuArray;
    NSMutableArray *displayMenuArray;
    NSMutableArray *firstMenuArray;
    UIButton *doneButton;
    NSMutableArray *jieArray;
    int _theTimes;
}
@end

@implementation CSIIAddMenuViewController
@synthesize menuTable;

-(id)initWithDisplayList:(NSMutableArray*)dicList{
    if (self = [super init]) {
        for (int i=0; i<dicList.count; i++)
        {
            if ([[dicList[i] objectForKey:MENU_ACTION_ID] isEqualToString:ACTIONID_FOR_EXIT])
            {
                NSMutableArray *displayArr= [[NSMutableArray alloc]initWithArray:dicList];
                [displayArr removeObjectAtIndex:i];
                displayMenuArray = displayArr;
                break;
            }
        }
        if(displayMenuArray == nil)
        {
            for (int x=0; x<dicList.count; x++) {
                if ([[[dicList objectAtIndex:x]objectForKey:@"ActionId"]isEqualToString:@"20000171"]) {
                    [dicList removeObjectAtIndex:x];
                }
            }
            displayMenuArray = (NSMutableArray *)dicList;
        }
        firstMenuArray = [[NSMutableArray alloc]init];
        NSArray *addedMenuArr = [[NSUserDefaults standardUserDefaults] objectForKey:kAddedMenu];
        addedMenuArray = [[NSMutableArray alloc]initWithArray:addedMenuArr];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    DebugLog(@"%@",NSStringFromClass([self class]));
    ((UILabel*)[self.navigationController.navigationBar viewWithTag:99]).text = @"添加";
    //self.rightButton.hidden = YES;
    //    doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    doneButton.frame = CGRectMake(0 ,0 ,80/2 ,80/2 );
    doneButton.tag = 11;
    doneButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [doneButton setTitle:@"完成" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:doneButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (doneButton!=nil)
    {
        [doneButton removeFromSuperview];
        doneButton = nil;
    }
    _theTimes = 0;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect rectTable;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    if (IOS7_OR_LATER)
    {
        rectTable = CGRectMake(0, 0, ScreenWidth, self.view.bounds.size.height-75-7);
    }
    else
#endif
        rectTable = CGRectMake(0, 0, ScreenWidth, self.view.bounds.size.height-64-30-7);
    self.menuTable = [[UITableView alloc]initWithFrame:rectTable style:UITableViewStyleGrouped];
    self.menuTable.backgroundView=nil;
    self.menuTable.backgroundColor=[UIColor clearColor];
    self.menuTable.delegate=self;
    self.menuTable.dataSource=self;
    [self.view addSubview:menuTable];
    
    
    // Do any additional setup after loading the view.
}

#pragma mark
#pragma mark UITableView DataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [displayMenuArray count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSString *CellIdentifier=[NSString stringWithFormat:@"%ld %ld",(long)indexPath.section,(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc]init];
        //添加换肤更改
        UIImage *image22 = [Context ImageName:[[displayMenuArray objectAtIndex:indexPath.row]objectForKey:MENU_ACTION_IMAGE]];
        if (image22) {
            imageView.image = image22;
        }else{
            imageView.image = [Context ImageName:@"tsfwimg"];
        }
        [cell.contentView addSubview:imageView];
        
        //添加label文字
        UILabel *label=[[UILabel alloc]initWithFrame:checkNameFrame2];
        label.textColor=[UIColor blackColor];
        
        label.textAlignment=NSTextAlignmentLeft;
        label.backgroundColor=[UIColor clearColor];
        label.text=[[displayMenuArray objectAtIndex:indexPath.row] objectForKey:MENU_ACTION_NAME];
        [cell.contentView addSubview:label];
        
        if ([[displayMenuArray objectAtIndex:indexPath.row] objectForKey:MENU_LIST]!=nil
            && ((NSArray*)[[displayMenuArray objectAtIndex:indexPath.row] objectForKey:MENU_LIST]).count>0)//说明有下一级菜单，添加该菜单
        {
            if (_theTimes) {
                label.font = [UIFont systemFontOfSize:17];
                label.frame = titleNameFrame;
                imageView.frame = titleImgFrame;
            }
            if (self.theTimes) {//第二次点击一级菜单，添加，
                NSLog(@"-------%d",self.theTimes);
                UIButton *checkBtn = [[UIButton alloc]initWithFrame:checkBtnFrame1];
                [checkBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
                [checkBtn setImage:[UIImage imageNamed:@"check_sec"] forState:UIControlStateSelected];
                checkBtn.tag = 100;
                [checkBtn addTarget:self action:@selector(addFirstMenu:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:checkBtn];
                if ([[CSIIMenuViewController sharedInstance]isMyFavoriteFixedMenu:[displayMenuArray objectAtIndex:indexPath.row]]==YES||[self isAddedMenu:[displayMenuArray objectAtIndex:indexPath.row]]==YES) {
                    checkBtn.selected = YES;
                }else{
                    checkBtn.selected = NO;
                }
            }else{//可以把点击按钮的一级菜单添加或删除
                label.font=[UIFont systemFontOfSize:15];
                imageView.frame = checkImgFrame2;
                UIButton *checkBtn = [[UIButton alloc]initWithFrame:checkBtnFrame2];
                checkBtn.tag = indexPath.row+100;
                [checkBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
                [checkBtn setImage:[UIImage imageNamed:@"check_sec"] forState:UIControlStateSelected];
                [checkBtn addTarget:self action:@selector(addFirstMenu:) forControlEvents:UIControlEventTouchUpInside];
                
                if ([[CSIIMenuViewController sharedInstance] isMyFavoriteFixedMenu:[displayMenuArray objectAtIndex:indexPath.row]] == YES
                    || [self isAddedMenu:[displayMenuArray objectAtIndex:indexPath.row]] == YES) {
                    checkBtn.selected = YES;
                }else{
                    checkBtn.selected = NO;
                }
                [cell.contentView addSubview:checkBtn];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }

            
        }
        else if([[CSIIMenuViewController sharedInstance] isMyFavoriteFixedMenu:[displayMenuArray objectAtIndex:indexPath.row]] == YES
                || [self isAddedMenu:[displayMenuArray objectAtIndex:indexPath.row]] == YES)
        {
            label.font=[UIFont systemFontOfSize:15];
            imageView.frame = checkImgFrame2;
            UIButton *checkBtn = [[UIButton alloc]initWithFrame:checkBtnFrame2];
            [checkBtn setImage:[UIImage imageNamed:@"check_sec"] forState:UIControlStateSelected];
            [checkBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
            checkBtn.tag = indexPath.row+100;
            [checkBtn addTarget:self action:@selector(addFirstMenu:) forControlEvents:UIControlEventTouchUpInside];
            checkBtn.selected = YES;
            [cell.contentView addSubview:checkBtn];
            
            
        }
        
        
        else{
            UIButton *checkBtn = [[UIButton alloc]initWithFrame:checkBtnFrame2];
            [checkBtn setImage:[UIImage imageNamed:@"check"] forState:UIControlStateNormal];
            [checkBtn setImage:[UIImage imageNamed:@"check_sec"] forState:UIControlStateSelected];
            checkBtn.tag = indexPath.row+100;
            [checkBtn addTarget:self action:@selector(addFirstMenu:) forControlEvents:UIControlEventTouchUpInside];
            checkBtn.selected = NO;
            [cell.contentView addSubview:checkBtn];
            label.font=[UIFont systemFontOfSize:15];
            imageView.frame = checkImgFrame2;
        }
        
    }
    if (!indexPath.row&&self.headerArray.count>0) {
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(60, 3, 260, 44)];
        label.textColor=[UIColor blackColor];
        label.font=[UIFont systemFontOfSize:18];
        label.textAlignment=NSTextAlignmentLeft;
        label.backgroundColor=[UIColor clearColor];
        label.text=[[_headerArray objectAtIndex:0] objectForKey:MENU_ACTION_NAME];
        [cell.contentView addSubview:label];
        
    }
    
    //下面的是不能添加本来就有的
    UIImageView *imageView = [[UIImageView alloc]init];
    UILabel *label=[[UILabel alloc]initWithFrame:checkNameFrame2];
    for (int i=0; i<[[_firstMenuDic objectForKey:MENU_LIST] count]; i++) {
        if ([[[_firstMenuDic objectForKey:MENU_LIST][i]objectForKey:MENU_ACTION_ID]isEqualToString:[displayMenuArray[indexPath.row]objectForKey:MENU_ACTION_ID]]) {
            
            label.font=[UIFont systemFontOfSize:15];
            UIButton *checkBtn;
            if (self.theTimes) {
                checkBtn = [[UIButton alloc]initWithFrame:checkBtnFrame1];
                imageView.frame = titleImgFrame;
                label.font = [UIFont systemFontOfSize:17];
                label.frame = titleNameFrame;
                checkBtn.enabled = NO;
            }else{
                checkBtn = [[UIButton alloc]initWithFrame:checkBtnFrame2];
                imageView.frame = checkImgFrame2;
            }
            [checkBtn setImage:[UIImage imageNamed:@"check_sec"] forState:UIControlStateNormal];
            checkBtn.enabled = NO;
            [cell.contentView addSubview:checkBtn];
        }
    }
    return cell;
}
-(void)addFirstMenu:(UIButton *)send
{

    for (int i=0; i<[[_firstMenuDic objectForKey:MENU_LIST] count]; i++) {
        if ([[[_firstMenuDic objectForKey:MENU_LIST][i]objectForKey:MENU_ACTION_ID]isEqualToString:[displayMenuArray[send.tag-100]objectForKey:MENU_ACTION_ID]]) {
            return;
        }
    }

    if (send.selected == YES) {
        for(int i=0; i<addedMenuArray.count;i++)
        {
            if([[[displayMenuArray objectAtIndex:send.tag-100] objectForKey:MENU_ACTION_NAME] isEqualToString:[[addedMenuArray objectAtIndex:i] objectForKey:MENU_ACTION_NAME]])
            {
                [addedMenuArray removeObjectAtIndex:i];
            }
        }
    }else{
        [addedMenuArray addObject:[displayMenuArray objectAtIndex:send.tag-100]];
    }
    send.selected = !send.selected;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([[displayMenuArray objectAtIndex:indexPath.row] objectForKey:MENU_LIST]!=nil
        && ((NSArray*)[[displayMenuArray objectAtIndex:indexPath.row] objectForKey:MENU_LIST]).count>0)//说明有下一级菜单
    {
        if (self.theTimes) {
            for (int i=0; i<[[_firstMenuDic objectForKey:MENU_LIST] count]; i++) {
                if ([[[_firstMenuDic objectForKey:MENU_LIST][i]objectForKey:MENU_ACTION_ID]isEqualToString:[displayMenuArray[indexPath.row]objectForKey:MENU_ACTION_ID]]) {
                    return;                }
            }
            UIButton *btn = (UIButton *)[[[tableView.visibleCells objectAtIndex:0] contentView ] viewWithTag:100];
            btn.selected = !btn.selected;
            if (btn.selected) {
                [addedMenuArray addObject:[displayMenuArray objectAtIndex:0]];
            }else{
                for (int i=0; i<addedMenuArray.count; i++) {
                    if ([[[displayMenuArray objectAtIndex:indexPath.row]objectForKey:MENU_ACTION_NAME] isEqualToString:[[addedMenuArray objectAtIndex:i] objectForKey:MENU_ACTION_NAME]]) {
                        [addedMenuArray removeObjectAtIndex:i];
                    }
                }
            }
        }
        if (!self.theTimes) {
            
            NSMutableArray *array = [[NSMutableArray alloc]init];
            [array addObject:[displayMenuArray objectAtIndex:indexPath.row]];
            for (int i=0; i<[[[displayMenuArray objectAtIndex:indexPath.row] objectForKey:MENU_LIST] count]; i++) {
                [array addObject:[[[displayMenuArray objectAtIndex:indexPath.row] objectForKey:MENU_LIST]objectAtIndex:i]];
            }
            _theTimes++;
            CSIIAddMenuViewController *addMenuVc = [[CSIIAddMenuViewController alloc]initWithDisplayList: array];
            addMenuVc.firstMenuDic = _firstMenuDic;
            addMenuVc.theTimes = _theTimes;
            [[self navigationController] pushViewController:addMenuVc animated:YES];
        }
        
    }
    else if([[CSIIMenuViewController sharedInstance]isMyFavoriteFixedMenu:[displayMenuArray objectAtIndex:indexPath.row]] == NO){
        if ([self isAddedMenu:[displayMenuArray objectAtIndex:indexPath.row]] == NO){
            
            for (int i=0; i<[[_firstMenuDic objectForKey:MENU_LIST] count]; i++) {
                if ([[[_firstMenuDic objectForKey:MENU_LIST][i]objectForKey:MENU_ACTION_ID]isEqualToString:[displayMenuArray[indexPath.row]objectForKey:MENU_ACTION_ID]]) {
                    
                    return;
                }
            }
            UIButton *checkBtn = (UIButton *)[self.view viewWithTag:indexPath.row+100];
            checkBtn.selected = !checkBtn.selected;
            [addedMenuArray addObject:[displayMenuArray objectAtIndex:indexPath.row]];
        }
        else if ([self isAddedMenu:[displayMenuArray objectAtIndex:indexPath.row]] == YES){
            
            for(int i=0; i<addedMenuArray.count;i++)
            {
                if([[[displayMenuArray objectAtIndex:indexPath.row] objectForKey:MENU_ACTION_NAME] isEqualToString:[[addedMenuArray objectAtIndex:i] objectForKey:MENU_ACTION_NAME]])
                {
                    [addedMenuArray removeObjectAtIndex:i];
                    UIButton *checkBtn = (UIButton *)[self.view viewWithTag:indexPath.row+100];
                    checkBtn.selected = !checkBtn.selected;
                    break;
                }
            }
        }
        
    }
    else if([[CSIIMenuViewController sharedInstance]isMyFavoriteFixedMenu:[displayMenuArray objectAtIndex:indexPath.row]] == YES)
    {
        NSLog(@"已选择");
        if ([self isAddedMenu:[displayMenuArray objectAtIndex:indexPath.row]] == NO){
            UIButton *checkBtn = (UIButton *)[self.view viewWithTag:indexPath.row+100];
            checkBtn.selected = !checkBtn.selected;
            [addedMenuArray addObject:[displayMenuArray objectAtIndex:indexPath.row]];
            
        }else if ([self isAddedMenu:[displayMenuArray objectAtIndex:indexPath.row]] == YES)
        {
            for(int i=0; i<addedMenuArray.count;i++)
            {
                if([[[displayMenuArray objectAtIndex:indexPath.row] objectForKey:MENU_ACTION_NAME] isEqualToString:[[addedMenuArray objectAtIndex:i] objectForKey:MENU_ACTION_NAME]])
                {
                    [addedMenuArray removeObjectAtIndex:i];
                    UIButton *checkBtn = (UIButton *)[self.view viewWithTag:indexPath.row+100];
                    checkBtn.selected = !checkBtn.selected;
                    break;
                }
            }
        }
    }
    
}
-(void)check:(UIButton *)btn
{
    btn.selected = !btn.selected;
}
-(void)doneButtonAction:(id)sender{
    
    [doneButton removeFromSuperview];
    doneButton = nil;
    [[NSUserDefaults standardUserDefaults] setObject:addedMenuArray forKey:kAddedMenu];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.navigationController popToViewController:self.navigationController.viewControllers[0] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)isAddedMenu:(NSDictionary *)menuDic
{
    for(int i=0; i<addedMenuArray.count;i++)
    {
        if([[menuDic objectForKey:MENU_ACTION_NAME] isEqualToString:[[addedMenuArray objectAtIndex:i] objectForKey:MENU_ACTION_NAME]])
        {
            return  YES;
        }
    }
    
    return NO;
}

@end
