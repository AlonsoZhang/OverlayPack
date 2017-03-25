//
//  ViewController.m
//  OverlayPack
//
//  Created by Alonso on 17/3/23.
//  Copyright © 2017年 Alonso. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self stationtv]becomeFirstResponder];
    randomfolderfm = [NSFileManager defaultManager];
    desktoppaths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    self.viewDropper.delegate = self;
}

-(void)dragShowStation:(NSArray *)files {
    if ([files count] > 1) {
        [self ShowMessage:@"Please only drag one file!" Error:true];
    }else{
        StationArray = [[NSMutableArray alloc] init];
        appPath = [[NSString alloc]init];
        appPath = files[0];
        NSArray * dealdata = [appPath componentsSeparatedByString:@"/"];
        if ([dealdata[dealdata.count-1] containsString:@"_AE"]) {
            [self ShowMessage:@"Please select the station and click the ZIP icon." Error:false];
            
            //设置 Product Name，为 D21_AE_Mix 中"_"前的代号。
            NSArray * dealaedata = [dealdata[dealdata.count-1]componentsSeparatedByString:@"_"];
            self.productName.stringValue = [dealaedata[0]lowercaseString];
            
            //设置当前日期，格式为8位。
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd"];
            self.dataLabel.stringValue = [dateFormatter stringFromDate:[NSDate date]];
            
            //生成一个随机数
            self.randomCode.stringValue = [NSString stringWithFormat:@"%d", (arc4random() % 900) + 100];
        }else{
            [self ShowMessage:@"Please drag correct file!" Error:true];
            return;
        }

        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *path = [files[0] stringByAppendingPathComponent:@"Contents/Resources"];
        path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *bundleURL =  [NSURL URLWithString:path];
        NSArray *contents = [fileManager contentsOfDirectoryAtURL:bundleURL
                                       includingPropertiesForKeys:@[]
                                                          options:0
                                                            error:nil];
        if ([contents count] == 0) {
            [self ShowMessage:@"Nothing in this file!" Error:true];
        }
        for (NSURL *fileURL in contents)
        {
            if ([[fileURL absoluteString]containsString:@"main.plist"] ) {
                NSMutableDictionary *mainplist = [[NSMutableDictionary alloc] initWithContentsOfFile:[[fileURL absoluteString]substringFromIndex:7]];
                NSDictionary *stationtype = [mainplist objectForKey:@"StationType"];
                for (NSString * stationname in stationtype) {
                    for (NSURL *stationplisturl in contents) {
                        if ([[stationplisturl absoluteString]containsString:[stationtype objectForKey:stationname]])
                        {
                            NSMutableDictionary *stationplist = [[NSMutableDictionary alloc] initWithContentsOfFile:[[stationplisturl absoluteString]substringFromIndex:7]];
                            NSString *version = [stationplist objectForKey:@"Version"];
                            if (version) {
                                NSMutableDictionary * existStation = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"0",[NSString stringWithFormat:@"%@_v%@",stationname,version], nil] forKeys:[NSArray arrayWithObjects:@"check",@"title",nil]];
                                [StationArray addObject:existStation];
                            }
                        }
                    }
                }
                
                NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
                NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
                NSArray *sortedArray = [StationArray sortedArrayUsingDescriptors:sortDescriptors];
                StationArray = [sortedArray mutableCopy];
            }
        }
        if ([StationArray count] == 0) {
            [self ShowMessage:@"No main.plist in this file!" Error:true];
        }
        [self.stationtv reloadData];
    }
}

- (void)ShowMessage:(NSString *)message Error:(BOOL)error{
    self.showTextView.string = message;
    if (error) {
        self.showTextView.textColor = [NSColor redColor];
    }else{
        self.showTextView.textColor = [NSColor blueColor];
    }
}

- (NSString *)RunCMD:(NSString *)CMD {
    NSDictionary *error = [NSDictionary new];
    NSString *script =  [NSString stringWithFormat:@"do shell script \"%@\"",CMD ];
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    NSAppleEventDescriptor *des = [appleScript executeAndReturnError:&error];
    return  des.stringValue;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark NSTableView Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSInteger i=[[aNotification object] selectedRow];
    if (i<0 || i>=[StationArray count]) {
        return;
    }
}

#pragma mark NSTableViewDataSource Delegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if(StationArray==nil){
        return 0;
    }
    else{
        return [StationArray count];
    }
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [[StationArray objectAtIndex:row] objectForKey:[tableColumn identifier]];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(nullable id)object forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    if([[tableColumn identifier] isEqualToString:@"check"]){
        if ([[StationArray[row] objectForKey:@"check"]isEqualToString:@"1"]) {
            [StationArray[row] setObject:@"0" forKey:@"check"];
        }else{
            [StationArray[row] setObject:@"1" forKey:@"check"];
        }
        [tableView reloadData];
    }
}

