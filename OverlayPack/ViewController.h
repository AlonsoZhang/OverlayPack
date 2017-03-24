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
    NSMutableArray *StationArray;
    BOOL checked;
}
@property (strong) IBOutlet ViewDropper *viewDropper;
@property (weak) IBOutlet NSTableView *stationtv;
@property (weak) IBOutlet NSTextField *productName;
@property (weak) IBOutlet NSTextField *dataLabel;
@property (weak) IBOutlet NSTextField *randomCode;
@property (weak) IBOutlet NSTextField *showTextfield;
- (IBAction)package:(NSButton *)sender;
- (IBAction)upload:(NSButton *)sender;


@end

