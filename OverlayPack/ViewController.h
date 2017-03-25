//
//  ViewController.h
//  OverlayPack
//
//  Created by Alonso on 17/3/23.
//  Copyright © 2017年 Alonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewDropper.h"

@interface ViewController : NSViewController<DragShowStationDelegate>{
    NSFileManager *randomfolderfm;
    NSString *appPath;
    NSArray *desktoppaths;
    NSMutableArray *StationArray;
    BOOL checked;
}
@property (weak) IBOutlet NSButton *selectbutton;
@property (strong) IBOutlet ViewDropper *viewDropper;
@property (weak) IBOutlet NSTableView *stationtv;
@property (weak) IBOutlet NSTextField *productName;
@property (weak) IBOutlet NSTextField *dataLabel;
@property (weak) IBOutlet NSTextField *randomCode;
@property (unsafe_unretained) IBOutlet NSTextView *showTextView;

- (IBAction)package:(NSButton *)sender;
- (IBAction)upload:(NSButton *)sender;
- (IBAction)selectall:(NSButton *)sender;


@end

