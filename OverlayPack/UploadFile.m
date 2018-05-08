//
//  UploadFile.m
//  Upload
//
//  Created by Alonso on 16/6/2.
//  Copyright © 2016年 Alonso. All rights reserved.
//

#import "UploadFile.h"

@implementation UploadFile
// 拼接字符串
static NSString *boundaryStr = @"--";   // 分隔字符串
static NSString *randomIDStr = @"YYWEB";           // 本次上传标示字符串
static NSString *uploadID = @"file";              // 上传(php)脚本中，接收文件字段

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


#pragma mark -
- (NSString *)topStringWithMimeType:(NSString *)mimeType uploadFile:(NSString *)uploadFile
{
    NSMutableString *strM = [NSMutableString string];
    [strM appendFormat:@"%@%@\n", boundaryStr, randomIDStr];
    [strM appendFormat:@"Content-Disposition:form-data;name=\"%@\";filename=\"%@\"\n", uploadID, uploadFile];
    [strM appendFormat:@"Content-Type: %@\n\n", mimeType];
    return [strM copy];
}

- (NSString *)bottomString
{
    NSMutableString *strM = [NSMutableString string];
    [strM appendFormat:@"%@%@\n", boundaryStr, randomIDStr];
    [strM appendString:@"Content-Disposition: form-data; name=\"submit\"\n\n"];
    [strM appendString:@"Submit\n"];
    [strM appendFormat:@"%@%@--\n", boundaryStr, randomIDStr];
    return [strM copy];
}

#pragma mark - 上传文件
- (NSString *)UploadFileWithURL:(NSString *)URL FileName:(NSString*)FileName FilePath:(NSString*)FilePath
{
    NSData *data  =[NSData dataWithContentsOfFile:FilePath];

    // 1> 数据体
    NSString *topStr    = [self topStringWithMimeType:@"file/zip" uploadFile:FileName];
    NSString *bottomStr = [self bottomString];
    
    NSMutableData *dataM = [NSMutableData data];
    [dataM appendData:[topStr dataUsingEncoding:NSUTF8StringEncoding]];
    [dataM appendData:data];
    [dataM appendData:[bottomStr dataUsingEncoding:NSUTF8StringEncoding]];
    
    // 1. Request
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:URL] cachePolicy:0 timeoutInterval:2.0f];
    
    // dataM出了作用域就会被释放,因此不用copy
    request.HTTPBody = dataM;
    
    // 2> 设置Request的头属性
    request.HTTPMethod = @"POST";
    
    // 3> 设置Content-Length
    NSString *strLength = [NSString stringWithFormat:@"%ld", (long)dataM.length];
    [request setValue:strLength forHTTPHeaderField:@"Content-Length"];
    
    // 4> 设置Content-Type
    NSString *strContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", randomIDStr];
    [request setValue:strContentType forHTTPHeaderField:@"Content-Type"];
    
    // 3> 连接服务器发送请求
    NSData *ResultStr = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *String  = [[NSString alloc]initWithData:ResultStr encoding: NSUTF8StringEncoding ];
    
    return String;
}



@end
