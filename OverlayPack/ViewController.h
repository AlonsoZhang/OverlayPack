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
    NSFileManager *overlayfm;
    NSString *appPath;
    NSArray *desktoppaths;
    NSMutableArray *StationArray;
    BOOL checked;
    BOOL comapred;
    NSMutableDictionary *Stations;
    NSString *AElimitsName;
    NSMutableDictionary *mainplist;
    NSArray *contents;
    NSMutableArray *compareResultArray;
    dispatch_queue_t UserQueue;
    NSMutableDictionary *sendmailDic;
}
@property (weak) IBOutlet NSButton *selectbutton;
@property (strong) IBOutlet ViewDropper *viewDropper;
@property (weak) IBOutlet NSTableView *stationtv;
@property (weak) IBOutlet NSTextField *productName;
@property (weak) IBOutlet NSTextField *dataLabel;
@property (weak) IBOutlet NSTextField *randomCode;
@property (weak) IBOutlet NSTextField *verisonLabel;
@property (unsafe_unretained) IBOutlet NSTextView *showTextView;
@property (strong) IBOutlet NSPopUpButton *AELimitsList;
@property (weak) IBOutlet NSButton *upload;
@property (weak) IBOutlet NSButton *package;
@property (weak) IBOutlet NSButton *compare;
@property (weak) IBOutlet NSImageView *loadingImage;

- (IBAction)package:(NSButton *)sender;
- (IBAction)upload:(NSButton *)sender;
- (IBAction)compare:(NSButton *)sender;
- (IBAction)selectall:(NSButton *)sender;

@end

