//
//  XspfQTDocument.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright masakih 2008 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@class XspfQTComponent;
@class XspfQTMovieWindowController;

@class QTMovie;

@interface XspfQTDocument : NSDocument
{
	XspfQTComponent* playlist;
	XspfQTMovieWindowController *movieWindowController;
	NSWindowController *playListWindowController;
	
	QTMovie *playingMovie;
}

- (IBAction)togglePlayAndPause:(id)sender;
- (IBAction)showPlayList:(id)sender;
- (IBAction)dump:(id)sender;

- (XspfQTComponent *)trackList;

- (void)setPlayingTrackIndex:(unsigned)index;

- (void)insertComponent:(XspfQTComponent *)item atIndex:(NSUInteger)index;
- (void)removeComponent:(XspfQTComponent *)item;

// throw self, if can not insert.
- (void)insertComponentFromURL:(NSURL *)url atIndex:(NSUInteger)index;

@end

extern NSString *XspfQTDocumentWillCloseNotification;
