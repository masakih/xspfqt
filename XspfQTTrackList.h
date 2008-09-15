//
//  XspfQTTrackList.h
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "XspfQTComponent.h"


@interface XspfQTTrackList : XspfQTComponent
{
	NSMutableArray *tracks;
	
	unsigned currentIndex;
}

- (void)setCurrentIndex:(unsigned)index;
- (unsigned)currentIndex;

@end
