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

@interface XspfQTDocument : NSDocument
{
	XspfQTComponent* trackList;
	XspfQTMovieWindowController *movieWindowController;
	NSWindowController *playListWindowController;
}

- (IBAction)togglePlayAndPause:(id)sender;
- (IBAction)showPlayList:(id)sender;
- (IBAction)dump:(id)sender;

- (void)setTrackList:(XspfQTComponent *)newList;
- (XspfQTComponent *)trackList;

- (void)setPlayTrackindex:(unsigned)index;

- (void)insertItem:(XspfQTComponent *)item atIndex:(NSUInteger)index;
- (void)removeItem:(XspfQTComponent *)item;

@end

extern NSString *XspfQTDocumentWillCloseNotification;
