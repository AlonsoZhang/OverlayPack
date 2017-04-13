//
//  CompareViewController.m
//  OverlayPack
//
//  Created by Alonso on 2017/4/10.
//  Copyright © 2017年 Alonso. All rights reserved.
//

#import "CompareViewController.h"

@interface CompareViewController ()

@end

@implementation CompareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"compare"] count] != 0)
    {
        compareArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"compare"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"compare"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return compareArray.count;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    NSString *returnString = [NSString stringWithFormat:@"%@",[[compareArray objectAtIndex:row] objectForKey:identifier]];
    if ([returnString rangeOfString:@"("].location != NSNotFound) {
        NSTextFieldCell* cell= (NSTextFieldCell*)[tableColumn dataCellForRow:row];
        cell.textColor=[NSColor redColor];
        cell.stringValue=returnString;
        return cell;
    }else
    {
        NSTextFieldCell* cell= (NSTextFieldCell*)[tableColumn dataCellForRow:row];
        cell.textColor=[NSColor blueColor];
        cell.stringValue=returnString;
        return cell;
    }
    return returnString;
}

@end
