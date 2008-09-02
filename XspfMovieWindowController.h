//
//  XspfMovieWindowController.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/31.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>


@interface XspfMovieWindowController : NSWindowController
{
	IBOutlet QTMovieView *qtView;
	
	NSWindow *fullscreenWindow;
	NSRect nomalModeSavedFrame;
	BOOL fullScreenMode;
	
	QTMovie *qtMovie;
	NSTimer *updateTime;
	
	NSPoint prevMouse;
	NSDate *prevMouseMovedDate;
}

- (IBAction)toggleFullScreenMode:(id)sender;
- (IBAction)forwardTagValueSecends:(id)sender;
- (IBAction)backwardTagValueSecends:(id)sender;

- (void)play;

- (void)setQtMovie:(QTMovie *)qt;
- (QTMovie *)qtMovie;
@end
