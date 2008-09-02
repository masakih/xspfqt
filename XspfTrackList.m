//
//  XspfTrackList.m
//  XspfQT
//
//  Created by Hori,Masaki on 08/08/29.
//  Copyright 2008 masakih. All rights reserved.
//

#import "XspfTrackList.h"
#import "XspfTrack.h"


@implementation XspfTrackList
- (id)initWithXMLElement:(NSXMLElement *)element
{
	self = [super init];
	
	NSArray *elems = [element elementsForName:@"track"];
	if(!elems) {
		[self release];
		return nil;
	}
	
	tracks = [[NSMutableArray alloc] init];
	
	unsigned i, count;
	for(i = 0, count = [elems count]; i < count; i++) {
		NSXMLElement *trackElem = [elems objectAtIndex:i];
		XspfTrack *track = [XspfTrack xspfComponemtWithXMLElement:trackElem];
		if(track) {
			[tracks addObject:track];
		}
	}
	[self setCurrentIndex:0];
	
	return self;
}
- (void)dealloc
{
	[tracks release];
	[title release];
	
	[super dealloc];
}
- (void)setCurrentIndex:(unsigned)index
{
	unsigned prev;
	
	if(index < 0) return;
	if([tracks count] <= index) return;
	
	[self willChangeValueForKey:@"qtMovie"];
	prev = currentIndex;
	currentIndex = index;
	[self didChangeValueForKey:@"qtMovie"];
	
	@try {
		XspfTrack *t = [tracks objectAtIndex:prev];
		[t purgeQTMovie];
		[t willChangeValueForKey:@"isSelected"];
		[t deselect];
		[t didChangeValueForKey:@"isSelected"];
		
		XspfComponent *t2 = [self currentTrack];
		[t2 willChangeValueForKey:@"isSelected"];
		[t2 select];
		[t2 didChangeValueForKey:@"isSelected"];
	}
	@catch (id ex) {
		if(![[ex name] isEqualTo:NSRangeException]) {
			@throw;
		}
	}
}
- (unsigned)currentIndex
{
	return currentIndex;
}
- (NSArray *)children
{
	return tracks;
}

- (void)next
{
	[self setCurrentIndex:[self currentIndex] + 1];
}
- (void)previous
{
	[self setCurrentIndex:[self currentIndex] - 1];
}
- (NSString *)description
{
	return [tracks description];
}

- (XspfComponent *)currentTrack
{
	if([tracks count] > currentIndex) {
		return [tracks objectAtIndex:currentIndex];
	}
	return nil;
}

- (QTMovie *)qtMovie
{
	return [[self currentTrack] qtMovie];
}

- (void)setTitle:(NSString *)t
{
	if(title == t) return;
	[title autorelease];
	title = [t copy];
}
- (NSString *)title
{
	return title;
}

@end
