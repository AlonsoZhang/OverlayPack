//
//  APoverlayViewController.m
//  OverlayPack
//
//  Created by Alonso on 2017/4/26.
//  Copyright © 2017年 Alonso. All rights reserved.
//

#import "APoverlayViewController.h"
#define ServerURL @"http://10.42.222.70/AEOverlay"

@interface APoverlayViewController ()

@end

@implementation APoverlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.productName.stringValue = @"D21";
    version = [[NSUserDefaults standardUserDefaults] objectForKey:@"APversion"];
    stationname = [[NSUserDefaults standardUserDefaults] objectForKey:@"APstationname"];
    
    NSArray * namearray = [stationname componentsSeparatedByString:@"_"];
    NSString *finalname = [[NSString alloc]init];
    for (NSString *name in namearray) {
        if ([name containsString:@"Mercury"]||[name containsString:@"AUtility"]||[name containsString:@"V0."]||[name containsString:@"Artemis"]) {
        }else{
            if ([finalname length] > 0) {
                finalname = [NSString stringWithFormat:@"%@_%@",finalname,name];
            }else{
                finalname = name;
            }
        }
    }
    self.stationName.stringValue = ([finalname length] > 0 ? finalname:stationname);
    if ([version floatValue] > 0) {
        releasenote = [NSString stringWithFormat:@"1. \n2. Change version from %.2f to %@.",[version floatValue]-0.01,version];
        self.releaseNote.textColor = [NSColor blackColor];
    }else{
        releasenote = [NSString stringWithFormat:@"No version number in main.plist, please check again!"];
        self.send.enabled = NO;
        self.releaseNote.textColor = [NSColor redColor];
    }
    self.releaseNote.string = releasenote;
    sendmailDic = [[NSMutableDictionary alloc]init];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"APversion"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"APstationname"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)uploadandsend:(NSButton *)sender {
    NSString *releasemsg = [NSString stringWithFormat:@"%@",self.releaseNote.string];
    NSFileManager *overlayfm = [NSFileManager defaultManager];
    NSArray *desktoppaths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    NSString *packagename = [NSString stringWithFormat:@"%@_%@ %@_V%@",[dateFormatter stringFromDate:[NSDate date]],[self.productName.stringValue lowercaseString],[self.stationName.stringValue lowercaseString],version];
    NSString *overlaypath = [NSString stringWithFormat:@"%@/%@",[desktoppaths objectAtIndex:0],packagename];
    //创建桌面文件夹
    if([overlayfm createDirectoryAtPath:overlaypath withIntermediateDirectories:false attributes:nil error:nil]){
        //隐藏 contents 文件夹
        [self RunCMD:[NSString stringWithFormat:@"chflags hidden %@/Contents",[[NSUserDefaults standardUserDefaults] objectForKey:@"appPath"]]];
        
        //将 bundle 中文件移到 overlay 文件夹中
        [self RunCMD:[NSString stringWithFormat:@"cp -R %@/ %@",[[NSBundle mainBundle]pathForResource:@"APoverlay" ofType:nil],[self fit:overlaypath]]];
        
        //将 overlay app 复制到 /Users/gdlocal/Desktop 中
        NSString * desktopPath = [overlaypath stringByAppendingString:@"/Users/gdlocal/Desktop"];
        [self RunCMD:[NSString stringWithFormat:@"cp -R %@ %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"appPath"],[self fit:desktopPath]]];
        
        //打包生成 overlay
        [self RunCMD:[NSString stringWithFormat:@"ditto -cVvk --keepParent %@/ %@.zip",[self fit:overlaypath],[self fit:overlaypath]]];

        if ([overlayfm fileExistsAtPath:overlaypath]) {
            
            [self ShowMessage:@"Waiting for upload..." Error:false];
            
            //上传 zip 到 server
            UploadFile *UPtoWEB = [[UploadFile alloc]init];
            NSString * returnmsg = [UPtoWEB UploadFileWithURL:[NSString stringWithFormat:@"%@/upload_file.php",ServerURL] FileName:[NSString stringWithFormat:@"%@.zip",packagename] FilePath:[NSString stringWithFormat:@"%@.zip",overlaypath]];
            if ([returnmsg length] == 0) {
                [self ShowMessage:@"No response for upload!" Error:true];
            }else{
                [self ShowMessage:returnmsg Error:false];
                NSDictionary *releaseDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self.stationName.stringValue,[NSString stringWithFormat:@"V%@",version],releasemsg,nil] forKeys:[NSArray arrayWithObjects:@"station",@"version",@"releasenote",nil]];
                NSMutableArray *releaseArray = [NSMutableArray arrayWithObject:releaseDict];
                [sendmailDic setObject:releaseArray forKey:@"release"];
                NSArray *pathArray = [NSArray arrayWithArray:[returnmsg  componentsSeparatedByString:@"\n"]];
                [sendmailDic setObject:@"No AELimits." forKey:@"AELimits"];
                [sendmailDic setObject:pathArray.lastObject forKey:@"download"];
                if(sendmailDic){
                    [self sendmail];
                }
            }
        }else{
            [self ShowMessage:[NSString stringWithFormat:@"%@ folder isn't on the desktop!",packagename] Error:true];
        }
        //删除原来 overlay folder
        [self RunCMD:[NSString stringWithFormat:@"rm -rf %@",[self fit:overlaypath]]];
        
        //删除 overlay
        [self RunCMD:[NSString stringWithFormat:@"rm -rf %@.zip",[self fit:overlaypath]]];
    }else{
        [self ShowMessage:@"Folder has exist on desktop, delete it and try again!" Error:true];
    }
}

