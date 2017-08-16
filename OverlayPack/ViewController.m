//
//  ViewController.m
//  OverlayPack
//
//  Created by Alonso on 17/3/23.
//  Copyright © 2017年 Alonso. All rights reserved.
//

#import "ViewController.h"

#define ServerURL @"http://10.42.222.70/AEOverlay"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self stationtv]becomeFirstResponder];
    //[self.upload setEnabled:false];
    overlayfm = [NSFileManager defaultManager];
    desktoppaths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    self.viewDropper.delegate = self;
    Stations =  [[NSMutableDictionary alloc]init];
    NSDictionary *List = [self PostURL:[NSString stringWithFormat:@"%@/D21AELimits/getlist.php",ServerURL] Cookie:@"" Postbody:@""];
    if (!List) {
        [self ShowMessage:@"Fail to connect server!" Error:true];
    }
    [self.AELimitsList addItemsWithTitles:[List objectForKey:@"list"]];
    [self.AELimitsList selectItem:self.AELimitsList.lastItem];
    UserQueue = dispatch_queue_create(NULL, DISPATCH_QUEUE_SERIAL);
}

- (NSMutableDictionary*)PostURL:(NSString *)URL Cookie:(NSString *)Cookie Postbody:(NSString *)BODY
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
        return  [NSJSONSerialization JSONObjectWithData:received options:NSJSONReadingMutableLeaves error:nil];
    }
    else
    {
        return nil;
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

-(void)dragShowStation:(NSArray *)files {
    if ([files count] > 1) {
        [self ShowMessage:@"Please only drag one file!" Error:true];
    }else{
        StationArray = [[NSMutableArray alloc] init];
        [self.stationtv reloadData];
        [self ShowMessage:@"" Error:false];
        appPath = [[NSString alloc]init];
        appPath = files[0];
        NSArray * dealdata = [appPath componentsSeparatedByString:@"/"];
        if ([appPath containsString:@" "]) {
            [self ShowMessage:[NSString stringWithFormat:@"No space in path!!!\n%@",appPath] Error:true];
            return;
        }else if ([[dealdata lastObject] containsString:@" "]) {
            [self ShowMessage:[NSString stringWithFormat:@"No space in app name!!!\n%@",[dealdata lastObject]] Error:true];
            return;
        }else if ([[dealdata lastObject] containsString:@"_AE"]) {
            [self ShowMessage:@"Please select the station and click the ZIP icon." Error:false];
            
            //设置 Product Name，为 D21_AE_Mix 中"_"前的代号。
            NSArray * dealaedata = [[dealdata lastObject]componentsSeparatedByString:@"_"];
            self.productName.stringValue = [dealaedata[0]lowercaseString];
            
            //设置当前日期，格式为8位。
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd"];
            self.dataLabel.stringValue = [dateFormatter stringFromDate:[NSDate date]];
            
            //生成一个随机数
            self.randomCode.stringValue = [NSString stringWithFormat:@"%d", (arc4random() % 900) + 100];
            isAE = true;
        }else if ([[dealdata lastObject] containsString:@".app"]){
            isAE = false;
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
                if ([mainplist objectForKey:@"sfcs"] && [[mainplist objectForKey:@"sfcs"]boolValue] == NO) {
                    [self ShowMessage:@"sfcs flag in main.plist is wrong!" Error:true];
                    return;
                }else if ([mainplist objectForKey:@"uppdca"] && [[mainplist objectForKey:@"uppdca"]boolValue] == NO){
                    [self ShowMessage:@"uppdca flag in main.plist is wrong!" Error:true];
                    return;
                }else if (isAE && [[mainplist objectForKey:@"DoDebug"]boolValue] == YES){
                    [self ShowMessage:@"DoDebug flag in main.plist is wrong!" Error:true];
                    return;
                }else if (!isAE){
                    [[NSUserDefaults standardUserDefaults]setObject:[[dealdata lastObject]substringToIndex:[[dealdata lastObject]length]-4] forKey:@"APstationname"];
                    [[NSUserDefaults standardUserDefaults]setObject:[mainplist objectForKey:@"version"] forKey:@"APversion"];
                    [[NSUserDefaults standardUserDefaults]setObject:appPath forKey:@"appPath"];
                    [self performSegueWithIdentifier:@"APoverlay" sender:nil];
                }
                else{
                    self.verisonLabel.stringValue = ([mainplist objectForKey:@"UpdateTime"]?[NSString stringWithFormat:@"%@",[mainplist objectForKey:@"UpdateTime"]]:@"");
                    NSDictionary *stationtype = [mainplist objectForKey:@"StationType"];
                    self.selectbutton.stringValue = @"0";
                    NSString *releasemsg = [[NSString alloc]init];
                    for (NSString * stationname in stationtype) {
                        for (NSURL *stationplisturl in contents) {
                            NSArray * stationarry = [[stationplisturl absoluteString] componentsSeparatedByString:@"/"];
                            //NSLog(@"%@",[stationarry lastObject]);
                            if ([[stationarry lastObject]isEqualToString:[NSString stringWithFormat:@"%@.plist",[stationtype objectForKey:stationname]]])
                            {
                                NSMutableDictionary *stationplist = [[NSMutableDictionary alloc] initWithContentsOfFile:[[stationplisturl absoluteString]substringFromIndex:7]];
                                NSString *version = [stationplist objectForKey:@"Version"];
                                if (version && ![version isEqualToString:@"NA"]) {
                                    //判断添加release note
                                    NSString *releasenote = [[[stationplist objectForKey:@"CodeRelease"]objectForKey:@"ReleaseNote"]objectForKey:version];
                                    if (!releasenote) {
                                        releasemsg = [NSString stringWithFormat:@"%@\n%@ no release note",releasemsg,stationname];
                                    }else{
                                        if (![version isEqualToString:@"0.01"]&&[releasenote rangeOfString:@"version"].location == NSNotFound){
                                            if ([releasenote rangeOfString:@"2. "].location == NSNotFound) {
                                                releasenote = [NSString stringWithFormat:@"%@\n2. Change version from %.2f to %@.",releasenote,[version floatValue]-0.01,version];
                                            }else{
                                                releasenote = [NSString stringWithFormat:@"%@\n3. Change version from %.2f to %@.",releasenote,[version floatValue]-0.01,version];
                                            }
                                        }
                                        NSMutableDictionary * existStation = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"0",stationname,[[stationtype objectForKey:stationname]substringFromIndex:9],[NSString stringWithFormat:@"V%@",version],releasenote, nil] forKeys:[NSArray arrayWithObjects:@"check",@"title",@"pdcaname",@"verison",@"releasenote",nil]];
                                        [StationArray addObject:existStation];
                                    }
                                    releasemsg = [releasemsg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                    if ([releasemsg length] > 0) {
                                        [self ShowMessage:releasemsg Error:true];
                                    }
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
        if ([StationArray count] == 0 && isAE) {
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
    comapred = NO;
    [self compare:self.compare];
    dispatch_async(UserQueue, ^{
        [self startloading];
        NSMutableArray *choosenStation = [[NSMutableArray alloc]init];
        for (NSDictionary *stationname in StationArray) {
            if ([[stationname objectForKey:@"check"] isEqualToString:@"1"]) {
                [choosenStation addObject:stationname];
            }
        }
        if ([choosenStation count] > 0) {
            if (comapred) {
                //创建桌面随机数文件夹
                NSString *randomfolderpath = [NSString stringWithFormat:@"%@/%@",[desktoppaths objectAtIndex:0],self.randomCode.stringValue];
                if([overlayfm createDirectoryAtPath:randomfolderpath withIntermediateDirectories:false attributes:nil error:nil])
                {
                    NSLog(@"Creat %@ folder",self.randomCode.stringValue);
                }
                
                //隐藏 contents 文件夹
                [self RunCMD:[NSString stringWithFormat:@"chflags hidden %@/contents",appPath]];
                
                
                NSMutableArray *releaseArray = [[NSMutableArray alloc]init];
                float i = 0;
                for (NSDictionary *needpackage in choosenStation) {
                    NSString *packagename = [NSString stringWithFormat:@"%@_%@ %@_%@",self.dataLabel.stringValue,self.productName.stringValue,[[needpackage objectForKey:@"title"]lowercaseString],[needpackage objectForKey:@"verison"]];
                    NSDictionary *releaseDict = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[needpackage objectForKey:@"title"],[needpackage objectForKey:@"verison"],[needpackage objectForKey:@"releasenote"],nil] forKeys:[NSArray arrayWithObjects:@"station",@"version",@"releasenote",nil]];
                    [releaseArray addObject:releaseDict];
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
                        
                        //将 overlay app 备份到 /Users/gdlocal/Documents 中
                        NSString * documentsPath = [overlaypath stringByAppendingString:@"/Users/gdlocal/Documents"];
                        [self RunCMD:[NSString stringWithFormat:@"cp -R %@ %@",appPath,[self fit:documentsPath]]];
                        
                        //打包生成 overlay
                        [self RunCMD:[NSString stringWithFormat:@"ditto -cVvk --keepParent %@/ %@.zip",[self fit:overlaypath],[self fit:overlaypath]]];
                        
                        //删除原来 overlay folder
                        [self RunCMD:[NSString stringWithFormat:@"rm -rf %@",[self fit:overlaypath]]];
                    }
                }
                
                //完成后打开文件夹
                if (i > 99) {
                    [self RunCMD:[NSString stringWithFormat:@"open %@",randomfolderpath]];
                    sendmailDic = [[NSMutableDictionary alloc]init];
                    [sendmailDic setObject:releaseArray forKey:@"release"];
                    [sendmailDic setObject:[self.AELimitsList.selectedItem.title substringToIndex:[self.AELimitsList.selectedItem.title length]-([self.AELimitsList.selectedItem.title containsString:@"xlsx"]? 5:4)] forKey:@"AELimits"];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self.upload setEnabled:true];
//                    });
                }
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

- (IBAction)compare:(NSButton *)sender {
    dispatch_async(UserQueue, ^{
        [self startloading];
        compareResultArray = [[NSMutableArray alloc]init];
        NSMutableArray *choosenStation = [[NSMutableArray alloc]init];
        NSString *judgelengthinfo = [[NSString alloc]init];
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
                        NSArray * stationarry = [[stationplisturl absoluteString] componentsSeparatedByString:@"/"];
                        if ([[stationarry lastObject]isEqualToString:[NSString stringWithFormat:@"%@.plist",chooseStationName]])
                        {
                            NSMutableDictionary *stationplist = [[NSMutableDictionary alloc] initWithContentsOfFile:[[stationplisturl absoluteString]substringFromIndex:7]];
                            NSArray * checkdataarray = [[stationplist objectForKey:@"CodeRelease"]objectForKey:@"CompareAELimits"];
                            if (checkdataarray) {
                                for(NSDictionary *checkdataDict in checkdataarray){
                                    NSArray * checkdata = [[[stationplist objectForKey:@"TestFlow"]objectAtIndex:[[checkdataDict objectForKey:@"ItemIndex"]intValue]]objectForKey:[checkdataDict objectForKey:@"DataName"]];
                                    if ([checkdata count] >= [[Stations objectForKey:([chooseStationName isEqualToString:@"TestSpec_STOM-OQC"]?@"TestSpec_STOM":chooseStationName)]count]) {
                                        if ([checkdata count] < [[checkdataDict objectForKey:@"EndIndex"]intValue]+1) {
                                            judgelengthinfo = [NSString stringWithFormat:@"%@\n%@ EndIndex format error." ,judgelengthinfo,chooseStationName];
                                            break;
                                        }
                                        NSArray * rangedataarray = [checkdata  subarrayWithRange:NSMakeRange([[checkdataDict objectForKey:@"StartIndex"]intValue], [[checkdataDict objectForKey:@"EndIndex"]intValue]-[[checkdataDict objectForKey:@"StartIndex"]intValue]+1)];
                                        NSMutableArray *comparedataarray = [rangedataarray mutableCopy];
                                        
                                        //AAA删除倒数第四个位置上图片名称
                                        if ([chooseStationName isEqualToString:@"TestSpec_AAA"]) {
                                            [comparedataarray removeObjectAtIndex:[comparedataarray count]-5];
                                        }
                                        
                                        if ([comparedataarray count] == [[Stations objectForKey:([chooseStationName isEqualToString:@"TestSpec_STOM-OQC"]?@"TestSpec_STOM":chooseStationName)]count]) {
                                            [self compareAElimits:comparedataarray with:[Stations objectForKey:([chooseStationName isEqualToString:@"TestSpec_STOM-OQC"]?@"TestSpec_STOM":chooseStationName)]station:[chooseStationName substringFromIndex:9]];
                                        }else
                                        {
                                            judgelengthinfo = [NSString stringWithFormat:@"%@\n%@ need compare data count is %lu, AE limits count is %lu, please check again.",judgelengthinfo,chooseStationName,[comparedataarray count],[[Stations objectForKey:chooseStationName]count]];
                                        }
                                    }
                                    else{
                                        judgelengthinfo = [NSString stringWithFormat:@"%@\n%@ need compare data total count is %lu < AE limits count %lu." ,judgelengthinfo,chooseStationName,[checkdata count],[[Stations objectForKey:chooseStationName]count]];
                                    }
                                }
                            }else{
                                judgelengthinfo = [NSString stringWithFormat:@"%@\n%@ compare plist format is wrong!",judgelengthinfo,chooseStationName];
                            }
                        }
                    }
                }
                judgelengthinfo = [judgelengthinfo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([judgelengthinfo length] != 0) {
                    [self ShowMessage:[NSString stringWithFormat:@"%@",judgelengthinfo] Error:true];
                    if ([compareResultArray count] > 0) {
                        [[NSUserDefaults standardUserDefaults]setObject:compareResultArray forKey:@"compare"];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self performSegueWithIdentifier:@"CompareResult" sender:nil];
                        });
                    }
                }else if ([compareResultArray count] > 0) {
                    [[NSUserDefaults standardUserDefaults]setObject:compareResultArray forKey:@"compare"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self performSegueWithIdentifier:@"CompareResult" sender:nil];
                    });
                }else{
                    comapred = YES;
                    [self ShowMessage:[NSString stringWithFormat:@"Compare with %@, all items are correct!",self.AELimitsList.selectedItem.title] Error:false];
                }
            }
        }else{
            [self ShowMessage:@"Please choose one more station!" Error:true];
        }
        [self stoploading];
    });
}

- (void)compareAElimits:(NSMutableArray *)comparearray with:(NSArray *)specarray station:(NSString *)station{
    NSArray *itemnamearray = [NSArray arrayWithObjects:@"TestItem",@"ItemType",@"LSpec",@"USpec",@"Units",nil];
    for (int i = 0; i < [comparearray count]; i++) {
        BOOL add = NO;
        NSMutableDictionary *savedic = [[NSMutableDictionary alloc]init];
        NSMutableDictionary *resultdic = [[NSMutableDictionary alloc]init];
        for (NSString *itemname in itemnamearray) {
            [savedic setObject:[comparearray[i] objectForKey:itemname] forKey:itemname];
            if (![[savedic objectForKey:itemname] isEqualToString:[NSString stringWithFormat:@"%@",[specarray[i] objectForKey:itemname]]]) {
                resultdic = savedic;
                [resultdic setObject:[NSString stringWithFormat:@"%@(%@)",[savedic objectForKey:itemname],[specarray[i] objectForKey:itemname]] forKey:itemname];
                [resultdic setObject:station forKey:@"Station"];
                add = YES;
            }
        }
        if (add) {
            [compareResultArray addObject:resultdic];
        }
    }
}

- (void)startloading{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.package setEnabled:false];
        [self.compare setEnabled:false];
        [self.upload setEnabled:false];
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
        [self.compare setEnabled:true];
        [self.upload setEnabled:true];
        self.loadingImage.hidden = true;
    });
}

