//
//  XspfQTPlayListWindowController.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XspfQTPlayListWindowController : NSWindowController
{
	IBOutlet NSOutlineView *listView;
	IBOutlet NSTreeController *trackListTree;
	
	id observedObject;
}

- (IBAction)showInFinder:(id)sender;
- (IBAction)showInformationInFinder:(id)sender;

@end


@interface XspfQTPlaylistOutlineView : NSOutlineView
@end
