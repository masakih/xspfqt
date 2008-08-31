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
	BOOL fullscreenMode;
	
	QTMovie *qtMovie;
	NSTimer *updateTime;
}

- (IBAction)toggleFullScreenMode:(id)sender;

- (void)play;

- (void)setQtMovie:(QTMovie *)qt;
- (QTMovie *)qtMovie;
@end