-(void)sendmail{
    //创建发送邮件alert
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Send"];
    [alert addButtonWithTitle:@"Cancel"];
    [alert setMessageText:@"Send release note"];
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 250, 24)];
    input.placeholderString = @"Input your e-mail address";
    alert.accessoryView = input;
    [alert setAlertStyle:NSWarningAlertStyle];
    NSUInteger action = [alert runModal];
    //响应window的按钮事件
    if(action == NSAlertFirstButtonReturn)
    {
        [sendmailDic setObject:input.stringValue forKey:@"mail"];
        NSString *returnmsg = [self Post2URL:[NSString stringWithFormat:@"%@/D21AELimits/SendMail.php",ServerURL] Cookie:@"" Postbody:[NSString stringWithFormat:@"Data=%@",[self DataTOjsonString:sendmailDic]]];
        if (returnmsg) {
            [self ShowMessage:[NSString stringWithFormat:@"%@\n\n%@",self.releaseNote.string,returnmsg] Error:false];
        }else{
            [self ShowMessage:[NSString stringWithFormat:@"%@\n\nError to send mail.",self.releaseNote.string] Error:true];
        }
    }
    else if(action == NSAlertSecondButtonReturn )
    {
        [self ShowMessage:[NSString stringWithFormat:@"%@\n\nUser cancel send mail.",self.releaseNote.string] Error:false];
    }
}

- (NSString*)Post2URL:(NSString *)URL Cookie:(NSString *)Cookie Postbody:(NSString *)BODY
{
    //第一步，创建URL
    NSURL *url = [NSURL URLWithString:  URL];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setValue:Cookie forHTTPHeaderField:@"Cookie"];
    //设置参数
    NSData *data = [BODY dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    //第三步，连接服务器
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    if(received != nil)
    {
        return  [[NSString alloc]initWithData:received encoding: NSUTF8StringEncoding ];
    }
    else
    {
        return nil;
    }
}


-(NSString*)DataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (!jsonData) {
        [self ShowMessage:[NSString stringWithFormat:@"Got an error: %@", error] Error:true];
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

- (NSString *)fit:(NSString *)path{
    NSString *fitstring = [path stringByReplacingOccurrencesOfString:@" " withString:@"\\\\ "];
    return fitstring;
}

- (NSString *)RunCMD:(NSString *)CMD {
    NSDictionary *error = [NSDictionary new];
    CMD = [CMD stringByReplacingOccurrencesOfString:@"&" withString:@"\\\\&"];
    NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\"",CMD ];
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor *des = [appleScript executeAndReturnError:&error];
    return  des.stringValue;
}

- (void)ShowMessage:(NSString *)message Error:(BOOL)error{
    self.releaseNote.string = message;
    if (error) {
        self.releaseNote.textColor = [NSColor redColor];
    }else{
        self.releaseNote.textColor = [NSColor blueColor];
    }
}

- (IBAction)close:(NSButton *)sender {
    [self dismissViewController:self];
    
}
@end
