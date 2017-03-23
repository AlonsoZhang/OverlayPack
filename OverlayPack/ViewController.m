//
//  ViewController.m
//  OverlayPack
//
//  Created by Alonso on 17/3/23.
//  Copyright © 2017年 Alonso. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    StationArray = [[NSMutableArray alloc] init];
    NSMutableDictionary * AE_1 = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"0",@"AE_1", nil] forKeys:[NSArray arrayWithObjects:@"check",@"title",nil]];
    NSMutableDictionary * AE_2 = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"0",@"AE_2", nil] forKeys:[NSArray arrayWithObjects:@"check",@"title",nil]];
    [StationArray addObject:AE_1];
    [StationArray addObject:AE_2];
    ViewDropper *vd = [[ViewDropper alloc]init];
    vd.delegate = self;
//    for(int i=0;i<10;i++){
//        [StationArray addObject:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1",[NSString stringWithFormat:@"title %d",i],nil]forKeys:[NSArray arrayWithObjects:@"check",@"title",nil]]];
//    }
}

-(void)doSomething:(NSArray *)files {
    NSLog(@"do something called");
    for (id file in files) {
        NSLog(@" the file is : %@",file);
        
//        File *f = [[File alloc] init];
//        [f createFromFilePathString:file];
//        
//        [fileListArray addObject:f];
//        [fileListView reloadData];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark NSTableView Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
    NSInteger i=[[aNotification object] selectedRow];
    if (i<0 || i>=[StationArray count]) {
        return;
    }
}

#pragma mark NSTableViewDataSource Delegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if(StationArray==nil){
        return 0;
    }
    else{
        return [StationArray count];
    }
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [[StationArray objectAtIndex:row] objectForKey:[tableColumn identifier]];
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(nullable id)object forTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    if([[tableColumn identifier] isEqualToString:@"check"]){
        if ([[StationArray[row] objectForKey:@"check"]isEqualToString:@"1"]) {
            [StationArray[row] setObject:@"0" forKey:@"check"];
        }else{
            [StationArray[row] setObject:@"1" forKey:@"check"];
        }
        [tableView reloadData];
    }
}


#pragma mark NSApplication Delegate Methods

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    return NO;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification {
}

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {
}

//Same as applicationDidFinishLaunching, called when we are asked to reopen (that is, we are already running)
- (BOOL) applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag {
    return NO;
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return NO;
}

- (void) applicationWillTerminate:(NSNotification *)notification {
}

@end
