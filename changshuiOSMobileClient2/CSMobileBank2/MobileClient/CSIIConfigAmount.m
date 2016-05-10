//
//  CSIIConfigAmount.m
//  BankofYingkou
//  开发：
//  维护：
//  Created by 刘旺 on 12-6-4.
//  Copyright (c) 2012年 科蓝公司. All rights reserved.
//

#import "CSIIConfigAmount.h"

@implementation CSIIConfigAmount
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <errno.h>
/**
    char  str[150];
    for (double i = 0; i<100; i++) {
        Amount_c(str, i);
        DebugLog(@"%@", [[NSString alloc]initWithCString:str encoding:NSUTF8StringEncoding]);
    }
 */
/************************************************************
 * 函数: Amount_c
 * 功能: 小写金额转化为大写
 * 参数: number输入的小写金额, dest存放转化后的大写金额
 * 返回: 0执行成功，－1执行失败
 ************************************************************/

int num_to(char *str, char num);
int tmp_4_bit(char *dest, const char *src, int ch);

int Amount_c(char *str, double number)
{
    /*pi临时指针, tmp_s存放number转化后的串, format模式记录:
     0(1万以下) 1(1万到一亿) 2(一亿到一万亿) 3(一万亿以上),
     pun_bit记录整数位数, high记录余数, ch汉字编码占字节数,
     dest, src, ch作为tmp_4_bit入口参数,pa pb存放角 分转化后
     的金额大写, i临时整数,num_flag记录正负*/
    char *pi;
    char *pa;
    char *pb;
    char tmp_s[24];
    char *dest;
    char src[5];
    int  format;
    int  pun_bit;
    int  high;
    int  i;
    int  ch;
    int  num_flag;
    
    assert(str != NULL);
    
    ch = strlen("零");/*记录当前环境下汉字的存储字节数*/
    
    *str = '\0';
    num_flag = 0;
    if (number < 0) {
        num_flag = 1;
        strcat(str, "负");
        number = -number;
    }
    
    /*number近似两位后转化为字符串保存在tmp_s中*/
    sprintf(tmp_s, "%lf", number);
    pi = tmp_s;
    for (pun_bit=0; *pi++!='.'; pun_bit++);/*记录整数位数*/
    
    if (*(pi+2) >= '5') {
        number += 0.01 - 0.005; /*防止9.9999999这样的数，所以要减0.005*/
    }/*保留两位小数, 四舍五入*/
    sprintf(tmp_s, "%lf", number);
    
    /*处理整数部分*/
    if (*tmp_s == '0') {
        strcat(str, "零元");
    }
    else {
        format = (pun_bit - 1) / 4;/*记录模式0 1 2 3*/
        high = pun_bit % 4;/*记录小数点向左四位一分，最后余几位*/
        if (high == 0) {
            high = 4;
        }/*修正*/
        
        if (format > 3) {
            errno = EINVAL;
            return -1;
        }/*只要number不溢出，就可以处理*/
        
        dest = malloc(7 * ch + 1);
        
        if (dest == NULL) {
            errno = ENOMEM;
            return -1;
        }
        
        pi = tmp_s;
        *(src+4) = '\0';
        switch (format) {
            case 3:
                i = 0;
                while (i < 4-high) {
                    *(src+i) = '0';
                    i++;
                }/*不满四位时高位补零*/
                while (i < 4) {
                    *(src+i) = *pi++;
                    i++;
                }/*记录要先转化的四位数字*/
                /*进行最终记录*/
                if (tmp_4_bit(dest, src, ch) == -1) {
                    return -1;
                }
                strcat(str, dest);
                strcat(str, "万");
                
            case 2:
                i = 0;
                if (format == 2 ) {
                    while (i < 4-high) {
                        *(src+i) = '0';
                        i++;
                    }
                }
                while (i < 4) {
                    *(src+i) = *pi++;
                    i++;
                }
                if (tmp_4_bit(dest, src, ch) == -1) {
                    return -1;
                }
                if (strcmp(dest,"零") != 0) {
                    strcat(str, dest);
                }
                strcat(str,"亿");
                
            case 1:
                i = 0;
                if (format == 1 ) {
                    while (i < 4-high) {
                        *(src+i) = '0';
                        i++;
                    }
                }
                while (i < 4) {
                    *(src+i) = *pi++;
                    i++;
                }
                if (tmp_4_bit(dest, src, ch) == -1) {
                    return -1;
                }
                strcat(str, dest);
                if (strcmp(dest,"零") != 0) {
                    strcat(str, "万");
                }
                
            case 0:
                i = 0;
                if (format == 0 ) {
                    while (i < 4-high) {
                        *(src+i) = '0';
                        i++;
                    }
                }
                while (i < 4) {
                    *(src+i) = *pi++; 
                    i++;
                }
                if (tmp_4_bit(dest, src, ch) == -1) {
                    return -1;
                }
                /*前面多次出现零时的处理*/
                if ((strcmp(str+strlen(str)-ch, "零")==0)
                    && (strncmp(dest, "零", 2) == 0)) {
                    strcpy(dest, dest+ch);
                }
                
                if ((strcmp(dest, "零")!=0) && (*dest!='\0')) {
                    strcat(str, dest);
                    strcat(str, "元");
                }
                else if (strcmp(str+strlen(str)-ch, "零") == 0) {
                    *(str+strlen(str)-ch) = '\0';
                    strcat(str, "元");
                }
                else {
                    strcat(str, "元");
                }
        }
        
        free(dest);
        
        if (strncmp(str+ch*num_flag, "零", ch) == 0) {
            strcpy(str+ch*num_flag, str+ch*num_flag+ch);
        }/*去掉开头的零*/
    }
    
    /*处理小数部分*/
    pa = malloc(ch);
    pb = malloc(ch);
    if ((pa==NULL) || (pb==NULL)) {
        errno = ENOMEM;
        return -1;
    }
    
    i = pun_bit + 1;/*记录小数在tmp_s字符串开始位置*/
    if (num_to(pa, *(tmp_s+i)) == -1) {
        return -1;
    }
    if (num_to(pb, *(tmp_s+i+1)) == -1) {
        return -1;
    }
    
    if (*(tmp_s+i)=='0' && *(tmp_s+i+1)=='0') {
        strcat(str, "整");
    }
    
    if (*(tmp_s+i)=='0' && *(tmp_s+i+1)!='0') {
        strcat(str, "零");
        strcat(str, pb);
        strcat(str, "分");
    }
    
    if (*(tmp_s+i) != '0') {
        strcat(str, pa);
        strcat(str, "角");
        if (*(tmp_s+i+1) != '0') {
            strcat(str, pb);
            strcat(str, "分");
        }
    }
    
    free(pa);
    free(pb);
    
    return 0;
}

