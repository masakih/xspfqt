//
//  MyDocument.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright masakih 2008 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@class XspfComponent;
@class XspfMovieWindowController;

@interface XspfDocument : NSDocument
{
	XspfComponent* trackList;
	XspfMovieWindowController *movieWindowController;
	NSWindowController *playListWindowController;
}

- (IBAction)togglePlayAndPause:(id)sender;
- (IBAction)showPlayList:(id)sender;
- (IBAction)dump:(id)sender;

- (void)setTrackList:(XspfComponent *)newList;
- (XspfComponent *)trackList;

- (void)setPlayTrackindex:(unsigned)index;

- (void)insertItem:(XspfComponent *)item atIndex:(NSInteger)index;
- (void)removeItem:(XspfComponent *)item;

@end
