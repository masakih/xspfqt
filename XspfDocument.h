//
//  MyDocument.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright masakih 2008 . All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>

@class XspfTrackList;
@class XspfMovieWindowController;

@interface XspfDocument : NSDocument
{
	XspfTrackList* trackList;
	XspfMovieWindowController *movieWindowController;
	NSWindowController *playListWindowController;
}

- (IBAction)showPlayList:(id)sender;

- (void)setTrackList:(XspfTrackList *)newList;
- (XspfTrackList *)trackList;

- (void)setPlayTrackindex:(unsigned)index;

@end
