//
//  ViewController.h
//  OverlayPack
//
//  Created by Alonso on 17/3/23.
//  Copyright © 2017年 Alonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewDropper.h"

@interface ViewController : NSViewController<DoSomethingDelegate>{
    NSMutableArray *StationArray;
    BOOL checked;
}

@end

