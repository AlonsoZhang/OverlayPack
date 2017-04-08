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
    overlayfm = [NSFileManager defaultManager];
    desktoppaths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    self.viewDropper.delegate = self;
    Stations =  [[NSMutableDictionary alloc]init];
    
    
    NSDictionary *List = [self PostURL:@"http://10.42.222.70/AEOverlay/D21AELimits/getlist.php" Cookie:@"" Postbody:@""];
    //[self.AELimitsList addItemWithTitle:@"--Please Choose AE Limits--"];
    [self.AELimitsList addItemsWithTitles:[List objectForKey:@"list"]];
    
    [self.AELimitsList selectItem:self.AELimitsList.lastItem];
    //    [self LoadAElimist:nil];
}


- (NSMutableDictionary*)PostURL:(NSString *)URL Cookie:(NSString *)Cookie Postbody:(NSString *)BODY
{
    //第一步，创建URL
    NSURL *url = [NSURL URLWithString:  URL];
    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
    [request setHTTPMethod:@"POST"];//设置请求方式为POST，默认为GET
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setValue:Cookie forHTTPHeaderField:@"Cookie"];
    
    
    //设置参数
    NSData *data = [BODY dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    
    //第三步，连接服务器
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //    NSString *String = [[NSString alloc]initWithData:received encoding: NSUTF8StringEncoding ];
    //    NSLog(@"%@", String);
    
    if(received != nil)
    {
        return  [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
    }
    else
    {
        return nil;
    }
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
        
        NSString *path = [files[0] stringByAppendingPathComponent:@"Contents/Resources"];
        path = [path stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSURL *bundleURL =  [NSURL URLWithString:path];
        contents = [overlayfm contentsOfDirectoryAtURL:bundleURL
                              includingPropertiesForKeys:@[]
                                                 options:0
                                                   error:nil];
        if ([contents count] == 0) {
            [self ShowMessage:@"Nothing in this file!" Error:true];
        }
        for (NSURL *fileURL in contents)
        {
            if ([[fileURL absoluteString]containsString:@"main.plist"] ) {
                mainplist = [[NSMutableDictionary alloc] initWithContentsOfFile:[[fileURL absoluteString]substringFromIndex:7]];
                
                //check sfcs/uppdca/DoDebug
                if ([[mainplist objectForKey:@"sfcs"]boolValue] == NO) {
                    [self ShowMessage:@"sfcs flag in main.plist is wrong!" Error:true];
                    return;
                }else if ([[mainplist objectForKey:@"uppdca"]boolValue] == NO){
                    [self ShowMessage:@"uppdca flag in main.plist is wrong!" Error:true];
                    return;
                }else if ([[mainplist objectForKey:@"DoDebug"]boolValue] == YES){
                    [self ShowMessage:@"DoDebug flag in main.plist is wrong!" Error:true];
                    return;
                }else{
                    //self.verisonLabel.stringValue = [NSString stringWithFormat:@"%@: %@",dealdata[dealdata.count-1],[mainplist objectForKey:@"UpdateTime"]];
                    self.verisonLabel.stringValue = [NSString stringWithFormat:@"%@",[mainplist objectForKey:@"UpdateTime"]];
                    NSDictionary *stationtype = [mainplist objectForKey:@"StationType"];
                    for (NSString * stationname in stationtype) {
                        for (NSURL *stationplisturl in contents) {
                            if ([[stationplisturl absoluteString]containsString:[stationtype objectForKey:stationname]])
                            {
                                NSMutableDictionary *stationplist = [[NSMutableDictionary alloc] initWithContentsOfFile:[[stationplisturl absoluteString]substringFromIndex:7]];
                                NSString *version = [stationplist objectForKey:@"Version"];
                                if (version) {
                                    NSMutableDictionary * existStation = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"0",stationname,[NSString stringWithFormat:@"V%@",version], nil] forKeys:[NSArray arrayWithObjects:@"check",@"title",@"verison",nil]];
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
        }
        if ([StationArray count] == 0) {
            [self ShowMessage:@"No correct main.plist in this file!" Error:true];
        }
        [self.stationtv reloadData];
    }
}

- (void)ShowMessage:(NSString *)message Error:(BOOL)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.showTextView.string = message;
        if (error) {
            self.showTextView.textColor = [NSColor redColor];
        }else{
            self.showTextView.textColor = [NSColor blueColor];
        }
    });
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
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self startloading];
        NSMutableArray *choosenStation = [[NSMutableArray alloc]init];
        for (NSDictionary *stationname in StationArray) {
            if ([[stationname objectForKey:@"check"] isEqualToString:@"1"]) {
                [choosenStation addObject:stationname];
            }
        }
        if ([choosenStation count] > 0) {
            
            //创建桌面随机数文件夹
            NSString *randomfolderpath = [NSString stringWithFormat:@"%@/%@",[desktoppaths objectAtIndex:0],self.randomCode.stringValue];
            if([overlayfm createDirectoryAtPath:randomfolderpath withIntermediateDirectories:false attributes:nil error:nil])
            {
                NSLog(@"Creat %@ folder",self.randomCode.stringValue);
            }
            
            //隐藏 contents 文件夹
            [self RunCMD:[NSString stringWithFormat:@"chflags hidden %@/contents",appPath]];
            
            float i = 0;
            for (NSDictionary *needpackage in choosenStation) {
                NSString *packagename = [NSString stringWithFormat:@"%@_%@ %@_%@",self.dataLabel.stringValue,self.productName.stringValue,[[needpackage objectForKey:@"title"]lowercaseString],[needpackage objectForKey:@"verison"]];
                NSLog(@"%@",packagename);
                
                //创建 overlay 单独文件夹
                NSString *overlaypath = [NSString stringWithFormat:@"%@/%@",randomfolderpath,packagename];
                if([overlayfm createDirectoryAtPath:overlaypath withIntermediateDirectories:false attributes:nil error:nil])
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
        [self stoploading];
    });
}

- (NSString *)fit:(NSString *)path{
    NSString *fitstring = [path stringByReplacingOccurrencesOfString:@" " withString:@"\\\\ "];
    return fitstring;
}

- (IBAction)upload:(NSButton *)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self startloading];
        if (![self.randomCode.stringValue isEqualToString:@""]) {
            NSString *randomfolderpath = [NSString stringWithFormat:@"%@/%@",[desktoppaths objectAtIndex:0],self.randomCode.stringValue];
            if ([overlayfm fileExistsAtPath:randomfolderpath]) {
                [self.package setEnabled:false];
                [self.upload setEnabled:false];
                [self ShowMessage:@"Waiting for upload..." Error:false];
                //将 randomfolder 压缩
                [self RunCMD:[NSString stringWithFormat:@"ditto -cVvk --keepParent %@/ %@.zip",randomfolderpath,randomfolderpath]];
                
                //上传 zip 到 server
                UploadFile *UPtoWEB = [[UploadFile alloc]init];
                NSString * returnmsg = [UPtoWEB UploadFileWithURL:@"http://10.42.222.70/AEOverlay/upload_file.php" FileName:[NSString stringWithFormat:@"%@.zip",self.randomCode.stringValue] FilePath:[NSString stringWithFormat:@"%@.zip",randomfolderpath]];
                if ([returnmsg length] == 0) {
                    [self ShowMessage:@"No response for upload!" Error:true];
                }else{
                    [self ShowMessage:returnmsg Error:false];
                }
                
                //删除 randomfolder
                [self RunCMD:[NSString stringWithFormat:@"rm -rf %@.zip",randomfolderpath]];
                [self.package setEnabled:true];
                [self.upload setEnabled:true];
            }else{
                [self ShowMessage:[NSString stringWithFormat:@"%@ folder isn't on the desktop!",self.randomCode.stringValue] Error:true];
            }
        }else{
            [self ShowMessage:@"No random folder on the desktop!" Error:true];
        }
        [self stoploading];
    });
}

