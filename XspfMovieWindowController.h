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
	IBOutlet NSButton *playButton;
	
	NSWindow *fullscreenWindow;
	NSRect nomalModeSavedFrame;
	BOOL fullScreenMode;
	
	QTMovie *qtMovie;
	NSTimer *updateTime;
	
	NSPoint prevMouse;
	NSDate *prevMouseMovedDate;
	
	NSSize windowSizeWithoutQTView;
}

- (IBAction)togglePlayAndPause:(id)sender;
- (IBAction)toggleFullScreenMode:(id)sender;
- (IBAction)forwardTagValueSecends:(id)sender;
- (IBAction)backwardTagValueSecends:(id)sender;
- (IBAction)nextTrack:(id)sender;
- (IBAction)previousTrack:(id)sender;

- (void)play;
- (void)stop;

- (void)setQtMovie:(QTMovie *)qt;
- (QTMovie *)qtMovie;
@end
