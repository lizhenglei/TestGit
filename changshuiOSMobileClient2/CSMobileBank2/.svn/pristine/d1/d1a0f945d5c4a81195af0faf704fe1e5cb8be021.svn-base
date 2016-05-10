//
//  CSIIDataAnalysis.m
//  SDPocProject
//
//  Created by Yuxiang on 13-3-2.
//  Copyright (c) 2013年 liuwang. All rights reserved.
//

#import "CSIIDataAnalysis.h"

@implementation CSIIDataAnalysis

+(NSDictionary *)initWithPath:(NSString *)string{
    NSString *path=string;
    NSData *jdata=[[NSData alloc] initWithContentsOfFile:path];
    NSError *error = nil;
    NSDictionary *dicData = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
    return dicData;
}

+(NSArray *)initWithArrayPath:(NSString *)string{
    NSString *path=string;
    NSData *jdata=[[NSData alloc] initWithContentsOfFile:path];
    NSError *error = nil;
    NSArray *dicData = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
    return dicData;
}



@end
