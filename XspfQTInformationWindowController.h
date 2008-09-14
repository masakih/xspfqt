//
//  XspfQTInformationWindowController.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/09/14.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface XspfQTInformationWindowController : NSWindowController
{
	IBOutlet NSObjectController *docController;
	IBOutlet NSObjectController *currentTrackController;
	NSMutableArray *observedDocs;
}

+ (XspfQTInformationWindowController *)sharedInstance;

@end