- (IBAction)selectall:(NSButton *)sender {
    if ([StationArray count] == 0) {
        self.selectbutton.stringValue = @"0";
    }
    if ([self.selectbutton.stringValue isEqualToString:@"1"]) {
        for (NSMutableDictionary *stationname in StationArray) {
            [stationname setObject:@"1" forKey:@"check"];
        }
    }else{
        for (NSMutableDictionary *stationname in StationArray) {
            [stationname setObject:@"0" forKey:@"check"];
        }
    }
    [self.stationtv reloadData];
}

- (IBAction)package:(NSButton *)sender {
    NSMutableArray *choosenStation = [[NSMutableArray alloc]init];
    for (NSDictionary *stationname in StationArray) {
        if ([[stationname objectForKey:@"check"] isEqualToString:@"1"]) {
            [choosenStation addObject:stationname];
        }
    }
    if ([choosenStation count] > 0) {
        
        //创建桌面随机数文件夹
        NSString *randomfolderpath = [NSString stringWithFormat:@"%@/%@",[desktoppaths objectAtIndex:0],self.randomCode.stringValue];
        if([randomfolderfm createDirectoryAtPath:randomfolderpath withIntermediateDirectories:false attributes:nil error:nil])
        {
            NSLog(@"Creat %@ folder",self.randomCode.stringValue);
        }
        
        //隐藏 contents 文件夹
        [self RunCMD:[NSString stringWithFormat:@"chflags hidden %@/contents",appPath]];
        
        float i = 0;
        for (NSDictionary *needpackage in choosenStation) {
            NSString *packagename = [NSString stringWithFormat:@"%@_%@ %@",self.dataLabel.stringValue,self.productName.stringValue,[[needpackage objectForKey:@"title"]lowercaseString]];
            NSLog(@"%@",packagename);
            
            //创建 overlay 单独文件夹
            NSString *overlaypath = [NSString stringWithFormat:@"%@/%@",randomfolderpath,packagename];
            if([randomfolderfm createDirectoryAtPath:overlaypath withIntermediateDirectories:false attributes:nil error:nil])
            {
                //显示打包进度
                i = i + 100.0/[choosenStation count];
                [self ShowMessage:[NSString stringWithFormat:@"Overlay Packing Process: %.0f%%",i] Error:false];
                
                //将 bundle 中文件移到 overlay 文件夹中
                [self RunCMD:[NSString stringWithFormat:@"cp -R %@/ %@",[[NSBundle mainBundle]pathForResource:@"overlay" ofType:nil],[self fit:overlaypath]]];
                
                //将 overlay app 复制到 /Users/gdlocal/Desktop 中
                NSString * desktopPath = [overlaypath stringByAppendingString:@"/Users/gdlocal/Desktop"];
                [self RunCMD:[NSString stringWithFormat:@"cp -R %@ %@",appPath,[self fit:desktopPath]]];
                
                //打包生成 overlay
                [self RunCMD:[NSString stringWithFormat:@"ditto -cVvk --keepParent %@/ %@.zip",[self fit:overlaypath],[self fit:overlaypath]]];
                
                //删除原来 overlay folder
                [self RunCMD:[NSString stringWithFormat:@"rm -rf %@",[self fit:overlaypath]]];
            }
        }
        
        //完成后打开文件夹
        if (i > 99) {
            [self RunCMD:[NSString stringWithFormat:@"open %@",randomfolderpath]];
        }
    }else{
        [self ShowMessage:@"Please choose one more station!" Error:true];
    }
}

- (NSString *)fit:(NSString *)path{
    NSString *fitstring = [path stringByReplacingOccurrencesOfString:@" " withString:@"\\\\ "];
    return fitstring;
}

- (IBAction)upload:(NSButton *)sender {
    if (![self.randomCode.stringValue isEqualToString:@""]) {
        NSString *randomfolderpath = [NSString stringWithFormat:@"%@/%@",[desktoppaths objectAtIndex:0],self.randomCode.stringValue];
        if ([randomfolderfm fileExistsAtPath:randomfolderpath]) {
            //将 randomfolder 压缩
            [self RunCMD:[NSString stringWithFormat:@"ditto -cVvk --keepParent %@/ %@.zip",randomfolderpath,randomfolderpath]];
            
            //上传 zip 到 server
            
            //删除 randomfolder
            [self RunCMD:[NSString stringWithFormat:@"rm -rf %@.zip",randomfolderpath]];
        }else{
            [self ShowMessage:[NSString stringWithFormat:@"%@ folder isn't on the desktop!",self.randomCode.stringValue] Error:true];
        }
    }else{
        [self ShowMessage:@"No random folder on the desktop!" Error:true];
    }
}

@end
