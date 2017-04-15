//
//  CompareViewController.h
//  OverlayPack
//
//  Created by Alonso on 2017/4/10.
//  Copyright © 2017年 Alonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CompareViewController : NSViewController<NSTableViewDelegate, NSTableViewDataSource>{
    NSArray *compareArray;
}

@property (weak) IBOutlet NSTableView *comparetableview;

@end