- (IBAction)compare:(NSButton *)sender {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self startloading];
        NSMutableArray *choosenStation = [[NSMutableArray alloc]init];
        for (NSDictionary *stationname in StationArray) {
            if ([[stationname objectForKey:@"check"] isEqualToString:@"1"]) {
                [choosenStation addObject:stationname];
            }
        }
        if ([choosenStation count] > 0) {
            if ([self LoadAElimists]) {
                for (NSDictionary *needpackage in choosenStation) {
                    NSString *chooseStationName = [[mainplist objectForKey:@"StationType"]objectForKey:[needpackage objectForKey:@"title"]];
                    for (NSURL *stationplisturl in contents) {
                        if ([[stationplisturl absoluteString]containsString:chooseStationName])
                        {
                            NSMutableDictionary *stationplist = [[NSMutableDictionary alloc] initWithContentsOfFile:[[stationplisturl absoluteString]substringFromIndex:7]];
                            NSLog(@"%@",stationplist);
                            NSLog(@"%@",[Stations objectForKey:chooseStationName]);
                        }
                    }
                    
                }
            }
        }else{
            [self ShowMessage:@"Please choose one more station!" Error:true];
        }
        [self stoploading];
    });
}

- (void)startloading{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.package setEnabled:false];
        [self.upload setEnabled:false];
        [self.compare setEnabled:false];
        self.loadingImage.hidden = false;
        self.loadingImage.imageScaling = NSImageScaleAxesIndependently;
        [self.loadingImage setAnimates:YES];
        [self.loadingImage setImage:[NSImage imageNamed:@"loading.gif"]];
        self.loadingImage.canDrawSubviewsIntoLayer = YES;
    });
}

