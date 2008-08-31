//
//  XspfTrackList.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XspfComponent.h"


@interface XspfTrackList : XspfComponent
{
	NSString *title;
	NSMutableArray *tracks;
	
	unsigned currentIndex;
	
}

- (void)setCurrentIndex:(unsigned)index;
- (unsigned)currentIndex;
- (XspfComponent *)currentTrack;
- (void)next;
- (void)previous;

@end
