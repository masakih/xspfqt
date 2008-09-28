//
//  XspfQTPlaylist.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/09/28.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XspfQTComponent.h"


@interface XspfQTPlaylist : XspfQTComponent
{
	NSMutableArray *trackLists;
	
	unsigned selectionIndex;
	
	XspfQTComponent *selectedComponent;
}

@end
