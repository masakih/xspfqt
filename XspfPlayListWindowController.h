//
//  XspfPlayListWindowController.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XspfPlayListWindowController : NSWindowController
{
	IBOutlet NSOutlineView *listView;
	IBOutlet NSTreeController *trackListTree;
}

@end


@interface XspfThowSpacebarKeyDownOutlineView : NSOutlineView
@end
