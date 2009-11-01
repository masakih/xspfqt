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

@class XspfQTMovieLoader;
@class QTMovie;

@interface XspfQTDocument : NSDocument
{
	XspfQTComponent* playlist;
	XspfQTMovieWindowController *movieWindowController;
	NSWindowController *playListWindowController;
	
	QTMovie *playingMovie;
	XspfQTMovieLoader *loader;
	NSTimeInterval playingMovieDuration;
	
	BOOL didPreloading;
}

- (IBAction)togglePlayAndPause:(id)sender;
- (IBAction)showPlayList:(id)sender;

- (IBAction)setThumbnailFrame:(id)sender;
- (IBAction)removeThumbnail:(id)sender;

- (XspfQTComponent *)trackList;

- (void)insertComponent:(XspfQTComponent *)item atIndex:(NSUInteger)index;
- (void)removeComponent:(XspfQTComponent *)item;
- (void)moveComponent:(XspfQTComponent *)item toIndex:(NSUInteger)index;

// throw self, if can not insert.
- (void)insertComponentFromURL:(NSURL *)url atIndex:(NSUInteger)index;

@end

extern NSString *XspfQTDocumentWillCloseNotification;
