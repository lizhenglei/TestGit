//
//  MyHTTPURLResponse.m
//  MobileBank
//
//  Created by Yuxiang on 13-1-11.
//
//

#import "MyHTTPURLResponse.h"

@implementation MyHTTPURLResponse

-(id)initWithURL:(NSURL *)URL MIMEType:(NSString *)MIMEType expectedContentLength:(NSInteger)length textEncodingName:(NSString *)name{
    
    self=[super initWithURL:URL MIMEType:MIMEType expectedContentLength:length textEncodingName:name];
    if (self) {
        NSInteger statusCode = 200;
        id headerFields = nil;
        double requestTime = 1;
        
        SEL selector = NSSelectorFromString(@"initWithURL:statusCode:headerFields:requestTime:");
        NSMethodSignature *signature = [self methodSignatureForSelector:selector];
        
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:signature];
        [inv setTarget:self];
        [inv setSelector:selector];
        [inv setArgument:&URL atIndex:2];
        [inv setArgument:&statusCode atIndex:3];
        [inv setArgument:&headerFields atIndex:4];
        [inv setArgument:&requestTime atIndex:5];
        
        [inv invoke];
    }
    return self;
}

@end
