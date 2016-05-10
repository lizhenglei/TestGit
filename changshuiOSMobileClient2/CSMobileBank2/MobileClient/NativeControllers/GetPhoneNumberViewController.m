//
//  GetPhoneNumberViewController.m
//  MobileClient
//
//  Created by xiaoxin on 15/7/1.
//  Copyright (c) 2015年 pro. All rights reserved.
//

#import "GetPhoneNumberViewController.h"
#pragma ABAddressBookRef
#import <AddressBookUI/AddressBookUI.h>
@interface GetPhoneNumberViewController ()<ABPeoplePickerNavigationControllerDelegate>

@end

@implementation GetPhoneNumberViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView*view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    view.backgroundColor = [UIColor clearColor];
    self.view = view;
    
    
    ABPeoplePickerNavigationController *peoplePicker = [[ABPeoplePickerNavigationController alloc] init];
    peoplePicker.peoplePickerDelegate = self;
    [self presentViewController:peoplePicker animated:YES completion:nil];
    // Do any additional setup after loading the view.
}

#pragma mark -- ABPeoplePickerNavigationControllerDelegate
- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    
    ABMultiValueRef valuesRef = ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFIndex index = ABMultiValueGetIndexForIdentifier(valuesRef,identifier);
    
    //获取个人手机号
    CFStringRef value = ABMultiValueCopyValueAtIndex(valuesRef,index);
    
    //获取个人名字
    CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
    CFTypeRef lastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
    NSString *nameString = [NSString stringWithFormat:@"%@%@",(__bridge NSString *)lastName,(__bridge NSString *)abName];
    
    NSString *phoneNumber = [NSString stringWithFormat:@"%@",(__bridge NSString*)value];
    
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@""];

//    if (![[phoneNumber substringToIndex:1]isEqualToString:@"1"]) {
//        phoneNumber = [phoneNumber substringWithRange:NSMakeRange(3, 11)];
//    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"%@******",(__bridge NSString*)value);
        if ([self.delegate respondsToSelector:@selector(gobackPhone:Name:)]) {
            [self.delegate gobackPhone:phoneNumber Name:nameString];
        }
    }];
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker;
{
    if ([self.delegate respondsToSelector:@selector(gobackPhone:Name:)]) {
        [self.delegate gobackPhone:@"" Name:@""];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
