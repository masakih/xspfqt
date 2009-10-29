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

- (IBAction)openInFinder:(id)sender;
- (IBAction)openInformationInFinder:(id)sender;

@end


@interface XspfQTPlaylistOutlineView : NSOutlineView
@end
