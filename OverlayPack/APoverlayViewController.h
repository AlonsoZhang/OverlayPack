//
//  APoverlayViewController.h
//  OverlayPack
//
//  Created by Alonso on 2017/4/26.
//  Copyright © 2017年 Alonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UploadFile.h"

@interface APoverlayViewController : NSViewController{
    NSString *version;
    NSString *stationname;
    NSString *releasenote;
    NSMutableDictionary *sendmailDic;
}
@property (weak) IBOutlet NSTextField *productName;
@property (weak) IBOutlet NSTextField *stationName;
@property (unsafe_unretained) IBOutlet NSTextView *releaseNote;
- (IBAction)uploadandsend:(NSButton *)sender;
@property (weak) IBOutlet NSButton *send;
- (IBAction)close:(NSButton *)sender;
@end