/**********************************************************
 * 函数: num_to
 * 功能: 将输入的char型数字转化为金额大写
 **********************************************************/

int num_to( char *str, char num)
{
    assert(str != NULL);
    switch (num) {
        case '0': strcpy(str, "零");
            break;
        case '1': strcpy(str, "壹");
            break;
        case '2': strcpy(str, "贰");
            break;
        case '3': strcpy(str, "叁");
            break;
        case '4': strcpy(str, "肆");
            break;
        case '5': strcpy(str, "伍");
            break;
        case '6': strcpy(str, "陆");
            break;
        case '7': strcpy(str, "柒");
            break;
        case '8': strcpy(str, "捌");
            break;
        case '9': strcpy(str, "玖");
            break;
        default:  errno = EINVAL;
            return -1;
    }
    
    return 0;
}

/************************************************************
 * 函数: tmp_4_bit
 * 功能: 将一个含有4个数字的字符串，转化为金额大写
 * 参数: dest存放转化后的大写金额字符串, src含四个数字的源
 *       字符串, ch当前环境下的汉字的存储字节数
 ************************************************************/

int tmp_4_bit(char *dest, const char *src, int ch)
{
    int  i;
    char *last;/*记录当前dest字符串结尾位置*/
    
    assert((dest!=NULL) && (src!=NULL));
    
    last = dest;
    *last = '\0';/*dest中未存任何值时，首位置记为结尾*/
    
    if (strcmp(src, "0000") == 0) {
        strcat(dest, "零");
        return 0;
    }/*src全0时返回*/
    
    for (i=0; i!=4; i++) {
        switch (*(src+i)) {
            case '0':
                if (strcmp(last-ch, "零") != 0) {
                    /*当dest前存放汉字零时if条件判断有问题*/
                    strcat(dest, "零");
                    last += ch;
                }/*多次出现“零”时，只记录一个*/
                continue;/*出现零时，无需记录“拾佰仟”*/
            case '1':
                strcat(dest, "壹");
                last += ch;
                break;
            case '2':
                strcat(dest, "贰");
                last += ch;
                break;
            case '3':
                strcat(dest, "叁");
                last += ch;
                break;
            case '4':
                strcat(dest, "肆");
                last += ch;
                break;
            case '5':
                strcat(dest, "伍");
                last += ch;
                break;
            case '6':
                strcat(dest, "陆");
                last += ch;
                break;
            case '7':
                strcat(dest, "柒");
                last += ch;
                break;
            case '8':
                strcat(dest, "捌");
                last += ch;
                break;
            case '9':
                strcat(dest, "玖");
                last += ch;
                break;
            default:
                errno = EINVAL;
                return -1;
        }
        
        switch (i) {
            case 0:
                strcat(dest, "仟");
                last += ch;
                break;
            case 1:
                strcat(dest, "佰");
                last += ch;
                break;
            case 2:
                strcat(dest, "拾");
                last += ch;
                break;
            default:
                break;
        }
    }
    
    if (strcmp(last-ch, "零") == 0) {
        *(last-ch) = '\0';
    }/*转化后, 结尾的零去除*/
    
    return 0;
}
@end