- (void)stoploading{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.package setEnabled:true];
        [self.upload setEnabled:true];
        [self.compare setEnabled:true];
        self.loadingImage.hidden = true;
    });
}

- (BOOL)LoadAElimists{
    AElimitsName = [self.AELimitsList.selectedItem.title substringToIndex:[self.AELimitsList.selectedItem.title length]-4];
    NSString *aelimitspath = [NSString stringWithFormat:@"%@/%@.plist",[desktoppaths objectAtIndex:0],AElimitsName];
    if (![overlayfm fileExistsAtPath:aelimitspath]) {
        NSMutableDictionary *allStations = [self PostURL:@"http://10.42.222.70/AEOverlay/D21AELimits/index.php" Cookie:@"" Postbody:[NSString stringWithFormat:@"FileName=%@",self.AELimitsList.selectedItem.title]];
        [allStations writeToFile:[NSString stringWithFormat:@"%@/%@.plist",[desktoppaths objectAtIndex:0],AElimitsName] atomically:YES];
    }
    Stations = [NSMutableDictionary dictionaryWithContentsOfFile:aelimitspath];
    [self ShowMessage:[NSString stringWithFormat:@"Load AElimist:%@ \nCount:%lu",self.AELimitsList.selectedItem.title,(unsigned long)Stations.count] Error: Stations.count==0?true:false ];
    if ([Stations count] == 0) {
        return NO;
    }else{
        return YES;
    }
}

- (IBAction)LoadAElimist:(id)sender
{
    //    Stations =   [self PostURL:@"http://10.42.222.70/AEOverlay/D21AELimits/index.php" Cookie:@"" Postbody:[NSString stringWithFormat:@"FileName=%@",self.AELimitsList.selectedItem.title]];
    //
    //    [self ShowMessage:[NSString stringWithFormat:@"Load AElimist:%@ \nCount:%lu",self.AELimitsList.selectedItem.title,(unsigned long)Stations.count] Error: Stations.count==0?true:false ];
    //    AElimitsName = [self.AELimitsList.selectedItem.title substringToIndex:[self.AELimitsList.selectedItem.title length]-4];
    //    [Stations writeToFile:[NSString stringWithFormat:@"/Users/alonso/Desktop/%@.plist",AElimitsName] atomically:YES];
}
@end
