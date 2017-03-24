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
    self.viewDropper.delegate = self;
}

-(void)dragShowStation:(NSArray *)files {
    if ([files count] > 1) {
        NSLog(@"please only drag one file!");
    }else{
        NSLog(@" the file is : %@",files[0]);
        
        NSArray * dealdata = [files[0] componentsSeparatedByString:@"/"];
        if ([dealdata[dealdata.count-1] containsString:@"_AE"]) {
            
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
            NSLog(@"error");
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
        for (NSURL *fileURL in contents)
        {
            if ([[fileURL absoluteString]containsString:@"main.plist"] ) {
                NSMutableDictionary *mainplist = [[NSMutableDictionary alloc] initWithContentsOfFile:[[fileURL absoluteString]substringFromIndex:7]];
                NSDictionary *stationtype = [mainplist objectForKey:@"StationType"];
                StationArray = [[NSMutableArray alloc] init];
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
                [self.stationtv reloadData];
            }
        }
    }
    
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

- (IBAction)package:(NSButton *)sender {
    NSMutableArray *choosenStation = [[NSMutableArray alloc]init];
    for (NSDictionary *stationname in StationArray) {
        if ([[stationname objectForKey:@"check"] isEqualToString:@"1"]) {
            [choosenStation addObject:stationname];
        }
    }
    if ([choosenStation count] > 0) {
        for (NSDictionary *needpackage in choosenStation) {
            NSString *packagename = [NSString stringWithFormat:@"%@_%@ %@",self.dataLabel.stringValue,self.productName.stringValue,[[needpackage objectForKey:@"title"]lowercaseString]];
            NSLog(@"%@",packagename);
        }
    }else{
        NSLog(@"please choose one");
    }
}

- (IBAction)upload:(NSButton *)sender {
}
@end
