//
//  ViewController.h
//  OverlayPack
//
//  Created by Alonso on 17/3/23.
//  Copyright © 2017年 Alonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewDropper.h"
#import "UploadFile.h"

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
@property (weak) IBOutlet NSTextField *verisonLabel;

@property (unsafe_unretained) IBOutlet NSTextView *showTextView;

@property (weak) IBOutlet NSButton *upload;
@property (weak) IBOutlet NSButton *package;

- (IBAction)package:(NSButton *)sender;
- (IBAction)upload:(NSButton *)sender;
- (IBAction)selectall:(NSButton *)sender;


@end

