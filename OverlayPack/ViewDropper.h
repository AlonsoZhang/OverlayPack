//
//  ViewDropper.h
//  OverlayPack
//
//  Created by Alonso on 17/3/23.
//  Copyright © 2017年 Alonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DoSomethingDelegate
-(void)doSomething:(NSArray *)files;
@end

@interface ViewDropper : NSView
@property (nonatomic, weak) id<DoSomethingDelegate> delegate;
@end
