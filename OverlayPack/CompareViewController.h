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

@property (nonatomic, strong) NSArray *numbers;
@property (nonatomic, strong) NSArray *numberCodes;

@property (weak) IBOutlet NSTableView *comparetableview;

@end