- (BOOL)LoadAElimists{
    AElimitsName = [self.AELimitsList.selectedItem.title substringToIndex:[self.AELimitsList.selectedItem.title length] - ([self.AELimitsList.selectedItem.title containsString:@"xlsx"]? 5:4)];
    NSString *aelimitspath = [NSString stringWithFormat:@"%@/%@.plist",[desktoppaths objectAtIndex:0],AElimitsName];
    if (![overlayfm fileExistsAtPath:aelimitspath]) {
        NSMutableDictionary *allStations = [self PostURL:[NSString stringWithFormat:@"%@/D21AELimits/index.php",ServerURL] Cookie:@"" Postbody:[NSString stringWithFormat:@"FileName=%@",self.AELimitsList.selectedItem.title]];
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

- (IBAction)upload:(NSButton *)sender {
    dispatch_async(UserQueue, ^{
        [self startloading];
        if (![self.randomCode.stringValue isEqualToString:@""]) {
            NSString *randomfolderpath = [NSString stringWithFormat:@"%@/%@",[desktoppaths objectAtIndex:0],self.randomCode.stringValue];
            if ([overlayfm fileExistsAtPath:randomfolderpath]) {
                [self ShowMessage:@"Waiting for upload..." Error:false];
                //将 randomfolder 压缩
                [self RunCMD:[NSString stringWithFormat:@"ditto -cVvk --keepParent %@/ %@.zip",randomfolderpath,randomfolderpath]];
                
                //上传 zip 到 server
                UploadFile *UPtoWEB = [[UploadFile alloc]init];
                NSString * returnmsg = [UPtoWEB UploadFileWithURL:[NSString stringWithFormat:@"%@/upload_file.php",ServerURL] FileName:[NSString stringWithFormat:@"%@.zip",self.randomCode.stringValue] FilePath:[NSString stringWithFormat:@"%@.zip",randomfolderpath]];
                if ([returnmsg length] == 0) {
                    [self ShowMessage:@"No response for upload!" Error:true];
                }else{
                    [self ShowMessage:returnmsg Error:false];
                    NSArray *pathArray = [NSArray arrayWithArray:[returnmsg  componentsSeparatedByString:@"\n"]];
                    [sendmailDic setObject:pathArray.lastObject forKey:@"download"];
                    [self stoploading];
                    if(sendmailDic){
                        [self sendmail];
                    }
                }
                //删除 randomfolder
                [self RunCMD:[NSString stringWithFormat:@"rm -rf %@.zip",randomfolderpath]];
            }else{
                [self ShowMessage:[NSString stringWithFormat:@"%@ folder isn't on the desktop!",self.randomCode.stringValue] Error:true];
            }
        }else{
            [self ShowMessage:@"No random folder on the desktop!" Error:true];
        }
        [self stoploading];
    });
}

-(void)sendmail{
    dispatch_async(dispatch_get_main_queue(), ^{
        //创建发送邮件alert
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Send"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Send release note and download address"];
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
                [self ShowMessage:[NSString stringWithFormat:@"%@\n\n%@",self.showTextView.string,returnmsg] Error:false];
            }else{
                [self ShowMessage:[NSString stringWithFormat:@"%@\n\nError to send mail.",self.showTextView.string] Error:true];
            }
        }
        else if(action == NSAlertSecondButtonReturn )
        {
            [self ShowMessage:[NSString stringWithFormat:@"%@\n\nUser cancel send mail.",self.showTextView.string] Error:false];
        }
    });
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

@end
