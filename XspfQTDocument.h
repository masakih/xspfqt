//
//  XspfQTDocument.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright masakih 2008 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@class HMXSPFComponent;
@class XspfQTMovieWindowController;

@class XspfQTMovieLoader;
@class QTMovie;

@interface XspfQTDocument : NSDocument
{
	HMXSPFComponent* playlist;
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

- (HMXSPFComponent *)trackList;

- (void)insertComponent:(HMXSPFComponent *)item atIndex:(NSUInteger)index;
- (void)removeComponent:(HMXSPFComponent *)item;
- (void)moveComponent:(HMXSPFComponent *)item toIndex:(NSUInteger)index;

// throw self, if can not insert.
- (void)insertComponentFromURL:(NSURL *)url atIndex:(NSUInteger)index;

@end

extern NSString *XspfQTDocumentWillCloseNotification;
